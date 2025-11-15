# Dotfiles Testing Framework

This directory contains automated tests for the dotfiles repository using [bats-core](https://github.com/bats-core/bats-core) (Bash Automated Testing System).

## Test Structure

### Test Files

- **`syntax.bats`** - Template syntax validation tests
  - Verifies all `.tmpl` files render without errors
  - Checks template variables are defined correctly
  - Validates external binary configurations

- **`unit.bats`** - Unit tests for custom libraries
  - Tests logging helper library functions
  - Validates proper function existence and output format
  - Tests graceful degradation (with/without gum)

- **`binaries.bats`** - Binary verification tests
  - Checks binaries are installed as executable files (not directories)
  - Verifies binaries are functional (`--version` checks)
  - Covers: jq, fzf, zoxide, bat, gitui, gum, starship, glow, mods

- **`integration.bats`** - Full integration tests
  - Tests oh-my-zsh installation and plugins
  - Verifies zsh configuration loads without errors
  - Checks git configuration integration
  - Validates directory structure (notes, .local/bin, etc.)

- **`install.bats`** - install.sh script validation
  - Tests script structure and best practices
  - Validates command-line flags (--safe, --bootstrap)
  - Checks error handling and platform detection

### Legacy Test Scripts (Deprecated)

These scripts are maintained for backwards compatibility but are being replaced by bats tests:

- **`test-dotfiles.sh`** - Full integration test (local source) - **Use bats integration/binary tests instead**
- **`test-dotfiles-github.sh`** - GitHub integration test - **Use GitHub Actions workflow instead**
- **`test-render-simple.sh`** - Simple template rendering test - **Use bats syntax tests instead**
- **`test-logging-helpers.sh`** - Logging library test - **Use bats unit tests instead**

The bats-based tests provide better structure, clearer output, and easier maintenance.

## Running Tests

### Prerequisites

Tests require:
- `chezmoi` installed and in PATH
- `bats-core` (included as git submodule)
- Dotfiles applied (for integration/binary tests)

### Local Testing

```bash
# Run all bats tests
mise run test:bats

# Run specific test suites
mise run test:bats:syntax        # Syntax tests only
mise run test:bats:unit          # Unit tests only
mise run test:bats:binaries      # Binary verification tests
mise run test:bats:integration   # Integration tests
mise run test:bats:install       # install.sh validation

# Run CI test suite (syntax + unit + install validation)
mise run test:ci

# Legacy tests (Docker-based)
mise run test                    # Full Docker integration test
mise run test:github            # GitHub install test
mise run test:render            # Template rendering test
mise run test:logging           # Logging helpers test
```

### Direct bats Execution

```bash
# Run all tests
tests/libs/bats-core/bin/bats tests/*.bats

# Run specific file
tests/libs/bats-core/bin/bats tests/syntax.bats

# Verbose output
tests/libs/bats-core/bin/bats -t tests/syntax.bats
```

## GitHub Actions CI

Tests run automatically via GitHub Actions on:
- Push to `main`/`master` branches
- Pull requests to `main`/`master`
- Manual workflow dispatch

### Test Matrix

**Quick Tests** (runs first, fast feedback ~5 min):
- Syntax validation
- Unit tests
- install.sh validation
- Platform: ubuntu-latest

**Integration Tests** (full environment ~15-30 min):
- Linux amd64 (Docker) - Uses bats integration/binary tests instead of legacy scripts
- Linux arm64 (Docker with QEMU) - Only runs on main/master branch (slow)
- macOS Intel (native runner) - Applies real dotfiles
- macOS Apple Silicon (native runner) - Applies real dotfiles

**Installer Tests** (~10-15 min per mode):
- install.sh (default mode with gum UI)
- install.sh --safe (fallback mode)
- install.sh --bootstrap (custom path)

### Configuration

The workflow uses a centralized `DOTFILES_USER` environment variable set to `bxm156`.

**For forks:** Edit `.github/workflows/test.yml` and change:
```yaml
env:
  DOTFILES_USER: bxm156  # Change this to your GitHub username
```

### Workflow File

See `.github/workflows/test.yml` for the complete CI configuration.

## Test Development

### Adding New Tests

1. Create or edit a `.bats` file in `tests/`
2. Follow the bats-core syntax:

```bash
#!/usr/bin/env bats

setup() {
    load 'libs/bats-support/load'
    load 'libs/bats-assert/load'
}

@test "descriptive test name" {
    run command_to_test
    assert_success
    assert_output "expected output"
}
```

3. Test locally:
```bash
tests/libs/bats-core/bin/bats tests/your-file.bats
```

4. Add to mise.toml if needed
5. Update GitHub Actions workflow if needed

### Best Practices

- **Descriptive names**: `@test "jq is installed as executable file"`
- **Focused tests**: One assertion per test when possible
- **Use helpers**: `assert_success`, `assert_output`, `refute_output`
- **Skip when appropriate**: Use `skip` for platform-specific tests
- **Clean up**: Use `teardown()` for cleanup if needed

## Dependencies

### bats-core Ecosystem

Installed as git submodules in `tests/libs/`:

- **bats-core** - Core testing framework
- **bats-support** - Support library for better assertions
- **bats-assert** - Assertion library

### Updating bats

```bash
# Update all submodules to latest
git submodule update --remote --merge

# Or update specific library
cd tests/libs/bats-core
git pull origin master
cd ../../..
git add tests/libs/bats-core
git commit -m "chore: update bats-core"
```

## Troubleshooting

### Tests fail with "command not found: chezmoi"

Ensure chezmoi is installed and in PATH:
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
```

### Binary tests fail

Binary tests require dotfiles to be applied:
```bash
chezmoi init --apply <your-github-username>
```

Or run in Docker:
```bash
mise run test
```

### Syntax tests fail

Check template syntax:
```bash
chezmoi execute-template < .chezmoi.toml.tmpl
chezmoi execute-template < .chezmoiexternal.toml.tmpl
```

### Integration tests fail on macOS

Some tests may be Linux-specific. Check for `skip` conditions or run in Docker:
```bash
DOCKER_PLATFORM=linux/amd64 mise run test
```

## References

- **bats-core**: https://github.com/bats-core/bats-core
- **bats-support**: https://github.com/bats-core/bats-support
- **bats-assert**: https://github.com/bats-core/bats-assert
- **GitHub Actions**: https://docs.github.com/en/actions
- **Chezmoi**: https://www.chezmoi.io/
