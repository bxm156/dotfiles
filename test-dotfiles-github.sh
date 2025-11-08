#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing Chezmoi and Applying from GitHub ==="
mkdir -p ~/.local/bin

# Install chezmoi and init from GitHub repository
# This simulates the real-world installation flow
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply bxm156
echo "✓ Dotfiles applied successfully from GitHub"

echo ""
echo "=== Testing Zsh and Oh-My-Zsh ==="
zsh -c "echo ✓ Zsh version: \$ZSH_VERSION"

# Test oh-my-zsh installation
if [[ -d ~/.oh-my-zsh ]]; then
  echo "✓ Oh-My-Zsh directory exists"
else
  echo "✗ Oh-My-Zsh directory missing"
  exit 1
fi

# Test oh-my-zsh is loaded in interactive shell
zsh -i -c 'if [[ -n "$ZSH" ]]; then echo "✓ Oh-My-Zsh loaded (\$ZSH=$ZSH)"; else echo "✗ Oh-My-Zsh not loaded"; exit 1; fi'

# Test oh-my-zsh plugins are installed
if [[ -d ~/.oh-my-zsh/custom/plugins/zsh-vi-mode ]]; then
  echo "✓ zsh-vi-mode plugin installed"
else
  echo "✗ zsh-vi-mode plugin missing"
fi

if [[ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
  echo "✓ zsh-autosuggestions plugin installed"
else
  echo "✗ zsh-autosuggestions plugin missing"
fi

echo ""
echo "=== Binary Installation Verification ==="
# Verify binaries are files (not directories) and are executable
test_failed=0
for binary in jq fzf zoxide bat gitui starship; do
  binary_path="$HOME/.local/bin/$binary"

  if [[ ! -e "$binary_path" ]]; then
    echo "✗ $binary: not found at $binary_path"
    test_failed=1
    continue
  fi

  if [[ -d "$binary_path" ]]; then
    echo "✗ $binary: is a directory (should be a file)"
    test_failed=1
    continue
  fi

  if [[ ! -f "$binary_path" ]]; then
    echo "✗ $binary: exists but is not a regular file"
    test_failed=1
    continue
  fi

  if [[ ! -x "$binary_path" ]]; then
    echo "✗ $binary: is not executable"
    test_failed=1
    continue
  fi

  echo "✓ $binary: correctly installed as executable file"
done

if [[ $test_failed -eq 1 ]]; then
  echo ""
  echo "✗ Binary validation failed"
  exit 1
fi


if [[ $test_failed -eq 1 ]]; then
  echo ""
  echo "✗ Tool functionality tests failed"
  exit 1
fi

echo ""
echo "✓ All tests passed!"

# If running interactively (TTY attached), launch zsh shell
if [[ -t 0 ]]; then
  echo ""
  echo "Launching zsh shell..."
  exec zsh
fi
