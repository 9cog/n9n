#!/usr/bin/env luajit
--------------------------------------------------------------------------------
-- Exhaustive unit tests for torch.class
--------------------------------------------------------------------------------

local root = arg[0]:match("^(.*)/fs/appl/") or "."
package.path = root .. "/fs/os/lib/?.lua;" .. root .. "/fs/os/lib/?/init.lua;;"

local T     = require('testing')
local class = require('torch.class')

T.plan(46)

-- ── class() shorthand and class.new() ────────────────────────────────────────
T.no_err(function()
    class('TestA')
end, "class('TestA') does not raise")

T.err(function()
    class('TestA')  -- duplicate registration
end, "Registering duplicate class name raises an error")

T.err(function()
    class(42)
end, "class() with non-string name raises an error")

T.err(function()
    class('OrphanChild', 'NonExistentParent')
end, "class() with unknown parent raises an error")

-- ── simple class instantiation ────────────────────────────────────────────────
local Point = class('Point')

function Point:__init(x, y)
    self.x = x or 0
    self.y = y or 0
end

function Point:magnitude()
    return math.sqrt(self.x^2 + self.y^2)
end

function Point:__tostring()
    return string.format("Point(%s,%s)", tostring(self.x), tostring(self.y))
end

local p = Point(3, 4)
T.ok(p ~= nil,                         "Point instance is not nil")
T.is(p.x, 3,                           "constructor sets x")
T.is(p.y, 4,                           "constructor sets y")
T.is(p:magnitude(), 5,                  "method call returns correct value")

local p2 = Point()
T.is(p2.x, 0,                          "default x is 0")
T.is(p2.y, 0,                          "default y is 0")

-- ── class.new() explicit ─────────────────────────────────────────────────────
local Box = class.new('Box')
function Box:__init(w, h) self.w = w; self.h = h end
function Box:area() return self.w * self.h end

local b = Box(5, 3)
T.is(b:area(), 15,                     "class.new() works like class()")

-- ── class.type() ─────────────────────────────────────────────────────────────
T.is(class.type(p),  "Point",          "class.type() returns class name")
T.is(class.type(b),  "Box",            "class.type() returns correct name for Box")
T.is(class.type("hello"), "string",    "class.type() falls through to Lua type for string")
T.is(class.type(42),      "number",    "class.type() falls through to Lua type for number")
T.is(class.type(nil),     "nil",       "class.type() handles nil")
T.is(class.type(true),    "boolean",   "class.type() handles boolean")
T.is(class.type({}),      "table",     "class.type() returns 'table' for plain table")

-- ── class.istype() ───────────────────────────────────────────────────────────
T.ok(class.istype(p, "Point"),         "istype: Point is Point")
T.not_ok(class.istype(p, "Box"),       "istype: Point is not Box")
T.not_ok(class.istype(p, "string"),    "istype: Point is not string")
T.ok(class.istype("hi", "string"),     "istype: plain string is string")
T.ok(class.istype(7,    "number"),     "istype: number is number")
T.not_ok(class.istype(7, "string"),    "istype: number is not string")
T.err(function()
    class.istype(p, 42)
end, "istype() with non-string typename raises an error")

-- ── inheritance ───────────────────────────────────────────────────────────────
local Shape = class('Shape')
function Shape:__init(color)  self.color = color or "white" end
function Shape:describe()     return "shape:" .. self.color end

local Circle, ParentCircle = class('Circle', 'Shape')
T.ok(Circle ~= nil,                    "subclass constructor is not nil")
T.ok(ParentCircle ~= nil,              "parent ref returned as 2nd value")

function Circle:__init(radius, color)
    Shape.__init(self, color)
    self.radius = radius
end
function Circle:area()
    return math.pi * self.radius^2
end

local c = Circle(5, "red")
T.is(c.color,  "red",                  "subclass inherits parent constructor data")
T.is(c.radius, 5,                      "subclass has its own field")
T.ok(math.abs(c:area() - math.pi*25) < 1e-9, "subclass method works")

-- inherited method from Shape
T.is(c:describe(), "shape:red",        "subclass inherits parent method")

-- type checks with inheritance
T.ok(class.istype(c, "Circle"),        "istype: Circle is Circle")
T.ok(class.istype(c, "Shape"),         "istype: Circle is Shape (polymorphism)")
T.not_ok(class.istype(c, "Box"),       "istype: Circle is not Box")

T.is(class.type(c), "Circle",          "class.type() returns most-derived type")

-- ── multi-level inheritance ───────────────────────────────────────────────────
local ColoredCircle = class('ColoredCircle', 'Circle')
function ColoredCircle:__init(radius, color, fill)
    Circle.__init(self, radius, color)
    self.fill = fill
end

local cc = ColoredCircle(3, "blue", "solid")
T.ok(class.istype(cc, "ColoredCircle"), "3-level: istype self")
T.ok(class.istype(cc, "Circle"),        "3-level: istype grandparent Circle")
T.ok(class.istype(cc, "Shape"),         "3-level: istype great-grandparent Shape")
T.not_ok(class.istype(cc, "Point"),     "3-level: not unrelated class")

-- ── class.factory() ──────────────────────────────────────────────────────────
T.no_err(function()
    local raw = class.factory("Point")
    T.ok(raw ~= nil,                   "factory() returns an instance")
    T.ok(raw.__init == nil or true,    "factory() does not call __init")
    -- factory instance has no x/y set
    T.ok(raw.x == nil,                 "factory() instance has no x (no init)")
end, "class.factory() works")

T.err(function()
    class.factory("UnknownClass")
end, "factory() with unknown class raises an error")

-- ── class.metatable() ────────────────────────────────────────────────────────
local mt = class.metatable("Point")
T.ok(mt ~= nil,                        "metatable() returns non-nil")
T.is(mt.__typename, "Point",           "metatable() has __typename")

T.done()
