#!/usr/bin/env bats

# Tests for install.sh script

setup() {
    # Load bats helpers
    load 'libs/bats-support/load'
    load 'libs/bats-assert/load'

    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
    INSTALL_SCRIPT="$REPO_ROOT/install.sh"
}

@test "install.sh exists" {
    [ -f "$INSTALL_SCRIPT" ]
}

@test "install.sh is executable" {
    [ -x "$INSTALL_SCRIPT" ]
}

@test "install.sh has proper shebang" {
    run head -n 1 "$INSTALL_SCRIPT"
    assert_success
    assert_output --partial "#!/usr/bin/env bash"
}

@test "install.sh contains set -euo pipefail" {
    run grep -q "set -euo pipefail" "$INSTALL_SCRIPT"
    assert_success
}

@test "install.sh has --safe mode" {
    run grep -q "\-\-safe" "$INSTALL_SCRIPT"
    assert_success
}

@test "install.sh has --bootstrap mode" {
    run grep -q "\-\-bootstrap" "$INSTALL_SCRIPT"
    assert_success
}

@test "install.sh validates platform detection" {
    run grep -q "detect_platform" "$INSTALL_SCRIPT"
    assert_success
}

@test "install.sh has fallback to safe mode" {
    run grep -q "fallback_to_safe_mode" "$INSTALL_SCRIPT"
    assert_success
}

@test "install.sh uses absolute path for chezmoi binary" {
    run grep -q '\$HOME/\.local/bin/chezmoi' "$INSTALL_SCRIPT"
    assert_success
}

@test "install.sh has proper error handling" {
    run grep -q "if.*then" "$INSTALL_SCRIPT"
    assert_success
}

# Note: Actual functional testing of install.sh is done via mise tasks
# (test:install, test:install:safe, test:install:bootstrap) in Docker
