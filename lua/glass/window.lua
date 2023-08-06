local api = vim.api
local object = require("glass.object")
local class, is_instance = object.class, object.is_instance
local Cache = require("glass.cache")
local Sized = require("glass.sized")
local Animate = require("glass.animation").Animate

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
---@field parent Glass.Frame
---@field timer uv_timer_t
---@field new fun(id: integer, parent: Glass.Frame): Glass.Window
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
local Window = class("Window", Sized, Animate)

function Window:__eq(other)
  if type(other) == "number" then return self.winid == other end
  if not is_instance(other, Window) then return false end
  return self.winid == other.winid
end

---@param id window
---@param parent Glass.Frame
function Window:init(id, parent)
  if not id then error("Window id must be provided") end
  if not api.nvim_win_is_valid(id) then
    error(("Window %s is not valid"):format(id))
  end
  self = win_cache:get_or_insert(id, function()
    self.winid = id
    self.parent = parent
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

return Window
