#!/usr/bin/env bats

# Test template syntax validation

setup() {
    # Load bats helpers
    load 'libs/bats-support/load'
    load 'libs/bats-assert/load'

    # Get repository root
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
    cd "$REPO_ROOT"
}

@test "chezmoi is installed" {
    run command -v chezmoi
    assert_success
}

@test ".chezmoi.toml.tmpl renders without errors" {
    run chezmoi execute-template < .chezmoi.toml.tmpl
    assert_success
}

@test ".chezmoiexternal.toml.tmpl renders without errors" {
    run chezmoi execute-template < .chezmoiexternal.toml.tmpl
    assert_success
}

@test ".chezmoiignore file exists" {
    [ -f .chezmoiignore ]
}

@test ".chezmoi.toml.tmpl contains isWork variable" {
    run chezmoi execute-template < .chezmoi.toml.tmpl
    assert_success
    assert_output --partial "isWork ="
}

@test ".chezmoi.toml.tmpl contains isHome variable" {
    run chezmoi execute-template < .chezmoi.toml.tmpl
    assert_success
    assert_output --partial "isHome ="
}

@test ".chezmoi.toml.tmpl contains isDevContainer variable" {
    run chezmoi execute-template < .chezmoi.toml.tmpl
    assert_success
    assert_output --partial "isDevContainer ="
}

@test ".chezmoi.toml.tmpl contains isWSL variable" {
    run chezmoi execute-template < .chezmoi.toml.tmpl
    assert_success
    assert_output --partial "isWSL ="
}

@test ".chezmoi.toml.tmpl contains isWindows variable" {
    run chezmoi execute-template < .chezmoi.toml.tmpl
    assert_success
    assert_output --partial "isWindows ="
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

@test "all .tmpl files in repository render without errors" {
    # Note: This test requires chezmoi to be initialized with data from .chezmoi.toml.tmpl
    # For now, we skip this comprehensive test as the main templates are tested above
    # In CI, comprehensive template rendering is tested in integration tests
    skip "Comprehensive template rendering tested in integration tests"
}
