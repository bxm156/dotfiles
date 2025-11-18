# Testing Guide for AI Agents

**CRITICAL: READ THIS ENTIRE DOCUMENT BEFORE RUNNING ANY TESTS**

This document provides explicit instructions for AI agents on where and how to run tests in this dotfiles repository.

## Test Environments: Devcontainer vs Test Container

### Two Distinct Environments

This repository uses **TWO SEPARATE ENVIRONMENTS**:

1. **Devcontainer** (`/workspaces/dotfiles`)
   - User: `vscode`
   - Purpose: **EDITING SOURCE FILES ONLY**
   - Contains: Source files, git repository, development tools
   - External binaries: **MINIMAL SET** (only what's in `mise.toml`)
   - Dotfiles: **NOT APPLIED** - you're editing the source, not using the result

2. **Test Container** (Docker-based)
   - User: `user`
   - Purpose: **TESTING DOTFILE INSTALLATION**
   - Contains: Fresh Debian environment, simulates real user installation
   - External binaries: **FULL SET** (everything from `.chezmoiexternal.toml.tmpl`)
   - Dotfiles: **FULLY APPLIED** - tests the complete installation

### CRITICAL RULE: Never Confuse These Environments

**❌ WRONG: Running integration tests in devcontainer**

```bash
# DON'T DO THIS - These will fail because dotfiles aren't applied here
mise run test:bats:binaries      # ❌ Runs in devcontainer (incomplete)
mise run test:bats:integration   # ❌ Runs in devcontainer (wrong environment)
bats tests/binaries/*.bats       # ❌ Runs in devcontainer (wrong environment)
```

**✅ CORRECT: Running integration tests in test container**

```bash
# DO THIS - Runs in isolated Docker container with full installation
mise run test                    # ✅ Docker test container
mise run test:interactive        # ✅ Docker test container + shell
```

## Test Types and Where They Run

### Tests That Run in DEVCONTAINER ✓

These tests validate source files WITHOUT requiring a full installation:

**Syntax Tests** - Validate templates and scripts compile correctly

```bash
mise run test:bats:syntax        # ✓ Safe to run in devcontainer
mise run test:ci                 # ✓ Safe to run in devcontainer
bats tests/syntax/*.bats         # ✓ Safe to run in devcontainer
```

**Unit Tests** - Test library functions in isolation

```bash
mise run test:bats:unit          # ✓ Safe to run in devcontainer
bats tests/unit.bats             # ✓ Safe to run in devcontainer
```

**Install Script Tests** - Validate install.sh structure without running it

```bash
mise run test:bats:install       # ✓ Safe to run in devcontainer
bats tests/install/*.bats        # ✓ Safe to run in devcontainer
```

**Meta Tests** - Test the test suite itself

```bash
mise run test:bats:meta          # ✓ Safe to run in devcontainer
bats tests/meta/*.bats           # ✓ Safe to run in devcontainer
```

### Tests That MUST Run in TEST CONTAINER ⚠️

These tests require a FULL dotfiles installation and WILL FAIL in devcontainer:

**Binary Verification Tests** - Verify external binaries are installed

```bash
# ❌ NEVER run these in devcontainer
# ✅ ALWAYS use Docker test container
mise run test                    # Includes binary tests
```

**Integration Tests** - Test complete system integration

```bash
# ❌ NEVER run these in devcontainer
# ✅ ALWAYS use Docker test container
mise run test                    # Includes integration tests
mise run test:interactive        # Interactive exploration after tests
```

**Productivity Tools Tests** - Verify glow, mods, vhs, freeze, etc.

```bash
# ❌ NEVER run these in devcontainer
# ✅ ALWAYS use Docker test container
mise run test                    # Tests all productivity tools
```

## Why This Separation Exists

### Devcontainer Environment

The devcontainer is for **DEVELOPMENT**, not **TESTING THE RESULT**.

- Contains only minimal tools needed for editing (from `mise.toml`)
- Does NOT have the full external binary set (from `.chezmoiexternal.toml.tmpl`)
- Does NOT apply dotfiles - you're editing the source files directly
- Purpose: Fast, lightweight environment for coding

Example: VHS is NOT in `mise.toml`, so it's NOT in devcontainer, but it IS in `.chezmoiexternal.toml.tmpl`, so it WILL BE in test container.

### Test Container Environment

The test container is for **INTEGRATION TESTING**, simulating real installation.

- Starts from clean Debian base image
- Installs dotfiles using chezmoi (simulates real user)
- Downloads ALL external binaries (jq, fzf, vhs, freeze, glow, mods, etc.)
- Applies ALL templates and configurations
- Purpose: Verify the complete installation works correctly

## Common Mistakes and How to Avoid Them

### ❌ Mistake #1: Running Binary Tests in Devcontainer

**Wrong:**

```bash
# In devcontainer
bats tests/binaries/productivity-tools.bats
# Output: "not ok 13 vhs is installed as executable file"
# Reason: VHS isn't installed in devcontainer!
```

**Correct:**

```bash
# In devcontainer
mise run test
# This launches Docker test container where VHS IS installed
```

### ❌ Mistake #2: Thinking Failed Bats Tests Mean Configuration is Wrong

**Scenario:** You add VHS to `.chezmoiexternal.toml.tmpl`, run bats tests in devcontainer, test fails.

**Wrong conclusion:** "VHS configuration is broken, I need to fix it"

**Correct understanding:** "VHS test failed because I'm in devcontainer. I need to run `mise run test` to test in the proper environment."

### ❌ Mistake #3: Not Understanding Test Output Context

When you see:

```text
ok 13 .chezmoiexternal.toml.tmpl configures vhs binary     # Syntax test
not ok 14 vhs is installed as executable file              # Binary test
```

This means:

- ✅ VHS **configuration** is correct (syntax test passed)
- ❌ VHS **binary** is not installed in devcontainer (expected!)
- ℹ️  Need to run Docker test to verify actual installation

## Explicit Testing Workflow

### Step 1: Make Changes in Devcontainer

```bash
# Edit source files
vim .chezmoiexternal.toml.tmpl
vim tests/binaries/productivity-tools.bats
```

### Step 2: Run Quick Validation (Devcontainer)

```bash
# Verify syntax and configuration are correct
mise run test:bats:syntax
```

This checks:

- ✓ Templates render without errors
- ✓ Configuration syntax is valid
- ✓ Scripts have correct syntax
- ✓ Test suite integrity

This does NOT check:

- ✗ Binaries actually install
- ✗ Binaries are functional
- ✗ Full integration works

### Step 3: Run Integration Tests (Test Container)

```bash
# Launch Docker test container
mise run test
```

This:

1. Builds Docker image from scratch
2. Installs dotfiles using chezmoi
3. Downloads ALL external binaries
4. Runs COMPLETE test suite
5. Verifies everything works end-to-end

**Expected output includes:**

```text
=== Binary Installation Verification ===
[INFO] ✓ vhs: correctly installed as executable file
[INFO] ✓ freeze: correctly installed as executable file

=== Productivity Tools Verification ===
[INFO] ✓ vhs: installed and working
[INFO] ✓ freeze: installed and working
```

### Step 4: Optional Interactive Verification

```bash
# Drop into test container shell after tests
mise run test:interactive

# Inside test container, manually verify:
which vhs                    # Should output: /home/user/.local/bin/vhs
vhs --version               # Should show version
ls -la ~/.local/bin/vhs     # Should be executable file, not directory
```

## Test Container Commands Reference

### Basic Test Execution

```bash
# Run complete test suite in Docker
mise run test
```

### Interactive Testing

```bash
# Run tests, then open interactive shell
mise run test:interactive

# Open shell WITHOUT running tests (for debugging)
mise run test:shell
```

### GitHub-Based Testing

```bash
# Test installation from GitHub (not local source)
mise run test:github

# GitHub test + interactive shell
mise run test:github:interactive
```

## Understanding Test Results

### Test Container Output Sections

When you run `mise run test`, you'll see these sections:

1. **Installing Chezmoi** - Downloads and installs chezmoi in test container
2. **External Binary Installation** - Downloads all tools (jq, fzf, vhs, etc.)
3. **MCP Server Configuration** - Sets up Claude MCP servers
4. **External Binary Verification** - Verifies binaries downloaded successfully
5. **Testing Zsh and Oh-My-Zsh** - Tests shell configuration
6. **Binary Installation Verification** - Checks binaries are files, not directories
7. **Productivity Tools Verification** - Tests tool functionality (--version checks)

### What Success Looks Like

For a newly added tool like VHS:

```bash
=== External Binary Installation ===
[INFO] ✓ External binaries installation complete

=== Binary Installation Verification ===
[INFO] ✓ vhs: correctly installed as executable file    # ← File check passed

=== Productivity Tools Verification ===
[INFO] ✓ vhs: installed and working                     # ← Functional check passed
```

### What Failure Looks Like

**Configuration Error (wrong type):**

```bash
[ERROR] ✗ vhs: is a directory (should be a file)        # ← Wrong type in config
```

This means: Check `.chezmoiexternal.toml.tmpl` - probably used wrong type or missing path field

**Download Error:**

```bash
[ERROR] ✗ vhs: not found at /home/user/.local/bin/vhs   # ← Download failed
```

This means: Check URL, version number, platform support

**Functionality Error:**

```bash
[INFO] ✓ vhs: correctly installed as executable file
[ERROR] ✗ vhs: installed but not working                # ← Binary present but broken
```

This means: Binary downloaded but can't execute (wrong arch, missing dependencies)

## Adding New External Tools - Complete Workflow

When adding a new tool to `.chezmoiexternal.toml.tmpl`:

### 1. Add Configuration (Devcontainer)

```bash
# Edit external configuration
vim .chezmoiexternal.toml.tmpl

# Add tool following existing patterns
```

### 2. Add Tests (Devcontainer)

```bash
# Add syntax test
vim tests/syntax/externals.bats

# Add binary verification test
vim tests/binaries/productivity-tools.bats

# Add to test script lists
vim tests/test-dotfiles.sh
vim tests/test-dotfiles-github.sh
```

### 3. Validate Syntax (Devcontainer)

```bash
# Verify templates render correctly
mise run test:bats:syntax

# Expected: All tests pass including new tool
```

### 4. Run Integration Tests (Test Container)

```bash
# Launch Docker test container
mise run test

# Watch for your tool in output:
# - External Binary Installation section
# - Binary Installation Verification section
# - Productivity Tools Verification section
```

### 5. Verify Success (Test Container Output)

Look for these lines:

```text
[INFO] ✓ yourtool: correctly installed as executable file
[INFO] ✓ yourtool: installed and working
```

### 6. Optional: Manual Verification (Test Container Interactive)

```bash
mise run test:interactive

# Inside container:
which yourtool
yourtool --version
file ~/.local/bin/yourtool
ls -la ~/.local/bin/yourtool
```

## Frequently Asked Questions

### Q: Why do binary tests fail in devcontainer?

**A:** Because devcontainer only has tools from `mise.toml`, not `.chezmoiexternal.toml.tmpl`. External tools (vhs, freeze, glow, etc.) are only installed when dotfiles are applied, which happens in test container.

### Q: Can I apply dotfiles in devcontainer to test them?

**A:** NO. Never run `chezmoi apply` in devcontainer. The devcontainer is for editing source files. Use `mise run test` to test in isolated Docker container.

### Q: How do I know if a test should run in devcontainer or test container?

**A:**

- **Syntax/unit/meta tests**: Devcontainer (validate source files)
- **Binary/integration tests**: Test container (validate installation)
- **When in doubt**: Use test container

### Q: What if I want to debug why a binary isn't installing?

**A:** Use interactive test mode:

```bash
mise run test:interactive

# Inside container, check:
ls -la ~/.local/bin/
chezmoi diff
chezmoi status
```

### Q: Can I skip the Docker test and just check syntax?

**A:** You can validate syntax locally (`mise run test:bats:syntax`), but you MUST run Docker tests before committing to ensure the complete installation works.

### Q: The Docker test takes too long, can I speed it up?

**A:**

- Use `mise run test:ci` for quick syntax-only validation during development
- Use `mise run test` for final validation before commit
- Docker tests are necessary to catch real-world issues

## Summary: The Golden Rules

1. **NEVER run integration tests in devcontainer** - They will fail because dotfiles aren't applied there
2. **ALWAYS use `mise run test` for integration testing** - It runs in proper Docker environment
3. **Syntax tests are safe in devcontainer** - They only validate source files
4. **Binary tests require test container** - External tools only exist after installation
5. **When a bats test fails in devcontainer, check if it's an integration test** - If yes, run in test container instead
6. **Test container output is the source of truth** - That's where real installation happens

## Still Confused?

If you're unsure which environment to use:

**Default to test container:**

```bash
mise run test
```

This is ALWAYS safe and tests the complete installation. It's slower but comprehensive.

**Only use devcontainer for:**

- Editing files
- Quick syntax validation (`mise run test:ci`)
- Running unit tests

**Everything else: test container.**