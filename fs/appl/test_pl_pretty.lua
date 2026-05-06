#!/usr/bin/env luajit
--------------------------------------------------------------------------------
-- Unit tests for fs/os/lib/pl/pretty.lua
-- Also exercises the new is_deeply() and throws_ok() harness assertions.
--------------------------------------------------------------------------------

local root = arg[0]:match("^(.*)/fs/appl/") or "."
package.path = root .. "/fs/os/lib/?.lua;" .. root .. "/fs/os/lib/?/init.lua;;"

local T      = require('testing')
local pretty = require('pl.pretty')

T.plan(53)

-- ── Module loads ─────────────────────────────────────────────────────────────
T.ok(pretty ~= nil,                          "pl.pretty module loads")
T.is(type(pretty.write), "function",         "pretty.write is a function")
T.is(type(pretty.read),  "function",         "pretty.read is a function")
T.is(type(pretty.dump),  "function",         "pretty.dump is a function")

-- ── pretty.write: primitives ─────────────────────────────────────────────────
-- write() returns the serialised string plus a status flag; test the string.
local s, ok

s, ok = pretty.write(true)
T.is(s, "true",  "write(true) returns 'true'")
T.ok(ok ~= false, "write(true) is ok")

s, ok = pretty.write(false)
T.is(s, "false", "write(false) returns 'false'")

s, ok = pretty.write(42)
T.is(s, "42",    "write(42) returns '42'")

s, ok = pretty.write(3.14)
T.ok(s ~= nil,   "write(3.14) returns a string")
T.like(s, "3%.14","write(3.14) contains '3.14'")

s, ok = pretty.write("hello")
T.is(s, '"hello"', "write('hello') returns quoted string")

s, ok = pretty.write("say \"hi\"")
T.like(s, 'hi',   "write with embedded quote handled")

-- ── pretty.write: tables ─────────────────────────────────────────────────────
s = pretty.write({})
T.ok(s ~= nil,    "write({}) returns a string")
T.like(s, "{",    "write({}) contains opening brace")

s = pretty.write({1, 2, 3})
T.ok(s ~= nil,    "write({1,2,3}) returns a string")
T.like(s, "1",    "write array contains '1'")
T.like(s, "2",    "write array contains '2'")
T.like(s, "3",    "write array contains '3'")

s = pretty.write({name = "Alice", age = 30})
T.ok(s ~= nil,    "write object returns a string")
T.like(s, "Alice","write object contains 'Alice'")
T.like(s, "30",   "write object contains '30'")

-- ── pretty.write: nested tables ──────────────────────────────────────────────
local nested = { a = {1, 2, 3}, b = { x = "y" } }
s = pretty.write(nested)
T.ok(s ~= nil,    "write nested table returns a string")
T.like(s, "b",    "write nested table contains key 'b'")
T.like(s, '"y"',  "write nested table contains nested string value")

-- ── pretty.read ──────────────────────────────────────────────────────────────
local t = pretty.read("{1,2,3}")
T.ok(t ~= nil,          "read('{1,2,3}') returns a table")
T.is(type(t), "table",  "read returns a table type")
T.is(#t, 3,             "read array has length 3")
T.is(t[1], 1,           "read array[1] == 1")
T.is(t[2], 2,           "read array[2] == 2")
T.is(t[3], 3,           "read array[3] == 3")

local obj = pretty.read('{name="Bob", age=25}')
T.ok(obj ~= nil,         "read object returns table")
T.is(obj.name, "Bob",    "read object field 'name'")
T.is(obj.age,  25,       "read object field 'age'")

-- Nested read
local nested2 = pretty.read('{a={1,2},b="z"}')
T.ok(nested2 ~= nil,          "read nested table returns table")
T.is(type(nested2.a), "table","read nested: a is a table")
T.is(nested2.a[1], 1,         "read nested: a[1] == 1")
T.is(nested2.b, "z",          "read nested: b == 'z'")

-- ── pretty.read: bad input ───────────────────────────────────────────────────
local bad = pretty.read("not valid lua {{{{")
T.ok(bad == nil,  "read(invalid) returns nil")

-- ── round-trip: write → read ─────────────────────────────────────────────────
local original = { x = 10, y = 20, tags = {"a", "b", "c"} }
local serialised = pretty.write(original)
local restored   = pretty.read(serialised)
T.ok(restored ~= nil,            "round-trip: read after write succeeds")
T.is(restored.x, 10,             "round-trip: x preserved")
T.is(restored.y, 20,             "round-trip: y preserved")
T.is(type(restored.tags), "table","round-trip: tags is a table")
T.is(restored.tags[1], "a",      "round-trip: tags[1]")
T.is(restored.tags[3], "c",      "round-trip: tags[3]")

-- ── is_deeply: testing harness ───────────────────────────────────────────────
-- These tests exercise the new is_deeply() assertion added to testing.lua.
T.is_deeply({},       {},              "is_deeply: empty tables are equal")
T.is_deeply({1,2,3},  {1,2,3},        "is_deeply: equal arrays")
T.is_deeply({a=1},    {a=1},          "is_deeply: equal objects")
T.is_deeply({a={b=2}},{a={b=2}},      "is_deeply: nested equal")
T.is_deeply({x=1, y={2,3}}, {x=1, y={2,3}}, "is_deeply: mixed nested equal")

-- ── throws_ok: testing harness ───────────────────────────────────────────────
T.throws_ok(function() error("something bad happened") end,
    "bad", "throws_ok: error matches pattern")

T.throws_ok(function() error("json decode error") end,
    "decode", "throws_ok: partial match works")

T.throws_ok(function() error("type error: expected number") end,
    "number", "throws_ok: matches word in message")

T.throws_ok(function() error("UPPER and lower") end,
    "lower", "throws_ok: case-sensitive match")

T.done()
