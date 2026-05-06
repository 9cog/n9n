#!/usr/bin/env luajit
--------------------------------------------------------------------------------
-- Unit tests for fs/os/lib/json.lua
--------------------------------------------------------------------------------

local root = arg[0]:match("^(.*)/fs/appl/") or "."
package.path = root .. "/fs/os/lib/?.lua;" .. root .. "/fs/os/lib/?/init.lua;;"

local T    = require('testing')
local json = require('json')

T.plan(81)

-- ── Module loads ──────────────────────────────────────────────────────────────
T.ok(json ~= nil,                      "json module loads")
T.is(type(json.encode),       "function", "json.encode is a function")
T.is(type(json.decode),       "function", "json.decode is a function")
T.is(type(json.encode_pretty),"function", "json.encode_pretty is a function")
T.is(type(json.try_decode),   "function", "json.try_decode is a function")
T.is(type(json.is_valid),     "function", "json.is_valid is a function")

-- ── encode: primitives ────────────────────────────────────────────────────────
T.is(json.encode(nil),     "null",  "encode nil → null")
T.is(json.encode(true),    "true",  "encode true")
T.is(json.encode(false),   "false", "encode false")
T.is(json.encode(0),       "0",     "encode 0")
T.is(json.encode(42),      "42",    "encode integer")
T.is(json.encode(-7),      "-7",    "encode negative integer")
T.is(json.encode(3.14),    "3.14",  "encode float 3.14 round-trips")
T.is(json.encode("hello"), '"hello"', "encode plain string")

-- ── encode: string escaping ───────────────────────────────────────────────────
T.is(json.encode('say "hi"'), '"say \\"hi\\""',  "encode: double-quote escaped")
T.is(json.encode("a\\b"),     '"a\\\\b"',         "encode: backslash escaped")
T.is(json.encode("line\n"),   '"line\\n"',         "encode: newline escaped")
T.is(json.encode("tab\t"),    '"tab\\t"',           "encode: tab escaped")
T.is(json.encode("\r"),       '"\\r"',              "encode: CR escaped")
T.is(json.encode("\b"),       '"\\b"',              "encode: backspace escaped")
T.is(json.encode("\f"),       '"\\f"',              "encode: form-feed escaped")

-- ── encode: arrays ────────────────────────────────────────────────────────────
T.is(json.encode({}),       "[]", "encode empty table → [] (empty array)")
T.is(json.encode({1,2,3}),  "[1,2,3]", "encode simple array")
T.is(json.encode({"a","b"}), '["a","b"]', "encode string array")
T.is(json.encode({true,false,false,1}), '[true,false,false,1]',
     "encode boolean/number array")

-- ── encode: objects ───────────────────────────────────────────────────────────
local obj = json.encode({x=1})
T.ok(obj == '{"x":1}', "encode simple object")

local obj2 = json.decode(json.encode({name="Bob", age=30}))
T.is(obj2.name, "Bob", "encode/decode object round-trip name")
T.is(obj2.age,  30,    "encode/decode object round-trip age")

-- ── encode: nested ────────────────────────────────────────────────────────────
local nested = {a = {1,2,{b=true}}}
local rt = json.decode(json.encode(nested))
T.is(rt.a[1],   1,    "nested: rt.a[1]")
T.is(rt.a[2],   2,    "nested: rt.a[2]")
T.is(rt.a[3].b, true, "nested: rt.a[3].b")

-- ── encode: error cases ───────────────────────────────────────────────────────
T.err(function() json.encode(0/0)          end, "encode NaN raises error")
T.err(function() json.encode(math.huge)    end, "encode +Inf raises error")
T.err(function() json.encode(-math.huge)   end, "encode -Inf raises error")
T.err(function() json.encode(coroutine.create(function() end)) end,
      "encode coroutine raises error")

-- Circular reference
local circ = {}
circ.self = circ
T.err(function() json.encode(circ) end, "encode circular ref raises error")

-- Non-string object key
T.err(function()
    -- table with a numeric key mixed with a string key → not a pure array
    local t = {}; t["x"] = 1; t[99] = 2
    json.encode(t)
end, "encode object with non-string key raises error")

-- ── decode: null / booleans ───────────────────────────────────────────────────
T.is(json.decode("null"),  nil,   "decode null → nil")
T.is(json.decode("true"),  true,  "decode true")
T.is(json.decode("false"), false, "decode false")

-- ── decode: numbers ───────────────────────────────────────────────────────────
T.is(json.decode("0"),    0,    "decode 0")
T.is(json.decode("42"),   42,   "decode integer 42")
T.is(json.decode("-7"),   -7,   "decode negative integer")
T.is(json.decode("3.14"), 3.14, "decode float 3.14")
T.is(json.decode("1e2"),  100,  "decode scientific 1e2")
T.is(json.decode("1.5e1"), 15,  "decode 1.5e1")

-- ── decode: strings ───────────────────────────────────────────────────────────
T.is(json.decode('"hello"'),  "hello",  "decode plain string")
T.is(json.decode('"say \\"hi\\""'), 'say "hi"', "decode escaped double-quote")
T.is(json.decode('"a\\\\b"'), "a\\b",   "decode escaped backslash")
T.is(json.decode('"line\\n"'), "line\n", "decode \\n")
T.is(json.decode('"\\t"'),    "\t",     "decode \\t")
T.is(json.decode('"\\u0041"'), "A",     "decode \\u0041 (A)")
T.is(json.decode('"\\u00e9"'), "\xC3\xA9", "decode \\u00e9 (é UTF-8)")

-- ── decode: arrays ────────────────────────────────────────────────────────────
local arr = json.decode("[1,2,3]")
T.is(type(arr),  "table", "decode array is table")
T.is(#arr,       3,       "decode array length")
T.is(arr[1],     1,       "decode array[1]")
T.is(arr[3],     3,       "decode array[3]")

local empty_arr = json.decode("[]")
T.is(#empty_arr, 0, "decode empty array")

-- ── decode: objects ───────────────────────────────────────────────────────────
local dobj = json.decode('{"a":1,"b":"two"}')
T.is(dobj.a, 1,     "decode object field a")
T.is(dobj.b, "two", "decode object field b")

local empty_obj = json.decode("{}")
T.is(type(empty_obj), "table", "decode empty object is table")

-- ── decode: whitespace tolerance ─────────────────────────────────────────────
T.is(json.decode("  42  "), 42, "decode tolerates surrounding whitespace")
local ws_arr = json.decode(" [ 1 , 2 ] ")
T.ok(type(ws_arr) == "table" and ws_arr[1] == 1,
     "decode tolerates whitespace in array")

-- ── decode: error cases ───────────────────────────────────────────────────────
T.err(function() json.decode("{bad}")    end, "decode invalid object raises")
T.err(function() json.decode("[1,2,")   end, "decode truncated array raises")
T.err(function() json.decode('"unterminated') end, "decode open string raises")
T.err(function() json.decode('42 extra') end, "decode trailing garbage raises")
T.err(function() json.decode(42)        end, "decode non-string raises")

-- ── try_decode ────────────────────────────────────────────────────────────────
local val, err = json.try_decode('{"ok":true}')
T.ok(val ~= nil,  "try_decode success: val non-nil")
T.ok(err == nil,  "try_decode success: err nil")
T.is(val.ok, true, "try_decode success: value correct")

local val2, err2 = json.try_decode("{bad}")
T.ok(val2 == nil,    "try_decode failure: val nil")
T.ok(err2 ~= nil,    "try_decode failure: err non-nil")
T.is(type(err2), "string", "try_decode failure: err is string")

-- ── is_valid ──────────────────────────────────────────────────────────────────
T.ok(json.is_valid('{"x":1}'),  "is_valid true for valid JSON")
T.ok(json.is_valid('[1,2,3]'),  "is_valid true for array")
T.ok(not json.is_valid('{bad}'), "is_valid false for invalid JSON")
T.ok(not json.is_valid(''),      "is_valid false for empty string")

-- ── encode_pretty round-trip ─────────────────────────────────────────────────
local pretty = json.encode_pretty({name="Alice", scores={10,20,30}})
T.ok(type(pretty) == "string", "encode_pretty returns string")
local rt2 = json.decode(pretty)
T.is(rt2.name,     "Alice", "encode_pretty round-trip: name")
T.is(rt2.scores[2], 20,     "encode_pretty round-trip: scores[2]")

T.done()
