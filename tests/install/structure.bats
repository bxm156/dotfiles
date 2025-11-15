#!/usr/bin/env bats

# install.sh script structure and best practices tests

setup() {
    # Load bats helpers
    load '../test_helper'

    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
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

@test "install.sh uses absolute path for chezmoi binary" {
    run grep -q '\$HOME/\.local/bin/chezmoi' "$INSTALL_SCRIPT"
    assert_success
}

@test "install.sh has proper error handling" {
    run grep -q "if.*then" "$INSTALL_SCRIPT"
    assert_success
}
