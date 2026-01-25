# GitHub Configuration for Node9

This directory contains GitHub-specific configuration for the Node9 repository.

## Secrets Configuration

### Repository Secrets

The following secrets are configured for this repository:

- **`MOD_TOKEN`**: API key for AI model access in GitHub Actions workflows
  - Used by GitHub Actions workflows for automated tasks
  - Already configured - no setup needed!

### GitHub Copilot Environment Secrets

GitHub Copilot has access to environment secrets including:

- **`MODEL_TOKEN`**: API key for AI model access in GitHub Copilot
  - Automatically available when using Copilot in this repository
  - Copilot reads `node9.prompt.yml` to use specialized prompts
  - No manual configuration needed for Copilot users

## Using Secrets in Workflows

Access secrets in GitHub Actions workflows:

```yaml
env:
  MOD_TOKEN: ${{ secrets.MOD_TOKEN }}
```

Example workflow: `.github/workflows/ai-review.yml`

## Using Secrets with GitHub Copilot

GitHub Copilot automatically injects the `MODEL_TOKEN` when using prompts from `node9.prompt.yml`:

- The prompt file uses template variables that fall back in order:
  - `{{MODEL_TOKEN}}` - For GitHub Copilot environment
  - `{{MOD_TOKEN}}` - For GitHub Actions
  - `{{MODEL_KEY}}` - For local development
- Available prompts: code_review, code_generate, debug, build, library, etc.

## Agents

Custom agents are defined in `.github/agents/`:

- **`node9.agent.md`**: Specialized Node9 development orchestration agent

## Workflows

GitHub Actions workflows in `.github/workflows/`:

- **`ai-review.yml`**: AI-powered code review using MOD_TOKEN
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

## Secret Names Reference

| Context | Secret Name | Purpose |
|---------|-------------|---------|
| GitHub Copilot | `MODEL_TOKEN` | AI API key for Copilot environment |
| GitHub Actions | `MOD_TOKEN` | AI API key for Actions workflows |
| Local Dev | `MODEL_KEY` or `MODEL_TOKEN` | AI API key in .env file |

## Adding New Secrets

To add a new secret:

1. Go to repository Settings
2. Select "Secrets and variables" → "Actions"
3. Click "New repository secret"
4. Add name and value
5. Secret becomes available to workflows as `${{ secrets.SECRET_NAME }}`
