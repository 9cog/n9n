#!/usr/bin/env luajit
--------------------------------------------------------------------------------
-- Exhaustive unit tests for torch.argcheck
--------------------------------------------------------------------------------

local root = arg[0]:match("^(.*)/fs/appl/") or "."
package.path = root .. "/fs/os/lib/?.lua;" .. root .. "/fs/os/lib/?/init.lua;;"

local T        = require('testing')
local argcheck = require('torch.argcheck')

T.plan(43)

-- ── basic positional arguments ────────────────────────────────────────────────
local check_add = argcheck{
    help = "Add two numbers",
    {name="a", type="number", help="first number"},
    {name="b", type="number", help="second number"},
}

local function add(...)
    local a, b = check_add(...)
    return a + b
end

T.is(add(1, 2),       3,  "positional: integer addition")
T.is(add(0, 0),       0,  "positional: zero + zero")
T.is(add(-3, 3),      0,  "positional: negative + positive")
T.is(add(1.5, 2.5),   4,  "positional: float addition")

-- ── named (table) arguments ───────────────────────────────────────────────────
T.is(add{a=5, b=3},   8,  "named: {a=5,b=3}")
T.is(add{a=0, b=0},   0,  "named: zeros")
T.is(add{b=1, a=2},   3,  "named: out-of-order keys")

-- ── type errors ───────────────────────────────────────────────────────────────
T.err(function() add("x", 1)    end, "wrong type for first arg raises error")
T.err(function() add(1, "y")    end, "wrong type for second arg raises error")
T.err(function() add(nil, 1)    end, "nil for required arg raises error")
T.err(function() add()          end, "missing both args raises error")
T.err(function() add{a="bad",b=1} end, "named wrong type raises error")

-- ── default arguments ─────────────────────────────────────────────────────────
local check_greet = argcheck{
    {name="name",     type="string",  help="person's name"},
    {name="greeting", type="string",  default="Hello"},
}

local function greet(...)
    local name, g = check_greet(...)
    return g .. ", " .. name .. "!"
end

T.is(greet("Alice"),            "Hello, Alice!",   "default used when omitted")
T.is(greet("Bob", "Hi"),        "Hi, Bob!",        "explicit overrides default")
T.is(greet{name="C",greeting="Hey"}, "Hey, C!",    "named with explicit value")
T.is(greet{name="D"},           "Hello, D!",       "named with default fallback")

-- ── optional arguments ────────────────────────────────────────────────────────
local check_cfg = argcheck{
    {name="host",  type="string",  default="localhost"},
    {name="port",  type="number",  default=8080},
    {name="debug", type="boolean", opt=true},
}

local function configure(...)
    local h, p, d = check_cfg(...)
    return h, p, d
end

do
    local h, p, d = configure()
    T.is(h, "localhost", "default host")
    T.is(p, 8080,        "default port")
    T.is(d, nil,         "optional arg is nil when not provided (positional)")
end

do
    local h, p, d = configure("example.com", 9000)
    T.is(h, "example.com", "explicit host")
    T.is(p, 9000,          "explicit port")
    T.is(d, nil,           "optional arg nil when not provided (positional, 2-arg)")
end

do
    local h, p, d = configure{host="x.org", port=1234, debug=true}
    T.is(h, "x.org", "named host")
    T.is(p, 1234,    "named port")
    T.is(d, true,    "optional named arg set to true")
end

do
    local h, p, d = configure{debug=false}
    T.is(h, "localhost", "named host defaults")
    T.is(p, 8080,        "named port defaults")
    T.is(d, false,       "optional named arg set to false")
end

-- ── single-argument functions ─────────────────────────────────────────────────
local check_len = argcheck{
    {name="s", type="string"},
}
local function slen(...) local s = check_len(...) return #s end

T.is(slen("hello"),    5,  "single string arg positional")
T.is(slen{s="world"},  5,  "single string arg named")
T.err(function() slen(42)   end, "wrong type for single arg")
T.err(function() slen()     end, "missing single arg")

-- ── boolean argument ─────────────────────────────────────────────────────────
local check_flag = argcheck{
    {name="flag", type="boolean"},
}
local function check(...)
    local f = check_flag(...)
    return f
end
T.ok(check(true)  == true,   "boolean true positional")
T.ok(check(false) == false,  "boolean false positional")
T.ok(check{flag=true}  == true,  "boolean true named")
T.ok(check{flag=false} == false, "boolean false named")
T.err(function() check(1) end, "number is not boolean")

-- ── help field does not cause errors ─────────────────────────────────────────
T.no_err(function()
    local checker = argcheck{
        help = "A function with help text",
        {name="x", type="number", help="the x value"},
    }
    checker(1)
end, "help field in spec does not raise")

-- ── re-usable checker (called multiple times) ─────────────────────────────────
local check_mul = argcheck{
    {name="a", type="number"},
    {name="b", type="number"},
}
local function mul(...) local a,b = check_mul(...) return a*b end

T.is(mul(3,4),   12, "re-use checker call 1")
T.is(mul(2,5),   10, "re-use checker call 2")
T.is(mul{a=6,b=7}, 42, "re-use named call")

-- ── argcheck returns a callable ───────────────────────────────────────────────
T.is(type(check_add), "function",  "argcheck returns a function")
T.is(type(check_cfg), "function",  "argcheck with optionals returns a function")

T.done()
