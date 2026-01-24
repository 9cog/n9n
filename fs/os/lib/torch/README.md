# Torch Libraries for Node9

This directory contains adapted versions of useful Torch libraries for Node9. These libraries have been modified to work standalone with LuaJIT without external dependencies.

## Available Libraries

### 1. torch.sys - System Utilities

Provides system-level utilities and helper functions.

**Features:**
- High-precision timing: `sys.clock()`, `sys.tic()`, `sys.toc()`
- Sleep functions: `sys.sleep(seconds)`, `sys.usleep(microseconds)`
- OS detection: `sys.uname()`, `sys.OS`
- Command execution: `sys.execute(cmd)`, `sys.fexecute(cmd)`
- String utilities: `sys.split(str, pattern)`
- File path introspection: `sys.fpath()`
- NaN detection: `sys.isNaN(number)`
- Color codes: `sys.COLORS` table with ANSI color codes
- Directory listing (Unix only): `sys.ls()`, `sys.ll()`, `sys.la()`, `sys.lla()`

**Example:**
```lua
local sys = require('torch.sys')

-- Timing
sys.tic()
-- ... do something ...
local elapsed = sys.toc()  -- returns elapsed time

-- Colors
local c = sys.COLORS
print(c.red .. "Error!" .. c.none)

-- OS detection
print("Running on: " .. sys.OS)
```

### 2. torch.class - Object-Oriented Programming

Provides a simple and efficient class system with inheritance support.

**Features:**
- Class definition with `class(name)` or `class(name, parent)`
- Constructor method `__init()`
- Type checking: `class.type(obj)`, `class.istype(obj, typename)`
- Factory pattern: `class.factory(name)`
- Inheritance with proper type hierarchy

**Example:**
```lua
local class = require('torch.class')

-- Define a base class
local Animal = class('Animal')

function Animal:__init(name)
   self.name = name
end

function Animal:speak()
   print(self.name .. " makes a sound")
end

-- Define a derived class
local Dog = class('Dog', 'Animal')

function Dog:__init(name, breed)
   Animal.__init(self, name)
   self.breed = breed
end

function Dog:speak()
   print(self.name .. " barks!")
end

-- Usage
local dog = Dog("Buddy", "Golden Retriever")
dog:speak()  -- "Buddy barks!"

print(class.istype(dog, 'Dog'))     -- true
print(class.istype(dog, 'Animal'))  -- true (inheritance)
```

### 3. torch.argcheck - Argument Validation

Provides advanced argument checking and validation with automatic error messages.

**Features:**
- Type checking for function arguments
- Default values: `default=value`
- Default from another argument: `defaulta="argname"`
- Default from function: `defaultf=function`
- Optional arguments: `opt=true`
- Custom validation: `check=function`
- Automatic help/documentation generation
- Support for both positional and named arguments

**Example:**
```lua
local argcheck = require('torch.argcheck')

-- Define argument checker
local check = argcheck{
   help = "Calculate sum of two numbers",
   {name="a", type="number", help="first number"},
   {name="b", type="number", default=0, help="second number"}
}

function add(...)
   local a, b = check(...)
   return a + b
end

-- Usage
add(5, 3)           -- returns 8
add(5)              -- returns 5 (b defaults to 0)
add{a=10, b=20}     -- returns 30 (named arguments)
```

## Installation

These libraries are located in `fs/os/lib/torch/` and can be required directly:

```lua
local sys = require('torch.sys')
local class = require('torch.class')
local argcheck = require('torch.argcheck')
```

Make sure your `LUA_PATH` includes `fs/os/lib/?.lua`.

## Differences from Original Torch Libraries

These implementations are simplified and adapted for Node9:

1. **torch.sys**: Removed dependency on `paths` module and `libsys` C library. All functionality is implemented in pure Lua with FFI for system calls.

2. **torch.class**: Removed dependency on `argcheck` for the class definition itself. Simplified API while maintaining compatibility.

3. **torch.argcheck**: Simplified implementation focusing on core functionality. Does not include overloading, graphviz output, or some advanced features.

## Testing

Run the test suite with:

```bash
export LUA_PATH="./fs/os/lib/?.lua;./fs/os/lib/?/init.lua;;"
luajit test_torch_libs.lua
```

## Why These Libraries?

These libraries were chosen from the torch ecosystem because they provide general-purpose utilities that complement Node9's existing infrastructure:

- **sys**: Adds cross-platform system utilities and timing functions useful for any application
- **class**: Provides an alternative OOP approach that complements Penlight's class system
- **argcheck**: Enhances the existing argument parsing (lapp) with type checking and validation

Libraries **not** included:
- **nn, rnn, nngraph**: Neural network libraries - too heavy and specialized
- **gnuplot, cairo-ffi, sdl2-ffi**: Require external dependencies and graphics support
- **trepl**: Would conflict with Node9's existing shell
- **threads**: Conflicts with Node9's Inferno-based concurrency model

## License

These libraries are adapted from the Torch project (BSD license). See individual files for copyright information.
