# External Packages

This document tracks all external packages managed by chezmoi via `.chezmoiexternal.toml.tmpl`.

## Terminology

- **Devcontainer** (user: vscode) - Development environment at `/workspaces/dotfiles` where you edit source files
- **Test container** (user: user) - Isolated Debian container for testing dotfiles

## Installed Packages

| Package | Version | Type | Linux amd64 | Linux arm64 | macOS Intel | macOS ARM | Refresh | Notes |
|---------|---------|------|-------------|-------------|-------------|-----------|---------|-------|
| oh-my-zsh | master | archive | ✓ | ✓ | ✓ | ✓ | 168h | stripComponents=1 |
| zsh-vi-mode | v0.12.0 | archive | ✓ | ✓ | ✓ | ✓ | 168h | oh-my-zsh plugin, stripComponents=1 |
| zsh-autosuggestions | v0.7.1 | archive | ✓ | ✓ | ✓ | ✓ | 168h | oh-my-zsh plugin, stripComponents=1 |
| zsh-syntax-highlighting | v0.8.0 | archive | ✓ | ✓ | ✓ | ✓ | 168h | oh-my-zsh plugin, colors commands as you type, stripComponents=1 |
| jq | v1.8.1 | file | ✓ | ✓ | ✓ | ✓ | 672h | JSON processor, also supports 386 arch |
| fzf | v0.66.1 | archive | ✓ | ✓ | ✓ | ✓ | 672h | Fuzzy finder (Ctrl+R, Ctrl+T, Alt+C) |
| zoxide | v0.9.8 | archive | ✓ | ✓ | ✓ | ✓ | 672h | Smart cd replacement |
| bat | v0.26.0 | archive | ✓ | ✓ | ✓ | ✓ | 672h | cat with syntax highlighting, stripComponents=1 |
| gitui | v0.27.0 | archive-file | ✓ | ✓ | ✓ | ✓ | 672h | Fast terminal UI for git |
| rumdl | v0.0.174 | archive-file | ✓ | ✓ | ✓ | ✓ | 672h | Markdown linter/formatter, markdownlint-compatible, 5x faster, stdin/stdout support |
| glow | v2.1.1 | archive-file | ✓ | ✓ | ✓ | ✓ | 672h | Beautiful markdown reader for terminal, stripComponents=1 |
| mods | v1.8.1 | archive-file | ✓ | ✓ | ✓ | ✓ | 672h | AI on the command line (CLI interface to LLMs), stripComponents=1 |
| gum | v0.17.0 | archive-file | ✓ | ✓ | ✓ | ✓ | 672h | Glamorous shell scripts with spinners/progress indicators, stripComponents=1 |
| freeze | v0.2.2 | archive-file | ✓ | ✓ | ✓ | ✓ | 672h | Generate images of code and terminal output, stripComponents=1 |
| vhs | v0.10.0 | archive-file | ✓ | ✓ | ✓ | ✓ | 672h | Terminal session recorder and GIF generator, write terminal GIFs as code, stripComponents=1 |

**Refresh Periods:**
- `168h` = 7 days (weekly)
- `672h` = 28 days (monthly)

## Instructions for AI Agents Adding New Packages

**CRITICAL: Read these one-line rules before adding any external package:**

1. **ALWAYS review chezmoi external documentation online at https://www.chezmoi.io/reference/special-files/chezmoiexternal-format/ and use context7 to get latest chezmoi docs**
2. **Use `type = "archive-file"` with `path = "binary"` for single-file archives (e.g., tar.gz containing just one binary)**
3. **Use `type = "archive"` for directory structures or when extracting multiple files from an archive**
4. **Use `type = "file"` for direct binary downloads (no archive extraction needed)**
5. **Use `.chezmoi.os` and `.chezmoi.arch` directly in URLs when upstream naming matches (avoid redundant variable assignments)**
6. **Share platform mapping variables when multiple tools use identical naming patterns (e.g., Rust triple targets)**
7. **ALWAYS verify exact artifact names from GitHub releases page before adding URLs**
8. **ALWAYS check if binary supports both amd64 and arm64 architectures for each OS**
9. **Use `stripComponents = 1` when archive wraps files in a single top-level directory**
10. **Set `executable = true` for all binaries**
11. **Use `refreshPeriod = "672h"` (28 days) for stable tools, `"168h"` (7 days) for frequently updated ones**
12. **ALWAYS test additions with `mise run test` in test container before committing**
13. **Document package purpose in a comment above the configuration block**

## Common External Types Reference

```toml
# Single binary file download (no extraction)
[".local/bin/tool"]
    type = "file"
    url = "https://example.com/tool-{{ .chezmoi.os }}-{{ .chezmoi.arch }}"
    executable = true

# Archive containing single binary (tar.gz with one file)
[".local/bin/tool"]
    type = "archive-file"
    url = "https://example.com/tool.tar.gz"
    path = "tool"              # Path to binary inside archive
    executable = true

# Archive with directory structure (extract multiple files)
[".local/bin/tool"]
    type = "archive"
    url = "https://example.com/tool.tar.gz"
    stripComponents = 1        # Strip top-level directory
    executable = true

# Git repository clone
[".oh-my-zsh"]
    type = "git-repo"
    url = "https://github.com/ohmyzsh/ohmyzsh.git"
    refreshPeriod = "168h"
```

## Platform Variable Patterns

### Pattern 1: Direct Variable Use (fzf style)
```toml
# When the upstream uses chezmoi's naming directly, no mapping needed
url = "https://example.com/tool-{{ .chezmoi.os }}_{{ .chezmoi.arch }}.tar.gz"
```

### Pattern 2: Simple OS/Arch Remapping (jq style)
```toml
{{- $jqOS := .chezmoi.os }}
{{- if eq .chezmoi.os "darwin" }}
{{-   $jqOS = "macos" }}
{{- end }}
```

### Pattern 3: Shared Variable for Multiple Tools (Rust triple style)
```toml
# Define once, use for multiple tools with same naming
{{- $rustTriple := "" }}
{{- if eq .chezmoi.os "linux" }}
{{-   if eq .chezmoi.arch "amd64" }}
{{-     $rustTriple = "x86_64-unknown-linux-musl" }}
{{-   else if eq .chezmoi.arch "arm64" }}
{{-     $rustTriple = "aarch64-unknown-linux-musl" }}
{{-   end }}
{{- else if eq .chezmoi.os "darwin" }}
{{-   if eq .chezmoi.arch "amd64" }}
{{-     $rustTriple = "x86_64-apple-darwin" }}
{{-   else if eq .chezmoi.arch "arm64" }}
{{-     $rustTriple = "aarch64-apple-darwin" }}
{{-   end }}
{{- end }}

# Used by both zoxide and bat
url = "https://example.com/tool-{{ $rustTriple }}.tar.gz"
```

### Pattern 4: Custom Platform Names (gitui style)
```toml
{{- $target := "" }}
{{- if eq .chezmoi.os "linux" }}
{{-   if eq .chezmoi.arch "amd64" }}
{{-     $target = "linux-x86_64" }}
{{-   else if eq .chezmoi.arch "arm64" }}
{{-     $target = "linux-aarch64" }}
{{-   end }}
{{- else if eq .chezmoi.os "darwin" }}
{{-   if eq .chezmoi.arch "amd64" }}
{{-     $target = "mac-x86" }}
{{-   else if eq .chezmoi.arch "arm64" }}
{{-     $target = "mac" }}
{{-   end }}
{{- end }}
```

## Troubleshooting Guide

### "inconsistent state" Error
- **Cause:** Multiple `[".local/bin/tool"]` sections for same target path
- **Solution:** Use conditional blocks or ensure only one section defines the target

### Wrong External Type Symptoms
- `archive` used for single binary → creates nested directory instead of binary at target path
- `archive-file` without `path` → error about missing required field
- `file` used for archive → binary won't be extracted/executable

### Testing Workflow
```bash
# 1. Edit .chezmoiexternal.toml.tmpl
chezmoi edit .chezmoiexternal.toml.tmpl

# 2. Test in test container
mise run test

# 3. Check for successful binary installation in test output
# Look for: "diff --git a/.local/bin/TOOL b/.local/bin/TOOL"

# 4. If successful, apply to your system
chezmoi apply
```

## Version Update Procedure

1. Check project GitHub releases page for latest version
2. Update version number in URL
3. Verify artifact naming hasn't changed
4. Test with `mise run test`
5. Commit changes with descriptive message

## Additional Resources

- [Chezmoi External Format Reference](https://www.chezmoi.io/reference/special-files/chezmoiexternal-format/)
- [Chezmoi Template Variables](https://www.chezmoi.io/reference/templates/variables/)
- [Chezmoi Install Guide](https://www.chezmoi.io/install/)
