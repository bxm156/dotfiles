# Testing Dotfiles

## Terminology

- **Devcontainer** (user: vscode) - Your current development environment at `/workspaces/dotfiles`
- **Test container** (user: user) - Isolated Debian container for testing dotfiles

## Quick Start

### Automated Tests (bats-core)

```bash
# Run all bats tests
mise run test:bats

# Run specific test suites
mise run test:bats:syntax        # Template syntax validation
mise run test:bats:unit          # Unit tests (logging library)
mise run test:bats:binaries      # Binary verification tests
mise run test:bats:integration   # Integration tests
mise run test:bats:install       # install.sh validation

# Run CI test suite (fast feedback)
mise run test:ci
```

### Docker Integration Tests

```bash
# Local source tests (uses mounted directory)
mise run test              # Run tests in test container
mise run test:interactive  # Run tests + drop into zsh shell
mise run test:shell        # Raw bash shell (no dotfiles, for debugging)

# GitHub tests (simulates real installation)
mise run test:github              # Pull from GitHub and test
mise run test:github:interactive  # GitHub test + interactive shell
```

## Test Types

### 1. Syntax Tests (`tests/syntax.bats`)
- Validates all `.tmpl` files render without errors
- Checks template variables are defined
- Verifies external binary configurations
- **Fast** - runs in ~5 seconds

### 2. Unit Tests (`tests/unit.bats`)
- Tests custom logging library functions
- Validates function existence and output format
- Tests graceful degradation (with/without gum)
- **Fast** - runs in ~3 seconds

### 3. Binary Tests (`tests/binaries.bats`)
- Verifies binaries are installed as executable files
- Tests basic functionality (`--version` checks)
- Covers: jq, fzf, zoxide, bat, gitui, gum, starship, glow, mods, figlet
- **Requires dotfiles to be applied**

### 4. Integration Tests (`tests/integration.bats`)
- Tests oh-my-zsh installation and plugins
- Verifies zsh configuration loads without errors
- Checks git configuration integration
- Validates directory structure
- **Requires dotfiles to be applied**

### 5. Install Script Tests (`tests/install.bats`)
- Validates install.sh structure
- Tests command-line flags (--safe, --bootstrap)
- Checks error handling
- **Fast** - static analysis only

## How It Works

### bats-core Tests
- Uses [bats-core](https://github.com/bats-core/bats-core) testing framework
- Tests are in `tests/*.bats` files
- Can run locally or in CI (GitHub Actions)
- Installed as git submodules in `tests/libs/`

### Local Source Tests (Docker)
- Tests run in **test container** (Debian Bookworm, user: user)
- Dotfiles from **devcontainer** mounted read-only at `~/.local/share/chezmoi`
- `test-dotfiles.sh` installs chezmoi with `--source ~/.local/share/chezmoi`
- Fast for development - tests local changes without committing
- Test container auto-removed after exit (`--rm` flag)

### GitHub Tests (Docker)
- Tests run in **test container** (Debian Bookworm, user: user)
- No local directory mounted - pulls from GitHub
- `test-dotfiles-github.sh` runs `chezmoi init --apply bxm156`
- Simulates real-world installation from fresh machine
- **Requires committed and pushed changes to test**
- Validates the actual user installation experience

## GitHub Actions CI

Tests run automatically on every push and pull request:

**Quick Tests** (runs first):
- Syntax validation
- Unit tests
- install.sh validation

**Integration Tests** (full environment):
- Linux amd64 (Docker)
- Linux arm64 (Docker with QEMU)
- macOS Intel (native runner)
- macOS Apple Silicon (native runner)

**Installer Tests**:
- install.sh (default mode)
- install.sh --safe
- install.sh --bootstrap

See `.github/workflows/test.yml` for details.

## Cleanup

```bash
mise run clean             # Remove test containers/volumes
mise run clean:full        # Remove everything (forces rebuild)
```

## Documentation

See `tests/README.md` for detailed testing framework documentation.

**Never run `chezmoi apply` in devcontainer** - always test in test container first.
