# fzf - Fuzzy finder for command-line
# Keybindings: Ctrl+R (history), Ctrl+T (files), Alt+C (directories)

if command -v fzf &>/dev/null; then
    # Set up fzf key bindings
    source <(fzf --zsh)

    # Use fd for fzf file finding (if available)
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi

    # fzf preview with bat (if available)
    if command -v bat &>/dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range=:500 {}'"
    fi

    # fzf directory preview with eza (if available)
    if command -v eza &>/dev/null; then
        export FZF_ALT_C_OPTS="--preview 'eza --tree --level=1 --color=always {}'"
    fi
fi
