---
language: javascript
detection_patterns: ["package.json", "tsconfig.json", "*.js", "*.ts", "*.jsx", "*.tsx"]
---

# JavaScript/TypeScript Pre-commit Hooks

## Detection

This language is detected by finding: `package.json`, `tsconfig.json`, or JS/TS files.

## Primary Tool: Biome

Ultra-fast linter and formatter for JavaScript, TypeScript, JSON, CSS, and GraphQL - written in Rust.

- **Purpose:** Linting and formatting (replaces ESLint + Prettier)
- **Documentation:** https://biomejs.dev/
- **Guides:** https://biomejs.dev/guides/getting-started/
- **prek Docs:** https://prek.j178.dev/builtin/
- **Repository:** https://github.com/biomejs/pre-commit
- **Version API:** https://api.github.com/repos/biomejs/pre-commit/releases/latest

## Key Hooks

- `biome-check` - Combined linting and formatting check with auto-fix
- `biome-lint` - Linting only
- `biome-format` - Formatting only

## Configuration Example

```yaml
repos:
  - repo: https://github.com/biomejs/pre-commit
    rev: "{fetch from Version API}"
    hooks:
      - id: biome-check
        additional_dependencies: ["@biomejs/biome@latest"]
        args: [--write, --diagnostic-level=error]
```

## Biome v2.0 Features (2025)

Biome v2 introduced significant enhancements:

- **Type-aware linting:** Leverages TypeScript's type information for smarter analysis
- **Multi-file analysis:** Cross-file checks for imports, exports, and dependencies
- **Plugin system:** Extend with custom rules
- **HTML support:** Now stable for HTML files
- **Improved monorepo support:** Better handling of workspace configurations

```yaml
# Biome v2.0 with type-aware linting
repos:
  - repo: https://github.com/biomejs/pre-commit
    rev: "{fetch from Version API}"
    hooks:
      - id: biome-check
        additional_dependencies: ["@biomejs/biome@latest"]
        args: [--write, --diagnostic-level=error, --files-ignore-unknown=true]
```

## Alternative: Oxlint (Maximum Speed)

Oxlint is 50-100x faster than ESLint and 2x faster than Biome. Good for very large codebases.

- **Documentation:** https://oxc.rs/docs/guide/usage/linter.html
- **Repository:** https://github.com/oxc-project/oxc
- **Version API:** https://api.github.com/repos/oxc-project/oxc/releases/latest

```yaml
repos:
  - repo: local
    hooks:
      - id: oxlint
        name: oxlint
        entry: npx oxlint
        language: system
        types_or: [javascript, jsx, ts, tsx]
```

## Alternative: ESLint v9 (Plugin Ecosystem)

For projects requiring specific ESLint plugins not yet available in Biome.

- **Documentation:** https://eslint.org/
- **Flat Config Migration:** https://eslint.org/docs/latest/use/configure/migration-guide
- **Repository:** https://github.com/pre-commit/mirrors-eslint
- **Version API:** https://api.github.com/repos/pre-commit/mirrors-eslint/releases/latest

**Note:** ESLint v9 made flat config (`eslint.config.js`) the default. Migrate from `.eslintrc` using the migration guide.

```yaml
repos:
  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: "{fetch from Version API}"
    hooks:
      - id: eslint
        types_or: [javascript, jsx, ts, tsx]
        args: [--fix]
        additional_dependencies:
          - eslint@latest
          - typescript
          - "@typescript-eslint/parser"
          - "@typescript-eslint/eslint-plugin"
```

## Security: Dependency Scanning

JavaScript projects should scan for vulnerable dependencies.

### Option 1: Socket (Behavioral Malware Detection)

- **Documentation:** https://socket.dev/
- **Purpose:** Detects supply chain attacks, not just known CVEs

### Option 2: npm audit Alternative

```yaml
repos:
  - repo: local
    hooks:
      - id: npm-audit
        name: npm audit
        entry: npm audit --audit-level=moderate
        language: system
        files: package-lock\.json$
        pass_filenames: false
```

### Option 3: OSV Scanner (Google)

- **Documentation:** https://google.github.io/osv-scanner/
- **Repository:** https://github.com/google/osv-scanner

```yaml
repos:
  - repo: local
    hooks:
      - id: osv-scanner
        name: osv-scanner
        entry: osv-scanner --lockfile=package-lock.json
        language: system
        files: package-lock\.json$
        pass_filenames: false
```

## Security: Secret Detection

Prevent accidentally committing secrets. See index.md for cross-language secret detection hooks.

## Complete Configuration Example

```yaml
repos:
  # Linting and formatting with Biome
  - repo: https://github.com/biomejs/pre-commit
    rev: "{fetch from Version API}"
    hooks:
      - id: biome-check
        additional_dependencies: ["@biomejs/biome@latest"]
        args: [--write, --diagnostic-level=error]

  # Dependency vulnerability scanning
  - repo: local
    hooks:
      - id: npm-audit
        name: npm audit
        entry: npm audit --audit-level=moderate
        language: system
        files: package-lock\.json$
        pass_filenames: false
```

## Framework-Specific Considerations

### React
- Biome v2 includes React-specific domain rules
- Configure in `biome.json` under `linter.rules.react`

### Next.js
- Use Biome for linting/formatting
- Consider Next.js built-in eslint config for Next-specific rules if needed

### TypeScript Strict Mode
- Enable `strict: true` in `tsconfig.json`
- Biome respects TypeScript configuration for type-aware rules

## Special Considerations

- **Biome vs ESLint:** Biome is 10-25x faster and handles both linting and formatting. Use ESLint only if you need plugins not available in Biome.
- **Oxlint:** Use for maximum speed in very large codebases (50-100x faster than ESLint).
- **Configuration:** `biome.json` or `biome.jsonc` for Biome settings.
- **97% Prettier-compatible:** Biome formatting is nearly identical to Prettier.
- **200+ lint rules:** Covers most ESLint rules plus additional checks.
- **ESLint v9:** Requires flat config migration from `.eslintrc` to `eslint.config.js`.
