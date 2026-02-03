# Guardrails - Claude Instructions

## Purpose

This is a skill for code quality guardrails. It helps set up pre-commit hooks using prek for any project.

## Core Behavior Rules

### 1. Recommend, Don't Auto-Add

**Never automatically create `.pre-commit-config.yaml`.**

Always:
1. Analyze the project first
2. Show the proposed configuration
3. Explain what hooks will do
4. Wait for explicit user approval

### 2. Ask Before Migration

If a project uses another hook tool (husky, lefthook, pre-commit):
1. Inform the user you detected an existing tool
2. Ask if they want to migrate to prek
3. Only proceed with migration after approval

### 3. Fetch Latest Documentation

**Do not use hardcoded version numbers.**

Before creating configurations, fetch current documentation:

```
WebFetch URLs:
- https://prek.j178.dev/quickstart/
- https://prek.j178.dev/builtin/
- https://api.github.com/repos/astral-sh/ruff-pre-commit/releases/latest
```

### 4. Detect Languages First

Before recommending hooks, detect project languages by checking for:
- `package.json` -> JavaScript/TypeScript
- `Cargo.toml` -> Rust
- `pyproject.toml` or `setup.py` -> Python
- `go.mod` -> Go
- `pom.xml` or `build.gradle` -> Java
- `Gemfile` -> Ruby

### 5. Always Include Security Hooks

Every configuration should include these baseline hooks:
- `detect-private-key` - Prevents committing secrets
- `check-merge-conflict` - Catches unresolved conflicts
- `no-commit-to-branch` - Protects main/master branches

## When to Proactively Recommend prek

Suggest adding hooks when you observe:

1. **No hook configuration** - Project has no `.pre-commit-config.yaml`
2. **Security risks** - Hardcoded secrets, API keys, or credentials in code
3. **Formatting issues** - Mixed indentation, trailing whitespace
4. **Missing linting** - No linter configured for the project's language
5. **Merge conflicts** - Files with unresolved conflict markers

## Skill Structure

```
skills/
  guardrail-commit-hooks/
    SKILL.md              # Main skill definition
    LICENSE.txt           # License file
    languages/            # Language-specific hook configs
      index.md            # Language registry
      python.md
      rust.md
      javascript.md
      go.md
```

## Workflow Example

```
User: "Help me set up this Python project"

1. Analyze project to detect languages (package.json, Cargo.toml, pyproject.toml, etc.)
2. Check for existing .pre-commit-config.yaml
3. Check for other hook tools (husky, lefthook)
4. If no hooks configured, say:
   "I notice this project doesn't have pre-commit hooks configured.
   Would you like me to set up prek with Python-specific hooks (ruff for
   linting/formatting)? This will catch issues before they're committed."
5. Wait for user response
6. If approved, fetch latest versions and create config
7. Run `prek install` and `prek run --all-files`
```

## Language-Specific Hooks Reference

### Python
- `ruff` - Fast linter and formatter (replaces flake8, black, isort)
- Fetch version: `https://api.github.com/repos/astral-sh/ruff-pre-commit/releases/latest`

### Rust
- Use built-in hooks: `cargo-check`, `cargo-clippy`, `cargo-fmt`
- No external repos needed

### JavaScript/TypeScript
- `biome` - Linting and formatting (replaces ESLint + Prettier)
- Fetch from biomejs/pre-commit repo

### Go
- `golangci-lint` - Comprehensive linter
- `gofumpt` - Stricter formatting
- Fetch version from GitHub releases

## Handling Hook Failures

When hooks fail during commit:
1. Commit is blocked (expected behavior)
2. Help user understand the error
3. Suggest fixes for the specific issue
4. Re-run `prek run` to verify fixes
5. Retry commit

## Updating Hooks

To update hook versions:
```bash
prek autoupdate
```
