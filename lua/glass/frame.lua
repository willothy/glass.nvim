local object = require("glass.object")
local class = object.class
local Sized = require("glass.sized")
local Animate = require("glass.animation").Animate
local Window = require("glass.window")

---@param child Glass.Frame | Glass.Window | window
---@return Glass.Window | Glass.Frame
local function init_child(child, frame)
  if type(child) == "number" then return Window:new(child, frame) end
  if child[1] == "leaf" then return Window:new(child[2], frame) end
  return child
end

---@class Glass.Frame
---@field children Glass.Sized[]
---@field type "row" | "col"
---@field new fun(type: "row" | "col", children: Glass.Sized[]): Glass.Frame
local Frame = class("Frame", Sized, Animate)

function Frame:init(type, children)
  if type == "leaf" then error("Cannot create a frame with type 'leaf'") end
  self.type = type
  for _, child in ipairs(children) do
    self:add_child(child)
  end
end

---@param child Glass.Window | Glass.Frame | window
function Frame:add_child(child)
  child = init_child(child, self)
  if not self.children then self.children = {} end
  table.insert(self.children, child)
end

function Frame:add_child_at(child, index)
  child = init_child(child, self)
  if not self.children then self.children = {} end
  table.insert(self.children, index, child)
end

function Frame:remove_child_at(child, index)
  child = init_child(child, self)
  if not self.children then return end
  table.remove(self.children, index)
end

function Frame:remove_child(child)
  child = init_child(child, self)
  if not self.children then return end
  for i, c in ipairs(self.children) do
    if c == child then
      table.remove(self.children, i)
      return
    end
  end
end

return Frame
