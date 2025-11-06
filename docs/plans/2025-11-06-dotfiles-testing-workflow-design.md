# Dotfiles Testing Workflow Design

**Date:** 2025-11-06
**Status:** Approved

## Problem Statement

Managing dotfiles with chezmoi in a devcontainer creates confusion:
- Two git repos (`/workspaces/dotfiles` and `~/.local/share/chezmoi`) point to same origin
- Testing changes risks breaking the active shell environment
- Need safe, isolated testing before applying changes

## Solution Overview

Use Docker-in-Docker with Docker Compose to create isolated test containers that validate dotfiles before applying them to the main development environment.

## Design

### 1. Devcontainer Configuration

Enable Docker-in-Docker in `.devcontainer/devcontainer.json`:

```json
"features": {
  "ghcr.io/atty303/devcontainer-features/mise:1": {},
  "ghcr.io/devcontainers/features/docker-in-docker:2": {
    "version": "latest",
    "dockerDashComposeVersion": "v2"
  }
}
```

### 2. Docker Compose Test Service

Create `docker-compose.yml`:

```yaml
services:
  dotfiles-test:
    image: mcr.microsoft.com/devcontainers/python:1-3.12-bookworm
    volumes:
      - ./:/home/vscode/.local/share/chezmoi:ro
    working_dir: /home/vscode
    entrypoint: /bin/bash
    command:
      - -c
      - |
        # Install chezmoi
        sh -c "$$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

        # Drop into interactive shell
        exec /bin/bash
    stdin_open: true
    tty: true
    environment:
      - TERM=xterm-256color
```

**Key decisions:**
- Mount `/workspaces/dotfiles` as chezmoi source (read-only)
- Install chezmoi via official script on startup (stateless, ~2-3 seconds)
- Use same base image as devcontainer for consistency

### 3. Mise Tasks for Testing

Add to `.mise.toml`:

```toml
[tasks.test]
description = "Test dotfiles in isolated container"
run = """
docker compose run --rm dotfiles-test bash -c '
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
  chezmoi apply -v
  echo "✓ Dotfiles applied successfully"

  # Test zsh starts
  zsh -c "echo ✓ Zsh version: \$ZSH_VERSION"

  # Test key tools are available
  zsh -i -c "
    command -v starship >/dev/null && echo ✓ Starship found || echo ✗ Starship missing
    echo ✓ Shell config loaded successfully
  "
'
"""

[tasks."test:interactive"]
description = "Open interactive test container"
run = "docker compose run --rm dotfiles-test"
```

### 4. Simplified Workspace Structure

**Primary workspace:** `/workspaces/dotfiles` is the source of truth
- Edit files here
- Commit changes here
- No need to maintain `~/.local/share/chezmoi` separately

**Testing workflow:**
```bash
# 1. Edit dotfiles
vim dot_zshrc

# 2. Run automated smoke test
mise run test

# 3. Or test interactively
mise run test:interactive
  # Inside: chezmoi apply && zsh

# 4. If good, apply to devcontainer
chezmoi init --source=/workspaces/dotfiles
chezmoi apply

# 5. Commit when satisfied
git add . && git commit -m "Update zshrc"
```

## Benefits

1. **Isolated testing**: Changes don't affect working environment until validated
2. **Consistent environment**: Test container uses same base image
3. **Automated validation**: Smoke test catches common issues
4. **Developer-friendly**: Run tests without leaving devcontainer
5. **Claude-compatible**: Programmatic testing via `mise run test`
6. **Single source of truth**: `/workspaces/dotfiles` is the only repo to manage

## Trade-offs

- Chezmoi installs on every test run (~2-3 seconds overhead)
- Requires Docker-in-Docker (additional container resource usage)
- Test container is stateless (can't persist test state between runs)

## Future Enhancements

- Custom Docker image with mise/chezmoi pre-installed for faster tests
- Additional test tasks for specific scenarios (vim config, tmux, etc.)
- CI/CD integration to run tests on pull requests
- Test matrix for multiple base images/OS versions
