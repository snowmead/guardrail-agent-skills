---
language: go
detection_patterns: ["go.mod", "*.go"]
---

# Go Pre-commit Hooks

## Detection

This language is detected by finding: `go.mod` or `*.go` files.

## Primary Tools: Native Go Toolchain

The Go toolchain provides built-in formatting and analysis tools.

- **Documentation:** https://golang.org/cmd/go/
- **gofumpt Docs:** https://github.com/mvdan/gofumpt
- **go vet Docs:** https://pkg.go.dev/cmd/vet
- **prek Docs:** https://prek.j178.dev/builtin/

## Key Hooks

- `gofumpt` - Stricter Go formatter (superset of gofmt, gopls-integrated)
- `go-vet` - Official Go static analyzer
- `go-mod-tidy` - Clean up go.mod and go.sum

## Configuration Example

```yaml
repos:
  - repo: builtin
    hooks:
      - id: go-vet
      - id: go-mod-tidy

  # gofumpt - stricter formatting than gofmt
  - repo: https://github.com/mvdan/gofumpt
    rev: "{fetch from Version API}"
    hooks:
      - id: gofumpt
        args: [-w]
```

## Recommended: golangci-lint

Comprehensive meta-linter that runs multiple linters in parallel. The standard for Go projects.

- **Documentation:** https://golangci-lint.run/
- **Repository:** https://github.com/golangci/golangci-lint
- **Version API:** https://api.github.com/repos/golangci/golangci-lint/releases/latest
- **Migration Guide (v1 to v2):** https://golangci-lint.run/docs/configuration/

```yaml
repos:
  - repo: https://github.com/golangci/golangci-lint
    rev: "{fetch from Version API}"
    hooks:
      - id: golangci-lint
        args: [--fix]
```

**Note:** golangci-lint v2.x introduced breaking configuration changes. Run `golangci-lint migrate` to update existing `.golangci.yml` files.

## Security: govulncheck

Official Go vulnerability scanner maintained by the Go security team. Scans dependencies for known vulnerabilities.

- **Documentation:** https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck
- **Repository:** https://github.com/golang/vuln
- **Install:** `go install golang.org/x/vuln/cmd/govulncheck@latest`

```yaml
repos:
  - repo: https://github.com/TekWizely/pre-commit-golang
    rev: "{fetch from Version API}"
    hooks:
      - id: go-vulncheck-mod
```

**Alternative local hook:**

```yaml
repos:
  - repo: local
    hooks:
      - id: govulncheck
        name: govulncheck
        entry: govulncheck ./...
        language: system
        pass_filenames: false
        files: (\.go$|go\.mod$|go\.sum$)
```

## Optional: staticcheck

Advanced static analysis tool, now the default linter in VS Code for Go.

- **Documentation:** https://staticcheck.dev/
- **Repository:** https://github.com/dominikh/go-tools
- **Install:** `go install honnef.co/go/tools/cmd/staticcheck@latest`

```yaml
repos:
  - repo: local
    hooks:
      - id: staticcheck
        name: staticcheck
        entry: staticcheck ./...
        language: system
        pass_filenames: false
        types: [go]
```

**Note:** If using golangci-lint, staticcheck is included by default - no need for a separate hook.

## Complete Configuration Example

```yaml
repos:
  # Formatting
  - repo: https://github.com/mvdan/gofumpt
    rev: "{fetch from Version API}"
    hooks:
      - id: gofumpt
        args: [-w]

  # Linting (includes staticcheck, go vet, and 50+ linters)
  - repo: https://github.com/golangci/golangci-lint
    rev: "{fetch from Version API}"
    hooks:
      - id: golangci-lint
        args: [--fix]

  # Security scanning
  - repo: https://github.com/TekWizely/pre-commit-golang
    rev: "{fetch from Version API}"
    hooks:
      - id: go-vulncheck-mod

  # Module maintenance
  - repo: builtin
    hooks:
      - id: go-mod-tidy
```

## Special Considerations

- **gofumpt vs gofmt:** gofumpt is a strict superset of gofmt with additional formatting rules. It's backwards compatible and integrates with gopls.
- **golangci-lint v2:** Major configuration changes from v1. Use `golangci-lint migrate` to update configs.
- **govulncheck:** Should run on every commit that changes `.go`, `go.mod`, or `go.sum` files.
- **Performance:** golangci-lint caches results - subsequent runs are much faster.
- **Configuration:** Use `.golangci.yml` for golangci-lint customization. See [golden config example](https://gist.github.com/maratori/47a4d00457a92aa426dbd48a18776322).
- **68% of Go teams** use automated static analysis at commit stage, reducing post-merge defect discovery.
