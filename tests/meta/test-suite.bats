#!/usr/bin/env bats

# Test suite integrity tests
# Ensures the test suite itself is properly configured

setup() {
    load '../test_helper'

    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    cd "$REPO_ROOT"
}

@test "bats test libraries are installed" {
    [ -d "tests/libs/bats-core" ]
    [ -d "tests/libs/bats-support" ]
    [ -d "tests/libs/bats-assert" ]
}

@test "all test files have .bats extension" {
    local non_bats_tests
    non_bats_tests=$(find tests -type f -name "*test*" -not -name "*.bats" -not -name "*.sh" -not -path "tests/libs/*" 2>/dev/null || true)

    if [ -n "$non_bats_tests" ]; then
        echo "Found test files without .bats extension:"
        echo "$non_bats_tests"
        return 1
    fi
}

@test "all bats files are executable or loadable" {
    local file
    while IFS= read -r file; do
        # Bats files should be readable
        [ -r "$file" ]
    done < <(find tests -name "*.bats" -not -path "tests/libs/*" 2>/dev/null || true)
}

@test "no duplicate test names within same file" {
    local file
    local duplicates=""

    while IFS= read -r file; do
        local dup
        dup=$(grep "^@test" "$file" | sort | uniq -d)
        if [ -n "$dup" ]; then
            duplicates="${duplicates}  DUPLICATES in $file:\n$dup\n"
        fi
    done < <(find tests -name "*.bats" -not -path "tests/libs/*" 2>/dev/null || true)

    if [ -n "$duplicates" ]; then
        echo -e "Found duplicate test names:\n${duplicates}"
        return 1
    fi
}

@test "all tests have descriptive names" {
    local file
    local short_names=""

    while IFS= read -r file; do
        # Test names should be at least 15 characters
        while IFS= read -r test_name; do
            if [ ${#test_name} -lt 15 ]; then
                short_names="${short_names}  SHORT NAME in $file: $test_name\n"
            fi
        done < <(grep "^@test" "$file" | sed 's/@test "\(.*\)".*/\1/')
    done < <(find tests -name "*.bats" -not -path "tests/libs/*" 2>/dev/null || true)

    if [ -n "$short_names" ]; then
        echo -e "Test names should be descriptive (>15 chars):\n${short_names}"
        # Don't fail - just warn
    fi
}

@test "mise tasks reference existing test files" {
    # Verify mise.toml test tasks point to valid paths
    if [ ! -f mise.toml ]; then
        skip "mise.toml not found"
    fi

    # Check that test paths in mise.toml exist
    local test_paths
    test_paths=$(grep "bats.*tests/" mise.toml | grep -oE "tests/[^\"']*" || true)

    if [ -n "$test_paths" ]; then
        for pattern in $test_paths; do
            # Expand glob patterns
            local matches
            matches=$(eval "ls $pattern 2>/dev/null" || true)
            if [ -z "$matches" ]; then
                echo "mise.toml references non-existent path: $pattern"
                return 1
            fi
        done
    fi
}

@test "GitHub Actions workflow references existing tests" {
    local workflow=".github/workflows/test.yml"

    if [ ! -f "$workflow" ]; then
        skip "GitHub Actions workflow not found"
    fi

    # Check that test paths in workflow exist
    local test_paths
    test_paths=$(grep "bats.*tests/" "$workflow" | grep -oE "tests/[^\"' ]*" | sort -u || true)

    if [ -n "$test_paths" ]; then
        for pattern in $test_paths; do
            # Check if pattern expands to files
            local matches
            matches=$(eval "ls $pattern 2>/dev/null" || true)
            if [ -z "$matches" ]; then
                echo "Workflow references non-existent path: $pattern"
                return 1
            fi
        done
    fi
}

@test "test coverage is reasonable" {
    # Count number of tests vs number of source files
    local test_count source_count

    test_count=$(grep -r "^@test" tests --include="*.bats" --exclude-dir="libs" 2>/dev/null | wc -l)
    source_count=$(find .chezmoiscripts -type f 2>/dev/null | wc -l)

    echo "Test count: $test_count"
    echo "Script count: $source_count"

    # Should have at least some tests
    [ "$test_count" -gt 10 ]
}

@test "test files have proper structure" {
    local file
    local issues=""

    while IFS= read -r file; do
        # Check for setup() function
        if ! grep -q "^setup()" "$file"; then
            issues="${issues}  MISSING setup(): $file\n"
        fi

        # Check for bats helpers loading
        if ! grep -q "load.*bats-support\|load.*bats-assert" "$file"; then
            issues="${issues}  MISSING helper load: $file\n"
        fi

        # Check for shebang
        if ! head -n 1 "$file" | grep -q "#!/usr/bin/env bats"; then
            issues="${issues}  MISSING/WRONG shebang: $file\n"
        fi
    done < <(find tests -name "*.bats" -not -path "tests/libs/*" -not -name "unit.bats" 2>/dev/null || true)

    if [ -n "$issues" ]; then
        echo -e "Test files should follow standard structure:\n${issues}"
        # Don't fail - some files may have valid reasons to differ
    fi
}

@test "no skipped tests without reason" {
    local file
    local skips_without_reason=""

    while IFS= read -r file; do
        # Find skip without message
        if grep -E '^\s*skip\s*$' "$file" > /dev/null 2>&1; then
            skips_without_reason="${skips_without_reason}  SKIP WITHOUT REASON: $file\n"
        fi
    done < <(find tests -name "*.bats" -not -path "tests/libs/*" 2>/dev/null || true)

    if [ -n "$skips_without_reason" ]; then
        echo -e "Skipped tests should have a reason:\n${skips_without_reason}"
        # Don't fail - might be intentional
    fi
}

@test "test documentation exists" {
    [ -f "tests/README.md" ]
}

@test "external binary verification script includes all binaries from .chezmoiexternal.toml.tmpl" {
    # Extract all binaries from .chezmoiexternal.toml.tmpl
    local external_binaries
    external_binaries=$(grep -oP '^\[".local/bin/\K[^"]+' .chezmoiexternal.toml.tmpl | sort)

    # Extract binaries from verification script
    local verification_script=".chezmoiscripts/run_after_verify-external-binaries.sh.tmpl"
    local verified_binaries
    verified_binaries=$(grep -A 100 'binaries=(' "$verification_script" | \
                       grep -oP '^\s*"\K[^"]+' | \
                       grep -v 'taskwarrior-tui' | \
                       sort)

    # Add taskwarrior-tui separately since it's conditional
    local taskwarrior_tui_in_verification
    taskwarrior_tui_in_verification=$(grep -q 'binaries+=("taskwarrior-tui")' "$verification_script" && echo "taskwarrior-tui" || echo "")

    # Known exceptions (binaries that don't need verification)
    local exceptions=()

    # Check each binary from .chezmoiexternal.toml.tmpl
    local missing_from_verification=""
    for binary in $external_binaries; do
        # Skip exceptions
        local is_exception=false
        for exception in "${exceptions[@]}"; do
            if [ "$binary" = "$exception" ]; then
                is_exception=true
                break
            fi
        done

        if [ "$is_exception" = true ]; then
            continue
        fi

        # Check if binary is in verification script
        if [ "$binary" = "taskwarrior-tui" ]; then
            if [ -z "$taskwarrior_tui_in_verification" ]; then
                missing_from_verification="${missing_from_verification}  - $binary\n"
            fi
        else
            if ! echo "$verified_binaries" | grep -q "^${binary}$"; then
                missing_from_verification="${missing_from_verification}  - $binary\n"
            fi
        fi
    done

    if [ -n "$missing_from_verification" ]; then
        echo -e "Binaries in .chezmoiexternal.toml.tmpl but missing from verification script:\n${missing_from_verification}"
        echo ""
        echo "Add these binaries to the binaries=() array in:"
        echo "  $verification_script"
        return 1
    fi
}
