# CLAUDE.md - Chezmoi Dotfiles

**IMPORTANT: AI agents must read AGENTS.md for comprehensive workflow and implementation details.**

This repository uses **chezmoi** to manage dotfiles across machines with templating support.

## Critical Rules (One-Line Each)

1. **NEVER edit files in ~/ directly** - always use `chezmoi edit` or edit in source directory
2. **NEVER run `chezmoi apply` in devcontainer** - ONLY test with `mise run test` in isolated container
3. **ALWAYS run `chezmoi diff` before any apply** - preview changes before applying
4. **NEVER commit secrets or sensitive data** - dotfiles sync across multiple machines
5. **External binaries MUST go in `.chezmoiexternal.toml.tmpl`** - not custom download scripts
6. **Templates use Go syntax** - `{{ .chezmoi.os }}`, `{{ .chezmoi.arch }}`, `{{ .isWork }}`
7. **File naming determines behavior** - `dot_` becomes `.`, `.tmpl` gets processed, `run_once_` runs once
8. **Test in container before applying** - use `mise run test` to validate changes safely
9. **Scripts must be idempotent** - safe to run multiple times without side effects
10. **Use mise for task automation** - defined in `.mise.toml` for testing and development
11. **Document template variables in `.chezmoi.toml.tmpl`** - centralize data definitions

## Quick Reference

```bash
chezmoi diff                  # Preview changes
chezmoi apply                 # Apply to home directory
chezmoi edit ~/.zshrc         # Edit managed file
mise run test                 # Test in isolated container
```

## Key Files

- `.chezmoi.toml.tmpl` - Template variables and configuration
- `.chezmoiexternal.toml.tmpl` - External dependencies (oh-my-zsh, starship, tools)
- `dot_zshrc.tmpl` - Zsh configuration with oh-my-zsh + starship
- `.mise.toml` - Task automation (test, test:interactive)
- `docker-compose.yml` - Test container configuration

## Shell Script Standards

- Shebang: `#!/usr/bin/env bash` with `set -euo pipefail`
- Variables: Always quote `"$VAR"` not `$VAR`
- Command checks: `command -v` not `which`
- Conditionals: `[[ ]]` not `[ ]`

See **AGENTS.md** for detailed workflows, troubleshooting, and implementation patterns.
