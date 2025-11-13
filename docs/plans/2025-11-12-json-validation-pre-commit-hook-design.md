# JSON Validation Pre-commit Hook Design

**Date:** 2025-11-12
**Status:** Approved

## Overview

Add a git pre-commit hook that validates all JSON and JSON template files before allowing commits. This prevents broken JSON configurations from entering the repository.

## Design

### Hook Purpose and Behavior

The pre-commit hook validates JSON files before allowing commits by:

1. Checking if any `.json` or `.json.tmpl` files are staged
2. For each staged JSON file, executing the template using `chezmoi execute-template`
3. Piping the output to `jq` to validate JSON syntax
4. Blocking the commit if validation fails, showing the error
5. Allowing the commit if validation succeeds or if no JSON files are staged

The hook follows the "fail fast" principle - catching configuration errors before they enter the repository. Users can bypass with `git commit --no-verify` if needed for emergency commits.

### Installation

**File Location:** `.git/hooks/pre-commit` (created directly in the dotfiles repository)

**Setup:**

- Write the hook script directly to `.git/hooks/pre-commit`
- Make it executable with `chmod +x`
- Git automatically runs it before each commit
- No chezmoi involvement needed - standard git hook mechanism

### Implementation

**Script:**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Check if any .json or .json.tmpl files are staged
staged_json_files=$(git diff --cached --name-only | grep -E '\.(json|json\.tmpl)$' || true)

if [ -n "$staged_json_files" ]; then
  for file in $staged_json_files; do
    if ! chezmoi execute-template < "$file" | jq empty 2>&1; then
      echo "Error: $file validation failed"
      exit 1
    fi
  done
fi

exit 0
```

**Behavior Details:**

- Uses standard bash shebang and error handling (`set -euo pipefail`)
- `git diff --cached --name-only` lists staged files
- `grep -E '\.(json|json\.tmpl)$'` filters for JSON files
- `chezmoi execute-template` renders templates (passes plain JSON through unchanged)
- `jq empty` validates JSON without output
- Silent on success, logs specific filename and shows native tool errors on failure
- Exit code 1 blocks commit, 0 allows it

### Documentation Update

Add to CLAUDE.md "Critical Rules" section:

```markdown
16. **Git hooks live in `.git/hooks/`** - standard git mechanism, not managed by chezmoi
```

## Benefits

- Catches JSON syntax errors before commit
- Catches template syntax errors in `.tmpl` files
- Works on all JSON files in repository (generalized validation)
- Simple, standard git hook mechanism
- Minimal output - only shows errors when they occur