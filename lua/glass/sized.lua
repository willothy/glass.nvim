local object = require("glass.object")
local interface = object.interface

---@class Glass.Sized
---@field set_width fun(self: Sized, width: integer)
---@field set_height fun(self: Sized, height: integer)
---@field get_width fun(self: Sized): integer
---@field get_height fun(self: Sized): integer
---Interface implemented by windows and frames.
local Sized = interface("Sized", {
  "set_width",
  "set_height",
  "get_width",
  "get_height",
})

return Sized
