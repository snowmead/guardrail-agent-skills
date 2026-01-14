---
description: Full prek setup wizard - install prek, create configuration, and run hooks
allowed-tools: [Task, Glob, Read, Write, Bash, WebFetch, AskUserQuestion, Skill]
---

# Guardrail Setup - Full Installation Wizard

**First**: Load the guardrail-commit skill using the Skill tool to get full context on prek configuration.

Complete setup wizard for prek pre-commit hooks.

## Steps

### 1. Check prek Installation

```bash
prek --version
```

If not installed, ask user how they'd like to install:

```json
{
  "questions": [{
    "question": "prek is not installed. How would you like to install it?",
    "header": "Install",
    "multiSelect": false,
    "options": [
      {"label": "uv tool install (Recommended)", "description": "Fast, isolated installation via uv"},
      {"label": "pip install", "description": "Install via pip"},
      {"label": "Shell script", "description": "curl installer script"}
    ]
  }]
}
```

Then run the appropriate install command:
- uv: `uv tool install prek`
- pip: `pip install prek`
- shell: `curl -LsSf https://astral.sh/prek/install.sh | sh`

### 2. Analyze Project

Run `/guardrail` analysis or use prek-analyzer agent to detect:
- Project languages
- Existing hook configuration
- Monorepo structure

### 3. Check for Existing Configuration

```bash
ls -la .pre-commit-config.yaml 2>/dev/null
```

If exists:
- Ask if user wants to keep, update, or replace it
- If keeping: skip to step 5
- If updating: proceed to step 4

### 4. Create Configuration

#### Fetch Latest Versions

Use WebFetch to get current versions:

```
WebFetch: https://prek.j178.dev/builtin/
Prompt: "List all built-in hook IDs available"

WebFetch: https://api.github.com/repos/astral-sh/ruff-pre-commit/releases/latest
Prompt: "Get the latest release tag_name"
```

#### Generate Config

Build `.pre-commit-config.yaml` based on detected languages:

```yaml
# Base config (always included)
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

# Add language-specific hooks based on detection
```

#### Show to User

Present the configuration and ask for confirmation:

```
## Proposed Configuration

{show yaml}

This will:
- Check for trailing whitespace and fix line endings
- Validate YAML and JSON files
- Prevent committing private keys
- Block direct commits to main/master
- {language-specific descriptions}

Create this configuration?
```

#### Write File

After approval, use Write tool to create `.pre-commit-config.yaml`

### 5. Install Git Hooks

```bash
prek install
```

This installs the hooks into `.git/hooks/pre-commit`

### 6. Run Initial Check

```bash
prek run --all-files
```

This runs all hooks on every file to catch existing issues.

### 7. Handle Results

**If all hooks pass:**
```
Setup complete! Pre-commit hooks are now active.

On every commit, prek will automatically:
{list what each hook does}

To update hooks later: /guardrail:update
To skip hooks once: git commit --no-verify
```

**If hooks fail:**
```
Some hooks found issues in existing files:

{show failures}

These need to be fixed before commits will succeed.
Would you like me to help fix these issues?
```

### 8. Offer Next Steps

```
## Next Steps

1. **Fix any issues** found by the initial hook run
2. **Commit the configuration**: `git add .pre-commit-config.yaml && git commit -m "Add prek pre-commit hooks"`
3. **Share with team**: Other developers can run `prek install` after cloning

Your code quality guardrails are now active!
```
