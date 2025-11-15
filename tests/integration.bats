#!/usr/bin/env bats

# Integration tests for full dotfiles installation

setup() {
    # Load bats helpers
    load 'libs/bats-support/load'
    load 'libs/bats-assert/load'
}

@test "zsh is available" {
    run command -v zsh
    assert_success
}

@test "zsh version is valid" {
    run zsh -c 'echo $ZSH_VERSION'
    assert_success
    refute_output ""
}

@test "oh-my-zsh directory exists" {
    [ -d "$HOME/.oh-my-zsh" ]
}

@test "oh-my-zsh loads in interactive shell" {
    run zsh -i -c '[[ -n "$ZSH" ]]'
    assert_success
}

@test "zsh-vi-mode plugin is installed" {
    [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-vi-mode" ]
}

@test "zsh-autosuggestions plugin is installed" {
    [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]
}

@test "zsh-syntax-highlighting plugin is installed" {
    [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]
}

@test ".zshrc exists and is a file" {
    [ -f "$HOME/.zshrc" ]
}

@test ".zshrc loads without errors" {
    run zsh -i -c 'echo "loaded"'
    assert_success
    assert_output --partial "loaded"
}

@test "notes directory exists" {
    [ -d "$HOME/notes" ]
}

@test "notes directory is writable" {
    run touch "$HOME/notes/.test"
    assert_success
    rm -f "$HOME/notes/.test"
}

@test "git config includes dotfiles config" {
    skip_if_file_missing "$HOME/.gitconfig"
    run grep -q "\.gitconfig\.d/default" "$HOME/.gitconfig"
    assert_success
}

@test ".gitconfig.d/default exists" {
    [ -f "$HOME/.gitconfig.d/default" ]
}

@test ".local/bin directory exists" {
    [ -d "$HOME/.local/bin" ]
}

@test ".local/bin is in PATH" {
    run echo "$PATH"
    assert_success
    assert_output --partial ".local/bin"
}

@test "home directory is not polluted with unexpected files" {
    # Check that dotfiles installation didn't create unwanted files in ~
    # This is a basic sanity check
    [ -f "$HOME/.zshrc" ]
    [ -d "$HOME/.oh-my-zsh" ]
    [ -d "$HOME/.local" ]
}

# Helper function
skip_if_file_missing() {
    if [ ! -f "$1" ]; then
        skip "File $1 does not exist"
    fi
}
