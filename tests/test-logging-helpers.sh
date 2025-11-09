#!/usr/bin/env bash
set -euo pipefail

# Test logging helper library

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== Testing Logging Helper Library ==="

# Test 1: Library can be sourced
if source "$REPO_ROOT/.chezmoiscripts/lib/.logging.sh" 2>/dev/null; then
    echo "✓ .logging.sh can be sourced"
else
    echo "✗ .logging.sh cannot be sourced"
    exit 1
fi

# Test 2: All logging functions exist
test_failed=0
for func in log_info log_success log_error log_warning log_progress log_section log_binary log_script; do
    if declare -f "$func" >/dev/null; then
        echo "✓ Function $func exists"
    else
        echo "✗ Function $func missing"
        test_failed=1
    fi
done

if [[ $test_failed -eq 1 ]]; then
    exit 1
fi

# Test 3: Functions emit correct format (without gum)
export _LOGGING_HAS_GUM=false

output=$(log_success "test message")
if [[ "$output" =~ ^\[SUCCESS\].*test\ message$ ]]; then
    echo "✓ log_success emits correct format"
else
    echo "✗ log_success format incorrect: $output"
    exit 1
fi

output=$(log_info "test message")
if [[ "$output" =~ ^\[INFO\].*test\ message$ ]]; then
    echo "✓ log_info emits correct format"
else
    echo "✗ log_info format incorrect: $output"
    exit 1
fi

output=$(log_error "test message" 2>&1)
if [[ "$output" =~ ^\[ERROR\].*test\ message$ ]]; then
    echo "✓ log_error emits correct format to stderr"
else
    echo "✗ log_error format incorrect: $output"
    exit 1
fi

echo ""
echo "✓ All logging helper tests passed!"
