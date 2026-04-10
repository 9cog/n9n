#!/usr/bin/env luajit
--------------------------------------------------------------------------------
-- run_tests.lua — master test runner for Node9 Lua unit tests
--
-- Usage:
--   luajit fs/appl/run_tests.lua            (from repo root)
--   ./fs/appl/run_tests.lua                 (executable)
--
-- Returns exit code 0 if all suites pass, 1 if any suite fails.
--------------------------------------------------------------------------------

local root = arg[0]:match("^(.*)/fs/appl/") or "."
package.path = root .. "/fs/os/lib/?.lua;" .. root .. "/fs/os/lib/?/init.lua;;"

-- Suite list: {label, script-path}
local SUITES = {
    { "torch.sys",      root .. "/fs/appl/test_torch_sys.lua"      },
    { "torch.class",    root .. "/fs/appl/test_torch_class.lua"     },
    { "torch.argcheck", root .. "/fs/appl/test_torch_argcheck.lua"  },
    { "penlight",       root .. "/fs/appl/test_penlight.lua"        },
    { "environments",   root .. "/fs/appl/test_environments.lua"    },
}

local pass_count = 0
local fail_count = 0

local separator = string.rep("─", 64)

print(separator)
print("  Node9 Test Runner")
print(separator)

for _, suite in ipairs(SUITES) do
    local label, path = suite[1], suite[2]
    io.write(string.format("  ▶  %-20s  ", label))
    io.flush()

    local ok, err = pcall(dofile, path)
    if ok then
        pass_count = pass_count + 1
        print("PASS")
    else
        fail_count = fail_count + 1
        print("FAIL")
        -- indent the error message
        local msg = tostring(err):gsub("\n", "\n    ")
        print("    " .. msg)
    end
end

print(separator)
local total = pass_count + fail_count
print(string.format("  %d/%d suites passed", pass_count, total))
print(separator)

if fail_count > 0 then
    os.exit(1)
end
