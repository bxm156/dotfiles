#!/usr/bin/env bats

# Shell configuration tests (zsh, oh-my-zsh, plugins)

setup() {
    # Load bats helpers
    load '../test_helper'
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
