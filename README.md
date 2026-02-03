# Guardrails

Code quality guardrails skill for Claude Code. Add pre-commit hooks, security scanning, and more to your projects using [prek](https://github.com/j178/prek).

## Installation

### Claude Code (CLI)

```bash
npx skills add snowmead/guardrails
```

### Manual Installation

```bash
cp -r skills/guardrail-commit-hooks ~/.claude/skills/
```

### Claude.ai

Add the skill to project knowledge or paste the contents of `skills/guardrail-commit-hooks/SKILL.md` into your conversation.

## Features

- **Automatic language detection** - Detects Python, Rust, JavaScript/TypeScript, Go, and more
- **Dynamic version fetching** - Always uses latest hook versions from GitHub
- **Migration support** - Helps migrate from husky, lefthook, or pre-commit
- **Security-first defaults** - Always includes hooks for detecting secrets, with optional branch protection

## What is prek?

prek is a faster, dependency-free reimplementation of the pre-commit framework written in Rust.

**Why prek over pre-commit?**
- 4-10x faster installation and execution
- No Python runtime required (single binary)
- 50% less disk usage
- Full compatibility with existing configurations

## Usage Example

```
You: Help me set up this Python project with proper guardrails

Claude: I'll analyze your project and recommend appropriate pre-commit hooks...

[Detects Python, checks for existing hooks, scans for file types]

Claude: I recommend setting up prek with these hooks:
- Universal: trailing-whitespace, end-of-file-fixer, detect-private-key
- File validators: check-yaml (found 3 .yml files), check-toml (found pyproject.toml)
- Security: gitleaks
- Python: ruff (linting + formatting)

Do you want to prevent direct commits to main/master branches?

You: Yes

Claude: [Creates .pre-commit-config.yaml, runs prek install]
```

## Hook Selection

Hooks are selected based on project context, not blindly applied.

### Always Included

Universal hooks that benefit every project:

```yaml
repos:
  - repo: builtin
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: detect-private-key
      - id: check-merge-conflict
      - id: check-added-large-files
```

### Conditional (based on files detected)

| Hook | Included If |
|------|-------------|
| `check-yaml` | Project has `.yml` or `.yaml` files |
| `check-json` | Project has `.json` files |
| `check-toml` | Project has `.toml` files |

### User Confirmation Required

| Hook | Behavior |
|------|----------|
| `no-commit-to-branch` | Asked if team uses feature branches |

### Security (always recommended)

```yaml
  - repo: https://github.com/gitleaks/gitleaks
    hooks:
      - id: gitleaks
```

## Language-Specific Hooks

All recommended tools are Rust-based for maximum performance.

| Language | Hooks | Built With |
|----------|-------|------------|
| Python | ruff (linting + formatting) | Rust |
| Rust | cargo-check, cargo-clippy, cargo-fmt | Rust |
| JavaScript/TypeScript | biome (linting + formatting) | Rust |
| Go | golangci-lint, gofumpt | Go (native) |

## Included Files

- `skills/guardrail-commit-hooks/SKILL.md` - Main skill definition
- `skills/guardrail-commit-hooks/languages/` - Language-specific hook configurations
  - `index.md` - Language registry
  - `python.md`, `rust.md`, `javascript.md`, `go.md` - Per-language configs

## Documentation Links

- [prek Documentation](https://prek.j178.dev/)
- [prek GitHub](https://github.com/j178/prek)
- [Built-in Hooks](https://prek.j178.dev/builtin/)
- [Workspace Mode](https://prek.j178.dev/workspace/)

## License

MIT
