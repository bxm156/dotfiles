# Logging helpers using gum log for enhanced output
# This file is sourced, not executed directly

# Detect gum availability (cached for performance)
if [[ -z "${_LOGGING_HAS_GUM+x}" ]]; then
    if command -v gum &>/dev/null; then
        _LOGGING_HAS_GUM=true
    else
        _LOGGING_HAS_GUM=false
    fi
    export _LOGGING_HAS_GUM
fi

# Internal: emit message using gum log with proper levels
_log_emit() {
    local level="$1"      # gum log level: debug, info, warn, error, fatal, or none
    local icon="$2"       # icon/emoji to include in message
    local msg="$3"        # the message text
    local target="${4:-stdout}"  # stdout or stderr

    local formatted="${icon} ${msg}"

    if [[ "$_LOGGING_HAS_GUM" == true ]]; then
        if [[ "$level" == "none" ]]; then
            # For level "none", just use gum log without --level flag
            if [[ "$target" == "stderr" ]]; then
                gum log "$formatted" >&2
            else
                gum log "$formatted"
            fi
        else
            # Use gum log with specified level
            if [[ "$target" == "stderr" ]]; then
                gum log --level "$level" "$formatted" >&2
            else
                gum log --level "$level" "$formatted"
            fi
        fi
    else
        # Fallback: plain output with emoji
        if [[ "$target" == "stderr" ]]; then
            echo "[${level^^}] ${formatted}" >&2
        else
            echo "[${level^^}] ${formatted}"
        fi
    fi
}

# Public API - Simple and clean
log_info() {
    _log_emit "info" "ℹ️ " "$1"
}

log_success() {
    _log_emit "none" "✓" "$1"
}

log_error() {
    _log_emit "error" "✗" "$1" "stderr"
}

log_warning() {
    _log_emit "warn" "⚠️ " "$1"
}

log_progress() {
    _log_emit "debug" "⏳" "$1"
}

log_section() {
    local msg="$1"
    echo ""
    if [[ "$_LOGGING_HAS_GUM" == true ]]; then
        # Chain gum log with gum style for enhanced section headers
        # Redirect stderr to stdout since gum log outputs to stderr
        { gum log --level none "=== ${msg} ===" 2>&1; } | gum style --foreground 5 --bold --border rounded --padding "0 1"
    else
        echo "=== ${msg} ==="
    fi
    echo ""
}

# For binary installations - special formatting
log_binary() {
    local binary_name="$1"
    local status="$2"  # "installing" or "installed"

    if [[ "$status" == "installing" ]]; then
        log_progress "Installing ${binary_name}..."
    else
        log_success "${binary_name}: installed and verified"
    fi
}

# For script execution tracking
log_script() {
    local script_name="$1"
    log_info "Running: ${script_name}"
}
