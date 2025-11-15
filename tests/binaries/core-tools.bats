#!/usr/bin/env bats

# Core CLI tools installation and functionality tests
# Tests: jq, fzf, zoxide, bat

setup() {
    # Load bats helpers
    load '../libs/bats-support/load'
    load '../libs/bats-assert/load'

    # Binary installation directory
    BIN_DIR="$HOME/.local/bin"
}

# Helper function to check if binary is properly installed
check_binary() {
    local binary="$1"
    local binary_path="$BIN_DIR/$binary"

    # Check if binary exists
    [ -e "$binary_path" ] || return 1

    # Check it's not a directory
    [ ! -d "$binary_path" ] || return 2

    # Check it's a regular file
    [ -f "$binary_path" ] || return 3

    # Check it's executable
    [ -x "$binary_path" ] || return 4

    return 0
}

# Helper to skip test if binary is not installed
skip_if_not_installed() {
    local binary="$1"
    if [ ! -x "$HOME/.local/bin/$binary" ]; then
        skip "$binary not installed"
    fi
}

# jq - JSON processor
@test "jq is installed as executable file" {
    run check_binary "jq"
    assert_success
}

@test "jq is functional" {
    skip_if_not_installed jq
    run "$HOME/.local/bin/jq" --version
    assert_success
}

# fzf - Fuzzy finder
@test "fzf is installed as executable file" {
    run check_binary "fzf"
    assert_success
}

@test "fzf is functional" {
    skip_if_not_installed fzf
    run "$HOME/.local/bin/fzf" --version
    assert_success
}

# zoxide - Smarter cd command
@test "zoxide is installed as executable file" {
    run check_binary "zoxide"
    assert_success
}

@test "zoxide is functional" {
    skip_if_not_installed zoxide
    run "$HOME/.local/bin/zoxide" --version
    assert_success
}

# bat - Cat with syntax highlighting
@test "bat is installed as executable file" {
    run check_binary "bat"
    assert_success
}

@test "bat is functional" {
    skip_if_not_installed bat
    run "$HOME/.local/bin/bat" --version
    assert_success
}
