#!/usr/bin/env bash
# NAME: Test Failure Handling
# Demonstrates how the launcher handles script failures

set -euo pipefail

echo "This script will intentionally fail to demonstrate error handling."
echo ""
echo "Running some commands..."
sleep 1
echo "Command 1: OK"
sleep 1
echo "Command 2: OK"
sleep 1
echo "Command 3: FAIL"
echo ""

# Exit with error code
exit 1
