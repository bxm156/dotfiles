# Logging helpers with automatic gum enhancement
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

# Internal: emit message with optional gum styling
_log_emit() {
    local level="$1"
    local icon="$2"
    local color="$3"
    local msg="$4"
    local target="${5:-stdout}"

    local formatted="[${level}] ${icon} ${msg}"

    if [[ "$_LOGGING_HAS_GUM" == true ]]; then
        if [[ "$target" == "stderr" ]]; then
            echo "$formatted" | gum style --foreground "$color" --bold >&2
        else
            echo "$formatted" | gum style --foreground "$color"
        fi
    else
        # Fallback: plain output with emoji
        if [[ "$target" == "stderr" ]]; then
            echo "$formatted" >&2
        else
            echo "$formatted"
        fi
    fi
}

# Public API - Simple and clean
log_info() {
    _log_emit "INFO" "ℹ️ " "4" "$1"
}

log_success() {
    _log_emit "SUCCESS" "✓" "2" "$1"
}

log_error() {
    _log_emit "ERROR" "✗" "1" "$1" "stderr"
}

log_warning() {
    _log_emit "WARNING" "⚠️ " "3" "$1"
}

log_progress() {
    _log_emit "PROGRESS" "⏳" "6" "$1"
}

log_section() {
    local msg="$1"
    echo ""
    if [[ "$_LOGGING_HAS_GUM" == true ]]; then
        echo "[SECTION] === ${msg} ===" | gum style --foreground 5 --bold --border rounded --padding "0 1"
    else
        echo "[SECTION] === ${msg} ==="
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
