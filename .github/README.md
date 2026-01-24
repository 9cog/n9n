# GitHub Configuration for Node9

This directory contains GitHub-specific configuration for the Node9 repository.

## Secrets Configuration

### Repository Secrets

The following secrets are configured for this repository:

- **`MODEL_KEY`**: API key for AI model access (OpenAI, Anthropic, etc.)
  - Used by GitHub Copilot for code assistance
  - Used by GitHub Actions workflows for automated tasks
  - Already configured - no setup needed!

### GitHub Copilot Environment Secrets

GitHub Copilot has access to environment secrets including:

- **`MODEL_KEY`**: Automatically available when using Copilot in this repository
- Copilot reads `node9.prompt.yml` to use specialized prompts
- No manual configuration needed for Copilot users

## Using Secrets in Workflows

Access secrets in GitHub Actions workflows:

```yaml
env:
  MODEL_KEY: ${{ secrets.MODEL_KEY }}
```

Example workflow: `.github/workflows/ai-review.yml`

## Using Secrets with GitHub Copilot

GitHub Copilot automatically injects the `MODEL_KEY` when using prompts from `node9.prompt.yml`:

- The prompt file uses `{{MODEL_KEY}}` template variable
- Copilot fills this from environment secrets
- Available prompts: code_review, code_generate, debug, build, library, etc.

## Agents

Custom agents are defined in `.github/agents/`:

- **`node9.agent.md`**: Specialized Node9 development orchestration agent

## Workflows

GitHub Actions workflows in `.github/workflows/`:

- **`ai-review.yml`**: AI-powered code review using MODEL_KEY
- **`summary.yml`**: Other workflow tasks

## Security

- Secrets are never exposed in logs
- Only authorized users and workflows can access secrets
- Secrets are encrypted at rest
- Update secrets via repository settings: Settings → Secrets and variables → Actions

## Documentation

For more details on AI model configuration, see:
- [AI Model Configuration Guide](../doc/AI_MODEL_CONFIGURATION.md)
- [node9.prompt.yml](../node9.prompt.yml) - Prompt definitions

## Adding New Secrets

To add a new secret:

1. Go to repository Settings
2. Select "Secrets and variables" → "Actions"
3. Click "New repository secret"
4. Add name and value
5. Secret becomes available to workflows as `${{ secrets.SECRET_NAME }}`
