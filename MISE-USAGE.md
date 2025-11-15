# Mise Usage Guide

This document explains how to use mise for tool version management in this repository.

## What is Mise?

Mise is a polyglot tool version manager that manages development tools, environment variables, and tasks. It replaces tools like asdf, nvm, rbenv, pyenv, etc. with a single unified interface.

## Core Concepts

### 1. Tool Installation

Mise can install tools from multiple backends automatically:

```bash
# Mise automatically detects the best backend
mise use node@20              # Installs Node.js 20
mise use python@3.11          # Installs Python 3.11
mise use bats@latest          # Installs bats-core

# Explicit backend specification (when needed)
mise use npm:prettier         # Installs npm package
mise use cargo:ripgrep        # Installs Rust crate
mise use go:github.com/user/tool  # Installs Go tool
```

**Important**: Don't hardcode backend names unless necessary. Mise's registry automatically selects the appropriate backend.

### 2. Configuration

Tools are defined in `mise.toml`:

```toml
[tools]
node = "24"
python = "3.11"
bats = "latest"
"npm:bats-assert" = "latest"
"npm:bats-support" = "latest"
```

### 3. PATH Management - Two Approaches

#### Option A: PATH Activation (Recommended for Interactive Use)

Adds tools to PATH dynamically:

```bash
# For interactive shells
eval "$(mise activate bash)"      # Full activation with hooks
eval "$(mise activate zsh)"       # For zsh

# Add to shell config
echo 'eval "$(mise activate bash)"' >> ~/.bashrc
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
```

**Use when**: Working in interactive terminal sessions where you want full environment integration.

#### Option B: Shims (For Non-Interactive/CI Contexts)

Uses shim executables in a dedicated directory:

```bash
# For non-interactive shells (CI, scripts)
eval "$(mise activate bash --shims)"

# Add to shell profile for non-interactive sessions
echo 'eval "$(mise activate bash --shims)"' >> ~/.bash_profile
```

**Use when**:

- Running in CI/CD environments
- Using in Docker containers
- Working in non-interactive scripts
- IDE integrations

**Note**: You can use both! Mise activate removes shims directory from PATH, so it's safe to have `--shims` in `.bash_profile` and full activation in `.bashrc`.

### 4. Getting Tool Paths

**NEVER hardcode installation paths**. Always use mise commands:

```bash
# Get installation directory
mise where npm:bats-support
# Output: /home/user/.local/share/mise/installs/npm-bats-support/0.3.0

# Find files within installation
SUPPORT_DIR=$(mise where npm:bats-support)
find "$SUPPORT_DIR" -name "load.bash"

# Use in scripts
TOOL_PATH="$(mise where tool-name)"
```

### 5. Common Commands

```bash
# Install all tools from mise.toml
mise install

# Install specific tool
mise install node@20

# List installed tools
mise ls

# List available versions
mise ls-remote node

# Get tool information
mise where node
mise which node

# Update mise itself
mise self-update

# Check mise configuration
mise doctor
```

## Using Mise in Different Contexts

### In Development (Local Machine)

```bash
# Activate mise in your shell
eval "$(mise activate bash)"

# Install tools
mise install

# Tools are now available
node -v
python -v
bats -v
```

### In Docker Containers

**Dockerfile pattern**:

```dockerfile
USER appuser
WORKDIR /home/appuser

# Install mise
RUN curl https://mise.run | sh && \
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc && \
    echo 'eval "$(~/.local/bin/mise activate bash --shims)"' >> ~/.bash_profile
```

**Why both activations?**

- `.bashrc`: For interactive shells (when you exec into container)
- `.bash_profile`: For non-interactive contexts (scripts, CI commands)

### In GitHub Actions

**Pattern for host runners** (Ubuntu, macOS):

```yaml
- name: Install mise and setup PATH
  run: |
    curl https://mise.run | sh
    echo "$HOME/.local/bin" >> $GITHUB_PATH
    echo 'eval "$(mise activate bash --shims)"' >> ~/.bash_profile

- name: Install tools
  run: mise install

- name: Run commands
  run: bats tests/*.bats  # Tools available via shims
```

**Pattern for Docker-based steps** (container already has mise):

```yaml
- name: Run tests in container
  run: |
    docker compose run --rm test-container -c "
      mise install
      bats tests/*.bats
    "
```

### In BATS Tests

**Create a test helper** (`tests/test_helper.bash`):

```bash
#!/usr/bin/env bash
# Load bats libraries from mise - dynamically find paths

BATS_SUPPORT_LOAD="$(find "$(mise where npm:bats-support)" -name "load.bash" -path "*/bats-support/load.bash")"
BATS_ASSERT_LOAD="$(find "$(mise where npm:bats-assert)" -name "load.bash" -path "*/bats-assert/load.bash")"

load "${BATS_SUPPORT_LOAD%.bash}"
load "${BATS_ASSERT_LOAD%.bash}"
```

**Use in tests**:

```bash
setup() {
    load 'test_helper'  # or load '../test_helper' from subdirectories
    # ... rest of setup
}
```

## Key Principles

1. **Don't hardcode paths**: Always use `mise where` or rely on PATH
2. **Don't hardcode backends**: Let mise auto-detect unless absolutely necessary
3. **Use shims for CI/scripts**: Non-interactive contexts work better with shims
4. **Use full activation for development**: Interactive shells benefit from full activation
5. **Check with `mise doctor`**: Verify configuration and diagnose issues

## Troubleshooting

### Tools not found in PATH

```bash
# Check if mise is activated
mise doctor

# Manually add shims to PATH for current session
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Or activate mise
eval "$(mise activate bash --shims)"
```

### Finding tool installations

```bash
# Check where tool is installed
mise where tool-name

# Check all installed tools
mise ls

# Verify mise configuration
mise doctor
```

### Stale shims

```bash
# Regenerate shims after manual installation
mise reshim
```

## Migration from Git Submodules

This repository previously used git submodules for BATS test libraries. We migrated to mise because:

- **Simpler**: No submodule init/update commands
- **Faster**: Parallel installations, better caching
- **Consistent**: Same tool management everywhere (dev, CI, Docker)
- **Automatic**: Tools install on-demand from mise.toml

**Before** (git submodules):

```bash
git submodule update --init --recursive
load 'tests/libs/bats-support/load'
```

**After** (mise):

```bash
mise install
load 'test_helper'  # Dynamically finds libraries via mise
```

## Reference

- **Official Docs**: <https://mise.jdx.dev>
- **Shims Documentation**: <https://mise.jdx.dev/dev-tools/shims.html>
- **Registry**: <https://mise.jdx.dev/registry.html>
- **Backends**: <https://mise.jdx.dev/dev-tools/backends/>