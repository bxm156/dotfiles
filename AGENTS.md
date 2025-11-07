# AGENTS.md - Chezmoi Dotfiles Implementation Guide

Comprehensive guide for AI agents working with this chezmoi-managed dotfiles repository.

## Critical Path Definitions

### Source Directory (This Repository)
- **Path in Devcontainer**: `/workspaces/dotfiles`
- **Path on Local Machine**: `~/.local/share/chezmoi`
- **Purpose**: Contains chezmoi source files with special naming conventions
- **Key Point**: This is where you edit files and manage the dotfiles configuration

### Target Directory (Applied Dotfiles)
- **Path**: `~` (user's home directory, e.g., `/home/user` or `/home/vscode`)
- **Purpose**: Where dotfiles are actually used by the system
- **Key Point**: Never edit files here directly - always edit in source directory

### Test Container Paths
- **Source Mount**: `/home/user/.local/share/chezmoi` (read-only, mounted from `/workspaces/dotfiles`)
- **Target**: `/home/user` (where dotfiles get applied during test)
- **Working Directory**: `/home/user`

## Understanding Chezmoi

**⚠️ CRITICAL WARNING FOR AI AGENTS: NEVER run `chezmoi apply` in the devcontainer or main development environment. ONLY test changes using `mise run test` which runs in an isolated container. The devcontainer is for editing source files only.**

Chezmoi manages dotfiles across multiple machines using:
- **Templating**: Machine-specific configurations with Go templates
- **External Dependencies**: Auto-downloads tools, plugins, binaries
- **Safe Workflows**: Preview before applying changes
- **State Tracking**: Knows what's been applied and when

### File Naming Conventions

| Source Filename | Target Result | Notes |
|----------------|---------------|-------|
| `dot_zshrc` | `~/.zshrc` | `dot_` prefix becomes `.` |
| `dot_config/starship.toml` | `~/.config/starship.toml` | Directory structure preserved |
| `file.tmpl` | `~/file` | Template processed, `.tmpl` removed |
| `dot_zshrc.tmpl` | `~/.zshrc` | Both transformations applied |
| `run_once_install.sh` | Executed once | Runs on first apply only |
| `run_script.sh` | Executed always | Runs every apply |
| `executable_script` | Made executable | Preserves executable bit |

### Template Processing Flow

```
Source File (with .tmpl) → Go Template Processing → Target File
                              ↓
                    Uses variables from .chezmoi.toml.tmpl
```

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

Testing happens in an isolated Debian container that simulates a fresh user environment.

### Running Tests

```bash
# Automated test (runs chezmoi apply and validates)
mise run test

# Interactive test (drops into shell for manual testing)
mise run test:interactive
```

### What `mise run test` Does

1. **Starts container** as UID 3000 (matches devcontainer user)
2. **Creates user** named `user` with home at `/home/user`
3. **Installs dependencies**: curl, zsh via apt
4. **Installs chezmoi** to `/home/user/.local/bin`
5. **Mounts source** at `/home/user/.local/share/chezmoi` (read-only)
6. **Applies dotfiles**: Runs `chezmoi apply -v`
7. **Executes scripts**: Installs starship, sets up oh-my-zsh
8. **Validates**:
   - Zsh starts successfully
   - Starship binary is available
   - Shell config loads without errors

### Test Container Configuration

**docker-compose.yml key settings:**
- `image: debian:bookworm-slim` - Clean, minimal Debian environment
- `user: "3000:3000"` - Matches devcontainer UID to avoid permission issues
- `volumes: ./:/home/user/.local/share/chezmoi:ro` - Mounts repo as read-only
- `platform: linux/amd64` - Ensures consistent architecture

**Why these choices:**
- **Debian** - Standard, well-supported Linux distribution
- **UID 3000** - Matches devcontainer user, prevents permission problems
- **Read-only mount** - Prevents accidental modifications to source
- **Regular user** - Tests realistic non-root usage

### Testing Workflow

1. **Edit files** in `/workspaces/dotfiles/`
2. **Run test**: `mise run test`
3. **Check output** for errors/warnings
4. **Fix issues** and retest
5. **Apply locally** (optional): `chezmoi apply`
6. **Commit** when satisfied

### Interactive Testing

```bash
# Open shell in test container
mise run test:interactive

# Inside container, manually test:
mkdir -p ~/.local/bin
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
~/.local/bin/chezmoi apply -v

# Explore applied configuration
cat ~/.zshrc
zsh
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
# 1. Create source file with chezmoi naming
touch dot_gitconfig           # For static file
touch dot_zshrc.tmpl          # For template file

# 2. Edit with your configuration
vim dot_gitconfig

# 3. Test in container
mise run test

# 4. Preview what will be applied (optional, requires local chezmoi)
chezmoi diff

# 5. Commit
git add dot_gitconfig
git commit -m "Add gitconfig with core settings"
```

### Adding External Dependencies

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
5. ✅ **Test in container first** - catch issues before applying to real system

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

1. ✅ **Test before committing** - `mise run test` catches issues early
2. ✅ **Test on target platform** - containers can't catch OS-specific issues
3. ✅ **Document requirements** - note required OS versions, tools
4. ✅ **Pin versions** - avoid `latest` tags in production configs

### Maintenance

1. ✅ **Update regularly** - check for new versions of external tools
2. ✅ **Clean up** - remove obsolete configurations
3. ✅ **Document changes** - update AGENTS.md for new patterns
4. ✅ **Version external dependencies** - explicit versions > `latest`

## Detailed Workflows

### Making Changes to Existing Dotfiles

```bash
# 1. Edit source file in repository
vim /workspaces/dotfiles/dot_zshrc.tmpl

# 2. Test in isolated container
mise run test

# 3. If test passes, optionally preview on local machine
chezmoi diff

# 4. Apply locally (optional)
chezmoi apply -v

# 5. Verify in your shell
source ~/.zshrc

# 6. Commit changes
git add dot_zshrc.tmpl
git commit -m "feat: add fzf keybindings to zshrc"
git push
```

### Setting Up Dotfiles on New Machine

```bash
# 1. Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# 2. Initialize from this repository
chezmoi init https://github.com/username/dotfiles.git

# 3. Preview what will be applied
chezmoi diff

# 4. Apply dotfiles
chezmoi apply -v

# 5. External dependencies auto-install
# (oh-my-zsh, starship, jq, etc.)

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

# Test in container
mise run test

# Interactive test container
mise run test:interactive

# Update from git and apply
chezmoi update
```

## Additional Resources

- **Chezmoi Documentation**: https://www.chezmoi.io/
- **Go Template Reference**: https://pkg.go.dev/text/template
- **Chezmoi Templates**: https://www.chezmoi.io/reference/templates/
- **External Format**: https://www.chezmoi.io/reference/special-files-and-directories/chezmoiexternal-format/
- **Mise Documentation**: https://mise.jdx.dev/

---

**Remember**: This repository is designed for safety (test before apply), clarity (document everything), and portability (works across machines). Always test in the container before applying to your real environment.
