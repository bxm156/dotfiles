#!/bin/sh

# https://github.com/batistein/dotfiles/blob/master/.chezmoiscripts/run_once_install-starship.sh

if  command -v starship >/dev/null 2>&1; then
    echo "starship already installed"
else
    mkdir -p ~/.local/bin
    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir ~/.local/bin -y
fi
