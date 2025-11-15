#!/usr/bin/env bats

# Productivity and content tools tests
# Tests: glow, mods, figlet

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

# glow - Markdown viewer
@test "glow is installed as executable file" {
    run check_binary "glow"
    assert_success
}

@test "glow is functional" {
    skip_if_not_installed glow
    run "$HOME/.local/bin/glow" --version
    assert_success
}

# mods - AI CLI tool
@test "mods is installed as executable file" {
    run check_binary "mods"
    assert_success
}

@test "mods is functional" {
    skip_if_not_installed mods
    run "$HOME/.local/bin/mods" --version
    assert_success
}

# figlet - ASCII art text
@test "figlet is installed as executable file" {
    run check_binary "figlet"
    assert_success
}

@test "figlet is functional" {
    skip_if_not_installed figlet
    run "$HOME/.local/bin/figlet" --version
    assert_success
}
