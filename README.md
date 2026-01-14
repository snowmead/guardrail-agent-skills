# Guardrail Commit Skill

A Claude Code plugin for creating and managing [prek](https://github.com/j178/prek) pre-commit hooks to enforce code quality guardrails.

## What is prek?

prek is a faster, dependency-free reimplementation of the pre-commit framework written in Rust. It's a drop-in replacement that works with existing `.pre-commit-config.yaml` files.

**Why prek over pre-commit?**
- 4-10x faster installation and execution
- No Python runtime required (single binary)
- 50% less disk usage
- Full compatibility with existing configurations

## Features

- **Automatic language detection** - Detects Python, Rust, JavaScript/TypeScript, Go, and more
- **Dynamic version fetching** - Always uses latest hook versions from GitHub
- **Migration support** - Helps migrate from husky, lefthook, or pre-commit
- **Security-first defaults** - Always includes hooks for detecting secrets and protecting branches

## Installation

### As a Claude Code Plugin

```bash
# Install from local directory
claude plugins install ~/opt/guardrails

# Or add as a working directory
claude /add-dir ~/opt/guardrails
```

### prek Installation

The plugin will help you install prek, but you can also install it manually:

```bash
# Recommended: via uv
uv tool install prek

# Via pip
pip install prek

# Via shell script
curl -LsSf https://astral.sh/prek/install.sh | sh
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `/guardrail` | Analyze current project and recommend hooks |
| `/guardrail:setup` | Full setup wizard - install prek, create config, test hooks |
| `/guardrail:update` | Update existing hooks to latest versions |

### Invoking the Skill

The skill automatically triggers when you:
- Ask about "pre-commit", "commit hooks", "prek", or "guardrails"
- Work on a project without `.pre-commit-config.yaml`
- Encounter formatting or linting issues
- Create a new project or initialize a git repository

### Example Workflow

```
You: Help me set up this Python project with proper guardrails

Claude: I'll analyze your project and recommend appropriate pre-commit hooks...

[Detects Python, checks for existing hooks]

Claude: I recommend setting up prek with these hooks:
- Security: detect-private-key, no-commit-to-branch
- Quality: trailing-whitespace, end-of-file-fixer
- Python: ruff (linting + formatting)

Would you like me to create this configuration?

You: Yes

Claude: [Creates .pre-commit-config.yaml, runs prek install]
```

## Default Hooks

Every project gets these baseline hooks:

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

## Language-Specific Hooks

The skill detects your project's languages and recommends appropriate hooks:

| Language | Hooks |
|----------|-------|
| Python | ruff (linting + formatting) |
| Rust | cargo-check, cargo-clippy, cargo-fmt (built-in) |
| JavaScript/TypeScript | eslint, prettier |
| Go | golangci-lint |

## Behavior

- **Recommend, don't auto-add** - Always asks before creating configuration
- **Ask before migration** - Checks with you before replacing existing hook tools
- **Fetch latest versions** - Never uses hardcoded versions, always fetches current releases

## Documentation Links

- [prek Documentation](https://prek.j178.dev/)
- [prek GitHub](https://github.com/j178/prek)
- [Built-in Hooks](https://prek.j178.dev/builtin/)
- [Workspace Mode](https://prek.j178.dev/workspace/)

## License

MIT
