#!/usr/bin/env luajit
--------------------------------------------------------------------------------
-- Test torch libraries for Node9
--------------------------------------------------------------------------------

print("Testing torch libraries for Node9")
print("=" .. string.rep("=", 60))

-- Test 1: sys library
print("\n[Test 1] torch.sys library")
print("-" .. string.rep("-", 60))

local sys = require('torch.sys')

-- Test clock and timing
print("Testing timing functions:")
sys.tic()
local t1 = sys.clock()
sys.sleep(0.1)
local t2 = sys.clock()
print(string.format("  sys.clock(): %.6f seconds", t2 - t1))
local elapsed = sys.toc()
print(string.format("  sys.toc(): %.6f seconds", elapsed))

-- Test OS detection
print("\nTesting OS detection:")
print("  sys.uname(): " .. sys.uname())
print("  sys.OS: " .. sys.OS)

-- Test string split
print("\nTesting string split:")
local parts = sys.split("hello,world,test", ",")
print("  Split 'hello,world,test' by ',':")
for i, part in ipairs(parts) do
   print("    [" .. i .. "] = " .. part)
end

-- Test NaN detection
print("\nTesting NaN detection:")
print("  sys.isNaN(0/0): " .. tostring(sys.isNaN(0/0)))
print("  sys.isNaN(42): " .. tostring(sys.isNaN(42)))

-- Test colors
print("\nTesting colors:")
local c = sys.COLORS
print("  " .. c.red .. "Red text" .. c.none)
print("  " .. c.green .. "Green text" .. c.none)
print("  " .. c.blue .. "Blue text" .. c.none)

-- Test file path
print("\nTesting file path:")
local dir, file = sys.fpath()
print("  Current file: " .. tostring(file))
print("  Current dir: " .. tostring(dir))

-- Test 2: class library
print("\n[Test 2] torch.class library")
print("-" .. string.rep("-", 60))

local class = require('torch.class')

-- Define a simple class
local Animal = class('Animal')

function Animal:__init(name)
   self.name = name
end

function Animal:speak()
   print("  " .. self.name .. " makes a sound")
end

-- Define a derived class
local Dog = class('Dog', 'Animal')

function Dog:__init(name, breed)
   Animal.__init(self, name)
   self.breed = breed
end

function Dog:speak()
   print("  " .. self.name .. " (" .. self.breed .. ") barks: Woof!")
end

-- Test class creation
print("\nTesting class creation:")
local animal = Animal("Generic Animal")
animal:speak()

local dog = Dog("Buddy", "Golden Retriever")
dog:speak()

-- Test type checking
print("\nTesting type checking:")
print("  class.type(dog): " .. class.type(dog))
print("  class.istype(dog, 'Dog'): " .. tostring(class.istype(dog, 'Dog')))
print("  class.istype(dog, 'Animal'): " .. tostring(class.istype(dog, 'Animal')))
print("  class.istype(dog, 'string'): " .. tostring(class.istype(dog, 'string')))

-- Test 3: argcheck library
print("\n[Test 3] torch.argcheck library")
print("-" .. string.rep("-", 60))

local argcheck = require('torch.argcheck')

-- Simple function with argument checking
local check_add = argcheck{
   help = "Add two numbers",
   {name="a", type="number", help="first number"},
   {name="b", type="number", help="second number"}
}

local function add(...)
   local a, b = check_add(...)
   return a + b
end

print("\nTesting simple argument checking:")
print("  add(5, 3) = " .. add(5, 3))
print("  add{a=10, b=20} = " .. add{a=10, b=20})

-- Function with default arguments
local check_greet = argcheck{
   help = "Greet someone",
   {name="name", type="string", help="person's name"},
   {name="greeting", type="string", default="Hello", help="greeting word"}
}

local function greet(...)
   local name, greeting = check_greet(...)
   print("  " .. greeting .. ", " .. name .. "!")
end

print("\nTesting default arguments:")
greet("Alice")
greet("Bob", "Hi")
greet{name="Charlie", greeting="Howdy"}

-- Function with optional arguments
local check_config = argcheck{
   {name="host", type="string", default="localhost"},
   {name="port", type="number", default=8080},
   {name="debug", type="boolean", opt=true}
}

local function configure(...)
   local host, port, debug = check_config(...)
   print(string.format("  Config: %s:%d (debug=%s)", host, port, tostring(debug)))
end

print("\nTesting optional arguments:")
configure()
configure("example.com", 3000)
configure{host="test.org", port=9000, debug=true}

print("\n" .. string.rep("=", 60))
print("All tests completed successfully!")
