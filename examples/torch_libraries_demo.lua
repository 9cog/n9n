#!/usr/bin/env luajit
--------------------------------------------------------------------------------
-- Example: Using Torch Libraries in Node9
-- This example demonstrates practical use of torch.sys, torch.class, and 
-- torch.argcheck in a real application scenario.
--------------------------------------------------------------------------------

-- Set up library path for torch modules
package.path = './fs/os/lib/?.lua;./fs/os/lib/?/init.lua;' .. package.path

local sys = require('torch.sys')
local class = require('torch.class')
local argcheck = require('torch.argcheck')

--------------------------------------------------------------------------------
-- Example 1: High-Precision Performance Measurement with torch.sys
--------------------------------------------------------------------------------

print(sys.COLORS.cyan .. "\n=== Example 1: Performance Measurement ===" .. sys.COLORS.none)

local function benchmark_function(name, func, iterations)
    sys.tic()
    for i = 1, iterations do
        func()
    end
    local elapsed = sys.toc()
    print(string.format("%s: %d iterations in %.6f seconds (%.2f µs/iter)",
        name, iterations, elapsed, (elapsed * 1000000) / iterations))
end

-- Benchmark some operations
benchmark_function("String concatenation", function()
    local s = "hello" .. "world"
end, 100000)

benchmark_function("Table creation", function()
    local t = {a=1, b=2, c=3}
end, 100000)

benchmark_function("Math operations", function()
    local x = math.sin(1.5) * math.cos(2.3)
end, 100000)

--------------------------------------------------------------------------------
-- Example 2: Building a Configuration System with torch.class
--------------------------------------------------------------------------------

print(sys.COLORS.cyan .. "\n=== Example 2: Configuration System ===" .. sys.COLORS.none)

-- Base configuration class
local Config = class('Config')

function Config:__init(name)
    self.name = name
    self.settings = {}
    self.created = sys.clock()
end

function Config:set(key, value)
    self.settings[key] = value
end

function Config:get(key, default)
    return self.settings[key] or default
end

function Config:dump()
    print(sys.COLORS.green .. string.format("Configuration '%s':", self.name) .. sys.COLORS.none)
    for k, v in pairs(self.settings) do
        print(string.format("  %s = %s", k, tostring(v)))
    end
end

-- Specialized server configuration
local ServerConfig = class('ServerConfig', 'Config')

function ServerConfig:__init(name)
    Config.__init(self, name)
    self:set('host', 'localhost')
    self:set('port', 8080)
    self:set('timeout', 30)
end

function ServerConfig:url()
    return string.format("http://%s:%d", 
        self:get('host'), self:get('port'))
end

-- Create and use configurations
local webConfig = ServerConfig('web-server')
webConfig:set('host', 'example.com')
webConfig:set('port', 443)
webConfig:dump()
print("  URL: " .. webConfig:url())

print("\nType checking:")
print("  class.type(webConfig):", class.type(webConfig))
print("  Is ServerConfig?", class.istype(webConfig, 'ServerConfig'))
print("  Is Config?", class.istype(webConfig, 'Config'))

--------------------------------------------------------------------------------
-- Example 3: API with Argument Validation using torch.argcheck
--------------------------------------------------------------------------------

print(sys.COLORS.cyan .. "\n=== Example 3: Validated API Functions ===" .. sys.COLORS.none)

-- File processing function with validated arguments
local check_process_file = argcheck{
    help = [[Process a file with optional filtering]],
    {name="filename", type="string", help="path to input file"},
    {name="output", type="string", opt=true, help="path to output file"},
    {name="filter", type="function", opt=true, help="filter function"},
    {name="verbose", type="boolean", default=false, help="verbose output"}
}

local function process_file(...)
    local filename, output, filter, verbose = check_process_file(...)
    
    if verbose then
        print(string.format("Processing: %s", filename))
        if output then
            print(string.format("Output to: %s", output))
        end
    end
    
    -- Simulate processing
    sys.tic()
    sys.usleep(10000)  -- 10ms
    local elapsed = sys.toc()
    
    print(string.format("%sProcessed '%s' in %.3f ms%s", 
        sys.COLORS.green, filename, elapsed * 1000, sys.COLORS.none))
    
    return true
end

-- Use the function with different argument styles
print("\nPositional arguments:")
process_file("data.txt", "output.txt", nil, true)

print("\nNamed arguments:")
process_file{
    filename = "config.json",
    verbose = true
}

print("\nMinimal arguments (using defaults):")
process_file("log.txt")

-- Network connection function with comprehensive validation
local check_connect = argcheck{
    help = [[Establish a network connection]],
    {name="host", type="string", help="hostname or IP address"},
    {name="port", type="number", help="port number"},
    {name="timeout", type="number", default=30, help="connection timeout in seconds"},
    {name="secure", type="boolean", default=false, help="use TLS/SSL"},
    {name="retries", type="number", default=3, help="number of retry attempts"}
}

local function connect(...)
    local host, port, timeout, secure, retries = check_connect(...)
    
    local protocol = secure and "https" or "http"
    print(string.format("%sConnecting to %s://%s:%d (timeout=%ds, retries=%d)%s",
        sys.COLORS.yellow, protocol, host, port, timeout, retries, sys.COLORS.none))
    
    return {host=host, port=port, secure=secure}
end

print("\nNetwork connections:")
connect("api.example.com", 443, 60, true)
connect{host="localhost", port=8080}

--------------------------------------------------------------------------------
-- Example 4: Combining All Libraries
--------------------------------------------------------------------------------

print(sys.COLORS.cyan .. "\n=== Example 4: Complete Application ===" .. sys.COLORS.none)

-- Task management system
local Task = class('Task')

local check_task_init = argcheck{
    {name="name", type="string"},
    {name="priority", type="number", default=5},
    {name="timeout", type="number", default=60}
}

function Task:__init(...)
    local name, priority, timeout = check_task_init(...)
    self.name = name
    self.priority = priority
    self.timeout = timeout
    self.status = "pending"
    self.created = sys.clock()
end

function Task:execute()
    print(string.format("%s[Task: %s] Starting (priority=%d)%s",
        sys.COLORS.blue, self.name, self.priority, sys.COLORS.none))
    
    self.status = "running"
    sys.tic()
    
    -- Simulate work
    sys.usleep(50000)  -- 50ms
    
    local elapsed = sys.toc()
    self.status = "completed"
    
    print(string.format("%s[Task: %s] Completed in %.3f ms%s",
        sys.COLORS.green, self.name, elapsed * 1000, sys.COLORS.none))
    
    return true
end

function Task:info()
    local age = sys.clock() - self.created
    return string.format("Task '%s': status=%s, priority=%d, age=%.3fs",
        self.name, self.status, self.priority, age)
end

-- Create and execute tasks
local tasks = {
    Task{name="Database backup", priority=10, timeout=300},
    Task{name="Log rotation", priority=5},
    Task{name="Cache cleanup", priority=3}
}

print("\nExecuting tasks:")
for _, task in ipairs(tasks) do
    print("  " .. task:info())
    task:execute()
end

--------------------------------------------------------------------------------
-- Summary
--------------------------------------------------------------------------------

print(sys.COLORS.cyan .. "\n=== Summary ===" .. sys.COLORS.none)
print("This example demonstrated:")
print("  • " .. sys.COLORS.green .. "torch.sys" .. sys.COLORS.none .. " - High-precision timing and OS utilities")
print("  • " .. sys.COLORS.green .. "torch.class" .. sys.COLORS.none .. " - Object-oriented programming with inheritance")
print("  • " .. sys.COLORS.green .. "torch.argcheck" .. sys.COLORS.none .. " - Robust argument validation")
print("\nOS Information:")
print("  Platform: " .. sys.OS)
print("  Full name: " .. sys.uname())
print("\nAll torch libraries are working correctly!")
