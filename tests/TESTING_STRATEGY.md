# Testing Strategy: Preventing Breaking Changes

This document outlines the comprehensive testing strategy to ensure master always installs correctly and blocks breaking changes.

## Test Categories

### 1. **Syntax & Configuration Tests** (`tests/syntax/`)

**Purpose**: Catch configuration errors before they reach production

- **templates.bats** (10 tests) - Template rendering validation
  - Ensures all `.tmpl` files render without errors
  - Validates template variables are defined

- **externals.bats** (9 tests) - External binary configuration
  - Verifies all binaries are configured in `.chezmoiexternal.toml.tmpl`

- **external-urls.bats** (6 tests) - ⚠️ **CRITICAL FOR BLOCKING BREAKING CHANGES**
  - Validates all external URLs are accessible (prevents 404s)
  - Ensures HTTPS is used (security)
  - Prevents use of `/latest/` URLs (prevents unexpected updates)
  - Tests: chezmoi installer, oh-my-zsh, starship installer

- **scripts.bats** (6 tests) - ⚠️ **CRITICAL FOR BLOCKING BREAKING CHANGES**
  - Validates bash script syntax before execution
  - Ensures proper error handling (`set -euo pipefail`)
  - Checks for proper shebangs
  - Validates idempotency patterns
  - Prevents hardcoded paths

**Why**: These tests prevent deployment of broken templates, dead links, or syntactically invalid scripts.

### 2. **Unit Tests** (`tests/unit.bats`)

**Purpose**: Test individual components in isolation

- **unit.bats** (18 tests) - Logging library tests
  - Tests all logging functions
  - Validates output format
  - Tests graceful degradation without gum

**Why**: Catches regressions in shared libraries.

### 3. **Binary Verification Tests** (`tests/binaries/`)

**Purpose**: Ensure all tools install correctly

- **core-tools.bats** (8 tests) - Essential CLI tools
- **ui-tools.bats** (6 tests) - Terminal UI tools
- **productivity-tools.bats** (6 tests) - Productivity tools

**Why**: Detects when external binaries fail to install or aren't executable.

### 4. **Integration Tests** (`tests/integration/`)

**Purpose**: Test complete system integration

- **shell.bats** (9 tests) - Shell configuration
- **git.bats** (3 tests) - Git setup
- **environment.bats** (6 tests) - Directory structure and PATH

- **platform-compatibility.bats** (7 tests) - ⚠️ **CRITICAL FOR MULTI-PLATFORM**
  - Platform detection works correctly
  - External binaries match system architecture
  - No unguarded platform-specific commands
  - WSL detection logic

- **installation-safety.bats** (8 tests) - ⚠️ **CRITICAL FOR DATA SAFETY**
  - No writes outside `$HOME`
  - No sudo requirements
  - Git config preservation
  - No destructive `rm -rf`
  - No sensitive data in repo
  - No world-writable files

- **dependencies.bats** (10 tests) - ⚠️ **CRITICAL FOR INSTALLATION SUCCESS**
  - Required tools are available
  - Network connectivity
  - Sufficient disk space
  - No hard language runtime dependencies
  - Chezmoi version compatibility

**Why**: Prevents installation failures, data loss, security issues, and platform incompatibilities.

### 5. **Install Script Tests** (`tests/install/`)

**Purpose**: Validate the installation entry point

- **structure.bats** (6 tests) - File structure and best practices
- **features.bats** (4 tests) - Script features and flags

**Why**: Ensures users can successfully install dotfiles.

### 6. **Meta Tests** (`tests/meta/`)

**Purpose**: Test the test suite itself

- **test-suite.bats** (10 tests) - Test suite integrity
  - Bats libraries installed
  - No duplicate test names
  - Descriptive test names
  - mise/GitHub Actions reference valid paths
  - Reasonable test coverage

**Why**: Prevents broken CI/CD pipelines and ensures test quality.

## What Each Test Category Prevents

| Test Category | Prevents |
|--------------|----------|
| **external-urls.bats** | 404 errors, moved files, broken installers |
| **scripts.bats** | Syntax errors, missing error handling, non-idempotent scripts |
| **platform-compatibility.bats** | macOS/Linux conflicts, wrong architecture binaries |
| **installation-safety.bats** | Data loss, permission issues, sensitive data leaks |
| **dependencies.bats** | Missing tools, network failures, insufficient resources |
| **meta tests** | Broken CI/CD, invalid test references |

## Running Tests

### Quick Validation (Fast, No Network)
```bash
mise run test:ci
```
Runs: syntax (no URLs), unit, install validation, meta tests
**Use this**: Before every commit

### Full Validation (Includes Network Tests)
```bash
mise run test:ci:full
```
Runs: All syntax tests including URL validation
**Use this**: Before merging to master, in CI

### Complete Test Suite (Requires Dotfiles Applied)
```bash
mise run test:bats
```
Runs: All tests including binary and integration tests
**Use this**: After installation, for comprehensive validation

### Individual Categories
```bash
mise run test:bats:syntax        # All syntax tests
mise run test:bats:integration   # All integration tests
mise run test:bats:meta          # Test suite integrity
```

## CI/CD Integration

### Pre-Commit Checks
1. Script syntax validation
2. Template rendering
3. Test suite integrity

### Pull Request Checks
1. All CI tests (`test:ci:full`)
2. URL accessibility
3. Platform compatibility
4. Installation safety

### Pre-Merge to Master
1. Complete test suite in Docker
2. Multi-platform validation (Linux amd64, arm64, macOS)
3. Fresh installation test

## Recommendations for Adding New Features

When adding new features, add tests for:

1. **New external tools**: Add URL validation test
2. **New scripts**: Ensure syntax test passes, add idempotency check
3. **New templates**: Add rendering test
4. **Platform-specific code**: Add compatibility test
5. **File modifications**: Add safety test

## Test Performance

- **Quick tests** (`test:ci`): ~30 seconds
- **Full tests** (`test:ci:full`): ~2-3 minutes (network dependent)
- **Complete suite** (`test:bats`): ~5-10 minutes (with installation)

## Future Enhancements

Consider adding:
- **Regression tests**: For each bug fix
- **Performance benchmarks**: Installation time, resource usage
- **Security scans**: shellcheck, static analysis
- **Documentation tests**: Link validation, example correctness
- **Upgrade path tests**: Old version → new version migration
