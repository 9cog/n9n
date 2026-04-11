#!/usr/bin/env luajit
--------------------------------------------------------------------------------
-- Exhaustive unit tests for torch.sys
--------------------------------------------------------------------------------

-- Allow running from the repository root or from fs/appl/
local root = arg[0]:match("^(.*)/fs/appl/") or "."
package.path = root .. "/fs/os/lib/?.lua;" .. root .. "/fs/os/lib/?/init.lua;;"

local T   = require('testing')
local sys = require('torch.sys')

T.plan(43)

-- ── tic / toc ────────────────────────────────────────────────────────────────
T.no_err(function() sys.tic() end,                       "tic() does not raise")
T.no_err(function() sys.toc() end,                       "toc() does not raise after tic()")

sys.tic()
local elapsed = sys.toc()
T.ok(type(elapsed) == "number",                          "toc() returns a number")
T.ok(elapsed >= 0,                                       "toc() value is non-negative")

sys.tic()
os.execute("sleep 0.05")  -- tiny sleep via OS
local e2 = sys.toc()
T.ok(e2 >= 0,                                            "toc() after sleep is non-negative")

T.ok(type(sys.toc(false)) == "number",                   "toc(false) returns number silently")

-- ── clock ────────────────────────────────────────────────────────────────────
local c1 = sys.clock()
T.ok(type(c1) == "number",                               "clock() returns a number")
T.ok(c1 >= 0,                                            "clock() is non-negative")

sys.sleep(0.05)
local c2 = sys.clock()
T.ok(c2 >= c1,                                           "clock() is monotonically non-decreasing")

-- ── sleep / usleep ───────────────────────────────────────────────────────────
local before = sys.clock()
sys.sleep(0.05)
local after  = sys.clock()
T.ok(after - before >= 0.04,                             "sleep(0.05) sleeps at least ~50 ms")

T.no_err(function() sys.sleep(0) end,                    "sleep(0) does not raise")

if sys.usleep then
    T.no_err(function() sys.usleep(1000) end,            "usleep(1000) does not raise")
else
    T.skip(1, "usleep not available")
end

-- ── uname / OS ───────────────────────────────────────────────────────────────
local uname = sys.uname()
T.ok(type(uname) == "string",                            "uname() returns a string")
T.ok(#uname > 0,                                         "uname() is non-empty")
T.like(uname, "^%a",                                     "uname() starts with a letter")

T.ok(type(sys.OS) == "string",                           "sys.OS is a string")
T.ok(#sys.OS > 0,                                        "sys.OS is non-empty")
T.is(sys.OS, uname,                                      "sys.OS equals uname()")

local valid_os = { linux=true, macos=true, bsd=true, windows=true, unknown=true }
T.ok(valid_os[sys.OS] ~= nil,                            "sys.OS is a recognised platform token")

-- ── split ────────────────────────────────────────────────────────────────────
local p1 = sys.split("a,b,c", ",")
T.is(type(p1), "table",                                  "split() returns a table")
T.is(#p1, 3,                                             "split() returns correct count")
T.is(p1[1], "a",                                         "split() part 1 correct")
T.is(p1[3], "c",                                         "split() part 3 correct")

local p2 = sys.split("hello", ",")
T.is(#p2, 1,                                             "split() on no separator gives 1 part")
T.is(p2[1], "hello",                                     "split() preserves value when no sep")

local p3 = sys.split("", ",")
T.ok(type(p3) == "table",                                "split('') returns a table")

local p4 = sys.split("x::y", ":")
T.ok(#p4 >= 2,                                           "split() with repeated sep works")

-- ── isNaN ─────────────────────────────────────────────────────────────────────
T.ok(sys.isNaN(0/0),                                     "isNaN(0/0) is true")
T.not_ok(sys.isNaN(0),                                   "isNaN(0) is false")
T.not_ok(sys.isNaN(42),                                  "isNaN(42) is false")
T.not_ok(sys.isNaN(-1),                                  "isNaN(-1) is false")
T.not_ok(sys.isNaN(math.huge),                           "isNaN(inf) is false")

-- ── COLORS ───────────────────────────────────────────────────────────────────
T.ok(type(sys.COLORS) == "table",                        "COLORS is a table")
local required_colors = {"red","green","blue","yellow","cyan","magenta","white","none"}
for _, name in ipairs(required_colors) do
    T.ok(type(sys.COLORS[name]) == "string",
         "COLORS." .. name .. " is a string")
end

-- ── fpath ────────────────────────────────────────────────────────────────────
local dir, file = sys.fpath()
T.ok(type(dir)  == "string" or dir  == nil,              "fpath() dir is string or nil")
T.ok(type(file) == "string" or file == nil,              "fpath() file is string or nil")

T.done()
