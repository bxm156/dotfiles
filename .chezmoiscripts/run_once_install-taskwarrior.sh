#!/usr/bin/env bash
set -euo pipefail

# Install taskwarrior via package manager
# Note: Building from source requires cmake, Rust 1.81+, and build tools
# For simplicity, we use the package manager version

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/.logging.sh"

log_script "install-taskwarrior.sh"

TASK_BIN="$HOME/.local/bin/task"

# Check if already installed
if [[ -x "$TASK_BIN" ]]; then
    version=$("$TASK_BIN" --version 2>/dev/null | head -n1 || echo "unknown")
    log_success "Taskwarrior already installed: $version"
    exit 0
fi

# Check if task is available in system PATH (installed via package manager)
if command -v task &>/dev/null; then
    # Create symlink to ~/.local/bin for consistency
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v task)" "$TASK_BIN"
    version=$("$TASK_BIN" --version 2>/dev/null | head -n1 || echo "unknown")
    log_success "Taskwarrior found in system, linked to ~/.local/bin: $version"
    exit 0
fi

log_progress "Installing taskwarrior via package manager..."

# Detect if we need sudo
SUDO=""
if [[ $EUID -ne 0 ]] && command -v sudo &>/dev/null; then
    SUDO="sudo"
fi

# Try package managers in order of preference
if command -v apt-get &>/dev/null; then
    log_info "Using apt to install taskwarrior..."
    if $SUDO apt-get update -qq && $SUDO apt-get install -y taskwarrior; then
        # Create symlink to ~/.local/bin
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v task)" "$TASK_BIN"
        log_success "Taskwarrior installed via apt"
        exit 0
    fi
elif command -v brew &>/dev/null; then
    log_info "Using brew to install taskwarrior..."
    if brew install task; then
        # Create symlink to ~/.local/bin
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v task)" "$TASK_BIN"
        log_success "Taskwarrior installed via brew"
        exit 0
    fi
elif command -v dnf &>/dev/null; then
    log_info "Using dnf to install taskwarrior..."
    if $SUDO dnf install -y task; then
        # Create symlink to ~/.local/bin
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v task)" "$TASK_BIN"
        log_success "Taskwarrior installed via dnf"
        exit 0
    fi
elif command -v pacman &>/dev/null; then
    log_info "Using pacman to install taskwarrior..."
    if $SUDO pacman -S --noconfirm task; then
        # Create symlink to ~/.local/bin
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v task)" "$TASK_BIN"
        log_success "Taskwarrior installed via pacman"
        exit 0
    fi
fi

log_warning "Could not install taskwarrior via package manager"
log_info "To install manually:"
log_info "  - Debian/Ubuntu: sudo apt-get install taskwarrior"
log_info "  - macOS: brew install task"
log_info "  - From source: https://taskwarrior.org/download/"
exit 0  # Exit 0 since taskwarrior is optional
