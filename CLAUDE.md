# CLAUDE.md - Quick Reference for AI Agents

**IMPORTANT: Read AGENTS.md for comprehensive workflows and implementation details, including those in subdirectories (e.g., tests/AGENTS.md).**
**IMPORTANT: Read TESTING.md for comprehensive workflows on writing and running tests**

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
15. **Use template variables from `.chezmoi.toml.tmpl` for OS conditionals** - prefer `{{ if .isWSL }}` over bash detection, enables conditional file inclusion
16. **`.chezmoiscripts/` is for chezmoi scripts only** - `run_once_`, `run_after_`, etc. Not for arbitrary files
17. **Store git hooks in `hooks/` directory** - install to `.git/hooks/` via run_once scripts
18. **No OS-specific file suffixes exist in chezmoi** - use template conditionals `{{ if eq .chezmoi.os "darwin" }}` for OS-specific content, not fictional suffixes like `_darwin`
1. **Bash functions don't work with `gum spin`** - `gum spin` runs commands in subshells where functions aren't available; inline commands or use scripts
2. **Always check exit codes after `gum spin` commands** - wrap in `if !` conditionals to detect failures and trigger fallback behavior
1. **Chezmoi installer needs absolute BINDIR path** - use `-b "$HOME/.local/bin"` flag; default `.local/bin` is relative to current directory
2. **Claude's --append-system-prompt requires inline content and concatenation** - flag accepts text content only (not file paths), and multiple flags override each other (last wins), so merge all prompts into a single flag
3. **Read MISE-USAGE.md before installing tools or packages** - comprehensive guide for AI agents on using mise correctly
4. **NEVER hardcode mise installation paths** - always use `mise where tool-name` to get dynamic paths
5. **NEVER hardcode mise backends** - let mise auto-detect from registry (use `mise use bats@latest`, not `mise use aqua:bats-core/bats-core`)
6. **Use `mise activate bash --shims` for non-interactive contexts** - CI, Docker, scripts; use `mise activate bash` for interactive shells
1. **Both mise activation modes can coexist** - `mise activate` removes shims from PATH, safe to have both in .bash_profile and .bashrc
1. **Never use `path` as a variable name in zsh** - it's a special tied array that mirrors `PATH`; declaring `local path` clears your entire PATH
2. **Declare `local` variables outside loops in zsh** - `local`/`typeset` prints existing variable values; inside loops this causes trace-like output on subsequent iterations
3. **When debugging issues, assume bugs are in your code first** - investigate and test your own code before suggesting the user's environment or setup is the problem

## Quick Reference

**In devcontainer (editing and testing):**

```bash
vim dot_zshrc.tmpl            # Edit source files directly
git add . && git commit       # Commit changes
mise run test                 # Test in test container
mise run test:interactive     # Test + interactive shell
```

**Enhanced chezmoi apply wrapper:**

```bash
chezmoi-apply                 # Wrapper with gum spinner + live output
cm-apply                      # Alias for chezmoi-apply (if in zsh)
chezmoi apply                 # Standard chezmoi (no enhancement)
```

**On local machine (if not in devcontainer):**
See AGENTS.md "Making Changes to Existing Dotfiles" for local machine workflows.

## Key Information

**Supported platforms:** Linux, macOS, WSL (uses Linux binaries)

**Template variables (from `.chezmoi.toml.tmpl`):**

- `.chezmoi.os`, `.chezmoi.arch` - Platform detection
- `.isWork`, `.isHome` - Machine-specific flags
- `.isDevContainer` - True in devcontainers/Codespaces
- `.isWSL` - True in Windows Subsystem for Linux
- `.isWindows` - True for native Windows or WSL
- Use these for OS conditionals: `{{- if .isWSL }}...{{- end }}`
- Prefer template logic over bash detection (enables conditional file inclusion)

**Shell script standards:** `#!/usr/bin/env bash` with `set -euo pipefail`, quote variables, use `command -v` not `which`

**Git configuration:** Uses `[include]` mechanism, setup is automatic via `run_once_after` script

**Claude Code custom instructions:** Located in `dot_config/claude/custom.d/`, deployed to `~/.config/claude/custom.d/`

- Files loaded in alphabetical order (00-, 01-, 02- prefixes control order)
- Automatically injected via wrapper when running `claude` command
- See dot_config/zsh/tools/claude.zsh.tmpl for wrapper implementation

**Productivity tools:** glow (markdown viewer), mods (AI CLI), taskwarrior + taskwarrior-tui (task management)

**Quick commands:**

```bash
glow file.md              # View markdown beautifully
mods "question"           # Ask AI anything
ai "question"             # Alias for mods
task add "todo"           # Add task
tt                        # Open taskwarrior TUI
note "capture this"       # Quick note to inbox
research "topic"          # AI research → markdown
```

**Todoist integration (via MCP):**

```bash
/todo                     # Top 10 urgent (p1) tasks today + overdue
/todo 5                   # Top 5 urgent tasks
/todo 20                  # Top 20 urgent tasks
/todo urgent              # High priority (p1 + p2) tasks
/todo work                # Urgent tasks in Work project
/todo tomorrow            # Urgent tasks due tomorrow
/todo this week           # Urgent tasks due this week
/todo overdue             # Only overdue urgent tasks
/todo "review PR"         # Search tasks matching text
```

## See Also

- **[AGENTS.md](AGENTS.md)** - Detailed workflows, troubleshooting, implementation patterns
- **[tests/AGENTS.md](tests/AGENTS.md)** - CRITICAL: Test environment guide (devcontainer vs test container)
- **[MISE-USAGE.md](MISE-USAGE.md)** - Tool version management with mise (read before installing packages)
- **[EXTERNAL.md](EXTERNAL.md)** - External packages reference and instructions for adding packages
- **[TESTING.md](TESTING.md)** - Testing workflow and commands
- **Logging Helpers** - `.chezmoiscripts/lib/logging.sh` - DRY logging functions with gum enhancement
