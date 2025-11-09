# Gum-Enhanced Logging System Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add gum-enhanced logging system to chezmoi dotfiles with DRY helper functions and wrapper script for improved visual feedback during installation and updates.

**Architecture:** Create a logging helper library that scripts can source, providing consistent logging functions (`log_success`, `log_error`, etc.) with automatic gum styling when available. Add a chezmoi wrapper script that shows a spinner during apply operations while displaying live enhanced output.

**Tech Stack:** Bash, gum (charmbracelet/gum), chezmoi

---

## Task 1: Create Logging Helper Library

**Files:**
- Create: `.chezmoiscripts/lib/logging.sh`
- Test: `tests/test-logging-helpers.sh`

**Step 1: Write the failing test**

Create test file that verifies logging functions exist and emit correct format:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Test logging helper library

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== Testing Logging Helper Library ==="

# Test 1: Library can be sourced
if source "$REPO_ROOT/.chezmoiscripts/lib/logging.sh" 2>/dev/null; then
    echo "✓ logging.sh can be sourced"
else
    echo "✗ logging.sh cannot be sourced"
    exit 1
fi

# Test 2: All logging functions exist
test_failed=0
for func in log_info log_success log_error log_warning log_progress log_section log_binary log_script; do
    if declare -f "$func" >/dev/null; then
        echo "✓ Function $func exists"
    else
        echo "✗ Function $func missing"
        test_failed=1
    fi
done

if [[ $test_failed -eq 1 ]]; then
    exit 1
fi

# Test 3: Functions emit correct format (without gum)
export _LOGGING_HAS_GUM=false

output=$(log_success "test message")
if [[ "$output" =~ ^\[SUCCESS\].*test\ message$ ]]; then
    echo "✓ log_success emits correct format"
else
    echo "✗ log_success format incorrect: $output"
    exit 1
fi

output=$(log_info "test message")
if [[ "$output" =~ ^\[INFO\].*test\ message$ ]]; then
    echo "✓ log_info emits correct format"
else
    echo "✗ log_info format incorrect: $output"
    exit 1
fi

output=$(log_error "test message" 2>&1)
if [[ "$output" =~ ^\[ERROR\].*test\ message$ ]]; then
    echo "✓ log_error emits correct format to stderr"
else
    echo "✗ log_error format incorrect: $output"
    exit 1
fi

echo ""
echo "✓ All logging helper tests passed!"
```

**Step 2: Run test to verify it fails**

Run: `bash tests/test-logging-helpers.sh`
Expected: FAIL with "logging.sh cannot be sourced" or "logging.sh: No such file or directory"

**Step 3: Create lib directory structure**

```bash
mkdir -p .chezmoiscripts/lib
```

**Step 4: Write minimal logging.sh implementation**

Create `.chezmoiscripts/lib/logging.sh`:

```bash
#!/usr/bin/env bash
# Logging helpers with automatic gum enhancement

# Detect gum availability (cached for performance)
if [[ -z "${_LOGGING_HAS_GUM+x}" ]]; then
    if command -v gum &>/dev/null; then
        _LOGGING_HAS_GUM=true
    else
        _LOGGING_HAS_GUM=false
    fi
    export _LOGGING_HAS_GUM
fi

# Internal: emit message with optional gum styling
_log_emit() {
    local level="$1"
    local icon="$2"
    local color="$3"
    local msg="$4"
    local target="${5:-stdout}"

    local formatted="[${level}] ${icon} ${msg}"

    if [[ "$_LOGGING_HAS_GUM" == true ]]; then
        if [[ "$target" == "stderr" ]]; then
            echo "$formatted" | gum style --foreground "$color" --bold >&2
        else
            echo "$formatted" | gum style --foreground "$color"
        fi
    else
        # Fallback: plain output with emoji
        if [[ "$target" == "stderr" ]]; then
            echo "$formatted" >&2
        else
            echo "$formatted"
        fi
    fi
}

# Public API - Simple and clean
log_info() {
    _log_emit "INFO" "ℹ️ " "4" "$1"
}

log_success() {
    _log_emit "SUCCESS" "✓" "2" "$1"
}

log_error() {
    _log_emit "ERROR" "✗" "1" "$1" "stderr"
}

log_warning() {
    _log_emit "WARNING" "⚠️ " "3" "$1"
}

log_progress() {
    _log_emit "PROGRESS" "⏳" "6" "$1"
}

log_section() {
    local msg="$1"
    echo ""
    if [[ "$_LOGGING_HAS_GUM" == true ]]; then
        echo "[SECTION] === ${msg} ===" | gum style --foreground 5 --bold --border rounded --padding "0 1"
    else
        echo "[SECTION] === ${msg} ==="
    fi
    echo ""
}

# For binary installations - special formatting
log_binary() {
    local binary_name="$1"
    local status="$2"  # "installing" or "installed"

    if [[ "$status" == "installing" ]]; then
        log_progress "Installing ${binary_name}..."
    else
        log_success "${binary_name}: installed and verified"
    fi
}

# For script execution tracking
log_script() {
    local script_name="$1"
    log_info "Running: ${script_name}"
}
```

**Step 5: Run test to verify it passes**

Run: `bash tests/test-logging-helpers.sh`
Expected: PASS with "✓ All logging helper tests passed!"

**Step 6: Commit**

```bash
git add .chezmoiscripts/lib/logging.sh tests/test-logging-helpers.sh
git commit -m "feat: add logging helper library with gum enhancement support"
```

---

## Task 2: Create Chezmoi Apply Wrapper Script

**Files:**
- Create: `dot_local/bin/executable_chezmoi-apply`
- Test: Manual test with `mise run test`

**Step 1: Create wrapper script**

Create `dot_local/bin/executable_chezmoi-apply`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Enhanced chezmoi apply wrapper with gum spinner
# Usage: chezmoi-apply [chezmoi apply arguments]

# Pass through all arguments to chezmoi apply (default to -v for verbose)
CHEZMOI_ARGS="${*:--v}"

if command -v gum &>/dev/null; then
    # With gum: Show spinner + live output
    gum spin \
        --spinner meter \
        --title "Applying dotfiles configuration..." \
        --show-output \
        -- chezmoi apply $CHEZMOI_ARGS
else
    # Without gum: Just run chezmoi
    chezmoi apply $CHEZMOI_ARGS
fi
```

**Step 2: Verify file naming for chezmoi**

Chezmoi naming convention:
- `dot_local/bin/` → `~/.local/bin/`
- `executable_` prefix → makes file executable

Full path: `dot_local/bin/executable_chezmoi-apply` becomes `~/.local/bin/chezmoi-apply`

**Step 3: Test wrapper manually in test container**

Run: `mise run test:shell`

In container shell:
```bash
# Apply dotfiles first to get the wrapper installed
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply --source ~/.local/share/chezmoi

# Test the wrapper exists and is executable
ls -la ~/.local/bin/chezmoi-apply
# Expected: -rwxr-xr-x ... /home/user/.local/bin/chezmoi-apply

# Test running the wrapper
~/.local/bin/chezmoi-apply --help
# Expected: Shows chezmoi apply help
```

**Step 4: Commit**

```bash
git add dot_local/bin/executable_chezmoi-apply
git commit -m "feat: add chezmoi-apply wrapper with gum spinner support"
```

---

## Task 3: Migrate Existing Script to Use Logging Helpers

**Files:**
- Modify: `.chezmoiscripts/run_once_after_setup-gitconfig-include.sh`

**Step 1: Review current script output**

Current script has these echo statements:
- Line 7: `echo "Setting up git configuration..."`
- Line 14: `echo "Creating new ~/.gitconfig"`
- Line 21: `echo "✓ [include] directive already present in ~/.gitconfig"`
- Line 25: `echo "Adding chezmoi-managed gitconfig include to ~/.gitconfig"`
- Line 35-36: Success messages

**Step 2: Update script to use logging helpers**

Modify `.chezmoiscripts/run_once_after_setup-gitconfig-include.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Automatically add [include] directive to ~/.gitconfig for chezmoi-managed config
# This runs once after chezmoi applies files

# Source logging helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/logging.sh"

log_script "setup-gitconfig-include.sh"

gitconfig="$HOME/.gitconfig"
include_path="$HOME/.gitconfig.d/default"

# Create .gitconfig if it doesn't exist
if [[ ! -f "$gitconfig" ]]; then
    log_info "Creating new ~/.gitconfig"
    touch "$gitconfig"
fi

# Check if include directive already exists
if grep -q "path = $include_path" "$gitconfig" 2>/dev/null || \
   grep -q "path = ~/.gitconfig.d/default" "$gitconfig" 2>/dev/null; then
    log_success "[include] directive already present in ~/.gitconfig"
    exit 0
fi

log_progress "Adding chezmoi-managed gitconfig include to ~/.gitconfig"

# Add include at the bottom (so managed settings take priority)
cat >> "$gitconfig" <<EOF

# Include chezmoi-managed git configuration
[include]
	path = ~/.gitconfig.d/default
EOF

log_success "Added [include] directive to ~/.gitconfig"
log_info "Git will now use settings from ~/.gitconfig.d/default"
```

**Step 3: Test in test container**

Run: `mise run test:interactive`

Expected output should show:
```
[INFO] ℹ️  Running: setup-gitconfig-include.sh
[SUCCESS] ✓ [include] directive already present in ~/.gitconfig
```

Or if first run:
```
[INFO] ℹ️  Running: setup-gitconfig-include.sh
[PROGRESS] ⏳ Adding chezmoi-managed gitconfig include to ~/.gitconfig
[SUCCESS] ✓ Added [include] directive to ~/.gitconfig
[INFO] ℹ️  Git will now use settings from ~/.gitconfig.d/default
```

**Step 4: Commit**

```bash
git add .chezmoiscripts/run_once_after_setup-gitconfig-include.sh
git commit -m "refactor: migrate gitconfig setup script to use logging helpers"
```

---

## Task 4: Add Binary Installation Verification Script

**Files:**
- Create: `.chezmoiscripts/run_after_verify-external-binaries.sh.tmpl`

**Step 1: Create verification script**

This script runs after external binaries are installed and logs their status.

Create `.chezmoiscripts/run_after_verify-external-binaries.sh.tmpl`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Verify external binary installations and log results
# This runs after .chezmoiexternal.toml.tmpl downloads binaries

# Source logging helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/logging.sh"

log_section "External Binary Verification"

# List of binaries from .chezmoiexternal.toml.tmpl
binaries=(
    "jq"
    "fzf"
    "zoxide"
    "bat"
    "gitui"
    "starship"
)

failed=0

for binary in "${binaries[@]}"; do
    binary_path="$HOME/.local/bin/$binary"

    if [[ ! -e "$binary_path" ]]; then
        log_error "${binary}: not found at ${binary_path}"
        failed=1
        continue
    fi

    if [[ ! -f "$binary_path" ]]; then
        log_error "${binary}: exists but is not a regular file"
        failed=1
        continue
    fi

    if [[ ! -x "$binary_path" ]]; then
        log_error "${binary}: is not executable"
        failed=1
        continue
    fi

    log_success "${binary}: installed and verified"
done

if [[ $failed -eq 1 ]]; then
    log_error "Some binary installations failed"
    exit 1
fi

log_success "All external binaries verified successfully"
```

**Step 2: Test in test container**

Run: `mise run test:interactive`

Expected output after binary installation:
```
[SECTION] === External Binary Verification ===

[SUCCESS] ✓ jq: installed and verified
[SUCCESS] ✓ fzf: installed and verified
[SUCCESS] ✓ zoxide: installed and verified
[SUCCESS] ✓ bat: installed and verified
[SUCCESS] ✓ gitui: installed and verified
[SUCCESS] ✓ starship: installed and verified

[SUCCESS] ✓ All external binaries verified successfully
```

**Step 3: Commit**

```bash
git add .chezmoiscripts/run_after_verify-external-binaries.sh.tmpl
git commit -m "feat: add external binary verification with logging"
```

---

## Task 5: Update Test Scripts to Use Logging Helpers

**Files:**
- Modify: `tests/test-dotfiles.sh`

**Step 1: Update test-dotfiles.sh**

Replace echo statements with logging functions:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Source logging helpers (from repo root in devcontainer, from installed location in test container)
if [[ -f ~/.local/share/chezmoi/.chezmoiscripts/lib/logging.sh ]]; then
    source ~/.local/share/chezmoi/.chezmoiscripts/lib/logging.sh
elif [[ -f .chezmoiscripts/lib/logging.sh ]]; then
    source .chezmoiscripts/lib/logging.sh
fi

log_section "Installing Chezmoi"

mkdir -p ~/.local/bin

# Add -v for verbose output for debugging
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply --source ~/.local/share/chezmoi
log_success "Dotfiles applied successfully"

log_section "Testing Zsh and Oh-My-Zsh"

zsh -c "echo ✓ Zsh version: \$ZSH_VERSION"

# Test oh-my-zsh installation
if [[ -d ~/.oh-my-zsh ]]; then
  log_success "Oh-My-Zsh directory exists"
else
  log_error "Oh-My-Zsh directory missing"
  exit 1
fi

# Test oh-my-zsh is loaded in interactive shell
if zsh -i -c '[[ -n "$ZSH" ]]' 2>/dev/null; then
    log_success "Oh-My-Zsh loaded in interactive shell"
else
    log_error "Oh-My-Zsh not loaded"
    exit 1
fi

# Test oh-my-zsh plugins are installed
if [[ -d ~/.oh-my-zsh/custom/plugins/zsh-vi-mode ]]; then
  log_success "zsh-vi-mode plugin installed"
else
  log_error "zsh-vi-mode plugin missing"
fi

if [[ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
  log_success "zsh-autosuggestions plugin installed"
else
  log_error "zsh-autosuggestions plugin missing"
fi

log_section "Binary Installation Verification"

# Note: This section is now handled by run_after_verify-external-binaries.sh
# but we keep it here for test completeness

test_failed=0
for binary in jq fzf zoxide bat gitui starship; do
  binary_path="$HOME/.local/bin/$binary"

  if [[ ! -e "$binary_path" ]]; then
    log_error "$binary: not found at $binary_path"
    test_failed=1
    continue
  fi

  if [[ -d "$binary_path" ]]; then
    log_error "$binary: is a directory (should be a file)"
    test_failed=1
    continue
  fi

  if [[ ! -f "$binary_path" ]]; then
    log_error "$binary: exists but is not a regular file"
    test_failed=1
    continue
  fi

  if [[ ! -x "$binary_path" ]]; then
    log_error "$binary: is not executable"
    test_failed=1
    continue
  fi

  log_success "$binary: correctly installed as executable file"
done

if [[ $test_failed -eq 1 ]]; then
  log_error "Binary validation failed"
  exit 1
fi

log_success "All tests passed!"

echo ""
log_section "Home Directory Contents (checking for pollution)"
ls -la ~

# If running interactively (TTY attached), launch zsh shell
if [[ -t 0 ]]; then
  echo ""
  echo "Launching zsh shell..."
  exec zsh
fi
```

**Step 2: Test the updated test script**

Run: `mise run test`

Expected: All tests pass with enhanced logging output

**Step 3: Commit**

```bash
git add tests/test-dotfiles.sh
git commit -m "refactor: update test-dotfiles.sh to use logging helpers"
```

---

## Task 6: Add Zsh Alias for Wrapper (Optional Enhancement)

**Files:**
- Modify: `dot_zshrc.tmpl` (if you want automatic wrapper usage)

**Step 1: Add alias to .zshrc**

Add near the end of `dot_zshrc.tmpl`, before final configurations:

```bash
# Chezmoi wrapper with enhanced UI
if [[ -x "$HOME/.local/bin/chezmoi-apply" ]]; then
    alias cm-apply='chezmoi-apply'
fi
```

**Step 2: Document the alias**

Add comment explaining:
- `cm-apply` runs chezmoi apply with gum-enhanced output
- Regular `chezmoi` command still available for other operations

**Step 3: Test in interactive shell**

Run: `mise run test:interactive`

In the zsh shell:
```bash
cm-apply --help
# Expected: Shows chezmoi apply help with gum wrapper
```

**Step 4: Commit**

```bash
git add dot_zshrc.tmpl
git commit -m "feat: add cm-apply alias for gum-enhanced chezmoi wrapper"
```

---

## Task 7: Update Documentation

**Files:**
- Modify: `AGENTS.md`
- Modify: `CLAUDE.md`

**Step 1: Document logging helpers in AGENTS.md**

Add new section after "Shell script standards":

```markdown
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
```

**Step 2: Document wrapper in CLAUDE.md**

Add to "Quick Reference" section:

```markdown
**Enhanced chezmoi apply wrapper:**
```bash
chezmoi-apply           # Wrapper with gum spinner + live output
cm-apply                # Alias for chezmoi-apply (if in zsh)
chezmoi apply           # Standard chezmoi (no enhancement)
```
```

**Step 3: Add to "See Also" section**

```markdown
- **Logging Helpers** - `.chezmoiscripts/lib/logging.sh` - DRY logging functions with gum enhancement
```

**Step 4: Commit documentation**

```bash
git add AGENTS.md CLAUDE.md
git commit -m "docs: add logging helpers and wrapper documentation"
```

---

## Task 8: Add Logging Test to mise Tasks

**Files:**
- Modify: `.mise.toml`

**Step 1: Add test task for logging helpers**

Add to `.mise.toml` after existing test tasks:

```toml
[tasks."test:logging"]
description = "Test logging helper library"
run = "bash tests/test-logging-helpers.sh"
```

**Step 2: Test the new task**

Run: `mise run test:logging`
Expected: "✓ All logging helper tests passed!"

**Step 3: Commit**

```bash
git add .mise.toml
git commit -m "feat: add logging helper test task to mise"
```

---

## Task 9: Final Integration Test

**Files:**
- None (testing only)

**Step 1: Clean test environment**

```bash
mise run clean:full
```

**Step 2: Run full test suite**

```bash
mise run test:render      # Test template rendering
mise run test:logging     # Test logging helpers
mise run test             # Full integration test
```

Expected: All tests pass with enhanced logging output visible

**Step 3: Test wrapper in test container**

```bash
mise run test:shell
```

In container:
```bash
# Apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply --source ~/.local/share/chezmoi

# Test wrapper directly
~/.local/bin/chezmoi-apply --dry-run
```

Expected: Spinner shows "Applying dotfiles configuration..." with live enhanced output

**Step 4: Verify gum enhancement**

Look for:
- ✅ Colored output (green for success, red for errors)
- ✅ Structured `[LEVEL]` prefixes
- ✅ Section borders with gum style
- ✅ Binary verification messages

**Step 5: Test without gum (fallback)**

```bash
# Temporarily hide gum
export PATH="${PATH//:\/home\/user\/.local\/bin/}"

~/.local/bin/chezmoi-apply --dry-run
```

Expected: Plain text output with emojis, no colors (graceful degradation)

---

## Verification Checklist

Before considering this task complete, verify:

- [ ] Logging library exists and can be sourced
- [ ] All 8 logging functions work correctly
- [ ] Wrapper script exists at `~/.local/bin/chezmoi-apply`
- [ ] Wrapper shows spinner with live output
- [ ] Graceful degradation when gum unavailable
- [ ] At least one existing script migrated to use helpers
- [ ] Binary verification script works
- [ ] Tests updated to use logging helpers
- [ ] Documentation updated (AGENTS.md, CLAUDE.md)
- [ ] All tests pass (`mise run test`)
- [ ] Manual test in container successful

---

## Future Enhancements (Not in This Plan)

- Add `--quiet` mode to suppress non-error output
- Add log level filtering (e.g., only show warnings and errors)
- Add timestamp support for debugging
- Add log file output option
- Migrate remaining scripts (`run_after_merge-claude-json.sh.tmpl`, `run_once_install-starship.sh`)
- Add colored output to test-render-simple.sh using logging helpers
- Create logging helper documentation in dedicated markdown file

---

## Notes for Implementation

**Testing Strategy:**
- Use @superpowers:test-driven-development for each task
- Write test first, watch it fail, implement, watch it pass
- Test both with and without gum available

**Error Handling:**
- All scripts should continue to work if logging.sh unavailable
- Add fallback: `source "${SCRIPT_DIR}/lib/logging.sh" 2>/dev/null || true`
- If logging functions unavailable, use plain echo

**Chezmoi Source Directory:**
- Scripts run with `CHEZMOI_SOURCE_DIR` environment variable set
- Can use: `source "${CHEZMOI_SOURCE_DIR}/.chezmoiscripts/lib/logging.sh"`
- Or use relative path: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`

**Gum Availability:**
- In test container: gum installed via .chezmoiexternal.toml.tmpl
- During install.sh: gum may not be in PATH yet
- Wrapper handles both cases gracefully

**Commit Frequency:**
- Commit after each task completes successfully
- Use conventional commit format: `feat:`, `refactor:`, `docs:`, `test:`
- Keep commits small and focused on single change
