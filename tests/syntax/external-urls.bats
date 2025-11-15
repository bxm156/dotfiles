#!/usr/bin/env bats

# External URL validation tests
# Ensures all external URLs are accessible and return valid responses

setup() {
    # Load bats helpers
    load '../libs/bats-support/load'
    load '../libs/bats-assert/load'

    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    cd "$REPO_ROOT"
}

# Helper to extract URLs from .chezmoiexternal.toml.tmpl
get_external_urls() {
    chezmoi execute-template < .chezmoiexternal.toml.tmpl | \
        grep -oE 'https://[^"]+' | sort -u
}

@test "all external URLs are accessible (HTTP 200)" {
    # This test ensures no 404s, moved files, or broken links
    local failed_urls=""
    local url

    while IFS= read -r url; do
        # Use HEAD request for performance, fall back to GET
        if ! curl -sfL --head --max-time 10 "$url" > /dev/null 2>&1; then
            if ! curl -sfL --max-time 10 --range 0-0 "$url" > /dev/null 2>&1; then
                failed_urls="${failed_urls}  FAILED: $url\n"
            fi
        fi
    done < <(get_external_urls)

    if [ -n "$failed_urls" ]; then
        echo -e "The following URLs are not accessible:\n${failed_urls}"
        return 1
    fi
}

@test "external URLs use HTTPS (not HTTP)" {
    run bash -c "chezmoi execute-template < .chezmoiexternal.toml.tmpl | grep -E 'url.*http://'"
    # Should NOT find any http:// URLs (only https://)
    assert_failure
}

@test "external URLs point to GitHub releases (not latest)" {
    # Ensure we're not using /latest/ which could break unexpectedly
    run bash -c "chezmoi execute-template < .chezmoiexternal.toml.tmpl | grep -E '/releases/latest/'"
    assert_failure
}

@test "oh-my-zsh URL is accessible" {
    run curl -sfL --head --max-time 10 "https://github.com/ohmyzsh/ohmyzsh/archive/refs/heads/master.tar.gz"
    assert_success
}

@test "chezmoi installer URL is accessible" {
    run curl -sfL --head --max-time 10 "https://get.chezmoi.io"
    assert_success
}

@test "starship installer URL is accessible" {
    # Check if starship install script exists
    run curl -sfL --head --max-time 10 "https://starship.rs/install.sh"
    assert_success
}
