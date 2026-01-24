Node9 is a hosted 64-bit operating system based on Bell Lab's Inferno OS, but
using the Lua scripting language instead of Limbo and the LuaJIT high
performance virtual machine instead of the Dis virtual machine.  It also uses
the libuv I/O library for maximum portability, efficient event processing and
thread management.

See the [node9.md][node9] file in ./doc for more information.

For current status and development information, check out the [Wiki][wiki9]

## AI Development Assistant

Node9 includes AI model integration for development assistance:

* **GitHub Copilot Integration** - MODEL_TOKEN configured in Copilot environment secrets
* **GitHub Actions Support** - MOD_TOKEN configured in repository secrets for CI/CD
* **Multiple Specialized Prompts** - code_review, code_generate, debug, build, library, etc.

See [AI Model Configuration Guide](doc/AI_MODEL_CONFIGURATION.md) for usage details.
Configuration file: [node9.prompt.yml](node9.prompt.yml)

## Libraries

Node9 includes several Lua libraries to enhance development:

* **Penlight** - Comprehensive Lua utility library (located in `fs/os/lib/pl/`)
* **Torch Libraries** - Selected utilities from the Torch ecosystem:
  * `torch.sys` - System utilities (timing, OS detection, colors, command execution)
  * `torch.class` - Object-oriented programming with inheritance
  * `torch.argcheck` - Advanced function argument validation

See [fs/os/lib/torch/README.md](fs/os/lib/torch/README.md) for torch library documentation.

See Also:
* [Inferno OS][inferno]
* [Limbo][limbo]
* [DIS VM][dis]
* [Lua][lua]
* [LuaJIT][luajit]
* [libuv][libuv]
* [Torch][torch]

[inferno]: http://www.vitanuova.com/inferno/
[limbo]: http://www.vitanuova.com/inferno/limbo.html
[dis]: http://www.vitanuova.com/inferno/papers/dis.html
[lua]: http://www.lua.org/
[luajit]: http://luajit.org/
[libuv]: http://docs.libuv.org/en/v1.x/
[torch]: https://github.com/torch
[hackers]: https://github.com/9cog/9n9/blob/main/doc/node9.md
[wiki9]: https://github.com/9cog/9n9/wiki
