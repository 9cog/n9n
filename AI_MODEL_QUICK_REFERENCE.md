# Node9 AI Model Quick Reference

## 🔑 Key Configuration

**Secrets are already set up for you!**
- ✅ **MODEL_TOKEN** - Available in GitHub Copilot environment secrets
- ✅ **MOD_TOKEN** - Available in GitHub Actions repository secrets
- ✅ No manual setup needed for GitHub users

## 📋 Available Prompts

The `node9.prompt.yml` file includes 7 specialized prompts:

1. **code_review** (default) - Reviews Node9 Lua code for best practices
2. **code_generate** - Generates Node9-compliant code
3. **doc_generate** - Creates documentation for Node9 code
4. **debug** - Analyzes errors and debugging issues
5. **build** - Helps with build system and compilation
6. **library** - Evaluates Lua libraries for Node9 integration
7. **meeting** - Extracts action items from meetings

## 🚀 Quick Usage

### With GitHub Copilot
Just use Copilot in this repository - MODEL_TOKEN is automatically available!

### With GitHub Actions
```yaml
env:
  MOD_TOKEN: ${{ secrets.MOD_TOKEN }}
```

### Local Development (Optional)
```bash
cp .env.example .env
# Edit .env with your keys (use MODEL_TOKEN or MODEL_KEY)
source .env
```

## 🔐 Secret Names

| Context | Variable Name | Status |
|---------|---------------|--------|
| GitHub Copilot | `MODEL_TOKEN` | ✓ Configured in environment secrets |
| GitHub Actions | `MOD_TOKEN` | ✓ Configured in repository secrets |
| Local Dev | `MODEL_TOKEN` or `MODEL_KEY` | Set in .env file |

**Fallback order**: MODEL_TOKEN → MOD_TOKEN → MODEL_KEY

## 📁 Files Created

- `.env.example` - Template for local environment variables
- `node9.prompt.yml` - AI prompt definitions (enhanced)
- `.github/README.md` - GitHub configuration docs
- `.github/workflows/ai-review.yml` - Example AI workflow
- `doc/AI_MODEL_CONFIGURATION.md` - Comprehensive guide
- `.gitignore` - Updated to protect secrets

## 🎯 Example Use Cases

### Code Review
Ask GitHub Copilot to review Node9 code using the code_review prompt
- Checks Node9 module system usage
- Validates LuaJIT FFI patterns
- Ensures platform compatibility

### Code Generation
Ask GitHub Copilot to generate Node9 code using the code_generate prompt
- Creates applications following Node9 conventions
- Uses proper imports and module structure
- Includes error handling

### Debugging Help
Ask GitHub Copilot to debug issues using the debug prompt
- Analyzes LuaJIT errors
- FFI troubleshooting
- Platform-specific problems

### Library Evaluation
Ask GitHub Copilot to evaluate libraries using the library prompt
- Checks LuaJIT 2.0.4 compatibility
- Assesses Node9 integration needs
- Reviews dependencies

## 📚 Documentation

Full documentation: [doc/AI_MODEL_CONFIGURATION.md](doc/AI_MODEL_CONFIGURATION.md)

## 🔒 Security

- MODEL_TOKEN and MOD_TOKEN never committed to git (in .gitignore)
- GitHub secrets are encrypted and secure
- Only authorized users and workflows can access

## 🛠️ Customization

Edit `node9.prompt.yml` to:
- Add custom prompts
- Adjust model parameters
- Change default settings
- Add new use cases

All prompts use MODEL_TOKEN/MOD_TOKEN from GitHub secrets automatically!
