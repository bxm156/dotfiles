#!/usr/bin/env bats

# Git configuration tests

setup() {
    # Load bats helpers
    load '../libs/bats-support/load'
    load '../libs/bats-assert/load'
}

# Helper function
skip_if_file_missing() {
    if [ ! -f "$1" ]; then
        skip "File $1 does not exist"
    fi
}

@test "git config includes dotfiles config" {
    skip_if_file_missing "$HOME/.gitconfig"
    run grep -q "\.gitconfig\.d/default" "$HOME/.gitconfig"
    assert_success
}

@test ".gitconfig.d/default exists" {
    [ -f "$HOME/.gitconfig.d/default" ]
}

@test ".gitconfig.d directory is properly structured" {
    [ -d "$HOME/.gitconfig.d" ]
    [ -f "$HOME/.gitconfig.d/default" ]
}
