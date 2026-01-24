# Torch Libraries Examples

This directory contains example applications demonstrating the usage of the torch libraries integrated into Node9.

## Available Examples

### 1. sys_example.lua - System Utilities

Demonstrates the usage of `torch.sys` library:

- **Timing and Benchmarking**: High-precision timing with `tic()`/`toc()` and `clock()`
- **OS Detection**: Detect operating system with `uname()` and `OS`
- **String Manipulation**: Split strings with `split()`
- **NaN Detection**: Check for NaN values with `isNaN()`
- **Terminal Colors**: Colorize output with `COLORS`
- **File Path Introspection**: Get current file path with `fpath()`
- **Command Execution**: Execute shell commands with `execute()`
- **Sleep Functions**: Sleep with `sleep()` and `usleep()`

**Run:**
```bash
cd /path/to/n9n
export LUA_PATH="./fs/os/lib/?.lua;./fs/os/lib/?/init.lua;;"
./luajit/src/luajit examples/torch/sys_example.lua
```

### 2. class_example.lua - Object-Oriented Programming

Demonstrates the usage of `torch.class` library:

- **Basic Class Definition**: Define classes with constructors and methods
- **Inheritance**: Create class hierarchies with parent-child relationships
- **Type Checking**: Use `type()` and `istype()` for runtime type checking
- **Polymorphism**: Override methods in subclasses
- **Real-World Examples**: Vehicle hierarchy, Shape hierarchy, Logger system

**Run:**
```bash
cd /path/to/n9n
export LUA_PATH="./fs/os/lib/?.lua;./fs/os/lib/?/init.lua;;"
./luajit/src/luajit examples/torch/class_example.lua
```

### 3. argcheck_example.lua - Function Argument Validation

Demonstrates the usage of `torch.argcheck` library:

- **Basic Type Checking**: Validate argument types
- **Default Values**: Provide default values for optional arguments
- **Optional Arguments**: Mark arguments as optional with `opt=true`
- **Named Arguments**: Use named argument syntax for clarity
- **Multiple Patterns**: Function overloading with different argument patterns
- **Custom Validation**: Use `check` functions for complex validation
- **Dynamic Defaults**: Generate default values with `defaultf` functions

**Run:**
```bash
cd /path/to/n9n
export LUA_PATH="./fs/os/lib/?.lua;./fs/os/lib/?/init.lua;;"
./luajit/src/luajit examples/torch/argcheck_example.lua
```

### 4. integrated_demo.lua - Complete Integration

Demonstrates how to use all three torch libraries together in a real-world application:

- **Task Management System**: A complete example using all three libraries
- **torch.sys**: Used for timing task execution and system information
- **torch.class**: Used for creating Task and TaskManager classes
- **torch.argcheck**: Used for validating task creation parameters
- **Practical Application**: Shows how the libraries complement each other

**Run:**
```bash
cd /path/to/n9n
export LUA_PATH="./fs/os/lib/?.lua;./fs/os/lib/?/init.lua;;"
./luajit/src/luajit examples/torch/integrated_demo.lua
```

## Quick Start

To run all examples:

```bash
cd /path/to/n9n
export LUA_PATH="./fs/os/lib/?.lua;./fs/os/lib/?/init.lua;;"

# Run individual examples
./luajit/src/luajit examples/torch/sys_example.lua
./luajit/src/luajit examples/torch/class_example.lua
./luajit/src/luajit examples/torch/argcheck_example.lua
./luajit/src/luajit examples/torch/integrated_demo.lua
```

## Learning Path

1. **Start with sys_example.lua**: Learn the basic utilities for system interaction
2. **Move to class_example.lua**: Understand object-oriented programming in Lua
3. **Study argcheck_example.lua**: Learn to create robust function interfaces
4. **Explore integrated_demo.lua**: See how to combine all libraries in practice

## Key Concepts

### torch.sys

The sys library provides essential system utilities:

```lua
local sys = require('torch.sys')

-- Timing
sys.tic()
-- ... do work ...
local elapsed = sys.toc()

-- OS detection
local os_name = sys.uname()  -- "linux", "macos", "windows", etc.

-- Colors
local c = sys.COLORS
print(c.red .. "Error!" .. c.none)
```

### torch.class

The class library enables clean OOP:

```lua
local class = require('torch.class')

local MyClass = class('MyClass')

function MyClass:__init(value)
    self.value = value
end

function MyClass:getValue()
    return self.value
end

local obj = MyClass(42)
print(obj:getValue())  -- 42
```

### torch.argcheck

The argcheck library validates function arguments:

```lua
local argcheck = require('torch.argcheck')

local myFunc = argcheck{
    {name="x", type="number"},
    {name="y", type="number", default=0},
    call = function(x, y)
        return x + y
    end
}

print(myFunc(5))      -- 5
print(myFunc(5, 3))   -- 8
```

## Further Reading

- [torch.sys Documentation](../../fs/os/lib/torch/README.md#torchsys---system-utilities)
- [torch.class Documentation](../../fs/os/lib/torch/README.md#torchclass---object-oriented-programming)
- [torch.argcheck Documentation](../../fs/os/lib/torch/README.md#torchargcheck---function-argument-validation)
- [Implementation Summary](../../IMPLEMENTATION_SUMMARY.md)
- [Torch Library Analysis](../../TORCH_LIBRARY_ANALYSIS.md)
