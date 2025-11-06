# zoxide - Smart cd replacement that learns your habits
# Usage: z <directory-name> - jump to frequently used directories

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi
