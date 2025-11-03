# AGENTS.md

This repository manages dotfiles using **chezmoi** - a dotfile management tool with templating support.

## Overview

**Repository Type:** Dotfiles configuration
**Primary Tool:** chezmoi
**Languages:** Shell, Go Templates, TOML, JSON
**Target:** Linux/macOS personal development environment

## Dev Environment Setup

### Initial Setup
```bash
# Clone and initialize
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply bxm156

# Navigate to source directory
chezmoi cd
```

### Directory Structure
- Source state: `~/.local/share/chezmoi`
- Target state: `~` (home directory)
- All files in source are prefixed/suffixed according to chezmoi conventions

### Required Tools
- **chezmoi** - Dotfile manager
- **git** - Version control
- **jq** - JSON processor (auto-installed via .chezmoiexternal.toml.tmpl)
- **curl/wget** - For downloading external dependencies

## Commands

### Primary Workflow
```bash
# Check status
chezmoi status

# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Refresh external dependencies (oh-my-zsh, plugins, binaries)
chezmoi apply --refresh-externals

# Edit a file in source state
chezmoi edit ~/.vimrc

# Add new file to chezmoi
chezmoi add ~/.newfile

# Test template rendering
chezmoi execute-template < path/to/file.tmpl
```

### File Operations
```bash
# Navigate to source directory
chezmoi cd

# Update from git and apply
chezmoi update

# Pull latest without applying
cd ~/.local/share/chezmoi && git pull
```

## Code Conventions

### Do ✅

**File Naming:**
- Use chezmoi naming conventions:
  - `dot_` → creates `.` prefix in home dir
  - `.tmpl` → template file (Go templating)
  - `run_once_` → script runs once
  - `executable_` → sets executable permissions
  - `private_` → sets 0600 permissions

**Shell Scripts:**
- Start with `#!/usr/bin/env bash`
- Include `set -euo pipefail` for safety
- Quote all variables: `"$VAR"` not `$VAR`
- Use `command -v` to check for commands
- Use `[[ ]]` for conditionals

**Templates:**
- Use `{{- }}` to trim whitespace
- Keep template logic simple
- Test with `chezmoi execute-template`
- Document complex logic

**External Dependencies:**
- Add to `.chezmoiexternal.toml.tmpl`
- Include `refreshPeriod` for auto-updates
- Set `executable = true` for binaries
- Use template variables for OS/arch-specific URLs

**Git Workflow:**
- Test with `chezmoi diff` before applying
- Commit from source directory: `chezmoi cd`
- Write clear commit messages
- Never commit secrets

### Don't ❌

- Don't edit files in `~` directly - use `chezmoi edit`
- Don't commit secrets or API keys
- Don't use hardcoded paths - use chezmoi template variables
- Don't skip `chezmoi diff` before applying
- Don't modify managed files outside of chezmoi
- Don't use `which` - use `command -v` instead
- Don't use unquoted variables in shell scripts
- Don't add external dependencies as manual scripts - use `.chezmoiexternal.toml.tmpl`

## Architecture

### Template System
Chezmoi uses Go's `text/template` syntax. Key variables:

```go
{{ .chezmoi.os }}           // "linux", "darwin", etc.
{{ .chezmoi.arch }}         // "amd64", "arm64", etc.
{{ .chezmoi.hostname }}     // machine hostname
{{ .chezmoi.username }}     // current user
{{ .chezmoi.sourceDir }}    // source directory path
{{ .chezmoi.homeDir }}      // home directory path
```

### External Dependency Management
`.chezmoiexternal.toml.tmpl` handles:
- Git repositories (oh-my-zsh, plugins)
- Binary downloads (jq, tools)
- Archives and compressed files
- OS/architecture-specific assets

Types: `file`, `archive`, `archive-file`, `git-repo`

### Scripts
- `run_once_*.sh` - Execute once (tracked in state)
- `run_*.sh` - Execute on every `chezmoi apply`
- Scripts run in sorted order

### Configuration Data
`data/*.json` files provide data for templates:
- `mcp.json` - Claude MCP server configuration

## Testing

### Before Committing
```bash
# 1. Check diff
chezmoi diff

# 2. Test templates
chezmoi execute-template < file.tmpl

# 3. Verify apply works
chezmoi apply --dry-run --verbose

# 4. Apply for real
chezmoi apply

# 5. Test in clean environment if possible
```

### Validation Commands
```bash
# Verify shell scripts
shellcheck script.sh

# Check JSON validity
jq empty data/mcp.json

# Verify TOML syntax
chezmoi execute-template < .chezmoiexternal.toml.tmpl | grep -v '^$'
```

## Pull Request Instructions

### Before Submitting
1. Run `chezmoi diff` to verify changes
2. Test template rendering for `.tmpl` files
3. Verify no secrets are committed
4. Update CLAUDE.md or AGENTS.md if adding new patterns
5. Test on target system if possible

### Title Format
```
type: brief description

Examples:
feat: add neovim configuration
fix: correct jq download URL for macOS
docs: update CLAUDE.md with new conventions
chore: update oh-my-zsh to latest
```

### Checklist
- [ ] No secrets or sensitive data
- [ ] Templates render correctly
- [ ] Shell scripts pass shellcheck
- [ ] External URLs are valid and accessible
- [ ] Changes tested with `chezmoi apply`

## Project-Specific Notes

### MCP Integration
- Claude MCP configuration managed via `data/mcp.json`
- Synced to `~/.claude.json` via `run_ensure_claude_mcp.sh.tmpl`
- Uses local or system `jq` (auto-downloaded if missing)

### Zsh Setup
- Framework: oh-my-zsh (auto-updated weekly)
- Plugins: git, cp, zsh-vi-mode, zsh-autosuggestions, mise
- Prompt: Starship
- Vi mode with `jj` escape

### SSH Configuration
- Templated configs in `.chezmoitemplates/.ssh/`
- Manage keys and config separately

## Common Patterns

### Adding OS-Specific Config
```toml
{{- if eq .chezmoi.os "darwin" }}
# macOS-specific config
{{- else if eq .chezmoi.os "linux" }}
# Linux-specific config
{{- end }}
```

### Adding External Binary
```toml
[".local/bin/tool"]
    type = "file"
    url = "https://example.com/tool-{{ .chezmoi.os }}-{{ .chezmoi.arch }}"
    executable = true
    refreshPeriod = "672h"  # 4 weeks
```

### Creating Run-Once Script
1. Create `.chezmoiscripts/run_once_install-something.sh`
2. Make executable: `chmod +x script.sh`
3. Chezmoi will execute it once on next apply

## Help & Resources

- Chezmoi docs: https://www.chezmoi.io/
- Template reference: https://www.chezmoi.io/reference/templates/
- External format: https://www.chezmoi.io/reference/special-files/chezmoiexternal-format/
