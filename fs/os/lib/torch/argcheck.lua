--------------------------------------------------------------------------------
-- argcheck - Simplified argument checking for Node9
-- Adapted from torch/argcheck, provides basic argument validation
--------------------------------------------------------------------------------

local argcheck = {}

-- Helper to format argument error messages
local function format_args(rules, help)
   local lines = {}
   
   if help then
      table.insert(lines, help)
      table.insert(lines, "")
   end
   
   table.insert(lines, "arguments:")
   table.insert(lines, "{")
   
   for _, rule in ipairs(rules) do
      local line = "  "
      
      -- Optional marker
      if rule.opt or rule.default or rule.defaulta or rule.defaultf then
         line = line .. "["
      else
         line = line .. " "
      end
      
      -- Name and type
      line = line .. rule.name
      if rule.type then
         line = line .. " = " .. rule.type
      end
      
      -- Optional marker close
      if rule.opt or rule.default or rule.defaulta or rule.defaultf then
         line = line .. "]"
      else
         line = line .. " "
      end
      
      -- Help text
      if rule.help then
         line = line .. "  -- " .. rule.help
      end
      
      -- Default value
      if rule.default ~= nil then
         line = line .. string.format(" [default=%s]", tostring(rule.default))
      elseif rule.defaulta then
         line = line .. string.format(" [default=%s]", rule.defaulta)
      end
      
      table.insert(lines, line)
   end
   
   table.insert(lines, "}")
   return table.concat(lines, "\n")
end

-- Type checking helper
local function check_type(value, typename)
   if typename == "number" then
      return type(value) == "number"
   elseif typename == "string" then
      return type(value) == "string"
   elseif typename == "boolean" then
      return type(value) == "boolean"
   elseif typename == "table" then
      return type(value) == "table"
   elseif typename == "function" then
      return type(value) == "function"
   else
      -- For other types, just check basic type
      return type(value) == typename
   end
end

-- Create an argument checker function
function argcheck.new(spec)
   local rules = {}
   local help = spec.help or spec.doc
   local pack = spec.pack
   local nonamed = spec.nonamed
   
   -- Extract rules from spec
   for k, v in ipairs(spec) do
      if type(v) == "table" and v.name then
         table.insert(rules, v)
      end
   end
   
   -- Generate checker function
   return function(...)
      local args = {...}
      local nargs = select('#', ...)
      local results = {}
      local named_args = nil
      
      -- Check if first argument is a table (named arguments)
      if nargs == 1 and type(args[1]) == "table" and not nonamed then
         -- Might be named arguments
         local first = args[1]
         local looks_like_named = false
         
         for _, rule in ipairs(rules) do
            if first[rule.name] ~= nil then
               looks_like_named = true
               break
            end
         end
         
         if looks_like_named then
            named_args = first
         end
      end
      
      -- Process each rule
      for i, rule in ipairs(rules) do
         local value
         local found = false
         
         if named_args then
            -- Named argument mode
            value = named_args[rule.name]
            found = value ~= nil
         else
            -- Positional argument mode
            if i <= nargs then
               value = args[i]
               found = true
            end
         end
         
         -- Check if argument was provided
         if not found then
            -- Use default value
            if rule.default ~= nil then
               value = rule.default
            elseif rule.defaulta then
               -- Default to another argument
               value = results[rule.defaulta]
            elseif rule.defaultf then
               -- Default function
               value = rule.defaultf()
            elseif not rule.opt then
               -- Required argument missing
               error("invalid arguments\n\n" .. format_args(rules, help), 2)
            end
         else
            -- Check type if specified
            if rule.type and value ~= nil then
               if not check_type(value, rule.type) then
                  error("invalid arguments\n\n" .. format_args(rules, help), 2)
               end
            end
            
            -- Custom check function
            if rule.check and value ~= nil then
               if not rule.check(value) then
                  error("invalid arguments\n\n" .. format_args(rules, help), 2)
               end
            end
         end
         
         -- Store result
         results[rule.name] = value
         table.insert(results, value)
      end
      
      -- Return results
      if pack then
         return results
      else
         return unpack(results)
      end
   end
end

-- Allow argcheck() as shorthand for argcheck.new()
setmetatable(argcheck, {
   __call = function(self, spec)
      return self.new(spec)
   end
})

return argcheck
