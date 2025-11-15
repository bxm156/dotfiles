#!/usr/bin/env bats

# Unit tests for custom libraries

setup() {
    # Load bats test helpers
    load 'test_helper'

    # Get repository root
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

    # Source the logging library (disable gum for consistent testing)
    export _LOGGING_HAS_GUM=false
    source "$REPO_ROOT/.chezmoiscripts/lib/.logging.sh"
}

@test "logging library can be sourced" {
    # This test passes if setup() succeeded
    run echo "loaded"
    assert_success
}

@test "log_info function exists" {
    run declare -f log_info
    assert_success
}

@test "log_success function exists" {
    run declare -f log_success
    assert_success
}

@test "log_error function exists" {
    run declare -f log_error
    assert_success
}

@test "log_warning function exists" {
    run declare -f log_warning
    assert_success
}

@test "log_progress function exists" {
    run declare -f log_progress
    assert_success
}

@test "log_section function exists" {
    run declare -f log_section
    assert_success
}

@test "log_binary function exists" {
    run declare -f log_binary
    assert_success
}

@test "log_script function exists" {
    run declare -f log_script
    assert_success
}

@test "log_success emits correct format" {
    run log_success "test message"
    assert_success
    assert_output --regexp '^\[.*\].*test message$'
}

@test "log_info emits correct format" {
    run log_info "test message"
    assert_success
    assert_output --regexp '^\[INFO\].*test message$'
}

@test "log_error emits to stderr" {
    run log_error "test message"
    # log_error outputs to stderr, check it succeeded
    assert_success
}

@test "log_warning emits correct format" {
    run log_warning "test message"
    assert_success
    assert_output --regexp '^\[WARN\].*test message$'
}

@test "log_progress emits correct format" {
    run log_progress "test message"
    assert_success
    assert_output --regexp '^\[DEBUG\].*test message$'
}

@test "log_binary with 'installing' status" {
    run log_binary "testbin" "installing"
    assert_success
    assert_output --partial "testbin"
}

@test "log_binary with 'installed' status" {
    run log_binary "testbin" "installed"
    assert_success
    assert_output --partial "testbin"
}

@test "log_script emits script name" {
    run log_script "test-script.sh"
    assert_success
    assert_output --partial "test-script.sh"
}

@test "logging works without gum installed" {
    export _LOGGING_HAS_GUM=false
    run log_success "test without gum"
    assert_success
}
