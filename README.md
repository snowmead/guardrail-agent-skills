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
bunx add-skill snowmead/guardrails
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
│   ├── agents/
│   │   └── prek-analyzer.md   # Project analyzer agent
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
├── scripts/                   # Validation scripts
└── template/                  # Template for new skills
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
- **Security-first defaults** - Always includes hooks for detecting secrets and protecting branches

## Usage Example

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

Every project gets these baseline security and quality hooks:

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
