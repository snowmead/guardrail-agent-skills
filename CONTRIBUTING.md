# Contributing to Guardrails Marketplace

Thank you for your interest in contributing to this Claude Code plugin marketplace!

## Development Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/snowmead/guardrails.git
   cd guardrails
   ```

2. Install uv and prek:

   ```bash
   # Install uv (Rust-based Python package manager)
   curl -LsSf https://astral.sh/uv/install.sh | sh

   # Install prek (Rust-based pre-commit)
   uv tool install prek
   ```

3. Install the pre-commit hooks:

   ```bash
   prek install
   ```

4. Test the plugin locally in Claude Code:

   ```bash
   claude --plugin-dir .
   ```

## Project Structure

```
guardrails/
├── .claude-plugin/
│   └── marketplace.json      # Plugin registry - defines available plugins and their skills
├── skills/
│   └── [skill-name]/
│       ├── SKILL.md          # Complete skill definition with commands
│       └── LICENSE.txt       # License file
├── agents/
│   └── [agent-name].md       # Shared agents (optional)
├── template/
│   └── SKILL.md              # Template for creating new skills
└── scripts/                  # Validation scripts
```

## Creating a New Guardrail Skill

### Step 1: Create Skill Directory

```bash
mkdir -p skills/guardrail-[your-skill-name]
```

### Step 2: Copy Template

```bash
cp template/SKILL.md skills/guardrail-[your-skill-name]/SKILL.md
```

### Step 3: Edit SKILL.md

Fill in the template with your skill's functionality:

```yaml
---
name: guardrail-[your-skill-name]
description: |
  [Brief description of what this guardrail does]

  **Trigger this skill when:**
  - [Trigger condition 1]
  - [Trigger condition 2]
license: "MIT. See LICENSE.txt for complete terms"
---

# Guardrail [Name]

[Your skill content here]

## Commands

### /guardrail:[command-name]

[Command implementation]
```

### Step 4: Add License

```bash
cp skills/guardrail-commit-hooks/LICENSE.txt skills/guardrail-[your-skill-name]/
```

### Step 5: Register in Marketplace

Edit `.claude-plugin/marketplace.json` to add your skill:

```json
{
  "plugins": [
    {
      "name": "commit-guardrails",
      "skills": ["./skills/guardrail-commit-hooks"]
    },
    {
      "name": "[your-plugin-name]",
      "description": "[Plugin description]",
      "source": "./",
      "strict": false,
      "skills": ["./skills/guardrail-[your-skill-name]"]
    }
  ]
}
```

Or add to an existing plugin's skills array if it fits an existing category.

## Skill Organization

Skills can be grouped into plugins by purpose:

| Plugin | Purpose |
|--------|---------|
| `commit-guardrails` | Pre-commit hooks and code quality |
| `security-guardrails` | Security scanning and vulnerability detection |
| `compliance-guardrails` | Compliance checks and regulatory requirements |

## Validation Requirements

All contributions must pass these validations before merging:

### Skill Structure

- Each skill must have a `SKILL.md` file with valid YAML frontmatter
- Each skill must include a `LICENSE.txt` file
- Skills must be registered in `marketplace.json`

### Frontmatter Requirements

**Skills** (`skills/*/SKILL.md`):

```yaml
---
name: guardrail-[name]
description: |
  Description including trigger conditions.
license: "MIT. See LICENSE.txt for complete terms"
---
```

**Agents** (`agents/*.md`) (if creating shared agents):

```yaml
---
name: agent-name
description: Description of the agent's purpose
model: haiku
tools: [Glob, Read, Grep]
---
```

### Code Quality

- No trailing whitespace or missing final newlines
- No merge conflict markers
- No private keys or secrets
- Valid JSON/YAML syntax

## Pre-commit Hooks

This project uses prek pre-commit hooks:

| Hook | Purpose |
|------|---------|
| `trailing-whitespace` | Remove trailing whitespace |
| `end-of-file-fixer` | Ensure files end with newline |
| `check-yaml` | Validate YAML syntax |
| `check-json` | Validate JSON syntax |
| `detect-private-key` | Prevent committing secrets |
| `check-merge-conflict` | Catch merge conflicts |
| `no-commit-to-branch` | Protect main/master branches |

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
   # Test your skill's commands
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

- `feat:` - New feature or skill
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `chore:` - Maintenance tasks
- `refactor:` - Code refactoring

## Release Process

Releases are automated through GitHub Actions:

1. Update `marketplace.json` version:

   ```bash
   # Edit .claude-plugin/marketplace.json and update metadata.version
   ```

2. Commit and tag:

   ```bash
   git add .claude-plugin/marketplace.json
   git commit -m "chore: bump version to 1.2.0"
   git tag v1.2.0
   git push origin main --tags
   ```

## Questions?

If you have questions, feel free to open an issue on GitHub.
