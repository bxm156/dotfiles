#!/usr/bin/env bash
set -euo pipefail

# Read JSON input from stdin
input=$(cat)

# Extract file_path - fast exit if not markdown
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[[ "$file_path" =~ \.(md|mdx)$ ]] || exit 0

# Check if rumdl is available
command -v rumdl &>/dev/null || exit 0

# Extract content from JSON
content=$(echo "$input" | jq -r '.tool_input.content // empty')

# Pipe content through rumdl fmt --stdin with quiet flag
# If rumdl fails, fall back to original content
fixed_content=$(echo "$content" | rumdl fmt --stdin --quiet 2>/dev/null || echo "$content")

# Output JSON with updated content for PreToolUse hook
jq -n \
  --arg content "$fixed_content" \
  '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "updatedInput": {
        "content": $content
      }
    }
  }'
