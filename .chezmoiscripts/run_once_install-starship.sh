#!/bin/sh

# https://github.com/batistein/dotfiles/blob/master/.chezmoiscripts/run_once_install-starship.sh

if  command -v starship >/dev/null 2>&1; then
    echo "✓ starship already installed"
else
    echo "Installing starship (this may take a moment)..."
    mkdir -p ~/.local/bin
    # Use curl without -s to show progress bar during download
    curl -L https://starship.rs/install.sh | sh -s -- --bin-dir ~/.local/bin -y >/dev/null
    echo "✓ starship installation complete"
fi
