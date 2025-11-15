#!/usr/bin/env bats

# Chezmoi scripts validation tests
# Ensures all scripts are syntactically valid and follow best practices

setup() {
    load '../libs/bats-support/load'
    load '../libs/bats-assert/load'

    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    cd "$REPO_ROOT"
}

@test "all bash scripts have valid syntax" {
    local script
    local failed_scripts=""

    # Find all .sh scripts and run_* scripts
    while IFS= read -r script; do
        # Skip if it's a template that needs chezmoi processing
        if [[ "$script" == *.tmpl ]]; then
            continue
        fi

        # Check bash syntax
        if ! bash -n "$script" 2>/dev/null; then
            failed_scripts="${failed_scripts}  FAILED: $script\n"
        fi
    done < <(find .chezmoiscripts tests -type f \( -name "*.sh" -o -name "run_*" \) -not -path "tests/libs/*" 2>/dev/null || true)

    if [ -n "$failed_scripts" ]; then
        echo -e "The following scripts have syntax errors:\n${failed_scripts}"
        return 1
    fi
}

@test "all scripts use set -euo pipefail or equivalent" {
    local script
    local failed_scripts=""

    while IFS= read -r script; do
        # Skip non-bash scripts
        if ! head -n 1 "$script" | grep -q "bash"; then
            continue
        fi

        # Check for set -e, set -u, set -o pipefail (in any combination)
        if ! grep -qE "set -[a-z]*e|set -o errexit" "$script"; then
            failed_scripts="${failed_scripts}  MISSING 'set -e': $script\n"
        fi
    done < <(find .chezmoiscripts -type f \( -name "*.sh" -o -name "run_*" \) 2>/dev/null || true)

    if [ -n "$failed_scripts" ]; then
        echo -e "The following scripts don't use proper error handling:\n${failed_scripts}"
        return 1
    fi
}

@test "all scripts have proper shebang" {
    local script
    local failed_scripts=""

    while IFS= read -r script; do
        # Skip library files meant to be sourced (like .logging.sh)
        if [[ "$script" == *"/lib/.logging.sh" ]]; then
            continue
        fi

        local first_line
        first_line=$(head -n 1 "$script")

        # Check for proper shebang
        if [[ ! "$first_line" =~ ^#! ]]; then
            failed_scripts="${failed_scripts}  NO SHEBANG: $script\n"
        elif [[ "$first_line" =~ /usr/bin/bash ]] && [[ ! "$first_line" =~ /usr/bin/env ]]; then
            failed_scripts="${failed_scripts}  USE '#!/usr/bin/env bash': $script\n"
        fi
    done < <(find .chezmoiscripts tests -type f \( -name "*.sh" -o -name "run_*" \) -not -path "tests/libs/*" 2>/dev/null || true)

    if [ -n "$failed_scripts" ]; then
        echo -e "The following scripts have shebang issues:\n${failed_scripts}"
        return 1
    fi
}

@test "run_once scripts are idempotent" {
    # Check that run_once scripts check for existing state
    local script
    local warnings=""

    while IFS= read -r script; do
        # run_once scripts should check if work is already done
        # Look for common patterns: command -v, [ -f ], [ -d ], etc.
        if ! grep -qE "command -v|\\[ -[fd]|\\[\\[ -[fd]|if .*exist" "$script"; then
            warnings="${warnings}  POSSIBLY NOT IDEMPOTENT: $script\n"
        fi
    done < <(find .chezmoiscripts -type f -name "run_once*" 2>/dev/null || true)

    if [ -n "$warnings" ]; then
        echo -e "WARNING: These run_once scripts may not be idempotent:\n${warnings}"
        echo "They should check if work is already done before executing."
        # Don't fail, just warn
    fi
}

@test "scripts don't contain hardcoded /home/user paths" {
    # Scripts should use $HOME, not hardcoded paths
    local script
    local failed_scripts=""

    while IFS= read -r script; do
        # Allow /home/user in comments and skip test container paths
        if grep -E "^[^#]*/home/user[^a-zA-Z]" "$script" | grep -v "docker\|container" > /dev/null; then
            failed_scripts="${failed_scripts}  HARDCODED PATH: $script\n"
        fi
    done < <(find .chezmoiscripts -type f 2>/dev/null || true)

    if [ -n "$failed_scripts" ]; then
        echo -e "The following scripts have hardcoded /home/user paths:\n${failed_scripts}"
        echo "Use \$HOME instead for portability."
        return 1
    fi
}

@test "logging library is used consistently" {
    # Check that scripts source the logging library
    local script
    local count=0
    local using_logging=0

    while IFS= read -r script; do
        count=$((count + 1))
        if grep -q "source.*logging\.sh\|\..*logging\.sh" "$script"; then
            using_logging=$((using_logging + 1))
        fi
    done < <(find .chezmoiscripts -type f -name "run_*" 2>/dev/null || true)

    # At least 50% of scripts should use logging
    if [ $count -gt 0 ] && [ $using_logging -lt $((count / 2)) ]; then
        echo "Only $using_logging out of $count scripts use the logging library"
        echo "Consider using logging.sh for consistent output"
        # Don't fail, just inform
    fi
}
