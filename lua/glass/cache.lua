local class = require("glass.object").class

local Cache = class("Cache")

function Cache:init()
  self.data = {}
end

function Cache:get_or_insert(key, fn)
  local value = self.data[key]
  if value == nil then
    value = fn()
    self.data[key] = value
  end
  return value
end

function Cache:invalidate(key)
  self.data[key] = nil
end

function Cache:clear()
  self.data = {}
end

function Cache:insert(key, value)
  self.data[key] = value
end

function Cache:has(key)
  return self.data[key] ~= nil
end

function Cache:get(key)
  return self.data[key]
end

return Cache
