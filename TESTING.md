# Testing Dotfiles

## Terminology

- **Devcontainer** (user: vscode) - Your current development environment at `/workspaces/dotfiles`
- **Test container** (user: user) - Isolated Debian container for testing dotfiles

## Quick Start

```bash
# Local source tests (uses mounted directory)
mise run test              # Run tests in test container
mise run test:interactive  # Run tests + drop into zsh shell
mise run test:shell        # Raw bash shell (no dotfiles, for debugging)

# GitHub tests (simulates real installation)
mise run test:github              # Pull from GitHub and test
mise run test:github:interactive  # GitHub test + interactive shell
```

## How It Works

### Local Source Tests
- Tests run in **test container** (Debian Bookworm, user: user)
- Dotfiles from **devcontainer** mounted read-only at `~/.local/share/chezmoi`
- `test-dotfiles.sh` installs chezmoi with `--source ~/.local/share/chezmoi`
- Fast for development - tests local changes without committing
- Test container auto-removed after exit (`--rm` flag)

### GitHub Tests
- Tests run in **test container** (Debian Bookworm, user: user)
- No local directory mounted - pulls from GitHub
- `test-dotfiles-github.sh` runs `chezmoi init --apply bxm156`
- Simulates real-world installation from fresh machine
- **Requires committed and pushed changes to test**
- Validates the actual user installation experience

## Cleanup

```bash
mise run clean             # Remove test containers/volumes
mise run clean:full        # Remove everything (forces rebuild)
```

**Never run `chezmoi apply` in devcontainer** - always test in test container first.
