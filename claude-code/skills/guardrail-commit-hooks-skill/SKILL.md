---
name: guardrail-commit-hooks-skill
description: |
  Use this skill when users need help with git pre-commit hooks, code quality guardrails, or prek configuration.

  **Trigger this skill when:**
  - User mentions "pre-commit", "commit hooks", "prek", or "guardrails"
  - Project has no .pre-commit-config.yaml and user is working on code
  - User encounters formatting/linting issues that hooks could prevent
  - User asks about code quality automation
  - User creates a new project or initializes a git repository
  - User has existing hooks (husky, pre-commit, lefthook) and asks about alternatives
license: "MIT. See LICENSE.txt for complete terms"
---

# Guardrail Commit Hooks Skill

This skill helps you create and manage prek pre-commit hooks for code quality guardrails.

## Command Dispatch

This skill handles three operations based on the `args` parameter:

| Args Pattern | Operation | Description |
|--------------|-----------|-------------|
| `analyze ...` | Analyze | Analyze project and recommend hooks |
| `setup ...` | Setup | Full installation wizard |
| `update ...` | Update | Update hooks to latest versions |

If no args are provided, default to the **analyze** operation.

---

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

- **Ruff** (Python): `https://api.github.com/repos/astral-sh/ruff-pre-commit/releases/latest`
- **Biome** (JS/TS): `https://api.github.com/repos/biomejs/pre-commit/releases/latest`

## Installation Commands

```bash
# Install prek (recommended via uv)
uv tool install prek

# Alternative: via pip
pip install prek

# Alternative: shell script
curl -LsSf https://astral.sh/prek/install.sh | sh
```

---

## Operation: analyze - Analyze and Recommend Hooks

Analyze the current project and recommend appropriate prek pre-commit hooks.

### Steps

#### 1. Launch Project Analyzer

Use the Task tool to launch the prek-analyzer agent:

```json
{
  "subagent_type": "commit-guardrails:prek-analyzer",
  "description": "Analyze project for prek hooks",
  "prompt": "Analyze this project to recommend prek pre-commit hooks."
}
```

The analyzer will check for:

- Languages: package.json, Cargo.toml, pyproject.toml, go.mod, pom.xml, Gemfile
- Existing hooks: .pre-commit-config.yaml, .husky/, lefthook.yml
- Project structure: Is this a monorepo?

#### 2. Check for Existing Hook Tools

If existing hooks detected:

- If `.pre-commit-config.yaml` exists: "This project already has pre-commit hooks configured. Would you like to review them or update to latest versions?"
- If husky/lefthook detected: Ask if user wants to migrate to prek

#### 3. Fetch Latest Documentation

Use WebFetch to get current hook versions:

```
WebFetch: https://prek.j178.dev/builtin/
Prompt: "List all available built-in hook IDs"

WebFetch: https://api.github.com/repos/astral-sh/ruff-pre-commit/releases/latest
Prompt: "Extract the tag_name for the latest version"
```

#### 4. Evaluate Base Hooks for Relevance

Before generating recommendations, evaluate each base hook for relevance to **this specific project**.

##### Always Include (Universal Benefits)

These hooks provide value for any project:

```yaml
repos:
  - repo: builtin
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: detect-private-key
      - id: check-merge-conflict
      - id: check-added-large-files
        args: [--maxkb=500]
```

##### Include If Files Exist

Run these checks and **only include the hook if matches are found**:

| Hook | Check | Include If |
|------|-------|------------|
| `check-yaml` | `Glob: **/*.{yml,yaml}` (exclude .git) | YAML files found |
| `check-json` | `Glob: **/*.json` (exclude node_modules, .git) | JSON files found |
| `check-toml` | `Glob: **/*.toml` | TOML files found |

Example evaluation:
```
Glob: **/*.yml → 3 files found → include check-yaml
Glob: **/*.json → 0 files found (excluding node_modules) → skip check-json
Glob: **/*.toml → 1 file found → include check-toml
```

##### Ask User About Workflow

The `no-commit-to-branch` hook assumes a feature-branch workflow. **Ask the user before including:**

```
Do you want to prevent direct commits to main/master branches?
This is useful if your team uses feature branches and pull requests.
```

Only include if user confirms:
```yaml
      - id: no-commit-to-branch
        args: [--branch, main, --branch, master]
```

##### Security Hooks (Always Recommend)

Always recommend gitleaks for comprehensive secret detection:

```yaml
  - repo: https://github.com/gitleaks/gitleaks
    rev: "{fetch from Version API}"
    hooks:
      - id: gitleaks
```

#### 5. Generate Recommendations

Based on detected languages and the base hook evaluation above, build a recommended configuration.

**Add language-specific hooks based on detection.**

#### 6. Present to User

Show the complete recommended configuration with explanations:

````
## Recommended prek Configuration

Based on my analysis, I recommend these pre-commit hooks for your {language} project:

### Universal Hooks
- `trailing-whitespace` - Removes trailing whitespace
- `end-of-file-fixer` - Ensures files end with newline
- `detect-private-key` - Prevents committing secrets
- `check-merge-conflict` - Catches unresolved conflicts
- `check-added-large-files` - Prevents bloating the repository

### File Format Validators (based on files detected)
- `check-yaml` - Validates YAML syntax (included because .yml files found)
- `check-toml` - Validates TOML syntax (included because .toml files found)

### Security
- `gitleaks` - Comprehensive secret detection

### {Language} Hooks
- `{hook}` - {description}

### Proposed Configuration

```yaml
{full config}
````

Would you like me to:

1. Create this configuration and set up prek
2. Modify the configuration first
3. Skip for now

````

Use AskUserQuestion to get user's decision before proceeding.

If user approves, suggest running `/guardrail:setup` to complete the installation.

---

## Operation: setup - Full Installation Wizard

Complete setup wizard for prek pre-commit hooks.

### Steps

#### 1. Check prek Installation

```bash
prek --version
````

If not installed, ask user how they'd like to install:

```json
{
  "questions": [
    {
      "question": "prek is not installed. How would you like to install it?",
      "header": "Install",
      "multiSelect": false,
      "options": [
        {
          "label": "uv tool install (Recommended)",
          "description": "Fast, isolated installation via uv"
        },
        { "label": "pip install", "description": "Install via pip" },
        { "label": "Shell script", "description": "curl installer script" }
      ]
    }
  ]
}
```

Then run the appropriate install command:

- uv: `uv tool install prek`
- pip: `pip install prek`
- shell: `curl -LsSf https://astral.sh/prek/install.sh | sh`

#### 2. Analyze Project

Run the **analyze** operation or use prek-analyzer agent to detect:

- Project languages
- Existing hook configuration
- Monorepo structure

#### 3. Check for Existing Configuration

```bash
ls -la .pre-commit-config.yaml 2>/dev/null
```

If exists:

- Ask if user wants to keep, update, or replace it
- If keeping: skip to step 5
- If updating: proceed to step 4

#### 4. Create Configuration

##### Fetch Latest Versions

Use WebFetch to get current versions:

```
WebFetch: https://prek.j178.dev/builtin/
Prompt: "List all built-in hook IDs available"

WebFetch: https://api.github.com/repos/astral-sh/ruff-pre-commit/releases/latest
Prompt: "Get the latest release tag_name"
```

##### Generate Config

Build `.pre-commit-config.yaml` using context-aware hook selection:

**Step 1: Always include universal hooks**
```yaml
repos:
  - repo: builtin
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: detect-private-key
      - id: check-merge-conflict
      - id: check-added-large-files
        args: [--maxkb=500]
```

**Step 2: Check for file format validators**

Run glob checks and only include hooks for file types that exist:

| Hook | Check | Include If |
|------|-------|------------|
| `check-yaml` | `Glob: **/*.{yml,yaml}` (exclude .git) | YAML files found |
| `check-json` | `Glob: **/*.json` (exclude node_modules, .git) | JSON files found |
| `check-toml` | `Glob: **/*.toml` | TOML files found |

**Step 3: Ask about branch protection**

Ask user: "Do you want to prevent direct commits to main/master branches?"

Only include if user confirms:
```yaml
      - id: no-commit-to-branch
        args: [--branch, main, --branch, master]
```

**Step 4: Add security hooks and language-specific hooks**

```yaml
  # Security - always recommend
  - repo: https://github.com/gitleaks/gitleaks
    rev: "{fetch from Version API}"
    hooks:
      - id: gitleaks

  # Language-specific hooks based on detection
```

##### Show to User

Present the configuration and ask for confirmation:

```
## Proposed Configuration

{show yaml}

This will:
- Check for trailing whitespace and fix line endings
- Prevent committing private keys
- Scan for secrets with gitleaks
{if check-yaml included} - Validate YAML syntax
{if check-json included} - Validate JSON syntax
{if check-toml included} - Validate TOML syntax
{if no-commit-to-branch included} - Block direct commits to main/master
- {language-specific descriptions}

Create this configuration?
```

##### Write File

After approval, use Write tool to create `.pre-commit-config.yaml`

#### 5. Install Git Hooks

```bash
prek install
```

This installs the hooks into `.git/hooks/pre-commit`

#### 6. Run Initial Check

```bash
prek run --all-files
```

This runs all hooks on every file to catch existing issues.

#### 7. Handle Results

**If all hooks pass:**

```
Setup complete! Pre-commit hooks are now active.

On every commit, prek will automatically:
{list what each hook does}

To update hooks later: /guardrail:update
To skip hooks once: git commit --no-verify
```

**If hooks fail:**

```
Some hooks found issues in existing files:

{show failures}

These need to be fixed before commits will succeed.
Would you like me to help fix these issues?
```

#### 8. Offer Next Steps

```
## Next Steps

1. **Fix any issues** found by the initial hook run
2. **Commit the configuration**: `git add .pre-commit-config.yaml && git commit -m "Add prek pre-commit hooks"`
3. **Share with team**: Other developers can run `prek install` after cloning

Your code quality guardrails are now active!
```

---

## Operation: update - Update Hook Versions

Update existing prek pre-commit hooks to their latest versions.

### Steps

#### 1. Check for Existing Configuration

```bash
ls -la .pre-commit-config.yaml 2>/dev/null
```

If no configuration exists:

```
No .pre-commit-config.yaml found. Run /guardrail:setup to create one first.
```

#### 2. Read Current Configuration

Use Read tool to examine `.pre-commit-config.yaml`

Extract:

- Current repos and their versions
- Which hooks are configured

#### 3. Fetch Latest Versions

For each external repo in the config, fetch latest version:

**Ruff:**

```
WebFetch: https://api.github.com/repos/astral-sh/ruff-pre-commit/releases/latest
Prompt: "Extract the tag_name"
```

**Biome (JS/TS):**

```
WebFetch: https://api.github.com/repos/biomejs/pre-commit/releases/latest
Prompt: "Extract the tag_name"
```

#### 4. Compare Versions

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

#### 5. Ask for Confirmation

Use AskUserQuestion:

```json
{
  "questions": [
    {
      "question": "How would you like to update the hooks?",
      "header": "Update",
      "multiSelect": false,
      "options": [
        {
          "label": "Update all",
          "description": "Update all hooks to latest versions"
        },
        {
          "label": "Use prek autoupdate",
          "description": "Let prek handle the updates automatically"
        },
        {
          "label": "Select specific",
          "description": "Choose which hooks to update"
        },
        { "label": "Cancel", "description": "Don't update anything" }
      ]
    }
  ]
}
```

#### 6. Perform Updates

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

#### 7. Test Updated Hooks

```bash
prek run --all-files
```

#### 8. Show Results

**If successful:**

```
## Updates Complete

Updated hooks:
- ruff-pre-commit: v0.8.0 -> v0.8.6
- mirrors-eslint: v9.15.0 -> v9.17.0

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

#### 9. Optional: Add New Hooks

After updating, check if project has new languages that need hooks:

```
I also noticed you have {language} files that don't have hooks configured.
Would you like to add {recommended hooks} for {language}?
```

---

## Language-Specific Hook Recommendations

Language-specific configurations are stored in the `languages/` directory for modularity and dynamic updates.

### Discovery Process

1. **Read the registry:** `languages/index.md` lists all supported languages
2. **Detect project languages:** Match files against detection patterns
3. **Load language configs:** Read `languages/{language}.md` for each detected language
4. **Fetch latest versions:** Use documentation URLs in language files
5. **Generate configuration:** Build `.pre-commit-config.yaml` dynamically

### Adding New Language Support

To add support for a new language:

1. Create `languages/{language}.md` with detection patterns and tool documentation URLs
2. Add entry to `languages/index.md`
3. The agent will automatically discover and use the new configuration

---

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

---

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

---

## Monorepo Support

For monorepos, prek supports workspace mode:

- Create `.pre-commit-config.yaml` files in subdirectories
- Use `orphan: true` to prevent parent config processing
- Target specific projects with `prek run <project>/`

Fetch workspace documentation: `https://prek.j178.dev/workspace/`
