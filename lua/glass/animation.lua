local iter = vim.iter
local class = require("glass.object").class

local M = {}

function M.easing.linear(progress)
  return progress
end

function M.easing.ease_in_quad(progress)
  return progress ^ 2
end

function M.easing.ease_out_quad(progress)
  return -(progress * (progress - 2))
end

function M.easing.ease_in_out_quad(progress)
  progress = progress * 2
  if progress < 1 then
    return 0.5 * progress ^ 2
  else
    return -0.5 * ((progress - 1) * (progress - 3) - 1)
  end
end

function M.interpolate(start, stop)
  return function(progress)
    return start + (stop - start) * progress
  end
end

---@class Glass.Animate
local Animate = class("Animate")

-- TODO:
-- * Groupable animations tied to a single timer but multiple Animate objects
-- * Decouple timer from T, trait-like constructs should not declare properties

---@generic T
---@param fn fun(self: T,...any)
---@param easing fun(progress: number): number
---@param generators (fun(progress: number): any)[] Passed to fn as varargs on each tick
---@param duration_ms integer
---@param fps integer
---@param interrupt boolean Whether to interrupt an already-running animation or cancel
---@param on_complete fun(self: T)?
---Animates arbitrary properties on an object using a given easing function.
---Requires a `self.timer` field to be set to a uv_timer_t on the object.
---If a timer does not exist, one will be created.
---
---# Usage
---
---This example shows animation of a Window object.
---
---```lua
---local cur = vim.api.nvim_get_current_win()
---local win = Window:new(cur)
---
---local anim = require("glass.animation")
---local easing, interpolate = anim.easing, anim.interpolate
---
---win:animate(
---  -- The function responsible for the actual animation.
---  -- Parameters `width` and `height` are passed from the generators.
---  function(self, width, height)
---    self:set_width(width)
---    self:set_height(height)
---  end,
---  -- the easing function used to process progress values
---  easing.ease_in_out_quad,
---  -- list of generator functions whose values should be passed to `fn`
---  {
---    interpolate(win.width, 180),
---    interpolate(win.height, 35),
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
function Animate:animate(
  fn,
  easing,
  generators,
  duration_ms,
  fps,
  interrupt,
  on_complete
)
  easing = easing or M.easing.linear
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
      if self.timer then self.timer:stop() end
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

function Animate:is_animating()
  return self.timer ~= nil and self.timer:is_active()
end

M.Animate = Animate

return M
