local M = {}

function M.class(name, ...)
  local cls = {}
  cls.__name = name
  cls.__super = setmetatable({ ... }, {
    __index = function(supers, k)
      for _, super in ipairs(supers) do
        if super[k] then return super[k] end
      end
    end,
  })
  cls.__index = cls
  setmetatable(cls, { __index = cls.__super })

  function cls:new(...)
    local instance = setmetatable({}, self)
    if instance.init then instance:init(...) end
    return instance
  end
  return cls
end

function M.interface(name, methods)
  local self = {}
  self.__name = name
  self.__index = self
  for _, method in ipairs(methods) do
    self[method] = M.virtual(method)
  end
  return self
end

function M.virtual(name)
  return function(self)
    error(
      ("\n%s:%s not implemented for %s.\n%s:%s is a virtual method and must be implemented.\n"):format(
        self.__super.__name,
        name,
        self.__name,
        self.__name,
        name
      )
    )
  end
end

function M.is_instance(obj, cls)
  return getmetatable(obj) == cls
end

function M.inherits(obj, super)
  for _, sup in ipairs(obj.__super) do
    if sup == super then return true end
  end
  for _, sup in ipairs(obj.__super) do
    if M.inherits(sup, super) then return true end
  end
  return false
end

function M.classname(obj)
  return getmetatable(obj).__name
end

return M
