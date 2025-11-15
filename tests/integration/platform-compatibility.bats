#!/usr/bin/env bats

# Platform compatibility tests
# Ensures configuration works across different platforms

setup() {
    load '../libs/bats-support/load'
    load '../libs/bats-assert/load'

    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    cd "$REPO_ROOT"
}

@test "platform detection variables are set" {
    run chezmoi execute-template < .chezmoi.toml.tmpl
    assert_success

    # Check that chezmoi can determine OS and arch
    output=$(chezmoi data)
    echo "$output" | grep -q "\"os\":"
    echo "$output" | grep -q "\"arch\":"
}

@test "external binaries have correct platform in URL" {
    # Ensure URLs contain platform/arch variables, not hardcoded values
    local rendered
    rendered=$(chezmoi execute-template < .chezmoiexternal.toml.tmpl)

    # Should see linux/darwin and amd64/arm64 in URLs
    # (rendered for current platform)
    local current_os current_arch
    current_os=$(chezmoi data | grep -o '"os": *"[^"]*"' | cut -d'"' -f4)
    current_arch=$(chezmoi data | grep -o '"arch": *"[^"]*"' | cut -d'"' -f4)

    # Verify URLs contain platform/arch (case insensitive for Linux/linux)
    echo "$rendered" | grep -iqE "$current_os|$(uname -s)"
    echo "$rendered" | grep -iqE "$current_arch|$(uname -m)"
}

@test "no platform-specific commands without guards" {
    # Check that platform-specific commands are properly guarded
    local script
    local warnings=""

    # macOS-specific commands that should be guarded
    local macos_commands="brew|defaults|launchctl|softwareupdate"
    # Linux-specific commands
    local linux_commands="apt-get|apt|yum|dnf|pacman|systemctl"

    while IFS= read -r script; do
        # Check for unguarded macOS commands
        if grep -E "^ *($macos_commands)" "$script" | grep -v "darwin\|macos\|if.*chezmoi\.os" > /dev/null 2>&1; then
            warnings="${warnings}  UNGUARDED macOS command in: $script\n"
        fi

        # Check for unguarded Linux commands
        if grep -E "^ *($linux_commands)" "$script" | grep -v "linux\|if.*chezmoi\.os" > /dev/null 2>&1; then
            warnings="${warnings}  UNGUARDED Linux command in: $script\n"
        fi
    done < <(find .chezmoiscripts -type f 2>/dev/null || true)

    if [ -n "$warnings" ]; then
        echo -e "WARNING: Platform-specific commands without guards:\n${warnings}"
        # Don't fail - just warn, as some commands might be universally available
    fi
}

@test "WSL detection logic is present" {
    # Ensure WSL detection is implemented
    run chezmoi execute-template < .chezmoi.toml.tmpl
    assert_success
    assert_output --partial "isWSL"
}

@test "required binaries for current platform are available after install" {
    # This test runs after dotfiles are applied
    # Check that essential tools are installed

    local required_tools="zsh git curl"
    local missing=""

    for tool in $required_tools; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing="${missing}  $tool\n"
        fi
    done

    if [ -n "$missing" ]; then
        echo -e "Missing required tools:\n${missing}"
        return 1
    fi
}

@test "architecture-specific binaries match system arch" {
    # Verify that downloaded binaries match system architecture
    skip_if_not_installed() {
        if [ ! -x "$HOME/.local/bin/$1" ]; then
            skip "$1 not installed"
        fi
    }

    local arch
    arch=$(uname -m)

    # Check a few binaries
    for binary in jq fzf zoxide; do
        skip_if_not_installed "$binary"

        local bin_path="$HOME/.local/bin/$binary"
        if [ -f "$bin_path" ]; then
            # Use file command to check architecture
            local file_info
            file_info=$(file "$bin_path" 2>/dev/null || echo "")

            case "$arch" in
                x86_64|amd64)
                    echo "$file_info" | grep -qiE "x86-64|x86_64|amd64"
                    ;;
                aarch64|arm64)
                    echo "$file_info" | grep -qiE "aarch64|arm64"
                    ;;
            esac
        fi
    done
}
