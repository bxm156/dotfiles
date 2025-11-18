# rcode - Open VS Code to remote folder via SSH
#
# Usage:
#   rcode                              Select host and browse from home directory
#   rcode <host>                       Browse directories on host from home
#   rcode <host> <path>                Open specific path directly (no browser)
#   rcode <host> --path=<dir>          Browse directories starting at <dir>
#
# Options:
#   --path=<dir>  Start interactive browser at this directory instead of home
#
# Environment:
#   RCODE_SHOW_HIDDEN=1  Show hidden directories in browser (default: hidden)
#
# Examples:
#   rcode                              # Select from SSH hosts, then browse
#   rcode engineering-bay              # Browse engineering-bay from ~
#   rcode engineering-bay projects/app # Open ~/projects/app directly
#   rcode engineering-bay --path=projects  # Browse starting at ~/projects
#
# Requirements:
#   - gum (for interactive selection)
#   - VS Code with Remote-SSH extension

rcode() {
    local host=""
    local target_path=""
    local start_path=""
    local remote_user remote_home
    local show_hidden="${RCODE_SHOW_HIDDEN:-0}"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --path=*)
                start_path="${1#--path=}"
                shift
                ;;
            *)
                if [[ -z "$host" ]]; then
                    host="$1"
                else
                    target_path="$1"
                fi
                shift
                ;;
        esac
    done

    # If no host argument, let user select from SSH config
    if [[ -z "$host" ]]; then
        if (( ! $+commands[gum] )); then
            echo "Usage: rcode <host> [path]" >&2
            echo "Example: rcode engineering-bay projects/dotfiles" >&2
            echo "Install gum for interactive selection" >&2
            return 1
        fi

        # Parse SSH hosts from config (excluding wildcards and Match blocks)
        local hosts
        hosts=$(grep -h "^Host " ~/.ssh/config 2>/dev/null | \
                awk '{for(i=2;i<=NF;i++) print $i}' | \
                grep -v '[*?]' | \
                sort -u)

        if [[ -z "$hosts" ]]; then
            echo "No SSH hosts found in ~/.ssh/config" >&2
            return 1
        fi

        host=$(echo "$hosts" | gum choose --header "🖥️  Select SSH host" --cursor "▶ ")

        if [[ -z "$host" ]]; then
            return 1
        fi
    fi

    # Get remote user and home directory for this host
    remote_user=$(ssh -G "$host" | awk '/^user / {print $2}')
    remote_home=$(ssh "$host" 'echo $HOME' 2>/dev/null)

    if [[ -z "$remote_home" ]]; then
        echo "Failed to connect to $host" >&2
        return 1
    fi

    # If no path argument, let user browse directories interactively
    if [[ -z "$target_path" ]]; then
        if (( ! $+commands[gum] )); then
            echo "Usage: rcode $host <path>" >&2
            echo "Example: rcode $host projects/dotfiles" >&2
            echo "Install gum for interactive selection" >&2
            return 1
        fi

        # Declare locals outside loop to avoid zsh typeset output on re-declaration
        local current_path="$start_path"
        local selection dirs opts has_subdirs display_path

        while true; do
            # Build the full path for display
            if [[ -z "$current_path" ]]; then
                display_path="~"
            else
                display_path="~/$current_path"
            fi

            # Fetch directories at current depth from remote server (-L follows symlinks)
            local hidden_filter=""
            if [[ "$show_hidden" != "1" ]]; then
                hidden_filter="| grep -v '/\\.'"
            fi

            if [[ -z "$current_path" ]]; then
                dirs=$(ssh "$host" "find -L ~ -maxdepth 1 -mindepth 1 -type d 2>/dev/null $hidden_filter | sed \"s|$remote_home/||\" | sed \"s|$remote_home||\" | grep -v '^\$' | sort")
            else
                dirs=$(ssh "$host" "find -L ~/$current_path -maxdepth 1 -mindepth 1 -type d 2>/dev/null $hidden_filter | sed \"s|$remote_home/||\" | sort")
            fi

            if [[ -z "$dirs" ]]; then
                # No subdirectories - open current path
                if [[ -n "$current_path" ]]; then
                    target_path="$current_path"
                else
                    target_path=""
                fi
                break
            fi

            # Build options: show [OPEN] option at top
            if [[ -n "$current_path" ]]; then
                opts="→ Open $display_path"$'\n'"$dirs"
            else
                opts="→ Open ~"$'\n'"$dirs"
            fi

            # Let user select - use gum choose for clearer navigation
            selection=$(echo "$opts" | gum choose --header "📂 $host:$display_path" --cursor "▶ ")

            if [[ -z "$selection" ]]; then
                return 1
            fi

            # Check if user wants to open current directory
            if [[ "$selection" == "→ Open "* ]]; then
                target_path="$current_path"
                break
            fi

            # Check if selection has subdirectories
            has_subdirs=$(ssh "$host" "find -L ~/$selection -maxdepth 1 -mindepth 1 -type d 2>/dev/null | head -1")

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

    # Build the folder URI
    if [[ -z "$target_path" ]]; then
        code --folder-uri "vscode-remote://ssh-remote+$host$remote_home"
    else
        code --folder-uri "vscode-remote://ssh-remote+$host$remote_home/$target_path"
    fi
}
