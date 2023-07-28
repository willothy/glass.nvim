local class = require("glass.object").class
local Sized = require("glass.sized")

---@class Glass.Frame
---@field children Glass.Sized[]
---@field type "row" | "col"
local Frame = class("Frame", Sized)
