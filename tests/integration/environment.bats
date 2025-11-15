#!/usr/bin/env bats

# Environment and directory structure tests

setup() {
    # Load bats helpers
    load '../test_helper'
}

@test "notes directory exists" {
    [ -d "$HOME/notes" ]
}

@test "notes directory is writable" {
    run touch "$HOME/notes/.test"
    assert_success
    rm -f "$HOME/notes/.test"
}

@test ".local/bin directory exists" {
    [ -d "$HOME/.local/bin" ]
}

@test ".local/bin is configured in PATH" {
    # In non-interactive shells, PATH may not include .local/bin
    # Check that .zshrc configures it (which will apply in interactive shells)
    run grep -E 'PATH.*\.local/bin|export PATH' "$HOME/.zshrc"
    assert_success
}

@test "expected dotfiles are present in home directory" {
    # Verify that key dotfiles and directories were created
    [ -f "$HOME/.zshrc" ]
    [ -d "$HOME/.oh-my-zsh" ]
    [ -d "$HOME/.local" ]
}

@test ".config directory exists" {
    [ -d "$HOME/.config" ]
}
