---
registry: language-hooks
---

# Language Hook Registry

This directory contains language-specific hook configurations for prek pre-commit hooks.

## Supported Languages

| Language | File | Detection Patterns | Primary Tool |
|----------|------|-------------------|--------------|
| Python | python.md | `pyproject.toml`, `setup.py`, `requirements.txt` | ruff |
| Rust | rust.md | `Cargo.toml` | cargo tools (built-in) |
| JavaScript/TypeScript | javascript.md | `package.json`, `tsconfig.json` | biome |
| Go | go.md | `go.mod` | golangci-lint, gofumpt |

## Cross-Language Security Hooks

These hooks should be included in **every project** regardless of language.

### Secret Detection: gitleaks

Industry-standard secret scanner. Detects API keys, passwords, tokens, and other secrets.

- **Documentation:** https://gitleaks.io/
- **Repository:** https://github.com/gitleaks/gitleaks
- **Version API:** https://api.github.com/repos/gitleaks/gitleaks/releases/latest

```yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: "{fetch from Version API}"
    hooks:
      - id: gitleaks
```

### Alternative: detect-secrets (Yelp)

> **⚠️ Maintenance Warning**: This project has reduced activity since 2024. Consider using gitleaks or trufflehog instead for actively maintained alternatives.

Lighter-weight secret detection with baseline support for managing false positives.

- **Documentation:** https://github.com/Yelp/detect-secrets
- **Repository:** https://github.com/Yelp/detect-secrets

```yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: "{fetch from Version API}"
    hooks:
      - id: detect-secrets
        args: [--baseline, .secrets.baseline]
```

### Alternative: trufflehog

Deep scanning for secrets including git history. More thorough but slower.

- **Documentation:** https://trufflesecurity.com/trufflehog
- **Repository:** https://github.com/trufflesecurity/trufflehog

```yaml
repos:
  - repo: local
    hooks:
      - id: trufflehog
        name: trufflehog
        entry: trufflehog git file://. --only-verified --fail
        language: system
        pass_filenames: false
        stages: [manual]  # Slow - run manually
```

## File Format Validators

Ensure configuration files are valid before committing.

### JSON Validation

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: "{fetch from Version API}"
    hooks:
      - id: check-json
```

### YAML Validation

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: "{fetch from Version API}"
    hooks:
      - id: check-yaml
        args: [--unsafe]  # Allow custom tags
```

### TOML Validation

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: "{fetch from Version API}"
    hooks:
      - id: check-toml
```

## Commit Message Standards

### commitlint (Conventional Commits)

Enforces conventional commit message format for better changelogs and versioning.

- **Documentation:** https://commitlint.js.org/
- **Repository:** https://github.com/alessandrojcm/commitlint-pre-commit-hook

```yaml
repos:
  - repo: https://github.com/alessandrojcm/commitlint-pre-commit-hook
    rev: "{fetch from Version API}"
    hooks:
      - id: commitlint
        stages: [commit-msg]
        additional_dependencies: ["@commitlint/config-conventional"]
```

**Note:** Requires `commitlint.config.js`:

```javascript
module.exports = { extends: ['@commitlint/config-conventional'] };
```

## Large File Prevention

Prevent accidentally committing large files that should be in Git LFS or excluded.

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: "{fetch from Version API}"
    hooks:
      - id: check-added-large-files
        args: [--maxkb=500]  # 500KB limit
```

## Essential Pre-commit Hooks

Standard hooks that every project should include.

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: "{fetch from Version API}"
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-merge-conflict
      - id: check-added-large-files
        args: [--maxkb=500]
      - id: check-json
      - id: check-yaml
        args: [--unsafe]
      - id: check-toml
      - id: detect-private-key
      - id: no-commit-to-branch
        args: [--branch, main, --branch, master]
```

## Complete Cross-Language Configuration

Include this in every project alongside language-specific hooks:

```yaml
repos:
  # Essential hooks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: "{fetch from Version API}"
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-merge-conflict
      - id: check-added-large-files
        args: [--maxkb=500]
      - id: check-json
      - id: check-yaml
        args: [--unsafe]
      - id: check-toml
      - id: detect-private-key
      - id: no-commit-to-branch
        args: [--branch, main, --branch, master]

  # Secret detection
  - repo: https://github.com/gitleaks/gitleaks
    rev: "{fetch from Version API}"
    hooks:
      - id: gitleaks

  # Commit message standards (optional but recommended)
  - repo: https://github.com/alessandrojcm/commitlint-pre-commit-hook
    rev: "{fetch from Version API}"
    hooks:
      - id: commitlint
        stages: [commit-msg]
        additional_dependencies: ["@commitlint/config-conventional"]
```

## Agent Workflow

When analyzing a project for hook recommendations:

1. **Read this index** to discover available languages and cross-language hooks
2. **Always include cross-language security hooks** (gitleaks, file validators)
3. **Detect project languages** using the detection patterns in the table above
4. **Read relevant language files** for each detected language
5. **Fetch documentation URLs** from language files to get latest versions
6. **Generate .pre-commit-config.yaml** dynamically with current versions

## Adding New Language Support

To add support for a new language:

1. Create `languages/{language}.md` following the template structure
2. Add an entry to this index table
3. Include documentation URLs for dynamic version fetching
4. Test with a project using that language

## Tool Philosophy

All recommended tools prioritize:

1. **Security first:** Secret detection and vulnerability scanning in every config
2. **Speed:** Rust-based tools where possible for maximum performance
3. **Comprehensiveness:** Multiple layers of checks (format, lint, security, types)

| Tool | Language | Speed | Notes |
|------|----------|-------|-------|
| ruff | Python | 10-100x faster | Replaces flake8, black, isort |
| biome | JS/TS | 10-25x faster | Replaces ESLint + Prettier |
| cargo tools | Rust | Native | Built into toolchain |
| golangci-lint | Go | Fast | Meta-linter with caching |
| gitleaks | All | Fast | Go-based secret scanner |
