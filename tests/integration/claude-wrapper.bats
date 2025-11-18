#!/usr/bin/env bats

# Claude wrapper tests (secret injection, bypass whitelist, fallback behavior)

setup() {
    # Load bats helpers
    load '../test_helper'

    # Create temp directory for test files
    export TEST_DIR="$(mktemp -d)"
    export ORIGINAL_HOME="$HOME"
    export HOME="$TEST_DIR/home"
    mkdir -p "$HOME/.config/claude"

    # Create a mock claude command
    export MOCK_CLAUDE="$TEST_DIR/mock-claude"
    cat > "$MOCK_CLAUDE" << 'EOF'
#!/usr/bin/env bash
# Mock claude command - outputs args and environment for testing
echo "MOCK_CLAUDE_CALLED"
echo "ARGS: $*"
# Output specific env vars we care about for testing
[[ -n "$TEST_VAR" ]] && echo "TEST_VAR=$TEST_VAR"
[[ -n "$API_KEY" ]] && echo "API_KEY=$API_KEY"
[[ -n "$PROJECT_VAR" ]] && echo "PROJECT_VAR=$PROJECT_VAR"
exit 0
EOF
    chmod +x "$MOCK_CLAUDE"

    # Create a mock op command that fails
    export MOCK_OP_FAIL="$TEST_DIR/mock-op-fail"
    cat > "$MOCK_OP_FAIL" << 'EOF'
#!/usr/bin/env bash
# Mock op command that always fails (simulates not signed in)
echo "[ERROR] You are not signed in to 1Password" >&2
exit 1
EOF
    chmod +x "$MOCK_OP_FAIL"

    # Create a mock op command that succeeds
    export MOCK_OP_SUCCESS="$TEST_DIR/mock-op-success"
    cat > "$MOCK_OP_SUCCESS" << 'EOF'
#!/usr/bin/env bash
# Mock op command that succeeds - sources env files and runs command
shift # remove 'run'
while [[ $# -gt 0 ]]; do
    case "$1" in
        --env-file=*)
            env_file="${1#*=}"
            set -a
            source "$env_file"
            set +a
            shift
            ;;
        --no-masking)
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            shift
            ;;
    esac
done
# Execute remaining command
"$@"
EOF
    chmod +x "$MOCK_OP_SUCCESS"

    # Add mock binaries to PATH
    export PATH="$TEST_DIR:$PATH"

    # Create symlink so our mock claude is found as 'claude'
    ln -s "$MOCK_CLAUDE" "$TEST_DIR/claude"

    # Load the claude wrapper function
    # We need to extract just the function from the template
    # (skip template processing, just get the function)
    source <(sed -n '/^claude() {/,/^}$/p' "$BATS_TEST_DIRNAME/../../dot_config/zsh/tools/claude.zsh.tmpl")
}

teardown() {
    # Restore original HOME
    export HOME="$ORIGINAL_HOME"
    # Clean up temp directory
    rm -rf "$TEST_DIR"
}

# ═══════════════════════════════════════════════════════════════
# Bypass Whitelist Tests
# ═══════════════════════════════════════════════════════════════

@test "claude --help bypasses secret injection" {
    # Create env file (should be ignored)
    echo "TEST_VAR=secret" > "$HOME/.config/claude/claude.env"

    run claude --help
    assert_success
    assert_output --partial "MOCK_CLAUDE_CALLED"
    assert_output --partial "ARGS: --help"
    refute_output --partial "TEST_VAR=secret"
}

@test "claude -h bypasses secret injection" {
    echo "TEST_VAR=secret" > "$HOME/.config/claude/claude.env"

    run claude -h
    assert_success
    assert_output --partial "ARGS: -h"
    refute_output --partial "TEST_VAR=secret"
}

@test "claude --version bypasses secret injection" {
    echo "TEST_VAR=secret" > "$HOME/.config/claude/claude.env"

    run claude --version
    assert_success
    assert_output --partial "ARGS: --version"
    refute_output --partial "TEST_VAR=secret"
}

@test "claude help bypasses secret injection" {
    echo "TEST_VAR=secret" > "$HOME/.config/claude/claude.env"

    run claude help
    assert_success
    assert_output --partial "ARGS: help"
    refute_output --partial "TEST_VAR=secret"
}

@test "custom bypass commands from ~/.config/claude/bypass-commands" {
    echo "TEST_VAR=secret" > "$HOME/.config/claude/claude.env"

    # Create custom bypass list
    cat > "$HOME/.config/claude/bypass-commands" << 'EOF'
# Custom bypass commands
--info
status
EOF

    # Test custom bypass command
    run claude --info
    assert_success
    assert_output --partial "ARGS: --info"
    refute_output --partial "TEST_VAR=secret"
}

@test "bypass-commands file ignores comments and empty lines" {
    echo "TEST_VAR=secret" > "$HOME/.config/claude/claude.env"

    cat > "$HOME/.config/claude/bypass-commands" << 'EOF'
# This is a comment

--custom-bypass

# Another comment
EOF

    run claude --custom-bypass
    assert_success
    assert_output --partial "ARGS: --custom-bypass"
    refute_output --partial "TEST_VAR=secret"
}

# ═══════════════════════════════════════════════════════════════
# No .env Files Tests
# ═══════════════════════════════════════════════════════════════

@test "runs claude directly when no .env files exist" {
    # No .env files created

    run claude test command
    assert_success
    assert_output --partial "MOCK_CLAUDE_CALLED"
    assert_output --partial "ARGS: test command"
}

# ═══════════════════════════════════════════════════════════════
# Op Success Tests
# ═══════════════════════════════════════════════════════════════

@test "uses op run when op is available and succeeds" {
    # Create symlink for successful op
    ln -sf "$MOCK_OP_SUCCESS" "$TEST_DIR/op"

    echo "API_KEY=secret123" > "$HOME/.config/claude/claude.env"

    run claude test
    assert_success
    assert_output --partial "MOCK_CLAUDE_CALLED"
    assert_output --partial "API_KEY=secret123"
}

@test "merges global and project .env files via op" {
    ln -sf "$MOCK_OP_SUCCESS" "$TEST_DIR/op"

    echo "API_KEY=global_key" > "$HOME/.config/claude/claude.env"
    mkdir -p "$TEST_DIR/project"
    cd "$TEST_DIR/project"
    echo "PROJECT_VAR=project_value" > "./.env"

    run claude test
    assert_success
    assert_output --partial "API_KEY=global_key"
    assert_output --partial "PROJECT_VAR=project_value"
}

# ═══════════════════════════════════════════════════════════════
# Op Failure Fallback Tests
# ═══════════════════════════════════════════════════════════════

@test "falls back to direct sourcing when op fails" {
    # Use the failing op mock
    ln -sf "$MOCK_OP_FAIL" "$TEST_DIR/op"

    echo "TEST_VAR=fallback_value" > "$HOME/.config/claude/claude.env"

    run claude test
    assert_success
    assert_output --partial "MOCK_CLAUDE_CALLED"
    assert_output --partial "TEST_VAR=fallback_value"
    assert_output --partial "1Password CLI failed"
    assert_output --partial "Falling back"
}

@test "fallback warning mentions op:// references won't resolve" {
    ln -sf "$MOCK_OP_FAIL" "$TEST_DIR/op"

    echo "API_KEY=plain_value" > "$HOME/.config/claude/claude.env"

    run claude test
    assert_success
    assert_output --partial "op:// secret references will NOT be resolved"
}

@test "fallback sources variables correctly" {
    ln -sf "$MOCK_OP_FAIL" "$TEST_DIR/op"

    echo "API_KEY=fallback_key" > "$HOME/.config/claude/claude.env"
    mkdir -p "$TEST_DIR/project2"
    cd "$TEST_DIR/project2"
    echo "PROJECT_VAR=project_fallback" > "./.env"

    run claude test
    assert_success
    assert_output --partial "API_KEY=fallback_key"
    assert_output --partial "PROJECT_VAR=project_fallback"
}

# ═══════════════════════════════════════════════════════════════
# Direct Sourcing Tests (no op available)
# ═══════════════════════════════════════════════════════════════

@test "sources .env directly when op not installed" {
    # Ensure no op command exists
    # (PATH already set to only have our TEST_DIR, and we don't create op symlink)

    echo "TEST_VAR=direct_value" > "$HOME/.config/claude/claude.env"

    run claude test
    assert_success
    assert_output --partial "MOCK_CLAUDE_CALLED"
    assert_output --partial "TEST_VAR=direct_value"
    refute_output --partial "1Password CLI failed"  # No fallback warning
}

@test "merges global and project .env without op" {
    echo "API_KEY=global" > "$HOME/.config/claude/claude.env"
    mkdir -p "$TEST_DIR/project3"
    cd "$TEST_DIR/project3"
    echo "PROJECT_VAR=local" > "./.env"

    run claude test
    assert_success
    assert_output --partial "API_KEY=global"
    assert_output --partial "PROJECT_VAR=local"
}

@test "project .env overrides global .env" {
    echo "API_KEY=global_value" > "$HOME/.config/claude/claude.env"
    mkdir -p "$TEST_DIR/project4"
    cd "$TEST_DIR/project4"
    echo "API_KEY=project_value" > "./.env"

    run claude test
    assert_success
    # Project value should win
    assert_output --partial "API_KEY=project_value"
    refute_output --partial "API_KEY=global_value"
}

# ═══════════════════════════════════════════════════════════════
# Environment Isolation Tests
# ═══════════════════════════════════════════════════════════════

@test "environment variables don't leak to parent shell" {
    echo "TEST_VAR=should_not_leak" > "$HOME/.config/claude/claude.env"

    # Run claude wrapper
    claude test > /dev/null 2>&1

    # Check that TEST_VAR is not set in our shell
    run bash -c '[[ -z "$TEST_VAR" ]]'
    assert_success
}

# ═══════════════════════════════════════════════════════════════
# Edge Cases
# ═══════════════════════════════════════════════════════════════

@test "handles empty .env file gracefully" {
    touch "$HOME/.config/claude/claude.env"

    run claude test
    assert_success
    assert_output --partial "MOCK_CLAUDE_CALLED"
}

@test "handles .env file with only comments" {
    cat > "$HOME/.config/claude/claude.env" << 'EOF'
# This is a comment
# Another comment
EOF

    run claude test
    assert_success
    assert_output --partial "MOCK_CLAUDE_CALLED"
}

@test "works when only project .env exists" {
    # No global .env
    mkdir -p "$TEST_DIR/project5"
    cd "$TEST_DIR/project5"
    echo "PROJECT_VAR=only_local" > "./.env"

    run claude test
    assert_success
    assert_output --partial "PROJECT_VAR=only_local"
}

@test "works when only global .env exists" {
    echo "API_KEY=only_global" > "$HOME/.config/claude/claude.env"
    # No project .env

    run claude test
    assert_success
    assert_output --partial "API_KEY=only_global"
}

@test "passes all arguments to claude correctly" {
    run claude arg1 "arg with spaces" --flag=value
    assert_success
    assert_output --partial 'ARGS: arg1 arg with spaces --flag=value'
}

@test "handles special characters in arguments" {
    run claude "test \$VAR" '@special' '!bang'
    assert_success
    assert_output --partial 'test $VAR'
}

# ═══════════════════════════════════════════════════════════════
# Custom.d Markdown Injection Tests
# ═══════════════════════════════════════════════════════════════

@test "loads single custom.d markdown file via --append-system-prompt" {
    mkdir -p "$HOME/.config/claude/custom.d"
    echo "# Custom Instruction" > "$HOME/.config/claude/custom.d/00-test.md"
    echo "Always use strict mode" >> "$HOME/.config/claude/custom.d/00-test.md"

    run claude test
    assert_success
    assert_output --partial "MOCK_CLAUDE_CALLED"
    # Check that --append-system-prompt flag was added
    assert_output --partial "ARGS:"
}

@test "loads multiple custom.d files in alphabetical order" {
    mkdir -p "$HOME/.config/claude/custom.d"
    echo "# First File" > "$HOME/.config/claude/custom.d/00-first.md"
    echo "# Second File" > "$HOME/.config/claude/custom.d/01-second.md"
    echo "# Third File" > "$HOME/.config/claude/custom.d/02-third.md"

    run claude test
    assert_success
    assert_output --partial "MOCK_CLAUDE_CALLED"
}

@test "custom.d files are sorted alphabetically (99 comes after 10)" {
    mkdir -p "$HOME/.config/claude/custom.d"
    echo "Content 10" > "$HOME/.config/claude/custom.d/10-ten.md"
    echo "Content 99" > "$HOME/.config/claude/custom.d/99-ninetynine.md"
    echo "Content 05" > "$HOME/.config/claude/custom.d/05-five.md"

    # Create a modified mock claude that shows the --append-system-prompt content
    cat > "$MOCK_CLAUDE" << 'EOF'
#!/usr/bin/env bash
echo "MOCK_CLAUDE_CALLED"
# Extract --append-system-prompt value
for ((i=1; i<=$#; i++)); do
    if [[ "${!i}" == "--append-system-prompt" ]]; then
        j=$((i+1))
        echo "CUSTOM_PROMPT_ORDER: ${!j}"
        break
    fi
done
EOF
    chmod +x "$MOCK_CLAUDE"

    run claude test
    assert_success
    assert_output --partial "MOCK_CLAUDE_CALLED"
    # Verify order: 05 should appear before 10, 10 before 99
    assert_output --regexp "Content 05.*Content 10.*Content 99"
}

@test "ignores non-markdown files in custom.d" {
    mkdir -p "$HOME/.config/claude/custom.d"
    echo "# Markdown" > "$HOME/.config/claude/custom.d/00-test.md"
    echo "Not markdown" > "$HOME/.config/claude/custom.d/01-test.txt"
    echo "Also not markdown" > "$HOME/.config/claude/custom.d/README"

    run claude test
    assert_success
    assert_output --partial "MOCK_CLAUDE_CALLED"
}

@test "works when custom.d directory doesn't exist" {
    # Don't create custom.d directory
    run claude test
    assert_success
    assert_output --partial "MOCK_CLAUDE_CALLED"
}

@test "works when custom.d directory is empty" {
    mkdir -p "$HOME/.config/claude/custom.d"
    # No files in directory

    # Mock that detects if --append-system-prompt was passed
    cat > "$MOCK_CLAUDE" << 'EOF'
#!/usr/bin/env bash
echo "MOCK_CLAUDE_CALLED"
for arg in "$@"; do
    if [[ "$arg" == "--append-system-prompt" ]]; then
        echo "CUSTOM_PROMPT_ADDED"
    fi
done
echo "ARGS: $*"
EOF
    chmod +x "$MOCK_CLAUDE"

    run claude test
    assert_success
    assert_output --partial "MOCK_CLAUDE_CALLED"
    assert_output --partial "ARGS: test"
    refute_output --partial "CUSTOM_PROMPT_ADDED"
}

@test "custom.d files are concatenated with double newline spacing" {
    mkdir -p "$HOME/.config/claude/custom.d"
    echo "First content" > "$HOME/.config/claude/custom.d/00-first.md"
    echo "Second content" > "$HOME/.config/claude/custom.d/01-second.md"

    # Mock claude that shows concatenated content
    cat > "$MOCK_CLAUDE" << 'EOF'
#!/usr/bin/env bash
echo "MOCK_CLAUDE_CALLED"
for ((i=1; i<=$#; i++)); do
    if [[ "${!i}" == "--append-system-prompt" ]]; then
        j=$((i+1))
        # Check for double newline between files (markdown section separation)
        if [[ "${!j}" =~ "First content"$'\n\n'"Second content" ]]; then
            echo "SPACING_CORRECT"
        fi
        break
    fi
done
EOF
    chmod +x "$MOCK_CLAUDE"

    run claude test
    assert_success
    assert_output --partial "SPACING_CORRECT"
}

@test "custom.d works with .env file injection" {
    mkdir -p "$HOME/.config/claude/custom.d"
    echo "# Custom" > "$HOME/.config/claude/custom.d/00-test.md"
    echo "API_KEY=test_key" > "$HOME/.config/claude/claude.env"

    run claude test
    assert_success
    assert_output --partial "MOCK_CLAUDE_CALLED"
    assert_output --partial "API_KEY=test_key"
}

@test "custom.d works with op run success" {
    ln -sf "$MOCK_OP_SUCCESS" "$TEST_DIR/op"
    mkdir -p "$HOME/.config/claude/custom.d"
    echo "# Custom" > "$HOME/.config/claude/custom.d/00-test.md"
    echo "API_KEY=secret" > "$HOME/.config/claude/claude.env"

    run claude test
    assert_success
    assert_output --partial "API_KEY=secret"
}

@test "custom.d works with op run failure fallback" {
    ln -sf "$MOCK_OP_FAIL" "$TEST_DIR/op"
    mkdir -p "$HOME/.config/claude/custom.d"
    echo "# Custom" > "$HOME/.config/claude/custom.d/00-test.md"
    echo "API_KEY=fallback" > "$HOME/.config/claude/claude.env"

    run claude test
    assert_success
    assert_output --partial "1Password CLI failed"
    assert_output --partial "API_KEY=fallback"
}

@test "bypass commands skip custom.d injection" {
    mkdir -p "$HOME/.config/claude/custom.d"
    echo "# Custom" > "$HOME/.config/claude/custom.d/00-test.md"

    # Mock that detects if --append-system-prompt was passed
    cat > "$MOCK_CLAUDE" << 'EOF'
#!/usr/bin/env bash
echo "MOCK_CLAUDE_CALLED"
for arg in "$@"; do
    if [[ "$arg" == "--append-system-prompt" ]]; then
        echo "CUSTOM_PROMPT_ADDED"
    fi
done
echo "ARGS: $*"
EOF
    chmod +x "$MOCK_CLAUDE"

    run claude --help
    assert_success
    assert_output --partial "ARGS: --help"
    refute_output --partial "CUSTOM_PROMPT_ADDED"
}

@test "custom.d works when op is not installed (with .env files)" {
    # Ensure no op command exists
    mkdir -p "$HOME/.config/claude/custom.d"
    echo "# Custom Instruction" > "$HOME/.config/claude/custom.d/00-test.md"
    echo "API_KEY=test_secret" > "$HOME/.config/claude/claude.env"

    # Mock that shows both env var AND custom prompt flag
    cat > "$MOCK_CLAUDE" << 'EOF'
#!/usr/bin/env bash
echo "MOCK_CLAUDE_CALLED"
[[ -n "$API_KEY" ]] && echo "API_KEY=$API_KEY"
for arg in "$@"; do
    if [[ "$arg" == "--append-system-prompt" ]]; then
        echo "CUSTOM_PROMPT_INCLUDED"
    fi
done
EOF
    chmod +x "$MOCK_CLAUDE"

    run claude test
    assert_success
    assert_output --partial "MOCK_CLAUDE_CALLED"
    assert_output --partial "API_KEY=test_secret"
    assert_output --partial "CUSTOM_PROMPT_INCLUDED"
}
