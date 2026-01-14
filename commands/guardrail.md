---
description: Analyze current project and recommend prek pre-commit hooks
allowed-tools: [Task, Glob, Read, Grep, WebFetch, AskUserQuestion, Skill]
---

# Guardrail - Analyze and Recommend Hooks

**First**: Load the guardrail-commit skill using the Skill tool to get full context on prek configuration.

Analyze the current project and recommend appropriate prek pre-commit hooks.

## Steps

### 1. Launch Project Analyzer

Use the Task tool to launch the prek-analyzer agent:

```json
{
  "subagent_type": "general-purpose",
  "description": "Analyze project for prek hooks",
  "prompt": "Analyze this project to recommend prek pre-commit hooks. Check for:
    1. Languages: Look for package.json, Cargo.toml, pyproject.toml, go.mod, pom.xml, Gemfile
    2. Existing hooks: Check for .pre-commit-config.yaml, .husky/, lefthook.yml
    3. Project structure: Is this a monorepo?

    Return a structured report with:
    - detected_languages: [list]
    - existing_hooks: {tool: name, config_file: path} or null
    - is_monorepo: boolean
    - recommended_hooks: [list based on languages]"
}
```

### 2. Check for Existing Hook Tools

If existing hooks detected:
- If `.pre-commit-config.yaml` exists: "This project already has pre-commit hooks configured. Would you like to review them or update to latest versions?"
- If husky/lefthook detected: Ask if user wants to migrate to prek

### 3. Fetch Latest Documentation

Use WebFetch to get current hook versions:

```
WebFetch: https://prek.j178.dev/builtin/
Prompt: "List all available built-in hook IDs"

WebFetch: https://api.github.com/repos/astral-sh/ruff-pre-commit/releases/latest
Prompt: "Extract the tag_name for the latest version"
```

### 4. Generate Recommendations

Based on detected languages, build a recommended configuration:

**Always include:**
```yaml
repos:
  - repo: builtin
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
      - id: detect-private-key
      - id: check-merge-conflict
      - id: no-commit-to-branch
        args: [--branch, main, --branch, master]
```

**Add language-specific hooks based on detection.**

### 5. Present to User

Show the complete recommended configuration with explanations:

```
## Recommended prek Configuration

Based on my analysis, I recommend these pre-commit hooks for your {language} project:

### Security & Quality Hooks
- `trailing-whitespace` - Removes trailing whitespace
- `end-of-file-fixer` - Ensures files end with newline
- `detect-private-key` - Prevents committing secrets
- `check-merge-conflict` - Catches unresolved conflicts
- `no-commit-to-branch` - Protects main/master branches

### {Language} Hooks
- `{hook}` - {description}

### Proposed Configuration

```yaml
{full config}
```

Would you like me to:
1. Create this configuration and set up prek
2. Modify the configuration first
3. Skip for now
```

### 6. Wait for User Response

Use AskUserQuestion to get user's decision before proceeding.

If user approves, suggest running `/guardrail:setup` to complete the installation.
