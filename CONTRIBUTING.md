# Contributing to Guardrail Commit Skill

Thank you for your interest in contributing to this Claude Code plugin!

## Development Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/snowmead/guardrail-commit-skill.git
   cd guardrail-commit-skill
   ```

2. Install prek for pre-commit hooks:

   ```bash
   # Install prek (recommended via uv)
   uv tool install prek

   # Or via pip
   pip install prek
   ```

3. Install the pre-commit hooks:

   ```bash
   prek install
   ```

4. Test the plugin locally in Claude Code:

   ```bash
   claude --plugin-dir .
   ```

## Validation Requirements

All contributions must pass these validations before merging:

### Plugin Structure

- `.claude-plugin/plugin.json` must have valid schema with required fields (`name`, `version`, `description`)
- Commands, skills, and agents must have proper YAML frontmatter
- All JSON/YAML files must have valid syntax

### Frontmatter Requirements

**Skills** (`skills/*.md`):

```yaml
---
name: skill-name
description: |
  Description of what this skill does and when it triggers.
---
```

**Commands** (`commands/*.md`):

```yaml
---
description: Brief description of the command
allowed-tools: [Task, Glob, Read, Write, Bash]
---
```

**Agents** (`agents/*.md`):

```yaml
---
name: agent-name
description: Description of the agent's purpose
---
```

### Code Quality

- No trailing whitespace or missing final newlines
- No merge conflict markers
- No private keys or secrets
- Files under 1MB

## Pre-commit Hooks

This project uses prek pre-commit hooks to ensure code quality:

| Hook | Purpose |
|------|---------|
| `trailing-whitespace` | Remove trailing whitespace |
| `end-of-file-fixer` | Ensure files end with newline |
| `check-yaml` | Validate YAML syntax |
| `check-json` | Validate JSON syntax |
| `detect-private-key` | Prevent committing secrets |
| `check-merge-conflict` | Catch merge conflicts |
| `no-commit-to-branch` | Protect main/master branches |
| `validate-plugin-structure` | Check plugin files |
| `check-frontmatter` | Validate markdown frontmatter |

Run all hooks manually:

```bash
prek run --all-files
```

## Making Changes

1. Create a feature branch:

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following existing patterns

3. Validate your changes:

   ```bash
   prek run --all-files
   ```

4. Test with Claude Code:

   ```bash
   claude --plugin-dir .
   # Then try /guardrail or /guardrail:setup
   ```

5. Commit and push:

   ```bash
   git add .
   git commit -m "feat: add your feature description"
   git push origin feature/your-feature-name
   ```

6. Create a pull request

## Commit Message Format

Follow conventional commits:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `chore:` - Maintenance tasks
- `refactor:` - Code refactoring

## Release Process

Releases are automated through GitHub Actions:

1. Update `plugin.json` version:

   ```bash
   # Edit .claude-plugin/plugin.json and update "version"
   ```

2. Commit and tag:

   ```bash
   git add .claude-plugin/plugin.json
   git commit -m "chore: bump version to 1.2.0"
   git tag v1.2.0
   git push origin main --tags
   ```

3. GitHub Actions will automatically:
   - Validate the plugin structure
   - Check version consistency
   - Create a GitHub release
   - Generate changelog
   - Create distribution archive

## Questions?

If you have questions, feel free to open an issue on GitHub.
