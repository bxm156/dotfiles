#!/usr/bin/env bash
set -euo pipefail

# KNOWN LIMITATION: Due to Claude Code bug #6246, Unicode characters may be
# corrupted in hook input. This hook exits early for non-markdown files to
# avoid making the corruption worse.
# https://github.com/anthropics/claude-code/issues/6246

# CRITICAL: Extract ONLY file_path first, let jq consume stdin without bash variables
# This prevents Unicode corruption in bash variable handling
file_path=$(jq -r '.tool_input.file_path // empty')

# Exit immediately if not markdown - stdin consumed by jq but never stored in bash variable
# Exit 0 means "continue with original input" (no modifications)
[[ "$file_path" =~ \.(md|mdx)$ ]] || exit 0

# Check if rumdl is available
command -v rumdl &>/dev/null || exit 0

# Read entire input, extract content, pipe through rumdl, output JSON
# Key: avoid bash variables for content - pipe directly through jq
{
  # Read full JSON, extract content, format with rumdl
  content=$(jq -r '.tool_input.content // empty' | rumdl fmt --stdin --quiet 2>/dev/null)

  # If rumdl failed or produced empty output, exit 0 (use original)
  [[ -n "$content" ]] || exit 0

  # Output JSON with formatted content
  jq -n --arg content "$content" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "updatedInput": {
        "content": $content
      }
    }
  }'
} < /dev/stdin
