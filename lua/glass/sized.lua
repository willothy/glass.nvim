local object = require("glass.object")
local interface = object.interface

---@class Glass.Sized
---@type fun(self: Sized, width: integer)
---@type fun(self: Sized, height: integer)
---@type fun(self: Sized): integer
---@type fun(self: Sized): integer
---Interface implemented by windows and frames.
local Sized = interface("Sized", {
  "set_width",
  "set_height",
  "get_width",
  "get_height",
})

return Sized
