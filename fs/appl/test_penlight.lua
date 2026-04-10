#!/usr/bin/env luajit
--------------------------------------------------------------------------------
-- Unit tests for the Penlight library (standalone subset)
-- Covers: pl.List, pl.Set, pl.Map, pl.utils, pl.tablex, pl.stringx
--------------------------------------------------------------------------------

local root = arg[0]:match("^(.*)/fs/appl/") or "."
package.path = root .. "/fs/os/lib/?.lua;" .. root .. "/fs/os/lib/?/init.lua;;"

local T = require('testing')

T.plan(58)

-- ── pl.List ──────────────────────────────────────────────────────────────────
local List = require('pl.List')

-- Construction
local l = List{1, 2, 3}
T.ok(l ~= nil,                       "List() constructs a list")
T.is(#l, 3,                          "List length is 3")
T.is(l[1], 1,                        "List[1] is 1")

local empty = List()
T.is(#empty, 0,                      "empty List() has length 0")

-- append
l:append(4)
T.is(#l, 4,                          "append increases length")
T.is(l[4], 4,                        "append adds to end")

-- extend
l:extend{5, 6}
T.is(#l, 6,                          "extend increases length by 2")

-- pop
local last = l:pop()
T.is(last, 6,                        "pop() returns last element")
T.is(#l, 5,                          "pop() reduces length")

-- contains / find
T.ok(l:contains(3),                  "contains finds existing element")
T.not_ok(l:contains(99),             "contains returns false for missing")

-- index
T.is(l:index(3), 3,                  "index() returns 1-based position")

-- sort (copy)
local unsorted = List{3,1,4,1,5,9,2,6}
local sorted   = unsorted:sort()
T.is(sorted[1], 1,                   "sorted first element is smallest")
T.is(sorted[#sorted], 9,             "sorted last element is largest")

-- reverse
local rev = List{1,2,3}:reverse()
T.is(rev[1], 3,                      "reverse: first is last")
T.is(rev[3], 1,                      "reverse: last is first")

-- map
local doubled = List{1,2,3}:map(function(x) return x*2 end)
T.is(doubled[1], 2,                  "map: first element doubled")
T.is(doubled[3], 6,                  "map: third element doubled")

-- filter
local evens = List{1,2,3,4,5,6}:filter(function(x) return x%2 == 0 end)
T.is(#evens, 3,                      "filter: 3 evens in 1..6")
T.is(evens[1], 2,                    "filter: first even is 2")

-- join
T.is(List{"a","b","c"}:join(","), "a,b,c", "join with comma")
T.is(List{"x"}:join("|"),        "x",      "join single element")

-- ── pl.Set ───────────────────────────────────────────────────────────────────
local Set = require('pl.Set')

local s1 = Set{1,2,3,4}
local s2 = Set{3,4,5,6}

T.ok(s1[1],                          "Set membership: 1 in s1")
T.not_ok(s1[5],                      "Set membership: 5 not in s1")

-- union
local u = s1 + s2
T.ok(u[1] and u[5],                  "union contains elements from both")

-- intersection
local inter = s1 * s2
T.ok(inter[3] and inter[4],          "intersection contains common elements")
T.not_ok(inter[1],                   "intersection excludes non-common")

-- difference
local diff = s1 - s2
T.ok(diff[1] and diff[2],            "difference has elements only in s1")
T.not_ok(diff[3],                    "difference excludes shared elements")

-- issubset
local sub = Set{1,2}
T.ok(Set.issubset(sub, s1),          "subset: {1,2} ⊆ s1")
T.not_ok(Set.issubset(s2, s1),       "subset: s2 ⊄ s1")

-- ── pl.Map (OrderedMap uses same API) ────────────────────────────────────────
local Map = require('pl.Map')

local m = Map{a=1, b=2, c=3}
T.ok(m ~= nil,                       "Map() constructs")
T.is(m:get("a"), 1,                  "Map get existing key")
T.is(m:get("z"), nil,                "Map get missing key returns nil")

m:set("d", 4)
T.is(m:get("d"), 4,                  "Map set adds new key")

m:set("a", 10)
T.is(m:get("a"), 10,                 "Map set updates existing key")

T.ok(m:get("b") ~= nil,              "Map contains existing key: get() returns non-nil")
T.ok(m:get("x") == nil,              "Map does not contain missing key: get() returns nil")

-- ── pl.utils ─────────────────────────────────────────────────────────────────
local utils = require('pl.utils')

-- assert_arg
T.no_err(function()
    utils.assert_arg(1, "hello", 'string')
end, "assert_arg passes for correct type")

T.err(function()
    utils.assert_arg(1, 42, 'string')
end, "assert_arg fails for wrong type")

-- split
local parts = utils.split("one two three")
T.is(#parts, 3,                      "utils.split on whitespace")
T.is(parts[1], "one",                "split first token")
T.is(parts[3], "three",              "split third token")

-- ── pl.tablex ────────────────────────────────────────────────────────────────
local tablex = require('pl.tablex')

-- copy
local orig  = {1,2,3,x=4}
local cp    = tablex.copy(orig)
T.is(cp[1], 1,                       "tablex.copy: indexed element")
T.is(cp.x, 4,                        "tablex.copy: hash element")
T.not_ok(cp == orig,                 "tablex.copy is a new table")

-- size (counts all keys)
T.ok(tablex.size({a=1,b=2,c=3}) == 3, "tablex.size counts hash keys")
T.ok(tablex.size({}) == 0,            "tablex.size of empty table")

-- keys / values
local keys = tablex.keys({a=1, b=2})
table.sort(keys)
T.is(keys[1], "a",                   "tablex.keys returns key list")
T.is(keys[2], "b",                   "tablex.keys second key")

-- map
local doubled2 = tablex.map(function(x) return x*2 end, {1,2,3})
T.is(doubled2[1], 2,                 "tablex.map first")
T.is(doubled2[3], 6,                 "tablex.map third")

-- ── pl.stringx ───────────────────────────────────────────────────────────────
local stringx = require('pl.stringx')

T.is(stringx.strip("  hello  "), "hello",  "strip removes surrounding spaces")
T.is(stringx.strip("no space"),  "no space","strip leaves trimmed string alone")

T.ok(stringx.startswith("foobar", "foo"),   "startswith true")
T.not_ok(stringx.startswith("foobar","baz"),"startswith false")

T.ok(stringx.endswith("foobar", "bar"),     "endswith true")
T.not_ok(stringx.endswith("foobar", "baz"), "endswith false")

T.done()
