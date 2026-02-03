# AGENTS.md

This file provides guidance to AI coding agents working on this repository.

## Repository Overview

A skill for Claude Code providing pre-commit hook setup and code quality guardrails using prek. The skill helps analyze projects, recommend appropriate hooks, and configure them automatically.

## Skill Structure

```
skills/
  guardrail-commit-hooks/
    SKILL.md              # Main skill definition
    LICENSE.txt           # License file
    languages/            # Language-specific configurations
      index.md            # Language registry
      python.md           # Python hooks (ruff)
      rust.md             # Rust hooks (cargo-check, clippy, fmt)
      javascript.md       # JavaScript/TypeScript hooks (biome)
      go.md               # Go hooks (golangci-lint, gofumpt)
```

## Updating the Skill

When updating this skill:

1. **Add new language support** - Create `languages/{language}.md` and add to `index.md`
2. **Update hook versions** - Fetch latest from GitHub releases, don't hardcode versions
3. **Keep SKILL.md under 500 lines** - Put detailed content in language files
4. **Test locally** before committing changes

## Testing Changes

Test the skill locally:

```bash
cp -r skills/guardrail-commit-hooks ~/.claude/skills/
```

Then start a Claude Code session and verify:
1. Skill is recognized when mentioning "pre-commit", "hooks", "prek", "guardrails"
2. Project analysis correctly detects languages
3. Hook configurations are generated correctly
