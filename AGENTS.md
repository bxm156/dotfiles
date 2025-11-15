# AGENTS.md - Chezmoi Dotfiles Implementation Guide

Comprehensive guide for AI agents working with this chezmoi-managed dotfiles repository.

## Terminology

- **Devcontainer** (user: vscode) - Development environment at `/workspaces/dotfiles` where you edit source files
- **Test container** (user: user) - Isolated Debian container built via `Dockerfile.test` and `docker-compose.yml` for testing dotfiles

## Critical Path Definitions

### Devcontainer (Development Environment)
- **User**: vscode
- **Source Directory**: `/workspaces/dotfiles`
- **Purpose**: Where you edit chezmoi source files with special naming conventions
- **Key Point**: NEVER run `chezmoi apply` here - only edit and test

### Test Container (Isolated Testing Environment)
- **User**: user (UID 3000)
- **Built From**: `Dockerfile.test` and `docker-compose.yml`
- **Source Mount**: `/home/user/.local/share/chezmoi` (read-only, mounted from devcontainer `/workspaces/dotfiles`)
- **Target Directory**: `/home/user` (where dotfiles get applied during test)
- **Purpose**: Safe, isolated environment to test dotfiles before applying to real systems

### Local Machine (Your Real System)
- **Source Directory**: `~/.local/share/chezmoi`
- **Target Directory**: `~` (where dotfiles are actually used)
- **Key Point**: Never edit files in `~` directly - always edit in source directory

## Understanding Chezmoi

**⚠️ CRITICAL WARNING FOR AI AGENTS: NEVER run `chezmoi apply` in the devcontainer. ONLY test changes using `mise run test` which runs in the test container. The devcontainer is for editing source files only.**

Chezmoi manages dotfiles across multiple machines using:
- **Templating**: Machine-specific configurations with Go templates
- **External Dependencies**: Auto-downloads tools, plugins, binaries
- **Safe Workflows**: Preview before applying changes
- **State Tracking**: Knows what's been applied and when

### File Naming Conventions

**IMPORTANT: The `dot_` prefix is how chezmoi creates hidden files (those starting with `.`)**

| Source Filename | Target Result | Notes |
|----------------|---------------|-------|
| `dot_zshrc` | `~/.zshrc` | `dot_` → `.` (creates hidden file) |
| `dot_config/starship.toml` | `~/.config/starship.toml` | `dot_` → `.` (creates hidden directory) |
| `notes/README.md` | `~/notes/README.md` | No `dot_` = visible directory |
| `dot_notes/README.md` | `~/.notes/README.md` | `dot_` → `.` (creates HIDDEN directory) |
| `file.tmpl` | `~/file` | Template processed, `.tmpl` removed |
| `dot_zshrc.tmpl` | `~/.zshrc` | Both transformations applied |
| `run_once_install.sh` | Executed once | Runs on first apply only |
| `run_script.sh` | Executed always | Runs every apply |
| `executable_script` | Made executable | Preserves executable bit |

**Key Rule:** Use `dot_` prefix ONLY when you want the file/directory to be hidden (start with `.`). For visible files/directories like `~/notes/`, use the name directly without `dot_` prefix.

### Template Processing Flow

```
Source File (with .tmpl) → Go Template Processing → Target File
                              ↓
                    Uses variables from .chezmoi.toml.tmpl
```

### Execution Order

**Understanding when things happen during `chezmoi apply` is critical for scripts that depend on external files.**

chezmoi executes operations in this deterministic order:

1. **Read states** - Read source, destination, and compute target state
2. **Run `run_before_` scripts** - Execute in alphabetical order
3. **Update all entries** - Files, directories, externals, symlinks (alphabetically by target name)
4. **Run `run_after_` scripts** - Execute in alphabetical order

**Key rules:**

- **External files are installed during step 3** (the update phase) alphabetically
- **Scripts without `_before_` or `_after_` run during step 3**, mixed alphabetically with files/externals
- **Alphabetical ordering matters**: `run_merge.sh` runs BEFORE `.local/bin/jq` is installed
- **`run_after_` scripts can safely depend on externals** - they run AFTER all externals are installed
- **`run_before_` scripts CANNOT depend on externals** - externals aren't installed yet

**Example problem:**
```bash
# ❌ WRONG: This runs during step 3, might execute before jq is installed
.chezmoiscripts/run_merge-json.sh   # "merge" < "local" alphabetically

# ✅ CORRECT: This runs in step 4, after ALL externals are installed
.chezmoiscripts/run_after_merge-json.sh
```

**Reference:** [Official Chezmoi Application Order](https://www.chezmoi.io/reference/application-order/)

## Tool Version Management with Mise

**⚠️ CRITICAL: Read [MISE-USAGE.md](MISE-USAGE.md) for comprehensive mise documentation before installing packages or tools.**

This repository uses **mise** for managing development tool versions, replacing git submodules and manual tool installation.

### Quick Reference

**Installing tools:**

```bash
# Install all tools defined in mise.toml
mise install

# Install specific tool (mise auto-detects backend)
mise use node@20
mise use python@3.11
mise use bats@latest

# Use explicit backend when necessary
mise use npm:prettier
mise use cargo:ripgrep
```

**Getting tool paths (NEVER hardcode paths):**

```bash
# Get installation directory
TOOL_DIR=$(mise where tool-name)

# Find files within installation
find "$(mise where npm:bats-support)" -name "load.bash"
```

**Activation patterns:**

```bash
# Interactive shells (full activation)
eval "$(mise activate bash)"

# Non-interactive/CI (shims only)
eval "$(mise activate bash --shims)"
```

### Key Principles for Agents

1. **Never hardcode paths** - Always use `mise where <tool>` to get installation directories
2. **Never hardcode backends** - Let mise auto-detect unless absolutely necessary
3. **Use shims for CI/Docker** - Non-interactive contexts need `--shims` activation
4. **Use full activation for development** - Interactive shells benefit from full `mise activate`
5. **Check configuration** - Run `mise doctor` to diagnose issues

### Common Mistakes to Avoid

❌ **DON'T hardcode paths:**

```bash
load '/home/user/.local/share/mise/installs/npm-bats-support/0.3.0/lib/node_modules/bats-support/load'
```

✅ **DO use dynamic paths:**

```bash
SUPPORT_LOAD="$(find "$(mise where npm:bats-support)" -name "load.bash" -path "*/bats-support/load.bash")"
load "${SUPPORT_LOAD%.bash}"
```

❌ **DON'T use hardcoded shims directory:**

```bash
export PATH="$HOME/.local/share/mise/shims:$PATH"
```

✅ **DO use mise activate:**

```bash
eval "$(mise activate bash --shims)"
```

**For complete mise documentation, see [MISE-USAGE.md](MISE-USAGE.md).**

## Repository Structure

```
/workspaces/dotfiles/          # SOURCE DIRECTORY (edit here)
├── .chezmoi.toml.tmpl         # Template variables & configuration
├── .chezmoiexternal.toml.tmpl # External dependencies (oh-my-zsh, tools)
├── .chezmoiignore             # Files to skip during apply
├── .chezmoiscripts/           # Scripts executed during apply
│   └── run_once_install-starship.sh
├── data/                      # Data files for templates
│   └── mcp.json.tmpl         # Claude MCP configuration
├── dot_zshrc.tmpl            # → ~/.zshrc (Zsh config)
├── dot_config/               # → ~/.config/ directory
│   └── starship.toml         # → ~/.config/starship.toml
├── dot_claude/               # → ~/.claude/ directory
│   └── settings.json.tmpl    # → ~/.claude/settings.json
├── .mise.toml                # Task automation (test commands)
├── docker-compose.yml        # Test container configuration
├── CLAUDE.md                 # Quick reference rules
└── AGENTS.md                 # This file - detailed guide
```

### Key Files Explained

- **`.chezmoi.toml.tmpl`** - Template variables and configuration (processed on first apply)
- **`.chezmoiexternal.toml.tmpl`** - External dependencies (oh-my-zsh, starship, tools)
- **`dot_zshrc.tmpl`** - Zsh configuration with oh-my-zsh + starship
- **`dot_gitconfig.d/default.tmpl`** - Git configuration (merges with existing .gitconfig via include)
- **`.mise.toml`** - Task automation (test, test:interactive, test:shell)
- **`docker-compose.yml`** - Test container configuration
- **`Dockerfile.test`** - Test container image definition
- **`test-dotfiles.sh`** - Test script executed in test container

## Platform Support

**Supported platforms:**
- Linux (native) - amd64, arm64
- macOS (darwin) - Intel (amd64), Apple Silicon (arm64)
- WSL (Windows Subsystem for Linux) - fully supported, uses Linux binaries

**WSL-specific details:**
- Automatically detected via kernel signature check in `.chezmoi.toml.tmpl`
- All Unix tools work: zsh, oh-my-zsh, starship, fzf, zoxide, bat, jq
- Template variables available:
  - `.isWSL` - true when running in WSL
  - `.isWindows` - true on Windows or WSL
- Use WSL-specific configuration when needed (e.g., Windows filesystem access at `/mnt/c/`)

**Architecture support:**
- Most tools support amd64 (x86_64) and arm64 (aarch64)
- Some tools use different naming conventions (e.g., Rust uses target triples)
- Check GitHub releases for exact artifact names before adding to `.chezmoiexternal.toml.tmpl`

## Template System

### Template Variables in `.chezmoi.toml.tmpl`

```toml
[data]
  # Hostname-based environment detection
  isWork = {{ contains "yelp" .chezmoi.hostname }}
  isHome = {{ contains "home" .chezmoi.hostname }}

  # Devcontainer detection
  isDevContainer = {{ or (env "REMOTE_CONTAINERS") (env "CODESPACES") | not | not }}

  # Auth token (safe - references keychain)
  authToken = "bmarty/claudecode"
```

### Built-in Chezmoi Variables

```go
{{ .chezmoi.os }}           // Operating system: "linux", "darwin", "windows"
{{ .chezmoi.arch }}         // Architecture: "amd64", "arm64", "386"
{{ .chezmoi.hostname }}     // Machine hostname
{{ .chezmoi.username }}     // Current username
{{ .chezmoi.homeDir }}      // Home directory absolute path
{{ .chezmoi.sourceDir }}    // Source directory absolute path
{{ .chezmoi.kernel.osrelease }} // Kernel release (for WSL detection)
```

### Custom Template Variables (from .chezmoi.toml.tmpl)

```go
{{ .isWork }}               // true on work machines
{{ .isHome }}               // true on home machines
{{ .isDevContainer }}       // true in devcontainer/codespaces
{{ .isWSL }}                // true when running in WSL
{{ .isWindows }}            // true on Windows or WSL
```

### Template Examples

**Conditional Configuration:**
```go
{{- if .isWork }}
export WORK_VAR="internal-value"
{{- else }}
export PERSONAL_VAR="public-value"
{{- end }}
```

**Platform-Specific:**
```go
{{- if eq .chezmoi.os "darwin" }}
alias ls='ls -G'
export HOMEBREW_PREFIX="/opt/homebrew"
{{- else if eq .chezmoi.os "linux" }}
alias ls='ls --color=auto'
{{- end }}
```

**WSL-Specific:**
```go
{{- if .isWSL }}
# WSL-specific configuration (e.g., access Windows filesystem)
export WINDOWS_HOME="/mnt/c/Users/{{ .chezmoi.username }}"
alias windir='cd "$WINDOWS_HOME"'
{{- end }}
```

**Including External Data:**
```go
{{- $mcpData := includeTemplate "data/mcp.json.tmpl" . | fromJson }}
"mcpServers": {{ $mcpData.mcpServers | toPrettyJson | indent 2 }}
```

## Testing Workflow

### Overview

Testing happens in the **test container** (user: user), an isolated Debian environment built from `Dockerfile.test` and `docker-compose.yml` that simulates a fresh user environment.

### Running Tests

```bash
# Automated test (runs chezmoi apply and validates)
mise run test

# Interactive test (drops into shell for manual testing)
mise run test:interactive
```

### What `mise run test` Does

1. **Builds test container** from `Dockerfile.test` (Debian bookworm-slim, user UID 3000)
2. **Starts test container** via `docker-compose.yml`
3. **Mounts devcontainer source** at `/home/user/.local/share/chezmoi` (read-only from `/workspaces/dotfiles`)
4. **Runs test-dotfiles.sh** which:
   - Installs chezmoi to `/home/user/.local/bin`
   - Applies dotfiles with `chezmoi apply -v`
   - Installs external dependencies (oh-my-zsh, starship, tools)
   - Validates installation:
     - Zsh starts successfully
     - Binaries are executable files (not directories)
     - Shell config loads without errors

### Test Container Configuration

**Dockerfile.test:**
- Base: `debian:bookworm-slim` - Clean, minimal Debian environment
- User: `user` (UID 3000, GID 3000) - Matches devcontainer user to avoid permission issues
- Entrypoint: `/usr/local/bin/test-dotfiles.sh` - Always runs tests before shell access

**docker-compose.yml:**
- Source mount: `./:/home/user/.local/share/chezmoi:ro` - Read-only mount from devcontainer
- Platform: `linux/amd64` - Ensures consistent architecture
- TTY: `stdin_open: true, tty: true` - Enables interactive shell after tests

### Testing Workflow

1. **Edit files** in devcontainer at `/workspaces/dotfiles/`
2. **Run test** in test container: `mise run test`
3. **Check output** for errors/warnings
4. **Fix issues** in devcontainer and retest
5. **Apply locally** to your real machine (optional): `chezmoi apply`
6. **Commit** when satisfied

### Interactive Testing

```bash
# Test container: Run tests then drop into zsh shell (dotfiles installed)
mise run test:interactive

# Test container: Raw bash shell without dotfiles (debugging only)
mise run test:shell

# Inside test container, explore applied configuration:
cat ~/.zshrc
starship --version
exit
```

## Git Configuration Strategy

This repository uses git's native `[include]` mechanism to merge managed settings with existing configurations.

### Structure

```
~/.gitconfig              # Your existing config (unmanaged)
~/.gitconfig.d/
  ├── default             # Managed by chezmoi (identity, signing, core)
  ├── work                # Future: work-specific overrides
  └── personal            # Future: personal project overrides
```

### Automatic Setup

On first `chezmoi apply`, a `run_once_after` script automatically adds this to your `~/.gitconfig`:

```ini
[include]
	path = ~/.gitconfig.d/default
```

**Script:** `.chezmoiscripts/run_once_after_setup-gitconfig-include.sh`
- Runs once after files are applied
- Creates `~/.gitconfig` if it doesn't exist
- Adds include directive if not already present
- Preserves any existing content

### How It Works

1. **Git reads** `~/.gitconfig` first (your local aliases, preferences)
2. **Then includes** `~/.gitconfig.d/default` (managed identity, signing, core settings)
3. **Last value wins** - included settings override earlier ones

### Benefits

- ✅ **Non-destructive** - preserves existing `.gitconfig`
- ✅ **Clear separation** - managed vs local settings
- ✅ **Flexible** - add work/personal includes conditionally
- ✅ **Git native** - uses built-in include mechanism

### Future Expansion

For work-specific git identity:

```ini
# In ~/.gitconfig
[includeIf "gitdir:~/work/"]
	path = ~/.gitconfig.d/work
```

## Common Tasks

### Adding a New Dotfile

```bash
# 1. Create source file in devcontainer with chezmoi naming
touch dot_gitconfig           # For static file
touch dot_zshrc.tmpl          # For template file

# 2. Edit with your configuration in devcontainer
vim dot_gitconfig

# 3. Test in test container
mise run test

# 4. Preview what will be applied on your local machine (optional)
chezmoi diff

# 5. Commit from devcontainer
git add dot_gitconfig
git commit -m "Add gitconfig with core settings"
```

### Adding External Dependencies

**📖 AI agents MUST read [EXTERNAL.md](EXTERNAL.md) before adding or modifying any external packages in `.chezmoiexternal.toml.tmpl`.**

Edit `.chezmoiexternal.toml.tmpl`:

```toml
# Download binary from GitHub releases
[".local/bin/tool"]
    type = "file"
    url = "https://github.com/owner/repo/releases/download/v1.0.0/tool-{{ .chezmoi.os }}-{{ .chezmoi.arch }}"
    executable = true
    refreshPeriod = "672h"  # Recheck weekly

# Extract from tar.gz archive
[".local/bin/another-tool"]
    type = "archive"
    url = "https://releases.example.com/tool-{{ .chezmoi.os }}.tar.gz"
    stripComponents = 1
    executable = true
    refreshPeriod = "168h"

# Clone git repository
[".oh-my-zsh/custom/plugins/my-plugin"]
    type = "archive"
    url = "https://github.com/user/plugin/archive/refs/heads/main.tar.gz"
    exact = true
    stripComponents = 1
    refreshPeriod = "168h"
```

**Platform-specific URLs:**
```toml
{{- $myArch := .chezmoi.arch }}
{{- if eq .chezmoi.arch "amd64" }}
{{-   $myArch = "x86_64" }}
{{- end }}

[".local/bin/tool"]
    url = "https://example.com/tool-{{ .chezmoi.os }}-{{ $myArch }}"
```

### Adding Installation Scripts

Create in `.chezmoiscripts/`:

**Run once (e.g., install tool):**
```bash
# .chezmoiscripts/run_once_install-tool.sh
#!/usr/bin/env bash
set -euo pipefail

if command -v tool >/dev/null 2>&1; then
    echo "tool already installed"
    exit 0
fi

# Non-interactive installation
curl -sS https://install.example.com/tool.sh | sh -s -- -y
```

**Run on every apply:**
```bash
# .chezmoiscripts/run_update-something.sh
#!/usr/bin/env bash
set -euo pipefail

# Update configuration that changes frequently
echo "Updating timestamps..."
```

**Platform-specific script:**
```bash
# .chezmoiscripts/run_once_install-linux-tool.sh.tmpl
{{- if eq .chezmoi.os "linux" }}
#!/usr/bin/env bash
set -euo pipefail

# Linux-specific installation
{{- end }}
```

### Shell Script Standards

All bash scripts in this repository must follow these conventions:

**Required shebang and options:**
```bash
#!/usr/bin/env bash
set -euo pipefail
```

- `set -e` - Exit on error
- `set -u` - Exit on undefined variable
- `set -o pipefail` - Exit on pipe failure

**Variable quoting:**
```bash
# Good
echo "$VAR"
path="$HOME/directory"

# Bad
echo $VAR
path=$HOME/directory
```

**Command availability checks:**
```bash
# Good
if command -v tool >/dev/null 2>&1; then
    echo "tool is available"
fi

# Bad
if which tool; then
    echo "tool is available"
fi
```

**Conditionals:**
```bash
# Good - use [[ ]] for bash
if [[ -f "$file" ]]; then
    echo "file exists"
fi

# Avoid - [ ] is POSIX but less powerful
if [ -f "$file" ]; then
    echo "file exists"
fi
```

**Idempotency:**
- Always check if work is already done before executing
- Scripts must be safe to run multiple times
- Use `run_once_` prefix for one-time installation scripts

**Non-interactive installation:**
- Use `-y`, `--yes`, or similar flags to avoid prompts
- Set environment variables to disable interactive behavior
- Test container has no TTY for automated scripts

**PATH considerations:**
- Scripts inherit PATH at startup and don't pick up newly installed binaries
- When installing binaries, use full paths for subsequent commands in same script
- Example: After installing to `~/.local/bin/tool`, use `$HOME/.local/bin/tool` not `tool`
- Never assume a just-installed binary is in PATH during same script execution

### Logging Helpers

All chezmoi scripts should use the logging helper library for consistent, enhanced output:

**Source the library:**
```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/logging.sh"
```

**Available functions:**
- `log_info "message"` - Informational messages (blue)
- `log_success "message"` - Success messages (green) with ✓
- `log_error "message"` - Error messages (red) with ✗ (goes to stderr)
- `log_warning "message"` - Warning messages (yellow) with ⚠️
- `log_progress "message"` - In-progress operations (cyan) with ⏳
- `log_section "Section Name"` - Section headers with borders
- `log_binary "name" "installing|installed"` - Binary installation tracking
- `log_script "script-name.sh"` - Script execution tracking

**Automatic gum enhancement:**
- If gum is available: colored, styled output
- If gum is unavailable: plain text with emojis (graceful degradation)

**Message format:**
All functions emit structured format: `[LEVEL] emoji message`
Example: `[SUCCESS] ✓ Binary installed successfully`

### Modifying Template Variables

Edit `.chezmoi.toml.tmpl` to add/modify variables:

```toml
[data]
  # Add new variable
  isDevelopment = {{ not .isWork }}

  # Conditional value
  apiEndpoint = {{ if .isWork }}"https://internal.api"{{ else }}"https://api.example.com"{{ end }}

  # Environment-based
  useProxy = {{ ne (env "HTTP_PROXY") "" }}
```

**Using in templates:**
```go
# In dot_zshrc.tmpl
{{- if .isDevelopment }}
export DEV_MODE=true
{{- end }}

export API_ENDPOINT="{{ .apiEndpoint }}"
```

## Troubleshooting

### Template Errors

**Error:** `template: file.tmpl:5:7: map has no entry for key "variable"`

**Cause:** Variable not defined in `.chezmoi.toml.tmpl`

**Solution:** Add to `.chezmoi.toml.tmpl`:
```toml
[data]
  variable = "default_value"
```

### Permission Errors in Test

**Error:** `permission denied` accessing mounted volume

**Cause:** UID mismatch between container user and files

**Solution:** Container uses UID 3000 to match devcontainer. Verify:
```bash
id -u  # Should output: 3000
```

If files have wrong ownership, Docker handles it via the user mapping.

### Starship Installation Fails

**Error:** `cannot open /dev/tty` or `yn: parameter not set`

**Cause:** Interactive installer can't prompt in non-TTY environment

**Solution:** Use `-y` flag for non-interactive install (already implemented):
```bash
curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir ~/.local/bin -y
```

### Chezmoi Can't Find Source

**Error:** `stat /root/.local/share/chezmoi: no such file or directory`

**Cause:** Running as root when source mounted for regular user

**Solution:** Ensure container runs as correct user (UID 3000) and source is mounted to `/home/user/.local/share/chezmoi`.

### Test Container Package Install Fails

**Error:** `E: Unable to locate package`

**Cause:** Package cache not updated

**Solution:** Always update before installing:
```bash
apt-get update && apt-get install -y package-name
```

### Template Won't Render

**Error:** Syntax error in template

**Debug:** Test template rendering:
```bash
chezmoi execute-template < dot_zshrc.tmpl
```

**Common issues:**
- Missing closing `}}` or `end`
- Using undefined variable
- Incorrect function syntax

## Best Practices

### Security

1. ✅ **Never commit secrets** - use environment variables or keychain references
2. ✅ **Use `.chezmoiignore`** for files containing sensitive data
3. ✅ **Review diffs carefully** - run `chezmoi diff` before applying
4. ✅ **Use placeholder values** in templates for credentials
5. ✅ **Test in test container first** - catch issues before applying to real system

### Template Design

1. ✅ **Provide defaults** for all variables
2. ✅ **Use descriptive names** - `isWork` not `w`
3. ✅ **Comment complex logic** - Go templates can be cryptic
4. ✅ **Keep templates simple** - move complex logic to scripts
5. ✅ **Test rendering** - use `chezmoi execute-template`

### Script Guidelines

1. ✅ **Make scripts idempotent** - check before installing/modifying
2. ✅ **Use `-y` flags** - avoid interactive prompts
3. ✅ **Handle errors** - use `set -euo pipefail`
4. ✅ **Log actions** - echo what's happening
5. ✅ **Exit cleanly** - return appropriate exit codes

### Testing

1. ✅ **Test in test container before committing** - `mise run test` catches issues early
2. ✅ **Test on target platform** - test container is Linux only, test on macOS/WSL separately if needed
3. ✅ **Document requirements** - note required OS versions, tools
4. ✅ **Pin versions** - avoid `latest` tags in production configs

### Maintenance

1. ✅ **Update regularly** - check for new versions of external tools
2. ✅ **Clean up** - remove obsolete configurations
3. ✅ **Document changes** - update AGENTS.md for new patterns
4. ✅ **Version external dependencies** - explicit versions > `latest`

## Installation Methods

### Using install.sh (Recommended)

The repository includes an optional enhanced installation script at `/workspaces/dotfiles/install.sh` that provides a prettier terminal UI using [gum](https://github.com/charmbracelet/gum).

**Features:**
- **Default mode**: Enhanced UI with spinners, progress indicators, and styled output
- **Safe mode**: Falls back to standard chezmoi installation (no gum required)
- **Bootstrap mode**: Install gum to a custom persistent location
- **Automatic fallback**: If gum download fails, automatically falls back to safe mode

**Usage:**

```bash
# Pretty install (recommended) - downloads gum temporarily
bash <(curl -fsLS https://raw.githubusercontent.com/bxm156/dotfiles/main/install.sh)

# Safe mode - standard chezmoi, no gum
bash <(curl -fsLS https://raw.githubusercontent.com/bxm156/dotfiles/main/install.sh) --safe

# Custom bootstrap path - keeps gum after installation
bash <(curl -fsLS https://raw.githubusercontent.com/bxm156/dotfiles/main/install.sh) --bootstrap ~/.local/bin
```

**How it works:**

1. Detects platform (Linux/macOS, amd64/arm64)
2. Downloads gum v0.17.0 from GitHub releases to temp directory
3. Uses gum to wrap chezmoi installation with:
   - Styled header box
   - Spinner for chezmoi download/install (dot spinner)
   - Spinner for `chezmoi init` (line spinner)
   - Spinner for `chezmoi apply` (meter spinner)
   - Success messages
4. Cleans up temporary gum binary (unless `--bootstrap` was used)

**Important implementation details:**

- **PATH issue**: The script installs chezmoi to `~/.local/bin/chezmoi`, but this directory is NOT in `$PATH` during script execution
- **Solution**: Uses full path `$HOME/.local/bin/chezmoi` for subsequent commands instead of bare `chezmoi`
- **Why this matters**: Scripts inherit their PATH at startup and don't automatically pick up newly installed binaries
- **General rule**: When installing binaries in a script, always use full paths for subsequent commands in the same script

**Testing install.sh:**

```bash
# Test default pretty mode
mise run test:install

# Test safe mode
mise run test:install:safe

# Test custom bootstrap path
mise run test:install:bootstrap
```

**Error handling:**

The script has robust error handling and will fall back to safe mode if:
- Platform detection fails
- gum download fails
- chezmoi installation fails
- Any spinner/styled output fails

This ensures the installation completes successfully even if the enhanced UI fails.

## Detailed Workflows

### Making Changes to Existing Dotfiles

```bash
# 1. Edit source file in devcontainer
vim /workspaces/dotfiles/dot_zshrc.tmpl

# 2. Test in test container
mise run test

# 3. If test passes, optionally preview on your local machine (outside devcontainer)
chezmoi diff

# 4. Apply to your local machine (optional)
chezmoi apply -v

# 5. Verify in your shell
source ~/.zshrc

# 6. Commit changes from devcontainer
git add dot_zshrc.tmpl
git commit -m "feat: add fzf keybindings to zshrc"
git push
```

### Setting Up Dotfiles on New Machine

**Option 1: Using install.sh (Recommended - Enhanced UI)**

```bash
# One-line install with gum UI
bash <(curl -fsLS https://raw.githubusercontent.com/bxm156/dotfiles/main/install.sh)
```

This will automatically:
1. Download and install chezmoi
2. Initialize from GitHub repository (bxm156/dotfiles)
3. Apply all dotfiles with enhanced visual feedback
4. Install all external dependencies

**Option 2: Traditional chezmoi installation**

```bash
# 1. Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# 2. Initialize from this repository
chezmoi init https://github.com/bxm156/dotfiles.git

# 3. Preview what will be applied
chezmoi diff

# 4. Apply dotfiles (use -v to see download progress and script output)
chezmoi apply -v

# 5. External dependencies auto-install
# (oh-my-zsh, starship, jq, etc.)
# Note: The -v flag is important! Without it, downloads and scripts run silently,
# which can make it seem like the process is stuck. With -v, you'll see:
# - External binary download progress (jq, fzf, zoxide, bat, gitui)
# - oh-my-zsh and plugin extraction progress
# - Script execution output (starship install, git config setup, etc.)

# 6. Restart shell or source config
exec zsh
```

### Updating External Dependencies

```bash
# 1. Edit version in .chezmoiexternal.toml.tmpl
vim .chezmoiexternal.toml.tmpl
# Change: url = "https://github.com/tool/releases/download/v1.0.0/..."
#     To: url = "https://github.com/tool/releases/download/v2.0.0/..."

# 2. Test in container
mise run test

# 3. Apply update and refresh externals
chezmoi apply --refresh-externals

# 4. Verify new version
tool --version

# 5. Commit
git add .chezmoiexternal.toml.tmpl
git commit -m "chore: update tool to v2.0.0"
```

### Debugging Template Issues

```bash
# 1. Test template rendering
chezmoi execute-template < dot_zshrc.tmpl

# 2. Check available variables
chezmoi data

# 3. Dry-run apply to see what would happen
chezmoi apply --dry-run --verbose

# 4. View rendered file without applying
chezmoi cat ~/.zshrc
```

## Quick Command Reference

```bash
# Preview changes
chezmoi diff

# Apply changes
chezmoi apply -v

# Apply and refresh external dependencies
chezmoi apply --refresh-externals

# Edit managed file
chezmoi edit ~/.zshrc

# See what chezmoi manages
chezmoi managed

# Navigate to source directory
chezmoi cd

# View rendered file without applying
chezmoi cat ~/.zshrc

# Test template rendering
chezmoi execute-template < file.tmpl

# Show chezmoi data/variables
chezmoi data

# Test in test container (automated)
mise run test

# Test in test container (interactive zsh shell after tests)
mise run test:interactive

# Debug in test container (raw bash, no dotfiles)
mise run test:shell

# Update from git and apply (on local machine, not in devcontainer)
chezmoi update
```

## Additional Resources

**Local Documentation:**
- **[CLAUDE.md](CLAUDE.md)** - Quick reference and critical rules
- **[EXTERNAL.md](EXTERNAL.md)** - External packages reference and AI agent instructions
- **[TESTING.md](TESTING.md)** - Testing workflow and commands
- **[PRODUCTIVITY.md](docs/PRODUCTIVITY.md)** - Productivity tools guide (glow, mods, taskwarrior)

**Chezmoi Documentation:**
- **Daily Operations**: https://www.chezmoi.io/user-guide/daily-operations/
- **User Guide**: https://www.chezmoi.io/user-guide/setup/
- **Templates Reference**: https://www.chezmoi.io/user-guide/templating/
- **External Format**: https://www.chezmoi.io/reference/special-files-and-directories/chezmoiexternal-format/
- **Chezmoi Home**: https://www.chezmoi.io/

**Other:**
- **Go Template Reference**: https://pkg.go.dev/text/template
- **Mise Documentation**: https://mise.jdx.dev/

---

**Remember**: This repository is designed for safety (test before apply), clarity (document everything), and portability (works across machines). Always test in the test container before applying to your real environment.
