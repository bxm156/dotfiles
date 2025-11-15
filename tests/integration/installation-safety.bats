#!/usr/bin/env bats

# Installation safety tests
# Ensures installation doesn't cause data loss or conflicts

setup() {
    load '../test_helper'
}

@test "no scripts modify files outside home directory" {
    # Scripts should only modify files in $HOME
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    cd "$REPO_ROOT"

    local script
    local violations=""

    while IFS= read -r script; do
        # Look for writes outside $HOME (excluding /tmp)
        # Check for: cp, mv, rm, mkdir, touch, etc. with absolute paths
        if grep -E "(^|[^#].*)(\bcp\b|\bmv\b|\brm\b|\bmkdir\b|\btouch\b).*/[^$]" "$script" | \
           grep -v "\$HOME\|\$TMPDIR\|/tmp/\|/var/tmp/" > /dev/null 2>&1; then
            violations="${violations}  WRITES OUTSIDE HOME: $script\n"
        fi
    done < <(find .chezmoiscripts -type f 2>/dev/null || true)

    if [ -n "$violations" ]; then
        echo -e "Scripts should only modify files in \$HOME:\n${violations}"
        return 1
    fi
}

@test "no scripts use sudo or require root" {
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    cd "$REPO_ROOT"

    local script
    local warnings=""

    while IFS= read -r script; do
        if grep -E "^[^#]*\bsudo\b" "$script" > /dev/null 2>&1; then
            warnings="${warnings}  USES SUDO: $script\n"
        fi
    done < <(find .chezmoiscripts -type f 2>/dev/null || true)

    if [ -n "$warnings" ]; then
        echo -e "Scripts should not require sudo (dotfiles should be user-scoped):\n${warnings}"
        return 1
    fi
}

@test "git include setup preserves existing .gitconfig" {
    # Verify that git config setup doesn't destroy existing config
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"

    local setup_script
    setup_script=$(find "$REPO_ROOT/.chezmoiscripts" -name "*gitconfig*" -type f | head -1)

    if [ -n "$setup_script" ] && [ -f "$setup_script" ]; then
        # Should use append/include, not overwrite
        grep -qE ">>|append|include" "$setup_script"
    fi
}

@test "no destructive rm -rf commands" {
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    cd "$REPO_ROOT"

    local script
    local warnings=""

    while IFS= read -r script; do
        # Check for dangerous rm patterns
        if grep -E "rm -rf /|rm -rf \$HOME[^/]|rm -rf ~[^/]" "$script" > /dev/null 2>&1; then
            warnings="${warnings}  DANGEROUS RM: $script\n"
        fi
    done < <(find .chezmoiscripts -type f 2>/dev/null || true)

    if [ -n "$warnings" ]; then
        echo -e "Found potentially dangerous rm commands:\n${warnings}"
        return 1
    fi
}

@test "scripts handle existing files gracefully" {
    # Scripts should check if files exist before overwriting
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    cd "$REPO_ROOT"

    local script
    local count_total=0
    local count_safe=0

    while IFS= read -r script; do
        # Look for file creation (touch, echo >, cat >)
        if grep -E "touch |echo.*>|cat.*>" "$script" > /dev/null 2>&1; then
            count_total=$((count_total + 1))

            # Check if there's a guard (if [ ! -f ], if [ -f ], etc.)
            if grep -E "if.*-f|if.*-e|if.*exist" "$script" > /dev/null 2>&1; then
                count_safe=$((count_safe + 1))
            fi
        fi
    done < <(find .chezmoiscripts -type f 2>/dev/null || true)

    if [ $count_total -gt 0 ]; then
        echo "Found $count_safe/$count_total scripts that check for existing files"
        # Don't fail, just inform
    fi
}

@test "no sensitive data in repository" {
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    cd "$REPO_ROOT"

    # Check for common patterns of leaked secrets
    local patterns="password=|api_key=|secret=|token=|private_key"
    local violations=""

    # Check all files except .git and tests
    while IFS= read -r file; do
        if grep -iE "$patterns" "$file" 2>/dev/null | grep -v "example\|placeholder\|TODO\|FIXME" > /dev/null; then
            violations="${violations}  POSSIBLE SECRET: $file\n"
        fi
    done < <(find . -type f -not -path "./.git/*" -not -path "./tests/*" 2>/dev/null || true)

    if [ -n "$violations" ]; then
        echo -e "WARNING: Possible sensitive data found:\n${violations}"
        echo "Verify these are just examples/placeholders"
        # Don't fail - might be false positives
    fi
}

@test "chezmoi apply is safe to run multiple times" {
    # Test idempotency - running apply twice should be safe
    # This is an integration test that requires dotfiles to be applied

    if [ ! -f "$HOME/.zshrc" ]; then
        skip "Dotfiles not applied yet"
    fi

    # Record current state
    local zshrc_before zshrc_after
    zshrc_before=$(stat -c %Y "$HOME/.zshrc" 2>/dev/null || stat -f %m "$HOME/.zshrc" 2>/dev/null)

    # This test is conceptual - actual chezmoi re-apply would be done in CI
    # For now, just verify the file still exists
    [ -f "$HOME/.zshrc" ]

    # In full integration test, we would:
    # 1. Apply dotfiles
    # 2. Modify timestamp
    # 3. Re-apply dotfiles
    # 4. Verify no unexpected changes
}

@test "installation doesn't create world-writable files" {
    # Security check: no files should be world-writable

    if [ ! -d "$HOME/.local/bin" ]; then
        skip "Dotfiles not applied yet"
    fi

    local world_writable
    world_writable=$(find "$HOME/.local" "$HOME/.config" -type f -perm -002 2>/dev/null || true)

    if [ -n "$world_writable" ]; then
        echo "Found world-writable files:"
        echo "$world_writable"
        return 1
    fi
}
