#!/usr/bin/env bash
set -euo pipefail

# Automatically add [include] directive to ~/.gitconfig for chezmoi-managed config
# This runs once after chezmoi applies files

gitconfig="$HOME/.gitconfig"
include_path="$HOME/.gitconfig.d/default"

# Create .gitconfig if it doesn't exist
if [[ ! -f "$gitconfig" ]]; then
    echo "Creating new ~/.gitconfig"
    touch "$gitconfig"
fi

# Check if include directive already exists
if grep -q "path = $include_path" "$gitconfig" 2>/dev/null || \
   grep -q "path = ~/.gitconfig.d/default" "$gitconfig" 2>/dev/null; then
    echo "✓ [include] directive already present in ~/.gitconfig"
    exit 0
fi

echo "Adding chezmoi-managed gitconfig include to ~/.gitconfig"

# Add include at the bottom (so managed settings take priority)
cat >> "$gitconfig" <<EOF

# Include chezmoi-managed git configuration
[include]
	path = ~/.gitconfig.d/default
EOF

echo "✓ Added [include] directive to ~/.gitconfig"
echo "  Git will now use settings from ~/.gitconfig.d/default"
