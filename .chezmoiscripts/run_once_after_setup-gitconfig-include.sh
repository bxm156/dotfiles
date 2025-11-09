#!/usr/bin/env bash
set -euo pipefail

# Automatically add [include] directive to ~/.gitconfig for chezmoi-managed config
# This runs once after chezmoi applies files

# Source logging helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/.logging.sh"

log_script "setup-gitconfig-include.sh"

gitconfig="$HOME/.gitconfig"
include_path="$HOME/.gitconfig.d/default"

# Create .gitconfig if it doesn't exist
if [[ ! -f "$gitconfig" ]]; then
    log_info "Creating new ~/.gitconfig"
    touch "$gitconfig"
fi

# Check if include directive already exists
if grep -q "path = $include_path" "$gitconfig" 2>/dev/null || \
   grep -q "path = ~/.gitconfig.d/default" "$gitconfig" 2>/dev/null; then
    log_success "[include] directive already present in ~/.gitconfig"
    exit 0
fi

log_progress "Adding chezmoi-managed gitconfig include to ~/.gitconfig"

# Add include at the bottom (so managed settings take priority)
cat >> "$gitconfig" <<EOF

# Include chezmoi-managed git configuration
[include]
	path = ~/.gitconfig.d/default
EOF

log_success "Added [include] directive to ~/.gitconfig"
log_info "Git will now use settings from ~/.gitconfig.d/default"
