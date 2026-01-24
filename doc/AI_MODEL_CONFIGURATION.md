# Node9 AI Model Configuration Guide

This guide explains how to configure and use AI models with Node9 for development assistance.

## Overview

Node9 includes a flexible AI model configuration system that supports:
- Multiple AI model providers (OpenAI, Anthropic, local models)
- GitHub Copilot integration with secrets management
- GitHub Actions CI/CD with repository secrets
- Multiple specialized prompts for Node9 development tasks
- Secure API key management

## Quick Start

### Using with GitHub Copilot (Recommended)

**MODEL_KEY is already configured in GitHub Copilot environment secrets!**

The `MODEL_KEY` and related variables are available automatically when using GitHub Copilot in this repository. No setup needed - just start using the prompts!

```bash
# The MODEL_KEY is already available in Copilot environment
# Just reference the prompts in node9.prompt.yml
```

### Using with GitHub Actions

**MODEL_KEY is configured in repository secrets!**

GitHub Actions workflows can access `MODEL_KEY` from repository secrets:

```yaml
- name: AI Code Review
  env:
    MODEL_KEY: ${{ secrets.MODEL_KEY }}
    MODEL_PROVIDER: openai
    MODEL_NAME: gpt-4o
  run: |
    # Your AI-powered tasks here
```

### Local Development (Optional)

For local testing outside of GitHub Copilot:

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` and add your API key:**
   ```bash
   # For OpenAI
   OPENAI_API_KEY=sk-your-key-here
   OPENAI_MODEL=gpt-4o
   
   # Or use generic configuration
   MODEL_KEY=your-key-here
   MODEL_PROVIDER=openai
   MODEL_NAME=gpt-4o
   ```

3. **Source the environment file:**
   ```bash
   source .env
   export MODEL_KEY=$OPENAI_API_KEY
   ```

## Configuration Files

### `.env.example`
Template for environment variables. Copy this to `.env` and fill in your values.

### `node9.prompt.yml`
Main configuration file containing:
- Model settings (provider, name, temperature, etc.)
- Prompt templates for different tasks
- Default prompt selection

## Available Prompts

The configuration includes several specialized prompts:

### 1. **code_review** (default)
Reviews Node9 Lua code for best practices, security, and correctness.

**Use for:**
- Code review before committing
- Checking Node9-specific patterns
- Validating FFI usage
- Platform compatibility checks

**Example:**
```bash
# Pipe code through review
cat fs/appl/myapp.lua | your-ai-tool --prompt code_review
```

### 2. **code_generate**
Generates Node9-compliant Lua code following conventions.

**Use for:**
- Creating new applications
- Generating boilerplate code
- Module scaffolding
- Example implementations

**Example:**
```bash
echo "Create a file listing application using Penlight" | your-ai-tool --prompt code_generate
```

### 3. **doc_generate**
Creates comprehensive documentation for Node9 code.

**Use for:**
- API documentation
- README files
- Tutorial content
- Code examples

**Example:**
```bash
echo "Document the torch.sys module" | your-ai-tool --prompt doc_generate
```

### 4. **debug**
Analyzes errors and debugging issues specific to Node9.

**Use for:**
- Runtime error analysis
- FFI debugging
- Platform-specific issues
- Module loading problems

**Example:**
```bash
cat error.log | your-ai-tool --prompt debug
```

### 5. **build**
Helps with build system and compilation issues.

**Use for:**
- premake5 configuration
- Cross-platform build problems
- Library linking issues
- Build optimization

**Example:**
```bash
echo "Help setup build for Android" | your-ai-tool --prompt build
```

### 6. **library**
Evaluates Lua libraries for Node9 integration.

**Use for:**
- Library compatibility analysis
- Integration planning
- Dependency evaluation
- Adaptation strategy

**Example:**
```bash
echo "Can we integrate luasocket into Node9?" | your-ai-tool --prompt library
```

### 7. **meeting**
Extracts action items from meeting transcripts (original example).

**Example:**
```bash
cat meeting.txt | your-ai-tool --prompt meeting
```

## Environment Variables

### Required Variables

- **`MODEL_KEY`**: API key for your model provider
  - **Already configured in GitHub Copilot environment secrets**
  - **Already configured in GitHub repository secrets for Actions**
  - For OpenAI: Your OpenAI API key (sk-...)
  - For Anthropic: Your Anthropic API key
  - For local models: Not required
  - For local development: Set in your `.env` file (optional)

### Optional Variables

- **`MODEL_PROVIDER`**: Provider name (default: `openai`)
  - Options: `openai`, `anthropic`, `ollama`, etc.
  
- **`MODEL_NAME`**: Specific model to use (default: `gpt-4o`)
  - OpenAI: `gpt-4o`, `gpt-4-turbo`, `gpt-3.5-turbo`
  - Anthropic: `claude-3-5-sonnet-20241022`, `claude-3-opus-20240229`
  - Local: `llama2`, `codellama`, etc.

- **`MODEL_TEMPERATURE`**: Creativity level (default: `0.7`)
  - Range: 0.0 (deterministic) to 1.0 (creative)
  - Lower for code generation, higher for creative tasks

- **`MODEL_MAX_TOKENS`**: Maximum response length (default: `2000`)
  - Adjust based on your needs and model limits

### Provider-Specific Variables

#### OpenAI
```bash
OPENAI_API_KEY=sk-your-key-here
OPENAI_MODEL=gpt-4o
```

#### Anthropic
```bash
ANTHROPIC_API_KEY=your-key-here
ANTHROPIC_MODEL=claude-3-5-sonnet-20241022
```

#### Local Models (e.g., Ollama)
```bash
LOCAL_MODEL_URL=http://localhost:11434
LOCAL_MODEL_NAME=llama2
MODEL_PROVIDER=ollama
MODEL_NAME=llama2
```

## Usage Examples

### Using with GitHub Copilot (Primary Usage)

**MODEL_KEY is automatically available in GitHub Copilot!**

When using GitHub Copilot in this repository, the prompts defined in `node9.prompt.yml` are automatically available:

```bash
# Review code (MODEL_KEY automatically injected)
# Copilot reads node9.prompt.yml and uses the code_review prompt

# Generate code
# Copilot uses code_generate prompt with MODEL_KEY from secrets

# Get debugging help
# Copilot uses debug prompt with MODEL_KEY from secrets
```

The `node9.prompt.yml` file uses template variables that Copilot automatically fills:
- `{{MODEL_KEY}}` - Filled from Copilot environment secrets
- `{{MODEL_PROVIDER:openai}}` - Defaults to "openai" if not set
- `{{MODEL_NAME:gpt-4o}}` - Defaults to "gpt-4o" if not set

### Using with GitHub Copilot CLI (if available)

```bash
# MODEL_KEY is automatically available from Copilot environment

# Review code
gh copilot --prompt code_review < fs/appl/myapp.lua

# Generate code
gh copilot --prompt code_generate "Create a TCP server using libuv"

# Get debugging help
gh copilot --prompt debug < error.log
```

### Using with curl (Direct API calls)

```bash
# OpenAI API
curl https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
    "model": "gpt-4o",
    "messages": [
      {"role": "system", "content": "You are a Node9 expert..."},
      {"role": "user", "content": "Review this code: ..."}
    ]
  }'
```

### Using with Lua/LuaJIT

You could create a Node9 application that uses the FFI to call model APIs:

```lua
-- fs/appl/ai.lua
-- Node9 AI assistant application

usage = "ai [options] <prompt-type> <input>"

function init(argv)
    sys = import("sys")
    arg = import("arg")
    
    arg.setusage(usage)
    local opts = arg.getopt(argv, "m:model k:key")
    local argl = arg.strip()
    
    if #argl < 1 then
        arg.usage()
    end
    
    local prompt_type = argl[1]
    local input = table.concat(argl, " ", 2)
    
    -- Load configuration
    local model = opts.model or os.getenv("MODEL_NAME") or "gpt-4o"
    local key = opts.key or os.getenv("MODEL_KEY")
    
    if not key then
        sys.fprint(sys.fildes(2), "Error: MODEL_KEY not set\n")
        sys.exit("fail:nokey")
    end
    
    -- Call AI API (implementation would go here)
    -- This is a placeholder showing the structure
    
    sys.exit(nil)
end
```

## Integration with Development Workflow

### Pre-commit Hook
Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Review changed Lua files before commit

source .env 2>/dev/null || true

if [ -z "$MODEL_KEY" ]; then
    echo "MODEL_KEY not set, skipping AI review"
    exit 0
fi

changed_files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.lua$')

if [ -n "$changed_files" ]; then
    echo "Running AI code review..."
    for file in $changed_files; do
        echo "Reviewing $file..."
        # Your AI tool command here
        # e.g., cat "$file" | your-ai-tool --prompt code_review
    done
fi
```

### VS Code Integration
Add to `.vscode/settings.json`:

```json
{
  "ai.model": "${env:MODEL_NAME}",
  "ai.apiKey": "${env:MODEL_KEY}",
  "ai.prompts": {
    "node9.codeReview": "Review this Node9 code...",
    "node9.generate": "Generate Node9 code..."
  }
}
```

### Continuous Integration (GitHub Actions)

**MODEL_KEY is already configured in repository secrets!**

In your CI pipeline, access the MODEL_KEY from secrets:

```yaml
- name: AI Code Review
  env:
    MODEL_KEY: ${{ secrets.MODEL_KEY }}
    MODEL_PROVIDER: openai
    MODEL_NAME: gpt-4o
  run: |
    # Review changed files
    git diff origin/main...HEAD --name-only | grep '\.lua$' | while read file; do
      echo "Reviewing $file"
      # Your review command
    done
```

Example workflow using the configured secrets:

```yaml
name: AI-Powered Code Review

on:
  pull_request:
    branches: [ main ]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Review with AI
        env:
          MODEL_KEY: ${{ secrets.MODEL_KEY }}
        run: |
          echo "MODEL_KEY is available from repository secrets"
          # Use your AI tool with the prompts from node9.prompt.yml
```

## Security Best Practices

1. **GitHub Secrets Management (Primary)**
   - **MODEL_KEY is stored in GitHub Copilot environment secrets** ✓
   - **MODEL_KEY is stored in GitHub repository secrets** ✓
   - These secrets are never exposed in logs or pull requests
   - Only accessible to authorized GitHub Copilot users and Actions

2. **Never commit API keys**
   - `.env` is in `.gitignore` ✓
   - Use `.env.example` as a template only
   - Keys should only be in GitHub secrets or secure vaults

3. **Use environment-specific keys**
   - GitHub Copilot/Actions: Use repository secrets (already configured)
   - Local development: Use separate keys in `.env` file
   - Never use production keys in development

4. **Rotate keys regularly**
   - Update GitHub secrets when rotating keys
   - Set up key rotation schedule
   - Use provider's key management features
   - Monitor key usage

5. **Limit key permissions**
   - Use read-only keys where possible
   - Set spending limits on provider side
   - Enable usage alerts
   - Use different keys for different environments

## Troubleshooting

### Issue: "MODEL_KEY not set"

**For GitHub Copilot users:**
- MODEL_KEY should be automatically available from Copilot environment secrets
- No action needed - it's already configured!

**For GitHub Actions:**
- MODEL_KEY should be in repository secrets
- Verify workflow accesses it: `${{ secrets.MODEL_KEY }}`

**For local development:**
```bash
source .env
export MODEL_KEY=$OPENAI_API_KEY
```

### Issue: "Invalid API key"
**Solution:** 
- Verify key is correct in `.env`
- Check key hasn't expired
- Ensure key has necessary permissions

### Issue: "Rate limit exceeded"
**Solution:** 
- Reduce request frequency
- Check your provider's rate limits
- Consider upgrading your plan

### Issue: "Model not found"
**Solution:** 
- Verify model name is correct
- Check provider supports the model
- Update `MODEL_NAME` in `.env`

## Advanced Configuration

### Custom Prompts
Add your own prompts to `node9.prompt.yml`:

```yaml
prompts:
  my_custom:
    messages:
      - role: system
        content: |
          Your custom system prompt here
      - role: user
        content: '{{input}}'
```

### Multiple Providers
Switch between providers:

```bash
# Use OpenAI
export MODEL_KEY=$OPENAI_API_KEY
export MODEL_PROVIDER=openai
export MODEL_NAME=gpt-4o

# Switch to Anthropic
export MODEL_KEY=$ANTHROPIC_API_KEY
export MODEL_PROVIDER=anthropic
export MODEL_NAME=claude-3-5-sonnet-20241022

# Use local model
export MODEL_PROVIDER=ollama
export MODEL_NAME=codellama
unset MODEL_KEY  # Not needed for local
```

### Temperature Tuning
Adjust for different tasks:

```bash
# Code generation (more deterministic)
export MODEL_TEMPERATURE=0.2

# Documentation (balanced)
export MODEL_TEMPERATURE=0.7

# Creative tasks (more varied)
export MODEL_TEMPERATURE=0.9
```

## Contributing

To add new prompts or improve configurations:

1. Edit `node9.prompt.yml`
2. Test with various inputs
3. Document in this guide
4. Submit a pull request

## Resources

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Anthropic API Documentation](https://docs.anthropic.com/)
- [Node9 Documentation](doc/node9.md)
- [Node9 Wiki](https://github.com/9cog/n9n/wiki)

## License

This configuration system is part of Node9 and follows the same license.
