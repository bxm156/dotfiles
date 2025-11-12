#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Claude Code PreToolUse Hook: Markdown Formatter
# =============================================================================
#
# PURPOSE:
#   Automatically formats markdown files using rumdl before Write/Edit operations.
#   Ensures consistent markdown formatting across the vault.
#
# HOOK BEHAVIOR (Claude Code Documentation):
#   Exit Codes:
#     0 = Continue with original or modified input, stdout/stderr not shown
#     1 = Show stderr to user only, but continue with original input
#     2 = Block tool call completely and show stderr to all
#
#   Input Format:
#     {
#       "tool_name": "Write" | "Edit" | "MultiEdit",
#       "tool_input": {
#         "file_path": "path/to/file.md",
#         // For Write:
#         "content": "markdown content",
#         // For Edit:
#         "old_string": "text to find",
#         "new_string": "text to replace with"
#       }
#     }
#
#   Output Format (to modify input):
#     {
#       "hookSpecificOutput": {
#         "hookEventName": "PreToolUse",
#         "permissionDecision": "allow",
#         "permissionDecisionReason": "Auto-formatted markdown with rumdl",
#         "updatedInput": {
#           // ALL tool_input fields, with modifications applied
#           "file_path": "path/to/file.md",  // REQUIRED: Must include ALL parameters
#           "content": "formatted content"    // Modified fields
#         }
#       }
#     }
#
#   CRITICAL REQUIREMENTS FOR PRETOOLUSE HOOKS:
#     1. MUST include "permissionDecision": "allow"
#        - Without this, Claude Code won't apply updatedInput changes
#     2. MUST include "permissionDecisionReason" with explanation
#     3. MUST include ALL tool_input parameters in updatedInput
#        - Not just the modified fields (e.g., content)
#        - Must also include unmodified fields (e.g., file_path)
#        - Missing parameters will be undefined in the tool call
#     4. MUST use jq --arg for each bash variable
#        - Example: jq -n --arg file_path "$file_path" --arg content "$content"
#        - Cannot reference bash variables directly in jq JSON template
#
#   Common Errors:
#     - Missing permissionDecision → updatedInput ignored, original input used
#     - Missing file_path in updatedInput → "Path must be a string, received undefined"
#     - Missing --arg in jq → "error: $variable is not defined"
#
# CRITICAL DESIGN DECISIONS:
#   1. Write Tool: Format the entire 'content' field
#   2. Edit Tool: Format ONLY 'new_string', NOT 'old_string'
#      - Reason: old_string must match file exactly for Edit to work
#      - If both are formatted, they become identical and Edit fails
#   3. MultiEdit Tool: Not yet implemented (exits 0)
#
# KNOWN LIMITATIONS:
#   - Due to Claude Code bug #6246, Unicode characters may be corrupted
#   - Hook exits early for non-markdown files to avoid corruption
#   - Reference: https://github.com/anthropics/claude-code/issues/6246
#
# DEPENDENCIES:
#   - rumdl (Rust markdown linter/formatter)
#   - jq (JSON processor)
#   - Configuration: ~/.config/rumdl/rumdl.toml
#
# CONFIGURATION (~/.claude/settings.json):
#   {
#     "hooks": {
#       "PreToolUse": [
#         {
#           "matcher": "Edit|Write",
#           "hooks": [
#             {
#               "type": "command",
#               "command": "$HOME/.claude/hooks/markdownlint-fix.sh",
#               "timeout": 30000
#             }
#           ]
#         }
#       ]
#     }
#   }
#
# TESTING:
#   Test Write operation:
#     echo '{"tool_name":"Write","tool_input":{"file_path":"test.md","content":"## Test\n- Item"}}' | \
#       ~/.claude/hooks/markdownlint-fix.sh | jq .
#
#   Test Edit operation:
#     echo '{"tool_name":"Edit","tool_input":{"file_path":"test.md","old_string":"## Test","new_string":"## Test\n\n"}}' | \
#       ~/.claude/hooks/markdownlint-fix.sh | jq .
#
# DEBUGGING HISTORY:
#   2025-11-11: Initial implementation issues
#     - Problem: Hook ran but updatedInput was ignored
#     - Root Cause: Missing permissionDecision field
#     - Fix: Added "permissionDecision": "allow" and "permissionDecisionReason"
#     - Lesson: PreToolUse hooks MUST explicitly grant permission to modify input
#
#   2025-11-11: Path undefined error
#     - Problem: "Path must be a string, received undefined"
#     - Root Cause: updatedInput only contained modified fields (content), not file_path
#     - Fix: Added file_path to updatedInput with --arg file_path "$file_path"
#     - Lesson: updatedInput must contain ALL tool parameters, not just modified ones
#
#   2025-11-11: jq variable not defined error
#     - Problem: "jq: error: $file_path is not defined"
#     - Root Cause: Used $file_path in jq template without passing it via --arg
#     - Fix: Changed jq -n --arg content to jq -n --arg file_path --arg content
#     - Lesson: Every bash variable referenced in jq template needs --arg declaration
#
# AUTHOR: Bryan Marty
# LAST UPDATED: 2025-11-11
# =============================================================================

# Read the full input once and store it
input=$(cat)

# CRITICAL: Extract ONLY file_path first, let jq consume stdin without bash variables
# This prevents Unicode corruption in bash variable handling
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Exit immediately if not markdown - stdin consumed by jq but never stored in bash variable
# Exit 0 means "continue with original input" (no modifications)
[[ "$file_path" =~ \.(md|mdx)$ ]] || exit 0

# Check if rumdl is available
command -v rumdl &>/dev/null || exit 0

# Detect which tool is being used
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

# Handle Write tool (has 'content' field)
if [[ "$tool_name" == "Write" ]]; then
  content=$(echo "$input" | jq -r '.tool_input.content // empty' | rumdl fmt --stdin --quiet 2>/dev/null)

  # If rumdl failed or produced empty output, exit 0 (use original)
  [[ -n "$content" ]] || exit 0

  # Output JSON with formatted content
  jq -n --arg file_path "$file_path" --arg content "$content" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "allow",
      "permissionDecisionReason": "Auto-formatted markdown with rumdl",
      "updatedInput": {
        "file_path": $file_path,
        "content": $content
      }
    }
  }'

# Handle Edit tool (has 'old_string' and 'new_string' fields)
# CRITICAL: Only format new_string, NOT old_string!
# old_string must match exactly what's in the file
elif [[ "$tool_name" == "Edit" ]]; then
  # Extract old_string without formatting (must match file exactly)
  old_string=$(echo "$input" | jq -r '.tool_input.old_string // empty')

  # Format only the new_string
  new_string=$(echo "$input" | jq -r '.tool_input.new_string // empty' | rumdl fmt --stdin --quiet 2>/dev/null)

  # If rumdl failed or produced empty output for new_string, exit 0 (use original)
  [[ -n "$old_string" ]] && [[ -n "$new_string" ]] || exit 0

  # Output JSON with unmodified old_string and formatted new_string
  jq -n --arg file_path "$file_path" --arg old_string "$old_string" --arg new_string "$new_string" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "allow",
      "permissionDecisionReason": "Auto-formatted markdown with rumdl",
      "updatedInput": {
        "file_path": $file_path,
        "old_string": $old_string,
        "new_string": $new_string
      }
    }
  }'

# Handle MultiEdit tool (has 'edits' array with old_string/new_string)
elif [[ "$tool_name" == "MultiEdit" ]]; then
  # For MultiEdit, we need to format each edit's new_string (not old_string)
  # This is more complex, so for now just exit 0 (no formatting)
  # TODO: Implement MultiEdit support if needed
  exit 0

else
  # Unknown tool, exit without modification
  exit 0
fi
