--------------------------------------------------------------------------------
-- testing.lua — minimal TAP-compatible test harness for Node9
-- Usage:
--   local T = require('testing')
--   T.plan(N)                    -- optional: declare expected test count
--   T.ok(cond, desc)             -- basic assertion
--   T.is(got, exp, d)            -- equality assertion
--   T.not_ok(c, d)               -- negative assertion
--   T.err(fn, d)                 -- expect an error
--   T.no_err(fn, d)              -- expect no error
--   T.is_deeply(got, exp, d)     -- deep (recursive) table equality
--   T.throws_ok(fn, pat, d)      -- expect error message matching Lua pattern
--   T.done()                     -- print summary; os.exit(1) on failure
--------------------------------------------------------------------------------

local M = {}

local _plan   = nil
local _run    = 0
local _pass   = 0
local _fail   = 0
local _skip   = 0

local function _tap(ok, desc, diag)
    _run = _run + 1
    local status = ok and "ok" or "not ok"
    if ok then _pass = _pass + 1 else _fail = _fail + 1 end
    io.write(string.format("%s %d - %s\n", status, _run, desc or ""))
    if not ok and diag then
        io.write(string.format("# %s\n", diag))
    end
    return ok
end

function M.plan(n)
    _plan = n
    io.write(string.format("1..%d\n", n))
end

function M.ok(cond, desc)
    return _tap(cond and true or false, desc)
end

function M.not_ok(cond, desc)
    return _tap(not cond, desc)
end

function M.is(got, expected, desc)
    local ok = (got == expected)
    local diag
    if not ok then
        diag = string.format("got: %s  expected: %s",
            tostring(got), tostring(expected))
    end
    return _tap(ok, desc, diag)
end

function M.not_is(got, expected, desc)
    local ok = (got ~= expected)
    local diag
    if not ok then
        diag = string.format("expected something other than: %s", tostring(expected))
    end
    return _tap(ok, desc, diag)
end

function M.err(fn, desc)
    local ok, _ = pcall(fn)
    return _tap(not ok, desc or "should raise an error")
end

function M.no_err(fn, desc)
    local ok, err = pcall(fn)
    local diag = not ok and tostring(err) or nil
    return _tap(ok, desc or "should not raise an error", diag)
end

function M.like(str, pattern, desc)
    local ok = type(str) == "string" and str:find(pattern) ~= nil
    local diag
    if not ok then
        diag = string.format("'%s' does not match pattern '%s'", tostring(str), pattern)
    end
    return _tap(ok, desc, diag)
end

-- Deep equality comparison for tables (recursive).
local function deep_eq(a, b, seen)
    if a == b then return true end
    if type(a) ~= "table" or type(b) ~= "table" then return false end
    seen = seen or {}
    if seen[a] then return true end  -- cycle guard
    seen[a] = true
    -- Check all keys in a exist in b with equal values.
    for k, v in pairs(a) do
        if not deep_eq(v, b[k], seen) then return false end
    end
    -- Check b has no extra keys.
    for k in pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

--- Assert deep equality between two values (recursively compares tables).
function M.is_deeply(got, expected, desc)
    local ok = deep_eq(got, expected)
    local diag
    if not ok then
        diag = string.format("deep mismatch: got %s  expected %s",
            tostring(got), tostring(expected))
    end
    return _tap(ok, desc, diag)
end

--- Assert that fn() raises an error whose message matches the Lua pattern.
-- @param fn       zero-argument callable that should raise
-- @param pattern  Lua string pattern to match against the error message
-- @param desc     test description
function M.throws_ok(fn, pattern, desc)
    local ok, err = pcall(fn)
    if ok then
        return _tap(false, desc or "should raise an error matching pattern",
            "no error was raised")
    end
    local msg = tostring(err)
    local matched = msg:find(pattern) ~= nil
    local diag = not matched and
        string.format("error '%s' does not match pattern '%s'", msg, pattern) or nil
    return _tap(matched, desc, diag)
end

function M.skip(count, reason)
    count = count or 1
    for _ = 1, count do
        _run = _run + 1
        _skip = _skip + 1
        io.write(string.format("ok %d # SKIP %s\n", _run, reason or ""))
    end
end

function M.done()
    if _plan and _run ~= _plan then
        io.write(string.format("# Planned %d but ran %d tests\n", _plan, _run))
    end
    io.write(string.format("# %d/%d tests passed", _pass, _run))
    if _skip > 0 then io.write(string.format(" (%d skipped)", _skip)) end
    if _fail > 0 then
        io.write(string.format(", %d FAILED\n", _fail))
        os.exit(1)
    else
        io.write("\n")
    end
end

return M
