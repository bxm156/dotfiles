#!/usr/bin/env bats

# Binary installation and verification tests
# These tests check that binaries are installed correctly and are executable

setup() {
    # Load bats helpers
    load 'libs/bats-support/load'
    load 'libs/bats-assert/load'

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

@test "jq is installed as executable file" {
    run check_binary "jq"
    assert_success
}

@test "jq is functional" {
    skip_if_not_installed jq
    run "$HOME/.local/bin/jq" --version
    assert_success
}

@test "fzf is installed as executable file" {
    run check_binary "fzf"
    assert_success
}

@test "fzf is functional" {
    skip_if_not_installed fzf
    run "$HOME/.local/bin/fzf" --version
    assert_success
}

@test "zoxide is installed as executable file" {
    run check_binary "zoxide"
    assert_success
}

@test "zoxide is functional" {
    skip_if_not_installed zoxide
    run "$HOME/.local/bin/zoxide" --version
    assert_success
}

@test "bat is installed as executable file" {
    run check_binary "bat"
    assert_success
}

@test "bat is functional" {
    skip_if_not_installed bat
    run "$HOME/.local/bin/bat" --version
    assert_success
}

@test "gitui is installed as executable file" {
    run check_binary "gitui"
    assert_success
}

@test "gitui is functional" {
    skip_if_not_installed gitui
    run "$HOME/.local/bin/gitui" --version
    assert_success
}

@test "gum is installed as executable file" {
    run check_binary "gum"
    assert_success
}

@test "gum is functional" {
    skip_if_not_installed gum
    run "$HOME/.local/bin/gum" --version
    assert_success
}

@test "starship is installed as executable file" {
    run check_binary "starship"
    assert_success
}

@test "starship is functional" {
    skip_if_not_installed starship
    run "$HOME/.local/bin/starship" --version
    assert_success
}

@test "glow is installed as executable file" {
    run check_binary "glow"
    assert_success
}

@test "glow is functional" {
    skip_if_not_installed glow
    run "$HOME/.local/bin/glow" --version
    assert_success
}

@test "mods is installed as executable file" {
    run check_binary "mods"
    assert_success
}

@test "mods is functional" {
    skip_if_not_installed mods
    run "$HOME/.local/bin/mods" --version
    assert_success
}

@test "figlet is installed as executable file" {
    run check_binary "figlet"
    assert_success
}

@test "figlet is functional" {
    skip_if_not_installed figlet
    run "$HOME/.local/bin/figlet" --version
    assert_success
}

# Helper to skip test if binary is not installed
skip_if_not_installed() {
    local binary="$1"
    if [ ! -x "$HOME/.local/bin/$binary" ]; then
        skip "$binary not installed"
    fi
}
