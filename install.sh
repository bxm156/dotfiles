#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GUM_VERSION="0.17.0"
CHEZMOI_GITHUB_USER="bxm156"

# Note: The chezmoi installer command is duplicated in 3 places because:
# - Functions don't work with `gum spin` (runs in subshell)
# - Functions don't work with `exec` (replaces current process)
# - Variable expansion breaks shell quoting for command substitution
# IMPORTANT: Always set BINDIR to absolute path - installer defaults to relative ".local/bin"

# Parse arguments
SAFE_MODE=false
BOOTSTRAP_PATH=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --safe)
            SAFE_MODE=true
            shift
            ;;
        --bootstrap)
            if [[ -n "${2:-}" ]]; then
                BOOTSTRAP_PATH="$2"
                shift 2
            else
                echo -e "${RED}Error: --bootstrap requires a path argument${NC}" >&2
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}" >&2
            echo "Usage: $0 [--safe] [--bootstrap <path>]"
            exit 1
            ;;
    esac
done

# Safe mode: run standard chezmoi installation
if [[ "$SAFE_MODE" == true ]]; then
    echo -e "${BLUE}Running in safe mode (standard chezmoi installation)...${NC}"
    exec env BINDIR="$HOME/.local/bin" sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply "$CHEZMOI_GITHUB_USER"
fi

# Detect platform (matches .chezmoiexternal.toml.tmpl naming)
detect_platform() {
    local os=""
    local arch=""

    # Detect OS (title-cased: Linux, Darwin)
    case "$(uname -s)" in
        Linux*)
            os="Linux"
            ;;
        Darwin*)
            os="Darwin"
            ;;
        *)
            echo -e "${RED}Unsupported operating system: $(uname -s)${NC}" >&2
            return 1
            ;;
    esac

    # Detect architecture (gum uses x86_64 not amd64)
    case "$(uname -m)" in
        x86_64|amd64)
            arch="x86_64"
            ;;
        aarch64|arm64)
            arch="arm64"
            ;;
        *)
            echo -e "${RED}Unsupported architecture: $(uname -m)${NC}" >&2
            return 1
            ;;
    esac

    echo "${os}_${arch}"
}

# Bash spinner animation
spinner() {
    local pid=$1
    local message="${2:-Working...}"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r${BLUE}${spin:$i:1}${NC} %s" "$message" >&2
        sleep 0.1
    done

    # Wait for process to complete and get exit code
    wait "$pid"
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        printf "\r${GREEN}✓${NC} %s\n" "$message" >&2
    else
        printf "\r${RED}✗${NC} %s\n" "$message" >&2
    fi

    return $exit_code
}

# Download and extract gum
download_gum() {
    local platform="$1"
    local gum_dir="$2"
    local gum_path="${gum_dir}/gum"

    # Create gum directory
    mkdir -p "$gum_dir"

    # Build download URL
    local gum_url="https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_${platform}.tar.gz"

    echo -e "${BLUE}Downloading gum v${GUM_VERSION} for enhanced install experience...${NC}" >&2

    # Build the path to the binary inside the archive
    local archive_name="gum_${GUM_VERSION}_${platform}"
    local binary_path="${archive_name}/gum"

    # Download and extract in background
    (
        curl -fsSL "$gum_url" | tar -xz -C "$gum_dir" 2>/dev/null
        if [[ -f "${gum_dir}/${binary_path}" ]]; then
            mv "${gum_dir}/${binary_path}" "${gum_dir}/gum"
            rm -rf "${gum_dir}/${archive_name}"
        fi
        sync  # Ensure all file operations are flushed to disk
    ) &

    local download_pid=$!
    spinner "$download_pid" "Downloading gum..." >&2
    local spinner_exit=$?

    # Check spinner exit code first
    if [[ $spinner_exit -ne 0 ]]; then
        echo -e "${RED}Failed to download gum${NC}" >&2
        return 1
    fi

    # Give filesystem a moment to catch up
    sleep 0.1

    if [[ ! -f "$gum_path" ]]; then
        echo -e "${RED}Failed to download gum (file not found)${NC}" >&2
        return 1
    fi

    chmod +x "$gum_path"
    echo "$gum_path"
}

# Install chezmoi with gum UI
install_with_gum() {
    local gum_bin="$1"

    echo ""
    "$gum_bin" style \
        --foreground 212 \
        --border-foreground 212 \
        --border double \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "1 2" \
        "Installing Dotfiles" \
        "with enhanced UI"

    # Download and install chezmoi
    if ! "$gum_bin" spin \
        --spinner dot \
        --title "Downloading and installing chezmoi..." \
        --show-error \
        -- env BINDIR="$HOME/.local/bin" sh -c "$(curl -fsLS get.chezmoi.io/lb)"; then
        echo -e "${RED}Failed to install chezmoi${NC}" >&2
        return 1
    fi

    # chezmoi is installed to ~/.local/bin/chezmoi - use full path
    local chezmoi_bin="$HOME/.local/bin/chezmoi"

    # Verify chezmoi was installed successfully
    if [[ ! -f "$chezmoi_bin" ]]; then
        echo -e "${RED}Chezmoi binary not found at $chezmoi_bin${NC}" >&2
        return 1
    fi

    # Initialize and apply dotfiles
    if ! "$gum_bin" spin \
        --spinner line \
        --title "Initializing dotfiles from GitHub..." \
        -- "$chezmoi_bin" init "$CHEZMOI_GITHUB_USER"; then
        echo -e "${RED}Failed to initialize dotfiles${NC}" >&2
        return 1
    fi

    # Check for conflicts with dry-run
    if ! "$gum_bin" spin \
        --spinner meter \
        --title "Checking for conflicts..." \
        -- "$chezmoi_bin" apply --dry-run --verbose > /dev/null 2>&1; then
        echo -e "${RED}Failed to check for conflicts${NC}" >&2
        return 1
    fi

    local apply_flags=""

    # Check if there are existing files that would be modified
    local dry_run_output
    dry_run_output=$("$chezmoi_bin" apply --dry-run 2>&1 || true)

    if echo "$dry_run_output" | grep -q "would\|exist\|conflict" 2>/dev/null; then
        echo ""
        local apply_mode
        apply_mode=$("$gum_bin" choose \
            --header "Existing config files detected. How should they be handled?" \
            --cursor.foreground 212 \
            "Skip (keep existing files)" \
            "Overwrite (replace with dotfiles)")

        if [[ "$apply_mode" == "Overwrite (replace with dotfiles)" ]]; then
            apply_flags="--force"
        fi
    fi

    if ! "$gum_bin" spin \
        --spinner meter \
        --title "Applying dotfiles configuration..." \
        -- "$chezmoi_bin" apply $apply_flags; then
        echo -e "${RED}Failed to apply dotfiles${NC}" >&2
        return 1
    fi

    echo ""
    "$gum_bin" style \
        --foreground 212 \
        --bold \
        "✓ Dotfiles installed successfully!"

    echo ""
    "$gum_bin" style \
        --foreground 240 \
        "Your dotfiles are ready to use."
}

# Fallback to safe mode
fallback_to_safe_mode() {
    local reason="$1"
    echo ""
    echo -e "${YELLOW}⚠ ${reason}${NC}"
    echo -e "${YELLOW}Falling back to safe mode...${NC}"
    echo ""
    exec env BINDIR="$HOME/.local/bin" sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply "$CHEZMOI_GITHUB_USER"
}

# Main installation flow
main() {
    echo -e "${GREEN}=== Dotfiles Installation ===${NC}"
    echo ""

    # Detect platform
    local platform
    if ! platform=$(detect_platform); then
        fallback_to_safe_mode "Platform detection failed"
    fi

    # Determine gum installation path
    local gum_dir
    local cleanup_gum=false

    if [[ -n "$BOOTSTRAP_PATH" ]]; then
        gum_dir="$BOOTSTRAP_PATH"
        echo -e "${BLUE}Using custom bootstrap path: ${gum_dir}${NC}"
    else
        gum_dir="${TMPDIR:-/tmp}/gum-bootstrap-$$"
        cleanup_gum=true
    fi

    # Download gum
    local gum_bin
    if ! gum_bin=$(download_gum "$platform" "$gum_dir"); then
        fallback_to_safe_mode "Failed to download gum"
    fi

    # Install with gum UI
    if ! install_with_gum "$gum_bin"; then
        if [[ "$cleanup_gum" == true ]]; then
            rm -rf "$gum_dir"
        fi
        fallback_to_safe_mode "Installation failed"
    fi

    # Cleanup temporary gum
    if [[ "$cleanup_gum" == true ]]; then
        rm -rf "$gum_dir"
    fi

    echo ""
    echo -e "${GREEN}All done! 🎉${NC}"
}

# Run main
main
