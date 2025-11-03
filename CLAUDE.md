# CLAUDE.md - Chezmoi Dotfiles

This repository uses **chezmoi** to manage dotfiles across machines with templating support.

## Essential Commands

```bash
chezmoi diff                  # ALWAYS check before applying
chezmoi apply                 # Apply changes to home directory
chezmoi edit <file>           # Edit managed file
chezmoi cd                    # Navigate to source (~/.local/share/chezmoi)
```

## Key File Naming Rules

- `dot_vimrc` → `~/.vimrc` (dot_ becomes .)
- `file.tmpl` → Processed with Go templates ({{ .chezmoi.os }}, {{ .chezmoi.arch }})
- `run_once_script.sh` → Runs once on apply
- `run_script.sh` → Runs every apply

## Project Structure

- `.chezmoiexternal.toml.tmpl` - External deps (oh-my-zsh, plugins, jq)
- `data/mcp.json` - Claude MCP configuration
- `run_ensure_claude_mcp.sh.tmpl` - Syncs MCP config to ~/.claude.json
- `dot_zshrc` - Zsh config (oh-my-zsh + starship + vi-mode with `jj`)

## Critical Rules

1. **NEVER edit dotfiles directly in ~/** - use `chezmoi edit` instead
2. **ALWAYS run `chezmoi diff`** before `chezmoi apply`
3. **NEVER commit secrets** - they sync to multiple machines
4. **External binaries go in `.chezmoiexternal.toml.tmpl`** - not custom scripts

## Shell Script Style

- Start with `#!/usr/bin/env bash` and `set -euo pipefail`
- Quote variables: `"$VAR"` not `$VAR`
- Use `command -v` not `which`
- Use `[[ ]]` for conditionals

## Adding External Dependencies

Edit `.chezmoiexternal.toml.tmpl`:
```toml
[".local/bin/tool"]
    type = "file"
    url = "https://example.com/tool-{{ .chezmoi.os }}-{{ .chezmoi.arch }}"
    executable = true
    refreshPeriod = "672h"
```

## Workflow

1. `chezmoi edit ~/.file` or edit in source directory
2. `chezmoi diff` to preview changes
3. `chezmoi apply` to apply
4. `cd ~/.local/share/chezmoi && git commit` if good

See AGENTS.md for detailed specifications.
