# Guardrails Plugin Marketplace

A Claude Code plugin marketplace for code quality guardrails. Add pre-commit hooks, security scanning, compliance checks, and more to your projects.

## Available Plugins

### commit-guardrails

Pre-commit hooks and code quality enforcement using [prek](https://github.com/j178/prek).

**Skills included:**
- `guardrail-commit-hooks-skill` - Create and manage prek pre-commit hooks

**Commands:**
| Command | Description |
|---------|-------------|
| `/guardrail` | Analyze project and recommend hooks |
| `/guardrail:setup` | Full setup wizard - install prek, create config, test hooks |
| `/guardrail:update` | Update existing hooks to latest versions |

## Installation

```bash
bunx skills add snowmead/guardrail-agent-skills
```

**Install location:** `~/.claude/skills/commit-guardrails/`

## Project Structure

```
guardrails/
├── .claude-plugin/
│   └── marketplace.json       # Plugin registry
├── claude-code/               # Plugin source
│   ├── .claude-plugin/
│   │   └── plugin.json        # Plugin metadata
│   ├── commands/
│   │   ├── guardrail.md
│   │   ├── guardrail-setup.md
│   │   └── guardrail-update.md
│   └── skills/
│       └── guardrail-commit-hooks-skill/
│           ├── SKILL.md
│           ├── LICENSE.txt
│           └── languages/     # Language configs
├── skills/                    # Dual discovery path
│   └── commit-guardrails/
│       └── SKILL.md
└── scripts/                   # Validation scripts
```

## What is prek?

prek is a faster, dependency-free reimplementation of the pre-commit framework written in Rust.

**Why prek over pre-commit?**
- 4-10x faster installation and execution
- No Python runtime required (single binary)
- 50% less disk usage
- Full compatibility with existing configurations

## Features

- **Automatic language detection** - Detects Python, Rust, JavaScript/TypeScript, Go, and more
- **Dynamic version fetching** - Always uses latest hook versions from GitHub
- **Migration support** - Helps migrate from husky, lefthook, or pre-commit
- **Security-first defaults** - Always includes hooks for detecting secrets, with optional branch protection

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

## Adding New Guardrail Skills

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add new guardrail skills to the marketplace.

Use the template at `template/SKILL.md` as a starting point.

## Documentation Links

- [prek Documentation](https://prek.j178.dev/)
- [prek GitHub](https://github.com/j178/prek)
- [Built-in Hooks](https://prek.j178.dev/builtin/)
- [Workspace Mode](https://prek.j178.dev/workspace/)

## License

MIT
