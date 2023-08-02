local M = {}

-- Layout-related exports
M.Window = require("glass.window")
M.Frame = require("glass.frame")

-- Miscellaneous / utility exports
M.Cache = require("glass.cache")

local anim = require("glass.animation")
M.Animate = anim.Animate
M.interpolate = anim.interpolate
M.easing = anim.easing

return M
