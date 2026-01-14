---
name: guardrail-commit
description: |
  Use this skill when users need help with git pre-commit hooks, code quality guardrails, or prek configuration.

  **Trigger this skill when:**
  - User mentions "pre-commit", "commit hooks", "prek", or "guardrails"
  - Project has no .pre-commit-config.yaml and user is working on code
  - User encounters formatting/linting issues that hooks could prevent
  - User asks about code quality automation
  - User creates a new project or initializes a git repository
  - User has existing hooks (husky, pre-commit, lefthook) and asks about alternatives
---

# Guardrail Commit Skill

This skill helps you create and manage prek pre-commit hooks for code quality guardrails.

## What is prek?

prek is a faster, dependency-free reimplementation of the pre-commit framework written in Rust. It's a drop-in replacement that works with existing `.pre-commit-config.yaml` files.

**Key benefits:**
- 4-10x faster than pre-commit
- No Python runtime required (single binary)
- 50% less disk usage
- Compatible with existing pre-commit configurations

## Always Fetch Current Documentation

**IMPORTANT**: Do not use hardcoded version numbers. Always fetch the latest documentation to get current hook versions.

### Documentation URLs to Fetch

Before creating or updating configurations, use WebFetch on these URLs:

1. **Quickstart & Installation**: `https://prek.j178.dev/quickstart/`
2. **Built-in Hooks Reference**: `https://prek.j178.dev/builtin/`
3. **Configuration Format**: `https://prek.j178.dev/config/`
4. **Workspace Mode (monorepos)**: `https://prek.j178.dev/workspace/`

### For Latest Hook Versions

Fetch GitHub releases to get current versions:
- **Ruff**: `https://api.github.com/repos/astral-sh/ruff-pre-commit/releases/latest`
- **ESLint**: `https://api.github.com/repos/pre-commit/mirrors-eslint/tags`
- **Prettier**: `https://api.github.com/repos/pre-commit/mirrors-prettier/tags`

## Installation Commands

```bash
# Install prek (recommended via uv)
uv tool install prek

# Alternative: via pip
pip install prek

# Alternative: shell script
curl -LsSf https://astral.sh/prek/install.sh | sh
```

## Project Setup Workflow

### Step 1: Analyze Project

Use the prek-analyzer agent to detect:
- Project languages (from package.json, Cargo.toml, pyproject.toml, go.mod, etc.)
- Existing hook tools (husky, lefthook, pre-commit)
- Existing `.pre-commit-config.yaml`

### Step 2: Recommend Configuration

Based on detected languages, recommend appropriate hooks:

**Always include (security & quality):**
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

**For Python projects** - add ruff (fetch latest version):
```yaml
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: <FETCH_LATEST_VERSION>
    hooks:
      - id: ruff
      - id: ruff-format
```

**For Rust projects** - use built-in hooks:
```yaml
  - repo: builtin
    hooks:
      - id: cargo-check
      - id: cargo-clippy
      - id: cargo-fmt
```

**For JavaScript/TypeScript** - add eslint/prettier (fetch latest versions):
```yaml
  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: <FETCH_LATEST_VERSION>
    hooks:
      - id: eslint
        files: \.[jt]sx?$
```

### Step 3: Get User Approval

**Never auto-create configuration.** Always:
1. Show the proposed configuration
2. Explain what each hook does
3. Ask for user confirmation before creating files

### Step 4: Install and Run

After user approves:
```bash
# Create .pre-commit-config.yaml
# Then install hooks
prek install

# Test on all files
prek run --all-files
```

## Handling Existing Hook Tools

If project already uses another hook tool:

1. **Detect** - Check for:
   - `package.json` with husky config
   - `.husky/` directory
   - `lefthook.yml` or `.lefthook.yml`
   - Existing `.pre-commit-config.yaml` (already using pre-commit)

2. **Ask before migrating** - Use AskUserQuestion:
   - "I noticed this project uses {tool}. Would you like to migrate to prek?"
   - Explain benefits of prek vs current tool

3. **For existing pre-commit configs** - prek is drop-in compatible:
   - Just run `prek install -f` to switch from pre-commit to prek
   - No configuration changes needed

## Available Commands

- `/guardrail` - Analyze project and recommend hooks
- `/guardrail:setup` - Full setup wizard (install prek, create config, run hooks)
- `/guardrail:update` - Update existing hooks to latest versions

## Error Handling

If hooks fail on commit:
1. The commit is blocked (this is expected behavior)
2. Read the error output to identify which hook failed
3. Fix the issues (formatting, linting, etc.)
4. Re-attempt the commit

To temporarily skip hooks (not recommended):
```bash
git commit --no-verify -m "message"
```

## Monorepo Support

For monorepos, prek supports workspace mode:
- Create `.pre-commit-config.yaml` files in subdirectories
- Use `orphan: true` to prevent parent config processing
- Target specific projects with `prek run <project>/`

Fetch workspace documentation: `https://prek.j178.dev/workspace/`
