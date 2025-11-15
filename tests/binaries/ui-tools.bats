#!/usr/bin/env bats

# UI and terminal enhancement tools tests
# Tests: gum, starship, gitui

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

# gum - Pretty CLI output
@test "gum is installed as executable file" {
    run check_binary "gum"
    assert_success
}

@test "gum is functional" {
    skip_if_not_installed gum
    run "$HOME/.local/bin/gum" --version
    assert_success
}

# starship - Shell prompt
@test "starship is installed as executable file" {
    run check_binary "starship"
    assert_success
}

@test "starship is functional" {
    skip_if_not_installed starship
    run "$HOME/.local/bin/starship" --version
    assert_success
}

# gitui - Terminal git UI
@test "gitui is installed as executable file" {
    run check_binary "gitui"
    assert_success
}

@test "gitui is functional" {
    skip_if_not_installed gitui
    run "$HOME/.local/bin/gitui" --version
    assert_success
}
