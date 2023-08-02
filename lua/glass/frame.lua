local class = require("glass.object").class
local Sized = require("glass.sized")
local Animate = require("glass.animation").Animate

---@class Glass.Frame
---@field children Glass.Sized[]
---@field type "row" | "col"
local Frame = class("Frame", Sized, Animate)

return Frame
