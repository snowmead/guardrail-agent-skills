---
language: rust
detection_patterns: ["Cargo.toml", "*.rs"]
---

# Rust Pre-commit Hooks

## Detection

This language is detected by finding: `Cargo.toml` or `*.rs` files.

## Primary Tools: Cargo Built-ins

Native Rust toolchain provides all necessary tools. No external dependencies required.

- **Documentation:** https://doc.rust-lang.org/cargo/
- **Clippy Docs:** https://doc.rust-lang.org/clippy/
- **Rustfmt Docs:** https://rust-lang.github.io/rustfmt/
- **prek Docs:** https://prek.j178.dev/builtin/

## Key Hooks

- `cargo-check` - Fast compilation check without producing executable
- `cargo-clippy` - Official Rust linter with extensive checks
- `cargo-fmt` - Official Rust formatter

## Configuration Example

```yaml
repos:
  - repo: builtin
    hooks:
      - id: cargo-check
      - id: cargo-clippy
        args: [--workspace, --all-targets, --all-features, --, -D, warnings]
      - id: cargo-fmt
        args: [--all, --check]
```

## Security: cargo-audit (Vulnerability Scanning)

Scans dependencies for known security vulnerabilities using the RustSec Advisory Database.

- **Documentation:** https://rustsec.org/
- **Repository:** https://github.com/rustsec/rustsec/tree/main/cargo-audit
- **Advisory Database:** https://github.com/RustSec/advisory-db
- **Install:** `cargo install cargo-audit`

```yaml
repos:
  - repo: local
    hooks:
      - id: cargo-audit
        name: cargo-audit
        entry: cargo audit
        language: system
        pass_filenames: false
        files: Cargo\.(toml|lock)$
```

## Security: cargo-deny (Comprehensive Dependency Auditing)

More comprehensive than cargo-audit - handles licenses, security vulnerabilities, bans, and dependency sources.

- **Documentation:** https://embarkstudios.github.io/cargo-deny/
- **Repository:** https://github.com/EmbarkStudios/cargo-deny
- **Version API:** https://api.github.com/repos/EmbarkStudios/cargo-deny/releases/latest
- **Install:** `cargo install cargo-deny`

```yaml
repos:
  - repo: https://github.com/EmbarkStudios/cargo-deny
    rev: "{fetch from Version API}"
    hooks:
      - id: cargo-deny
        args: [--all-features, check]
```

**Note:** Requires a `deny.toml` configuration file. Generate with `cargo deny init`.

**deny.toml example:**

```toml
[advisories]
db-path = "~/.cargo/advisory-db"
db-urls = ["https://github.com/rustsec/advisory-db"]
vulnerability = "deny"
unmaintained = "warn"

[licenses]
allow = ["MIT", "Apache-2.0", "BSD-3-Clause"]
copyleft = "warn"

[bans]
multiple-versions = "warn"
wildcards = "deny"
```

## Dependency Management: cargo-machete (Unused Dependencies)

Detects unused dependencies in Cargo.toml to reduce bloat and attack surface.

- **Documentation:** https://github.com/bnjbvr/cargo-machete
- **Repository:** https://github.com/bnjbvr/cargo-machete
- **Install:** `cargo install cargo-machete`

```yaml
repos:
  - repo: local
    hooks:
      - id: cargo-machete
        name: cargo-machete
        entry: cargo machete
        language: system
        pass_filenames: false
        files: Cargo\.(toml|lock)$
```

## API Compatibility: cargo-semver-checks

Lints for semantic versioning violations. Ensures public API changes match version bumps.

- **Documentation:** https://crates.io/crates/cargo-semver-checks
- **Repository:** https://github.com/obi1kenobi/cargo-semver-checks
- **Install:** `cargo install cargo-semver-checks`

**Note:** This tool has 120+ lints and is planned for integration into cargo itself.

```yaml
repos:
  - repo: local
    hooks:
      - id: cargo-semver-checks
        name: cargo-semver-checks
        entry: cargo semver-checks check-release
        language: system
        pass_filenames: false
        files: Cargo\.(toml|lock)$
        stages: [manual]  # Run manually due to performance cost
```

## Optional: cargo-vet (Enterprise Audit Workflows)

Mozilla's shared security audit system for organizations to collaborate on dependency audits.

- **Documentation:** https://mozilla.github.io/cargo-vet/
- **Repository:** https://github.com/mozilla/cargo-vet
- **Install:** `cargo install cargo-vet`

```yaml
repos:
  - repo: local
    hooks:
      - id: cargo-vet
        name: cargo-vet
        entry: cargo vet
        language: system
        pass_filenames: false
        files: Cargo\.(toml|lock)$
```

**Note:** cargo-vet allows organizations to share audit results, reducing duplicated security review effort across the Rust ecosystem.

## Advanced: miri (Undefined Behavior Detection)

Interpreter for Rust's mid-level intermediate representation (MIR) that detects undefined behavior.

- **Documentation:** https://github.com/rust-lang/miri
- **Rust Book:** https://doc.rust-lang.org/nightly/unstable-book/library-features/miri.html
- **Install:** `rustup +nightly component add miri`

```yaml
repos:
  - repo: local
    hooks:
      - id: miri
        name: miri
        entry: cargo +nightly miri test
        language: system
        pass_filenames: false
        stages: [manual]
```

**Aliasing Models:**
- Default: Stacked Borrows
- Alternative: Tree Borrows (use `MIRIFLAGS="-Zmiri-tree-borrows"`)

```yaml
# Tree Borrows variant
repos:
  - repo: local
    hooks:
      - id: miri-tree-borrows
        name: miri (tree borrows)
        entry: bash -c 'MIRIFLAGS="-Zmiri-tree-borrows" cargo +nightly miri test'
        language: system
        pass_filenames: false
        stages: [manual]
```

## Complete Configuration Example

```yaml
repos:
  # Core toolchain
  - repo: builtin
    hooks:
      - id: cargo-check
      - id: cargo-clippy
        args: [--workspace, --all-targets, --all-features, --, -D, warnings]
      - id: cargo-fmt
        args: [--all, --check]

  # Comprehensive dependency auditing (licenses, security, bans)
  - repo: https://github.com/EmbarkStudios/cargo-deny
    rev: "{fetch from Version API}"
    hooks:
      - id: cargo-deny
        args: [--all-features, check]

  # Unused dependency detection
  - repo: local
    hooks:
      - id: cargo-machete
        name: cargo-machete
        entry: cargo machete
        language: system
        pass_filenames: false
        files: Cargo\.(toml|lock)$

  # Manual checks (run with `prek run --hook-stage manual`)
  - repo: local
    hooks:
      - id: cargo-semver-checks
        name: cargo-semver-checks
        entry: cargo semver-checks check-release
        language: system
        pass_filenames: false
        stages: [manual]

      - id: miri
        name: miri
        entry: cargo +nightly miri test
        language: system
        pass_filenames: false
        stages: [manual]
```

## Minimal Configuration (Quick Start)

For projects that want essential checks without full security scanning:

```yaml
repos:
  - repo: builtin
    hooks:
      - id: cargo-check
      - id: cargo-clippy
        args: [--all-targets, --, -D, warnings]
      - id: cargo-fmt
        args: [--all, --check]

  - repo: local
    hooks:
      - id: cargo-audit
        name: cargo-audit
        entry: cargo audit
        language: system
        pass_filenames: false
        files: Cargo\.(toml|lock)$
```

## Special Considerations

- **Built-in hooks:** Always up-to-date with prek installation, no external version management.
- **Workspaces:** Use `--workspace` flag for clippy to check all crates.
- **cargo-deny vs cargo-audit:** cargo-deny is more comprehensive (licenses, bans, sources). Use both for maximum coverage.
- **cargo-machete:** Reduces attack surface and compilation time by removing unused dependencies.
- **cargo-semver-checks:** Essential for library crates to ensure API compatibility.
- **miri:** Slow - use `stages: [manual]` to run only when explicitly requested.
- **Performance:** Use `stages: [manual]` for slow checks (miri, semver-checks).
- **90%+ of major Rust projects** use cargo-deny with versions 0.16-0.19 as of 2025.
