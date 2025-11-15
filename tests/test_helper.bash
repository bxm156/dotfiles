#!/usr/bin/env bash
# Helper script to load bats libraries from mise installation paths
# Source this file in your bats test setup() function

# Find bats-support and bats-assert dynamically from mise
BATS_SUPPORT_LOAD="$(find "$(mise where npm:bats-support)" -name "load.bash" -path "*/bats-support/load.bash")"
BATS_ASSERT_LOAD="$(find "$(mise where npm:bats-assert)" -name "load.bash" -path "*/bats-assert/load.bash")"

# Load the libraries (remove .bash extension as bats load expects)
load "${BATS_SUPPORT_LOAD%.bash}"
load "${BATS_ASSERT_LOAD%.bash}"
