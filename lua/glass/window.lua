local api = vim.api
local iter = vim.iter
local class = require("glass.object").class
local Sized = require("glass.sized")
local Cache = require("glass.cache")

local win_cache = Cache:new()

---@class Glass.View
---@field col integer
---@field coladd integer
---@field curswant integer
---@field leftcol integer
---@field lnum integer
---@field skipcol integer
---@field topfill integer
---@field topline integer

---@class Glass.Window
---@field winid integer
---@field width integer
---@field height integer
---@field view Glass.View
---@field timer uv_timer_t
---
---# Usage
---
---```lua
---local id = vim.api.nvim_get_current_win()
---local win = Window:new(id)
---
---local width = win:get_width()
---win:set_width(width + 5)
---```
local Window = class("Window", Sized)

---@param id window
function Window:init(id)
  if not id then error("Window id must be provided") end
  if not api.nvim_win_is_valid(id) then
    error(("Window %s is not valid"):format(id))
  end
  self = win_cache:get_or_insert(id, function()
    self.winid = id
    self.timer = vim.loop.new_timer()
    return self
  end)
  self:refresh()
end

function Window:refresh()
  if not self:is_valid() then return end
  self:get_width()
  self:get_height()
  if not self:is_animating() then self:save_view() end
end

function Window:is_animating()
  return self.timer:is_active()
end

local Easing = {}

function Easing.linear(progress)
  return progress
end

function Easing.ease_in_quad(progress)
  return progress ^ 2
end

function Easing.ease_out_quad(progress)
  return -(progress * (progress - 2))
end

function Easing.ease_in_out_quad(progress)
  progress = progress * 2
  if progress < 1 then
    return 0.5 * progress ^ 2
  else
    return -0.5 * ((progress - 1) * (progress - 3) - 1)
  end
end

local Generators = {}

function Generators.from_to(start, stop)
  return function(progress)
    return start + (stop - start) * progress
  end
end

---@param fn fun(self: Glass.Window,...any)
---@param easing fun(progress: number): number
---@param generators (fun(progress: number): any)[] Passed to fn as varargs on each tick
---@param duration_ms integer
---@param fps integer
---@param interrupt boolean Whether to interrupt an already-running animation or cancel
---@param on_complete fun(self: Glass.Window)?
---Animates arbitrary properties on a window using a given easing function.
---
---# Usage
---
---```lua
---local cur = vim.api.nvim_get_current_win()
---local win = Window:new(cur)
---
---win:animate(
---  -- The function responsible for the actual animation.
---  -- Parameters `width` and `height` are passed from the generators.
---  function(self, width, height)
---    self:set_width(width)
---    self:set_height(height)
---  end,
---  -- the easing function used to process progress values
---  Easing.ease_in_out_quad,
---  -- list of generator functions whose values should be passed to `fn`
---  {
---    Generators.from_to(win.width, 180),
---    Generators.from_to(win.height, 35),
---  },
---  -- duration, in milliseconds
---  1000,
---  -- ticks (frames) per second
---  60,
---  -- whether to interrupt or cancel if already animating
---  true,
---  -- function to call on completion (receives self as argument)
---  Window.cleanup
---)
---```
function Window:animate(
  fn,
  easing,
  generators,
  duration_ms,
  fps,
  interrupt,
  on_complete
)
  easing = easing or Easing.linear
  duration_ms = duration_ms or 500
  fps = fps or 60
  interrupt = interrupt or false

  if not self:is_animating() then
    self:save_view()
  elseif not interrupt then
    return
  end

  local function gen(progress)
    return iter(generators):fold({}, function(values, f)
      table.insert(values, f(progress))
      return values
    end)
  end

  local start = vim.loop.hrtime()
  local tick = vim.schedule_wrap(function()
    if not self:is_valid() then return end
    local now = vim.loop.hrtime()
    local elapsed = now - start
    local progress = elapsed / duration_ms
    if progress >= 1 then
      self.timer:stop()
      fn(self, unpack(gen(1)))
      if not self:is_animating() then self:restore_view() end
      if on_complete then on_complete(self) end
    else
      fn(self, unpack(gen(easing(progress))))
    end
  end)

  local delta_time = 1000 / fps
  if not self.timer then self.timer = vim.loop.new_timer() end
  self.timer:start(0, delta_time, tick)
end

---@return integer width
function Window:get_width()
  local width = api.nvim_win_get_width(self.winid)
  self.width = width
  return width
end

---@return integer height
function Window:get_height()
  local height = api.nvim_win_get_height(self.winid)
  self.height = height
  return height
end

---@param height integer
function Window:set_width(width)
  api.nvim_win_set_width(self.winid, width)
  self.width = width
end

---@param height integer
function Window:set_height(height)
  api.nvim_win_set_height(self.winid, height)
  self.height = height
end

function Window:is_valid()
  local valid = api.nvim_win_is_valid(self.winid)
  -- perform window cleanup automatically if not valid
  if not valid then self:cleanup() end
  return valid
end

function Window:cleanup()
  if self.timer and not self.timer:is_closing() then
    self.timer:close(function()
      self.timer = nil
    end)
  end
end

function Window:close()
  api.nvim_win_close(self.winid, true)
  self:cleanup()
end

function Window:call(fn)
  api.nvim_win_call(self.winid, fn)
end

function Window:save_view()
  self.view = self:call(vim.fn.winsaveview)
  return self.view
end

function Window:restore_view()
  if self.view then
    self:call(function()
      vim.fn.winrestview(self.view)
    end)
  end
end

function Window:get_option(name)
  return vim.api.nvim_win_get_option(self.winid, name)
end

function Window:set_option(name, val)
  vim.api.nvim_win_set_option(self.winid, name, val)
end

return Window
