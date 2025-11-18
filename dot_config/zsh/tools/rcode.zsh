# rcode - Open VS Code to remote folder on engineering-bay
# Usage: rcode [path] - opens path or shows interactive selector with drill-down

rcode() {
    local target_path="$1"

    # If no argument, fetch paths from remote and let user choose
    if [[ -z "$target_path" ]]; then
        if (( ! $+commands[gum] )); then
            echo "Usage: rcode <path>" >&2
            echo "Example: rcode projects/dotfiles" >&2
            echo "Install gum for interactive selection" >&2
            return 1
        fi

        # Declare locals outside loop to avoid zsh typeset output on re-declaration
        local current_path="projects"
        local selection dirs opts has_subdirs

        while true; do
            # Fetch directories at current depth from remote server (-L follows symlinks)
            dirs=$(ssh engineering-bay "find -L ~/$current_path -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sed 's|/home/bryanmarty/||' | sort")

            if [[ -z "$dirs" ]]; then
                echo "No subdirectories found in $current_path" >&2
                # If we're not at root, use current path
                if [[ "$current_path" != "projects" ]]; then
                    target_path="$current_path"
                    break
                fi
                return 1
            fi

            # Build options: show [OPEN] at top if we've drilled down
            if [[ "$current_path" != "projects" ]]; then
                opts="→ Open $current_path"$'\n'"$dirs"
            else
                opts="$dirs"
            fi

            # Let user select - use gum choose for clearer navigation
            selection=$(echo "$opts" | gum choose --header "📂 $current_path" --cursor "▶ ")

            if [[ -z "$selection" ]]; then
                echo "No selection made" >&2
                return 1
            fi

            # Check if user wants to open current directory
            if [[ "$selection" == "→ Open "* ]]; then
                target_path="$current_path"
                break
            fi

            # Check if selection has subdirectories
            has_subdirs=$(ssh engineering-bay "find -L ~/$selection -maxdepth 1 -mindepth 1 -type d 2>/dev/null | head -1")

            if [[ -z "$has_subdirs" ]]; then
                # No subdirs, open this one
                target_path="$selection"
                break
            else
                # Has subdirs, drill down
                current_path="$selection"
            fi
        done
    fi

    code --folder-uri "vscode-remote://ssh-remote+engineering-bay/home/bryanmarty/$target_path"
}
