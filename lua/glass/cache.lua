local class = require("glass.object").class

---@generic K, V
---@class Glass.Cache<K, V>
local Cache = class("Cache")

function Cache:init()
  self.data = {}
end

---@generic K, V
---@param key K
---@param fn fun(): V
function Cache:get_or_insert(key, fn)
  local value = self.data[key]
  if value == nil then
    value = fn()
    self.data[key] = value
  end
  return value
end

---@generic K, V
---@param key K
function Cache:invalidate(key)
  self.data[key] = nil
end

function Cache:clear()
  self.data = {}
end

---@generic K, V
---@param key K
---@param value V
function Cache:insert(key, value)
  self.data[key] = value
end

---@generic K, V
---@param key K
---@return boolean
function Cache:has(key)
  return self.data[key] ~= nil
end

---@generic K, V
---@param key K
---@return V | nil
function Cache:get(key)
  return self.data[key]
end

return Cache
