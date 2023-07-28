local object = require("glass.object")
local class, virtual = object.class, object.virtual

---@class Glass.Sized
---Interface implemented by windows and frames.
local Sized = class("Sized")

---@type fun(self: Sized, width: integer)
Sized.set_width = virtual("set_width")
---@type fun(self: Sized, height: integer)
Sized.set_height = virtual("set_height")

---@type fun(self: Sized): integer
Sized.get_width = virtual("get_width")
---@type fun(self: Sized): integer
Sized.get_height = virtual("get_height")

return Sized
