#!/usr/bin/env bash
set -euo pipefail

# Source logging helpers (from repo root in devcontainer, from installed location in test container)
if [[ -f ~/.local/share/chezmoi/.chezmoiscripts/lib/.logging.sh ]]; then
    source ~/.local/share/chezmoi/.chezmoiscripts/lib/.logging.sh
elif [[ -f .chezmoiscripts/lib/.logging.sh ]]; then
    source .chezmoiscripts/lib/.logging.sh
fi

log_section "Installing Chezmoi"

mkdir -p ~/.local/bin

# Add -v for verbose output for debugging
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply --source ~/.local/share/chezmoi
log_success "Dotfiles applied successfully"

log_section "Testing Zsh and Oh-My-Zsh"

zsh -c "echo ✓ Zsh version: \$ZSH_VERSION"

# Test oh-my-zsh installation
if [[ -d ~/.oh-my-zsh ]]; then
  log_success "Oh-My-Zsh directory exists"
else
  log_error "Oh-My-Zsh directory missing"
  exit 1
fi

# Test oh-my-zsh is loaded in interactive shell
if zsh -i -c '[[ -n "$ZSH" ]]' 2>/dev/null; then
    log_success "Oh-My-Zsh loaded in interactive shell"
else
    log_error "Oh-My-Zsh not loaded"
    exit 1
fi

# Test oh-my-zsh plugins are installed
if [[ -d ~/.oh-my-zsh/custom/plugins/zsh-vi-mode ]]; then
  log_success "zsh-vi-mode plugin installed"
else
  log_error "zsh-vi-mode plugin missing"
fi

if [[ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
  log_success "zsh-autosuggestions plugin installed"
else
  log_error "zsh-autosuggestions plugin missing"
fi

if [[ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]]; then
  log_success "zsh-syntax-highlighting plugin installed"
else
  log_error "zsh-syntax-highlighting plugin missing"
fi

log_section "Binary Installation Verification"

# Note: This section is now handled by run_after_verify-external-binaries.sh
# but we keep it here for test completeness

test_failed=0
for binary in jq fzf zoxide bat gitui gum starship glow mods freeze vhs asciinema; do
  binary_path="$HOME/.local/bin/$binary"

  if [[ ! -e "$binary_path" ]]; then
    log_error "$binary: not found at $binary_path"
    test_failed=1
    continue
  fi

  if [[ -d "$binary_path" ]]; then
    log_error "$binary: is a directory (should be a file)"
    test_failed=1
    continue
  fi

  if [[ ! -f "$binary_path" ]]; then
    log_error "$binary: exists but is not a regular file"
    test_failed=1
    continue
  fi

  if [[ ! -x "$binary_path" ]]; then
    log_error "$binary: is not executable"
    test_failed=1
    continue
  fi

  log_success "$binary: correctly installed as executable file"
done

if [[ $test_failed -eq 1 ]]; then
  log_error "Binary validation failed"
  exit 1
fi

log_section "Productivity Tools Verification"

# Test glow
if [[ -x "$HOME/.local/bin/glow" ]]; then
    if "$HOME/.local/bin/glow" --version &>/dev/null; then
        log_success "glow: installed and working"
    else
        log_error "glow: installed but not working"
        test_failed=1
    fi
else
    log_error "glow: not installed"
    test_failed=1
fi

# Test mods
if [[ -x "$HOME/.local/bin/mods" ]]; then
    if "$HOME/.local/bin/mods" --version &>/dev/null; then
        log_success "mods: installed and working"
    else
        log_error "mods: installed but not working"
        test_failed=1
    fi
else
    log_error "mods: not installed"
    test_failed=1
fi

# Test freeze
if [[ -x "$HOME/.local/bin/freeze" ]]; then
    if "$HOME/.local/bin/freeze" --version &>/dev/null; then
        log_success "freeze: installed and working"
    else
        log_error "freeze: installed but not working"
        test_failed=1
    fi
else
    log_error "freeze: not installed"
    test_failed=1
fi

# Test vhs
if [[ -x "$HOME/.local/bin/vhs" ]]; then
    if "$HOME/.local/bin/vhs" --version &>/dev/null; then
        log_success "vhs: installed and working"
    else
        log_error "vhs: installed but not working"
        test_failed=1
    fi
else
    log_error "vhs: not installed"
    test_failed=1
fi

# Test asciinema
if [[ -x "$HOME/.local/bin/asciinema" ]]; then
    if "$HOME/.local/bin/asciinema" --version &>/dev/null; then
        log_success "asciinema: installed and working"
    else
        log_error "asciinema: installed but not working"
        test_failed=1
    fi
else
    log_error "asciinema: not installed"
    test_failed=1
fi

# Test taskwarrior
if [[ -x "$HOME/.local/bin/task" ]]; then
    if "$HOME/.local/bin/task" --version &>/dev/null; then
        log_success "taskwarrior: installed and working"
    else
        log_error "taskwarrior: installed but not working"
        test_failed=1
    fi
else
    log_warning "taskwarrior: not installed (optional, requires compilation)"
fi

# Test taskwarrior-tui (only on x86_64)
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    if [[ -x "$HOME/.local/bin/taskwarrior-tui" ]]; then
        if "$HOME/.local/bin/taskwarrior-tui" --version &>/dev/null; then
            log_success "taskwarrior-tui: installed and working"
        else
            log_error "taskwarrior-tui: installed but not working"
            test_failed=1
        fi
    else
        log_error "taskwarrior-tui: not installed"
        test_failed=1
    fi
else
    log_info "taskwarrior-tui: skipped (ARM64 not supported)"
fi

# Test notes directory
if [[ -d "$HOME/notes" ]]; then
    log_success "Notes directory created"
else
    log_error "Notes directory missing"
    test_failed=1
fi

if [[ $test_failed -eq 1 ]]; then
  log_error "Productivity tools validation failed"
  exit 1
fi

log_success "All tests passed!"

echo ""
log_section "Home Directory Contents (checking for pollution)"
ls -la ~

# If running interactively (TTY attached), launch zsh shell
if [[ -t 0 ]]; then
  echo ""
  echo "Launching zsh shell..."
  exec zsh
fi
