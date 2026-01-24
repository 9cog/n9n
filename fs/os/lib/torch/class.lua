--------------------------------------------------------------------------------
-- class - Object Classes for Lua (simplified version for Node9)
-- Adapted from torch/class for standalone use without argcheck dependency
--------------------------------------------------------------------------------

local class = {}
local classes = {}
local isofclass = {}

-- create a constructor table
local function constructortbl(metatable)
   local ct = {}
   setmetatable(ct, {
      __index = metatable,
      __newindex = metatable,
      __metatable = metatable,
      __call = function(self, ...)
         return self.new(...)
      end
   })
   return ct
end

-- Create a new class
-- Usage: class.new(name [, parentname])
-- Returns: constructor table [, parent class]
function class.new(name, parentname)
   assert(type(name) == "string", "class name must be a string")
   assert(not classes[name], string.format('class <%s> already exists', name))
   
   local newclass = {__typename = name}
   newclass.__index = newclass
   
   -- Factory function creates empty instances
   newclass.__factory = function()
      local self = {}
      setmetatable(self, newclass)
      return self
   end
   
   -- Default init does nothing
   newclass.__init = function()
   end
   
   -- Constructor calls factory and init
   newclass.new = function(...)
      local self = newclass.__factory()
      self:__init(...)
      return self
   end
   
   classes[name] = newclass
   isofclass[name] = {[name] = true}
   
   -- Handle inheritance
   if parentname then
      local parent = classes[parentname]
      assert(parent, string.format('parent class <%s> does not exist', parentname))
      setmetatable(newclass, parent)
      
      -- Mark as type of parent
      local p = parent
      while p do
         isofclass[p.__typename][name] = true
         p = getmetatable(p)
      end
      
      return constructortbl(newclass), classes[parentname]
   else
      return constructortbl(newclass)
   end
end

-- Return a new empty instance of the class (no __init called)
function class.factory(name)
   assert(type(name) == "string", "class name must be a string")
   assert(classes[name], string.format('unknown class <%s>', name))
   return classes[name].__factory()
end

-- Return the metatable of a class
function class.metatable(name)
   assert(type(name) == "string", "class name must be a string")
   return classes[name]
end

-- Return the type name of an object
function class.type(obj)
   local tname = type(obj)
   
   if tname == 'userdata' or tname == 'table' then
      local mt = getmetatable(obj)
      if mt then
         local typename = rawget(mt, '__typename')
         if typename then
            return typename
         end
      end
   end
   
   return tname
end

-- Check if obj is an instance of typename
function class.istype(obj, typename)
   assert(type(typename) == "string", "typename must be a string")
   
   local tname = type(obj)
   
   if tname == 'userdata' or tname == 'table' then
      local mt = getmetatable(obj)
      if mt then
         local objname = rawget(mt, '__typename')
         if objname then
            local valid = rawget(isofclass, typename)
            if valid then
               return rawget(valid, objname) or false
            else
               return objname == typename
            end
         end
      end
   end
   
   return tname == typename
end

-- Allow class() as shorthand for class.new()
setmetatable(class, {
   __call = function(self, ...)
      return self.new(...)
   end
})

return class
