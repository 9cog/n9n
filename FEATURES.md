# Node9 Feature List

This document provides a comprehensive catalog of Node9 features organized by category. For wiki publication.

## Table of Contents
- [Core Operating System](#core-operating-system)
- [Programming Environment](#programming-environment)
- [Libraries and Utilities](#libraries-and-utilities)
- [Build System](#build-system)
- [Platform Support](#platform-support)
- [Networking and Distribution](#networking-and-distribution)
- [Applications](#applications)
- [Development Tools](#development-tools)

---

## Core Operating System

### Inferno-Based Architecture
- **Hosted 64-bit OS** based on Bell Lab's Inferno OS
- **Per-process namespaces** for security isolation
- **Resource virtualization** via filesystem interface
- **Styx (9p) protocol** for resource sharing
- **Message channels** for inter-process communication
- **Concurrent task model** using Lua coroutines

**Location**: Core implementation in `src/`, kernel in `fs/os/lib/kernel.lua`

### Virtual Machine
- **LuaJIT 2.0.4** high-performance JIT compiler
- **FFI (Foreign Function Interface)** for seamless C integration
- **Lua 5.1** language semantics
- **JIT compilation** for performance-critical code
- **Portable bytecode** execution

**Location**: `luajit/` directory

### I/O and Event Processing
- **libuv integration** for portable, high-performance I/O
- **Event-driven architecture** (same library as Node.js)
- **Async I/O operations** with coroutine-based synchronous API
- **Multi-threading support** (one thread per user session)
- **Platform-native event loops**

**Location**: `libuv/` directory, integration in `src/`

---

## Programming Environment

### Lua Scripting
- **Interactive shell** with immediate mode expression evaluation
- **Module system** with `import()` and `require()`
- **Coroutine-based concurrency** with message passing
- **FFI access** to C libraries and system calls
- **Full standard library** support

**Location**: `fs/appl/sh.lua` (shell), `fs/module/` (modules)

### Object-Oriented Programming
Multiple OOP paradigms available:

#### Penlight Class System
- **Single inheritance** class system
- **Properties** and getters/setters
- **Multiple constructors**
- Integrated with Penlight utilities

**Location**: `fs/os/lib/pl/class.lua`

#### Torch Class System
- **Lightweight** class definition
- **Inheritance** with type hierarchy
- **Type checking** with `istype()`
- **Factory pattern** support

**Location**: `fs/os/lib/torch/class.lua`

### Argument Validation
- **Type checking** for function arguments
- **Default values** (static, from other args, or functions)
- **Optional arguments** support
- **Custom validation** functions
- **Automatic help/documentation** generation

**Location**: `fs/os/lib/torch/argcheck.lua`

---

## Libraries and Utilities

### Penlight Library
Comprehensive Lua utility library with:

#### String Utilities
- **Extended string operations** (`stringx.lua`)
- **Text processing** utilities (`text.lua`)
- **Lexical analysis** (`lexer.lua`)

#### Data Structures
- **MultiMap** - Multiple values per key
- **OrderedMap** - Ordered key-value pairs
- **Set**, **List**, **Map** operations
- **Tablex** - Extended table operations

#### File and Path Operations
- **Path manipulation**
- **File operations**
- **Directory utilities**

#### Other Utilities
- **Application framework** (`app.lua`)
- **Input handling** (`input.lua`)
- **Data loading** (`data.lua`)
- **Compatibility** layer (`compat.lua`)

**Location**: `fs/os/lib/pl/`

### Torch System Utilities

#### High-Precision Timing
- **`sys.clock()`** - Platform-aware monotonic clock
- **`sys.tic()` / `sys.toc()`** - MATLAB-style timing
- **Microsecond precision** using FFI

#### OS Detection and Info
- **`sys.uname()`** - Returns OS name
- **`sys.OS`** - Cached OS value
- **Platform constants** (CLOCK_MONOTONIC, etc.)

#### Command Execution
- **`sys.execute(cmd)`** - Execute and return output
- **`sys.fexecute(cmd)`** - Execute with temp file
- **Portable implementation** across platforms

#### Terminal Features
- **`sys.COLORS`** - ANSI color codes table
- **Red, green, blue, yellow, magenta, cyan** colors
- **Bold, underline** text formatting

#### Directory Listing (Unix)
- **`sys.ls()`** - Basic listing
- **`sys.ll()`** - Long format
- **`sys.la()`** - All files
- **`sys.lla()`** - Long format with all files

#### Utility Functions
- **`sys.split(str, pattern)`** - String splitting
- **`sys.isNaN(number)`** - NaN detection
- **`sys.fpath()`** - File path introspection
- **`sys.sleep(seconds)`** - Sleep function
- **`sys.usleep(microseconds)`** - Microsecond sleep

**Location**: `fs/os/lib/torch/sys.lua`

### Styx Protocol Libraries

#### Core Styx Libraries
- **lib9** - Protocol, conversion, formatting utilities
- **libbio** - Low-level I/O and rune (Unicode) support
- **libsec** - Cryptographic operations and SSL/TLS

**Location**: `src/styx/libs/`

### System Modules

#### sys Module
- **System call interface**
- **File descriptor management**
- **Error handling** (`sys.errstr()`)
- **Process operations**

**Location**: `fs/module/sys.lua`

#### arg Module
- **Command-line argument parsing**
- **Option handling** (`getopt()`)
- **Usage string** management
- **Argument stripping**

**Location**: `fs/module/arg.lua`

---

## Build System

### Premake5 Configuration
- **Multi-platform** build generation
- **Configuration management** (debug, devel, release)
- **Platform targeting** (Linux, macOS, BSD, Windows, Android, Solaris)
- **64-bit architecture** support
- **Automatic makefile** generation

**Location**: `premake5.lua`

### Build Targets
- **lib9** - Styx protocol libraries
- **libbio** - I/O and Unicode support
- **libsec** - Cryptographic libraries
- **ndate** - Date utilities
- **node9** - Main executable
- **libnode9** - Node9 library

### Build Configurations
Each platform supports:
- **debug** - Debug symbols, no optimization
- **devel** - Development build
- **release** - Optimized production build

**Commands**: See `Makefile` for details

---

## Platform Support

### Fully Supported
- **Linux** - Primary development platform
- **macOS** - Full feature support
- **FreeBSD** - Complete implementation
- **NetBSD** - Complete implementation
- **OpenBSD** - Complete implementation
- **DragonFly BSD** - Complete implementation

### Partial Support
- **Solaris** - Basic support
- **Windows** - Limited support with fallbacks
- **Android** - Experimental

### Platform-Specific Features
- **Automatic platform detection** at runtime
- **FFI constants** adjusted per platform
- **Fallback implementations** for limited platforms
- **Conditional compilation** for platform-specific code

**Location**: Platform-specific code in `src/styx/platform/`

---

## Networking and Distribution

### 9p Resource Sharing
- **Mount remote filesystems** via 9p/Styx protocol
- **Export local resources** to network
- **Namespace composition** from multiple sources
- **SSL/TLS encryption** for network connections

**Features**:
- Compatible with Plan9 and Inferno systems
- Network-transparent resource access
- Security via namespace isolation

**Applications**: `fs/appl/mount.lua`, `fs/appl/export.lua`, `fs/appl/listen.lua`, `fs/appl/styxlisten.lua`

### Network Protocols
- **TCP/IP** via libuv
- **SSL/TLS** via libsec
- **9p (Styx)** application protocol
- **Unix domain sockets**

---

## Applications

Node9 includes several built-in applications:

### Shell
- **Interactive Lua REPL**
- **Command execution**
- **Script loading**
- **Module management**
- **Immediate mode evaluation**

**Location**: `fs/appl/sh.lua`

### Filesystem Utilities
- **ls** - Directory listing
- **mount** - Mount filesystems
- **unmount** - Unmount filesystems
- **export** - Export local namespace

**Location**: `fs/appl/`

### System Tools
- **syscall** - System call tester
- **listen** - Network listener
- **styxlisten** - Styx protocol listener

**Location**: `fs/appl/`

### Test Applications
- **test.lua** - General testing
- **apptest.lua** - Application testing

**Location**: `fs/appl/`

---

## Development Tools

### Examples

#### Torch Library Examples
Comprehensive examples demonstrating library usage:
- **sys_example.lua** - System utilities demo
- **class_example.lua** - OOP examples
- **argcheck_example.lua** - Argument validation
- **integrated_demo.lua** - Combined features

**Location**: `examples/torch/`

### Testing Framework
- **test_torch_libs.lua** - Comprehensive Torch library tests
- Tests cover all features of sys, class, and argcheck
- Includes edge cases and error handling

**Location**: `test_torch_libs.lua`

### Documentation

#### Comprehensive Guides
- **README.md** - Project overview and quick start
- **doc/node9.md** - Comprehensive hacker's guide (31.6 KB)
- **IMPLEMENTATION_SUMMARY.md** - Recent implementation details
- **TORCH_LIBRARY_ANALYSIS.md** - Library evaluation and selection
- **fs/os/lib/torch/README.md** - Torch library API documentation

#### Documentation Coverage
- Architecture and design philosophy
- API references with examples
- Build and installation instructions
- Platform-specific notes
- Integration guidelines
- Security model

**Location**: `doc/`, `README.md`, various subdirectory READMEs

---

## Key Features Summary

### Performance
- ✅ **JIT compilation** via LuaJIT for near-native speed
- ✅ **Zero-copy I/O** where possible
- ✅ **Event-driven** architecture (libuv)
- ✅ **Efficient FFI** for C integration

### Portability
- ✅ **Multi-platform** support (8+ platforms)
- ✅ **Portable I/O** via libuv
- ✅ **Platform detection** at runtime
- ✅ **Graceful fallbacks** for limited platforms

### Security
- ✅ **Per-process namespaces**
- ✅ **SSL/TLS** support
- ✅ **No global state** pollution
- ✅ **Sandboxed** execution model

### Developer Experience
- ✅ **Interactive shell** for rapid prototyping
- ✅ **Rich library** ecosystem (Penlight + Torch utilities)
- ✅ **Multiple OOP** paradigms
- ✅ **Comprehensive documentation**
- ✅ **Example code** for all features

### Integration
- ✅ **FFI for C libraries**
- ✅ **libuv for async I/O**
- ✅ **9p protocol** for distribution
- ✅ **Compatible with** Plan9/Inferno

---

## Feature Comparison

### vs Traditional Unix
| Feature | Unix | Node9 |
|---------|------|-------|
| **Namespace** | Global | Per-process |
| **IPC** | Pipes, sockets | Message channels + 9p |
| **Scripting** | Shell (sh/bash) | Lua + LuaJIT |
| **VM** | None | LuaJIT JIT compiler |
| **I/O** | syscalls | libuv + FFI |

### vs Inferno OS
| Feature | Inferno | Node9 |
|---------|---------|-------|
| **Language** | Limbo | Lua |
| **VM** | Dis | LuaJIT |
| **I/O Library** | Native | libuv |
| **Threading** | Limited | Full OS threads |
| **Build** | mk | premake5 + Make |

### vs Node.js
| Feature | Node.js | Node9 |
|---------|---------|-------|
| **I/O Library** | libuv | libuv |
| **Language** | JavaScript | Lua |
| **VM** | V8 | LuaJIT |
| **OS Model** | Callbacks | Coroutines + Channels |
| **Distribution** | npm | 9p protocol |

---

## Future Directions

Based on documentation, potential future enhancements:
- Web-based management GUI for cloud environments
- Enhanced Windows support
- Additional library integrations
- More comprehensive test coverage
- Performance optimizations

---

## Quick Reference

### File Locations
```
Core System:     src/, fs/os/
Applications:    fs/appl/
Libraries:       fs/os/lib/
Modules:         fs/module/
Documentation:   doc/, README.md
Examples:        examples/
Tests:           test_torch_libs.lua, fs/appl/test.lua
Build:           premake5.lua, Makefile
External Deps:   luajit/, libuv/
```

### Key Commands
```bash
# Build
make config=debug_linux

# Run shell
./src/build/node9

# Run tests
./src/build/node9 test_torch_libs.lua

# Clean
make clean
```

### Module Loading
```lua
-- Kernel modules (use import)
sys = import("sys")
arg = import("arg")

-- Libraries (use require)
pl = require("pl")
sys_torch = require("torch.sys")
class = require("torch.class")
argcheck = require("torch.argcheck")
```

---

## License

Node9 is based on Inferno OS and inherits its licensing. See LICENSE file for details.

## Resources

- **Repository**: https://github.com/9cog/n9n
- **Wiki**: https://github.com/9cog/n9n/wiki
- **Inferno OS**: http://www.vitanuova.com/inferno/
- **Plan9**: http://plan9.bell-labs.com/plan9/
- **Lua**: http://www.lua.org/
- **LuaJIT**: http://luajit.org/
- **libuv**: http://docs.libuv.org/
- **Penlight**: https://github.com/lunarmodules/Penlight
- **Torch**: https://github.com/torch

---

*This feature list is maintained as part of the Node9 project documentation. Last updated: 2026-01-24*
