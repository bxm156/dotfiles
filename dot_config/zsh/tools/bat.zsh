# bat - cat with syntax highlighting and git integration

if command -v bat &>/dev/null; then
    alias cat='bat --style=auto'
    alias bcat='bat --style=plain'  # Plain bat without line numbers

    # Set bat theme (uncomment to customize)
    # export BAT_THEME="Monokai Extended"

    # Use bat as man pager for colored man pages
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi
