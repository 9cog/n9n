#!/usr/bin/env luajit
--------------------------------------------------------------------------------
-- Unit tests for the environments module (fs/os/lib/environments.lua)
--------------------------------------------------------------------------------

local root = arg[0]:match("^(.*)/fs/appl/") or "."
package.path = root .. "/fs/os/lib/?.lua;" .. root .. "/fs/os/lib/?/init.lua;;"

local T    = require('testing')
local envs = require('environments')

T.plan(41)

-- ── Module loads ──────────────────────────────────────────────────────────────
T.ok(envs ~= nil,          "environments module loads")
T.is(type(envs), "table",  "environments module is a table")
T.ok(envs.safe ~= nil,     "environments.safe exists")

-- ── safe() ────────────────────────────────────────────────────────────────────
local s = envs.safe()
T.ok(s ~= nil,             "safe() returns a value")
T.is(type(s), "table",     "safe() returns a table")

-- core Lua globals that must be present
local required = {
    "ipairs", "pairs", "next", "error", "pcall", "xpcall",
    "type", "tostring", "tonumber", "assert", "setmetatable",
    "collectgarbage", "loadstring",
}
for _, k in ipairs(required) do
    T.ok(s[k] ~= nil, "safe env has '" .. k .. "'")
end

-- ── sub-tables present and populated ─────────────────────────────────────────
T.is(type(s.string),    "table", "safe env has string table")
T.is(type(s.table),     "table", "safe env has table table")
T.is(type(s.math),      "table", "safe env has math table")
T.is(type(s.os),        "table", "safe env has os table")
T.is(type(s.coroutine), "table", "safe env has coroutine table")
T.is(type(s.bit),       "table", "safe env has bit table")
T.is(type(s.ffi),       "table", "safe env has ffi table")

-- ── string sub-table spot-checks ──────────────────────────────────────────────
T.ok(s.string.format ~= nil,  "safe env string.format present")
T.ok(s.string.gmatch ~= nil,  "safe env string.gmatch present")
T.ok(s.string.gsub   ~= nil,  "safe env string.gsub present")

-- ── math sub-table spot-checks ───────────────────────────────────────────────
T.ok(s.math.abs   ~= nil,  "safe env math.abs present")
T.ok(s.math.floor ~= nil,  "safe env math.floor present")
T.ok(s.math.sqrt  ~= nil,  "safe env math.sqrt present")
T.ok(s.math.pi    ~= nil,  "safe env math.pi present")

-- ── os sub-table spot-checks ─────────────────────────────────────────────────
T.ok(s.os.clock ~= nil,  "safe env os.clock present")
T.ok(s.os.time  ~= nil,  "safe env os.time present")

-- ── dprint alias ─────────────────────────────────────────────────────────────
T.ok(s.dprint ~= nil,           "safe env has dprint alias")
T.is(s.dprint, print,           "dprint is aliased to global print")

-- ── isolation: dangerous globals are absent ──────────────────────────────────
T.ok(s.io      == nil,  "safe env does NOT expose io")
T.ok(s.require == nil,  "safe env does NOT expose require")
T.ok(s.dofile  == nil,  "safe env does NOT expose dofile")
T.ok(s.load    == nil,  "safe env does NOT expose load")

-- ── calling safe() twice returns independent tables ───────────────────────────
local s2 = envs.safe()
T.not_ok(s == s2,  "two safe() calls return distinct tables")

T.done()
