---
language: python
detection_patterns: ["pyproject.toml", "setup.py", "requirements.txt", "*.py"]
---

# Python Pre-commit Hooks

## Detection

This language is detected by finding: `pyproject.toml`, `setup.py`, `requirements.txt`, or `*.py` files.

## Primary Tool: ruff

Ultra-fast Python linter and formatter written in Rust.

- **Purpose:** Linting and formatting (replaces flake8, black, isort, pylint, and many others)
- **Documentation:** https://docs.astral.sh/ruff/
- **prek Docs:** https://prek.j178.dev/builtin/
- **Repository:** https://github.com/astral-sh/ruff-pre-commit
- **Version API:** https://api.github.com/repos/astral-sh/ruff-pre-commit/releases/latest

## Key Hooks

- `ruff` - Linting with auto-fix capability
- `ruff-format` - Code formatting (black-compatible)

## Configuration Example

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: "{fetch from Version API}"
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix, --unsafe-fixes, --show-fixes]
      - id: ruff-format
```

## Security: pip-audit (Dependency Vulnerabilities)

Scans Python environments and requirements files for known security vulnerabilities.

- **Documentation:** https://pypi.org/project/pip-audit/
- **Repository:** https://github.com/pypa/pip-audit
- **Version API:** https://api.github.com/repos/pypa/pip-audit/releases/latest
- **Install:** `pip install pip-audit` or `uv pip install pip-audit`

```yaml
repos:
  - repo: https://github.com/pypa/pip-audit
    rev: "{fetch from Version API}"
    hooks:
      - id: pip-audit
        args: [--desc, --require-hashes]
```

## Security: bandit (Code Security Analysis)

> **💡 Tip**: Ruff includes Bandit-compatible security rules (S prefix) that run 10-100x faster. Use `ruff check --select S` for basic security checks. Use bandit for specialized analysis requiring its full rule set.

Identifies common security issues in Python code (SQL injection, hardcoded passwords, etc.).

- **Documentation:** https://bandit.readthedocs.io/
- **Repository:** https://github.com/PyCQA/bandit
- **Version API:** https://api.github.com/repos/PyCQA/bandit/releases/latest
- **Install:** `pip install bandit` or `uv pip install bandit`

```yaml
repos:
  - repo: https://github.com/PyCQA/bandit
    rev: "{fetch from Version API}"
    hooks:
      - id: bandit
        args: [--recursive, --format, json, --exclude, tests]
```

## Type Checking: pyright/basedpyright

Advanced static type checker, faster than mypy with better IDE integration.

- **pyright Documentation:** https://microsoft.github.io/pyright/
- **basedpyright Documentation:** https://docs.basedpyright.com/
- **Repository:** https://github.com/RobertCraigie/pyright-python
- **Version API:** https://api.github.com/repos/RobertCraigie/pyright-python/releases/latest

**Note:** basedpyright is a fork with better IDE compatibility and additional features.

```yaml
repos:
  - repo: https://github.com/RobertCraigie/pyright-python
    rev: "{fetch from Version API}"
    hooks:
      - id: pyright
```

**Alternative with basedpyright:**

```yaml
repos:
  - repo: local
    hooks:
      - id: basedpyright
        name: basedpyright
        entry: basedpyright
        language: system
        types: [python]
        pass_filenames: false
```

## Dependency Management: deptry

Detects unused, missing, and transitive dependencies in your project.

- **Documentation:** https://deptry.com/
- **Repository:** https://github.com/fpgmaas/deptry
- **Version API:** https://api.github.com/repos/fpgmaas/deptry/releases/latest
- **Install:** `pip install deptry` or `uv pip install deptry`

```yaml
repos:
  - repo: https://github.com/fpgmaas/deptry
    rev: "{fetch from Version API}"
    hooks:
      - id: deptry
```

## Modern Tooling: uv Integration

uv is the modern, Rust-based Python package manager (10-100x faster than pip).

- **Documentation:** https://docs.astral.sh/uv/
- **Pre-commit Guide:** https://docs.astral.sh/uv/guides/integration/pre-commit/
- **Repository:** https://github.com/astral-sh/uv-pre-commit
- **Version API:** https://api.github.com/repos/astral-sh/uv-pre-commit/releases/latest

```yaml
repos:
  - repo: https://github.com/astral-sh/uv-pre-commit
    rev: "{fetch from Version API}"
    hooks:
      - id: uv-lock
      - id: uv-export
        args: [--frozen, --no-hashes, -o, requirements.txt]
```

## Complete Configuration Example

```yaml
repos:
  # Linting and formatting
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: "{fetch from Version API}"
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix, --unsafe-fixes, --show-fixes]
      - id: ruff-format

  # Security: dependency vulnerabilities
  - repo: https://github.com/pypa/pip-audit
    rev: "{fetch from Version API}"
    hooks:
      - id: pip-audit

  # Security: code analysis
  - repo: https://github.com/PyCQA/bandit
    rev: "{fetch from Version API}"
    hooks:
      - id: bandit
        args: [--recursive, --exclude, tests]

  # Type checking
  - repo: https://github.com/RobertCraigie/pyright-python
    rev: "{fetch from Version API}"
    hooks:
      - id: pyright

  # Unused dependencies
  - repo: https://github.com/fpgmaas/deptry
    rev: "{fetch from Version API}"
    hooks:
      - id: deptry
```

## Minimal Configuration (Quick Start)

For projects that want essential checks without full security scanning:

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: "{fetch from Version API}"
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/PyCQA/bandit
    rev: "{fetch from Version API}"
    hooks:
      - id: bandit
        args: [--recursive, --exclude, tests]
```

## Special Considerations

- **ruff:** Handles both linting and formatting in one tool. 10-100x faster than traditional Python linters.
- **Configuration:** Prefer `pyproject.toml` for all tool configuration (ruff, bandit, pyright, deptry).
- **pip-audit:** Essential for production projects - catches known vulnerabilities in dependencies.
- **bandit:** Catches common security anti-patterns like hardcoded passwords, SQL injection risks.
- **pyright vs mypy:** pyright is faster and has better IDE integration. basedpyright adds extra features.
- **deptry:** Reduces attack surface by identifying unused dependencies to remove.
- **uv:** If your project uses uv for package management, use uv-pre-commit hooks for lock file validation.
- **Replaces:** flake8, black, isort, pylint, pycodestyle, pydocstyle, pyupgrade, and more.
