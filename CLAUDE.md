# CLAUDE.md - Quick Reference for AI Agents

**IMPORTANT: Read AGENTS.md for comprehensive workflows and implementation details.**

This repository uses **chezmoi** to manage dotfiles across machines with templating support.

## Terminology

- **Devcontainer** (user: vscode) - Development environment at `/workspaces/dotfiles` where you edit source files
- **Test container** (user: user) - Isolated Debian container for testing dotfiles before applying to real systems

## Critical Rules

1. **NEVER edit files in ~/ directly** - always edit in source directory
2. **NEVER run `chezmoi apply` in devcontainer** - ONLY test with `mise run test` in test container
3. **ALWAYS run `chezmoi diff` before any apply** - preview changes before applying
4. **NEVER commit secrets or sensitive data** - dotfiles sync across multiple machines
5. **External binaries MUST go in `.chezmoiexternal.toml.tmpl`** - not custom download scripts
6. **Templates use Go syntax** - `{{ .chezmoi.os }}`, `{{ .chezmoi.arch }}`, `{{ .isWork }}`
7. **File naming determines behavior** - `dot_` becomes `.`, `.tmpl` gets processed, `run_once_` runs once
8. **Test in test container before applying** - use `mise run test` to validate changes safely
9. **Scripts must be idempotent** - safe to run multiple times without side effects
10. **Use mise for task automation** - defined in `.mise.toml` for testing and development
11. **Document template variables in `.chezmoi.toml.tmpl`** - centralize data definitions
12. **Always keep tests updated** - especially when adding new external packages / tools
13. **NEVER assume installed binaries are in PATH during same script** - scripts inherit PATH at start, use full paths after installation
14. **When installing binaries in scripts, use full paths for subsequent commands** - e.g., `$HOME/.local/bin/tool` not `tool`

## Quick Reference

**In devcontainer (editing and testing):**
```bash
vim dot_zshrc.tmpl            # Edit source files directly
git add . && git commit       # Commit changes
mise run test                 # Test in test container
mise run test:interactive     # Test + interactive shell
```

**On local machine (if not in devcontainer):**
See AGENTS.md "Making Changes to Existing Dotfiles" for local machine workflows.

## Key Information

**Supported platforms:** Linux, macOS, WSL (uses Linux binaries)

**Template variables:** `.chezmoi.os`, `.chezmoi.arch`, `.isWork`, `.isHome`, `.isDevContainer`, `.isWSL`, `.isWindows`

**Shell script standards:** `#!/usr/bin/env bash` with `set -euo pipefail`, quote variables, use `command -v` not `which`

**Git configuration:** Uses `[include]` mechanism, setup is automatic via `run_once_after` script

## See Also

- **[AGENTS.md](AGENTS.md)** - Detailed workflows, troubleshooting, implementation patterns
- **[EXTERNAL.md](EXTERNAL.md)** - External packages reference and instructions for adding packages
- **[TESTING.md](TESTING.md)** - Testing workflow and commands