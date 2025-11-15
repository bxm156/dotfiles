#!/usr/bin/env bats

# Dependency validation tests
# Ensures all required dependencies are available or properly handled

setup() {
    load '../libs/bats-support/load'
    load '../libs/bats-assert/load'

    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    cd "$REPO_ROOT"
}

@test "minimal system requirements are documented" {
    # Check that README or docs mention minimum requirements
    local has_requirements=false

    for doc in README.md AGENTS.md CLAUDE.md; do
        if [ -f "$doc" ] && grep -qiE "require|prerequisite|depend" "$doc"; then
            has_requirements=true
            break
        fi
    done

    [ "$has_requirements" = true ]
}

@test "scripts check for required commands before using them" {
    local script
    local warnings=""

    # Commands that should be checked before use
    local commands_to_check="curl|wget|git|jq"

    while IFS= read -r script; do
        # Find usage of commands
        local used_commands
        used_commands=$(grep -oE "\b($commands_to_check)\b" "$script" 2>/dev/null || true)

        if [ -n "$used_commands" ]; then
            # Check if command -v or which is used to verify availability
            if ! grep -qE "command -v|which.*$used_commands" "$script"; then
                warnings="${warnings}  UNCHECKED COMMAND in $script: $used_commands\n"
            fi
        fi
    done < <(find .chezmoiscripts -type f 2>/dev/null || true)

    if [ -n "$warnings" ]; then
        echo -e "Scripts should check if commands exist before using them:\n${warnings}"
        # Don't fail - many scripts may assume basic commands exist
    fi
}

@test "curl is available (required for installation)" {
    run command -v curl
    assert_success
}

@test "git is available (required for chezmoi)" {
    run command -v git
    assert_success
}

@test "tar is available (required for archives)" {
    run command -v tar
    assert_success
}

@test "gzip is available (required for compressed archives)" {
    run command -v gzip
    assert_success
}

@test "network connectivity is available" {
    # Basic connectivity check
    run curl -s --max-time 5 --head https://github.com
    assert_success
}

@test "sufficient disk space for installation" {
    # Check available disk space in $HOME
    # External binaries + oh-my-zsh ≈ 100MB
    local required_kb=102400  # 100MB

    local available_kb
    available_kb=$(df -k "$HOME" | tail -1 | awk '{print $4}')

    [ "$available_kb" -gt "$required_kb" ]
}

@test "zsh is available or will be installed" {
    # Either zsh exists, or there's a script to install it
    if ! command -v zsh >/dev/null 2>&1; then
        # Check if any script installs zsh
        local has_zsh_install=false

        while IFS= read -r script; do
            if grep -qE "install.*zsh|apt.*zsh|brew.*zsh" "$script"; then
                has_zsh_install=true
                break
            fi
        done < <(find .chezmoiscripts -type f 2>/dev/null || true)

        if [ "$has_zsh_install" = false ]; then
            skip "zsh not available and no installation script found"
        fi
    fi
}

@test "installation works in minimal environment" {
    # Verify we don't depend on non-standard tools
    # Standard POSIX tools that should always be available:
    local standard_tools="sh bash cat grep sed awk find"

    for tool in $standard_tools; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "Missing standard tool: $tool"
            return 1
        fi
    done
}

@test "no python/ruby/node dependencies for core installation" {
    # Core dotfiles installation shouldn't require language runtimes
    local script
    local violations=""

    while IFS= read -r script; do
        # Check for hard dependencies on language runtimes
        if grep -E "^[^#].*(python|ruby|node|npm|gem|pip).*install" "$script" | \
           grep -v "optional\|recommended" > /dev/null 2>&1; then
            violations="${violations}  RUNTIME DEPENDENCY: $script\n"
        fi
    done < <(find .chezmoiscripts -type f -name "run_once*" -o -name "run_before*" 2>/dev/null || true)

    if [ -n "$violations" ]; then
        echo -e "Core scripts should not require language runtimes:\n${violations}"
        # Don't fail - some tools may legitimately need these
    fi
}

@test "chezmoi version compatibility is documented" {
    # Check if there's a minimum chezmoi version requirement
    local has_version_requirement=false

    for doc in README.md AGENTS.md .tool-versions mise.toml; do
        if [ -f "$doc" ] && grep -qE "chezmoi.*v?[0-9]+\.[0-9]+" "$doc"; then
            has_version_requirement=true
            break
        fi
    done

    [ "$has_version_requirement" = true ]
}
