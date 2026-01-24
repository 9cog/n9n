#!/usr/bin/env luajit
--------------------------------------------------------------------------------
-- torch.sys Example - System Utilities
--
-- This example demonstrates the usage of torch.sys library for:
-- - High-precision timing and benchmarking
-- - OS detection
-- - String manipulation
-- - Terminal colors
-- - File path introspection
--------------------------------------------------------------------------------

local sys = require('torch.sys')

print("=" .. string.rep("=", 70))
print("torch.sys - System Utilities Example")
print("=" .. string.rep("=", 70))

-- Example 1: Timing and Benchmarking
print("\n1. High-Precision Timing")
print("-" .. string.rep("-", 70))

-- Using tic/toc for MATLAB-style timing
sys.tic()
local sum = 0
for i = 1, 1000000 do
    sum = sum + i
end
local elapsed = sys.toc()
print(string.format("Computed sum of 1-1,000,000 in %.6f seconds", elapsed))
print(string.format("Result: %d", sum))

-- Using clock() for more control
local start = sys.clock()
local product = 1
for i = 1, 100 do
    product = (product * i) % 1000000007
end
local finish = sys.clock()
print(string.format("Computed modular product in %.6f seconds", finish - start))

-- Example 2: OS Detection
print("\n2. OS Detection")
print("-" .. string.rep("-", 70))
print("Operating System: " .. sys.uname())
print("Cached OS value: " .. sys.OS)

-- Conditional code based on OS
if sys.OS == "linux" then
    print("Running on Linux - full features available")
elseif sys.OS == "macos" then
    print("Running on macOS - full features available")
else
    print("Running on " .. sys.OS)
end

-- Example 3: String Manipulation
print("\n3. String Utilities")
print("-" .. string.rep("-", 70))

-- Split strings
local text = "apple,banana,cherry,date"
local fruits = sys.split(text, ",")
print("Splitting: " .. text)
for i, fruit in ipairs(fruits) do
    print(string.format("  [%d] %s", i, fruit))
end

-- Split with different delimiters
local path = "/usr/local/bin/luajit"
local parts = sys.split(path, "/")
print("\nSplitting path: " .. path)
for i, part in ipairs(parts) do
    if part ~= "" then
        print(string.format("  [%d] %s", i, part))
    end
end

-- Example 4: NaN Detection
print("\n4. NaN Detection")
print("-" .. string.rep("-", 70))

local values = {42, 0/0, math.sqrt(-1), 3.14, 1/0}
local names = {"42", "0/0", "sqrt(-1)", "3.14", "1/0"}

for i, val in ipairs(values) do
    local isnan = sys.isNaN(val)
    print(string.format("  %s: %s (isNaN: %s)", names[i], tostring(val), tostring(isnan)))
end

-- Example 5: Terminal Colors
print("\n5. Terminal Colors")
print("-" .. string.rep("-", 70))

local c = sys.COLORS
print("Available colors:")
print("  " .. c.red .. "Red text" .. c.none)
print("  " .. c.green .. "Green text" .. c.none)
print("  " .. c.blue .. "Blue text" .. c.none)
print("  " .. c.cyan .. "Cyan text" .. c.none)
print("  " .. c.magenta .. "Magenta text" .. c.none)
print("  " .. c.yellow .. "Yellow text" .. c.none)

-- Combined colors and formatting
print("\n" .. c.red .. "ERROR: " .. c.none .. "Something went wrong")
print(c.green .. "SUCCESS: " .. c.none .. "Operation completed")
print(c.yellow .. "WARNING: " .. c.none .. "Please review settings")
print(c.cyan .. "INFO: " .. c.none .. "Processing data...")

-- Example 6: File Path Introspection
print("\n6. File Path Introspection")
print("-" .. string.rep("-", 70))

local filepath, dirpath = sys.fpath()
print("Current script: " .. (filepath or "unknown"))
print("Current directory: " .. (dirpath or "unknown"))

-- Example 7: Command Execution
print("\n7. Command Execution")
print("-" .. string.rep("-", 70))

-- Execute a simple command
local output = sys.execute('echo "Hello from shell"')
print("Shell output: " .. output)

-- Get current date
local date = sys.execute('date +"%Y-%m-%d %H:%M:%S"')
print("Current date: " .. date)

-- Get system info
if sys.OS == "linux" or sys.OS == "macos" then
    local uname = sys.execute('uname -a')
    print("System info: " .. uname:sub(1, 60) .. "...")
end

-- Example 8: Sleep Functions
print("\n8. Sleep Functions")
print("-" .. string.rep("-", 70))

print("Sleeping for 0.5 seconds...")
sys.sleep(0.5)
print("Done!")

print("Microsleep for 100,000 microseconds (0.1 seconds)...")
sys.usleep(100000)
print("Done!")

print("\n" .. string.rep("=", 70))
print("Example completed successfully!")
print(string.rep("=", 70))
