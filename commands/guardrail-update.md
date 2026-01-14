---
description: Update existing prek hooks to latest versions
allowed-tools: [Read, Edit, Bash, WebFetch, AskUserQuestion, Skill]
---

# Guardrail Update - Update Hook Versions

**First**: Load the guardrail-commit skill using the Skill tool for context.

Update existing prek pre-commit hooks to their latest versions.

## Steps

### 1. Check for Existing Configuration

```bash
ls -la .pre-commit-config.yaml 2>/dev/null
```

If no configuration exists:
```
No .pre-commit-config.yaml found. Run /guardrail:setup to create one first.
```

### 2. Read Current Configuration

Use Read tool to examine `.pre-commit-config.yaml`

Extract:
- Current repos and their versions
- Which hooks are configured

### 3. Fetch Latest Versions

For each external repo in the config, fetch latest version:

**Ruff:**
```
WebFetch: https://api.github.com/repos/astral-sh/ruff-pre-commit/releases/latest
Prompt: "Extract the tag_name"
```

**ESLint:**
```
WebFetch: https://api.github.com/repos/pre-commit/mirrors-eslint/tags
Prompt: "Get the first (latest) tag name"
```

**Prettier:**
```
WebFetch: https://api.github.com/repos/pre-commit/mirrors-prettier/tags
Prompt: "Get the first (latest) tag name"
```

**golangci-lint:**
```
WebFetch: https://api.github.com/repos/golangci/golangci-lint/releases/latest
Prompt: "Extract the tag_name"
```

### 4. Compare Versions

Show user what will be updated:

```
## Hook Version Updates Available

| Hook | Current | Latest | Status |
|------|---------|--------|--------|
| ruff-pre-commit | v0.8.0 | v0.8.6 | Update available |
| mirrors-eslint | v9.15.0 | v9.17.0 | Update available |
| builtin | - | - | Always current |

Would you like to update these hooks?
```

### 5. Ask for Confirmation

Use AskUserQuestion:

```json
{
  "questions": [{
    "question": "How would you like to update the hooks?",
    "header": "Update",
    "multiSelect": false,
    "options": [
      {"label": "Update all", "description": "Update all hooks to latest versions"},
      {"label": "Use prek autoupdate", "description": "Let prek handle the updates automatically"},
      {"label": "Select specific", "description": "Choose which hooks to update"},
      {"label": "Cancel", "description": "Don't update anything"}
    ]
  }]
}
```

### 6. Perform Updates

**Option A: Manual updates via Edit tool**

For each hook to update, use Edit:
```
old_string: "rev: v0.8.0"
new_string: "rev: v0.8.6"
```

**Option B: Use prek autoupdate**

```bash
prek autoupdate
```

### 7. Test Updated Hooks

```bash
prek run --all-files
```

### 8. Show Results

**If successful:**
```
## Updates Complete

Updated hooks:
- ruff-pre-commit: v0.8.0 → v0.8.6
- mirrors-eslint: v9.15.0 → v9.17.0

All hooks passed on existing files.

Don't forget to commit the updated configuration:
git add .pre-commit-config.yaml && git commit -m "Update pre-commit hooks"
```

**If hooks fail after update:**
```
## Updates Applied, But Issues Found

The updated hooks found new issues in your code:

{show failures}

This is expected - newer versions may have stricter rules.
Would you like me to help fix these issues?
```

### 9. Optional: Add New Hooks

After updating, check if project has new languages that need hooks:

```
I also noticed you have {language} files that don't have hooks configured.
Would you like to add {recommended hooks} for {language}?
```
