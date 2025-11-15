#!/usr/bin/env bats

# External binaries configuration tests

setup() {
    # Load bats helpers
    load '../test_helper'

    # Get repository root
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    cd "$REPO_ROOT"
}

@test ".chezmoiexternal.toml.tmpl configures jq binary" {
    run chezmoi execute-template < .chezmoiexternal.toml.tmpl
    assert_success
    assert_output --partial ".local/bin/jq"
}

@test ".chezmoiexternal.toml.tmpl configures fzf binary" {
    run chezmoi execute-template < .chezmoiexternal.toml.tmpl
    assert_success
    assert_output --partial ".local/bin/fzf"
}

@test ".chezmoiexternal.toml.tmpl configures zoxide binary" {
    run chezmoi execute-template < .chezmoiexternal.toml.tmpl
    assert_success
    assert_output --partial ".local/bin/zoxide"
}

@test ".chezmoiexternal.toml.tmpl configures bat binary" {
    run chezmoi execute-template < .chezmoiexternal.toml.tmpl
    assert_success
    assert_output --partial ".local/bin/bat"
}

@test ".chezmoiexternal.toml.tmpl configures gum binary" {
    run chezmoi execute-template < .chezmoiexternal.toml.tmpl
    assert_success
    assert_output --partial ".local/bin/gum"
}

@test ".chezmoiexternal.toml.tmpl configures gitui binary" {
    run chezmoi execute-template < .chezmoiexternal.toml.tmpl
    assert_success
    assert_output --partial ".local/bin/gitui"
}

@test ".chezmoiexternal.toml.tmpl configures glow binary" {
    run chezmoi execute-template < .chezmoiexternal.toml.tmpl
    assert_success
    assert_output --partial ".local/bin/glow"
}

@test ".chezmoiexternal.toml.tmpl configures mods binary" {
    run chezmoi execute-template < .chezmoiexternal.toml.tmpl
    assert_success
    assert_output --partial ".local/bin/mods"
}

@test ".chezmoiexternal.toml.tmpl configures freeze binary" {
    run chezmoi execute-template < .chezmoiexternal.toml.tmpl
    assert_success
    assert_output --partial ".local/bin/freeze"
}

# Note: starship is installed via run_once scripts, not external configuration
