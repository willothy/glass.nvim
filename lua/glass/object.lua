local M = {}

function M.class(name, super)
  local cls = {}
  cls.__name = name
  cls.__super = super
  cls.__index = cls
  if super then setmetatable(cls, { __index = super }) end
  function cls:new(...)
    local instance = setmetatable({}, self)
    if instance.init then instance:init(...) end
    return instance
  end
  return cls
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

return M
