# Productivity TUI Tools - Phase 1: Quick Wins Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Install and configure essential TUI productivity tools (mods, glow, taskwarrior, taskwarrior-tui) with minimal friction for immediate productivity gains.

**Architecture:** Add binaries to .chezmoiexternal.toml.tmpl for automated installation, configure with sensible defaults, and integrate with existing zsh workflow.

**Tech Stack:** Bash, chezmoi templates, taskwarrior, mods (Charm), glow (Charm), zsh

---

## Task 1: Add Glow to External Binaries

**Files:**
- Modify: `.chezmoiexternal.toml.tmpl` (add glow binary)
- Test: Manual verification in test container

**Step 1: Research glow release URLs**

Visit https://github.com/charmbracelet/glow/releases to find latest stable version and download patterns.

Expected pattern: `https://github.com/charmbracelet/glow/releases/download/v{VERSION}/glow_{VERSION}_{OS}_{ARCH}.tar.gz`

**Step 2: Add glow configuration to .chezmoiexternal.toml.tmpl**

Add after the gitui section (around line 102):

```toml
# glow - Beautiful markdown reader for the terminal
{{- $glowOS := .chezmoi.os }}
{{- $glowArch := .chezmoi.arch }}
{{- if eq .chezmoi.arch "amd64" }}
{{-   $glowArch = "x86_64" }}
{{- else if eq .chezmoi.arch "arm64" }}
{{-   $glowArch = "arm64" }}
{{- end }}
[".local/bin/glow"]
    type = "archive-file"
    url = "https://github.com/charmbracelet/glow/releases/download/v2.0.0/glow_2.0.0_{{ $glowOS }}_{{ $glowArch }}.tar.gz"
    executable = true
    refreshPeriod = "672h"
    path = "glow"
```

**Step 3: Test template rendering**

Run: `chezmoi execute-template < .chezmoiexternal.toml.tmpl | grep -A 5 glow`

Expected: Valid TOML with correct URL for current platform

**Step 4: Test in container**

Run: `mise run test:shell`

In container:
```bash
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply --source ~/.local/share/chezmoi
~/.local/bin/glow --version
```

Expected: `glow version 2.0.0`

**Step 5: Commit**

```bash
git add .chezmoiexternal.toml.tmpl
git commit -m "feat: add glow markdown reader to external binaries"
```

---

## Task 2: Add Mods to External Binaries

**Files:**
- Modify: `.chezmoiexternal.toml.tmpl` (add mods binary)

**Step 1: Research mods release URLs**

Visit https://github.com/charmbracelet/mods/releases

Expected pattern: `https://github.com/charmbracelet/mods/releases/download/v{VERSION}/mods_{VERSION}_{OS}_{ARCH}.tar.gz`

**Step 2: Add mods configuration to .chezmoiexternal.toml.tmpl**

Add after glow section:

```toml
# mods - AI on the command line (CLI interface to LLMs)
[".local/bin/mods"]
    type = "archive-file"
    url = "https://github.com/charmbracelet/mods/releases/download/v1.11.1/mods_1.11.1_{{ $glowOS }}_{{ $glowArch }}.tar.gz"
    executable = true
    refreshPeriod = "672h"
    path = "mods"
```

**Step 3: Test template rendering**

Run: `chezmoi execute-template < .chezmoiexternal.toml.tmpl | grep -A 5 mods`

Expected: Valid TOML with correct URL

**Step 4: Test in container**

Run: `mise run test:shell`

In container:
```bash
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply --source ~/.local/share/chezmoi
~/.local/bin/mods --version
```

Expected: `mods version 1.11.1`

**Step 5: Commit**

```bash
git add .chezmoiexternal.toml.tmpl
git commit -m "feat: add mods CLI LLM interface to external binaries"
```

---

## Task 3: Add Taskwarrior to External Binaries

**Files:**
- Modify: `.chezmoiexternal.toml.tmpl` (add taskwarrior binary)

**Step 1: Research taskwarrior release URLs**

Visit https://github.com/GothenburgBitFactory/taskwarrior/releases

Expected pattern: `https://github.com/GothenburgBitFactory/taskwarrior/releases/download/v{VERSION}/task-{VERSION}.tar.gz`

Note: Taskwarrior needs to be compiled from source OR use pre-built binaries from unofficial sources.

Alternative: Use cargo to build from source in a run_once script.

**Step 2: Create taskwarrior installation script**

Create `.chezmoiscripts/run_once_install-taskwarrior.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Install taskwarrior from package manager or compile from source

# Source logging helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/logging.sh"

log_script "install-taskwarrior.sh"

TASK_BIN="$HOME/.local/bin/task"

# Check if already installed
if [[ -x "$TASK_BIN" ]]; then
    version=$("$TASK_BIN" --version | head -n1)
    log_success "Taskwarrior already installed: $version"
    exit 0
fi

log_progress "Installing taskwarrior..."

# Try to install via cargo if available
if command -v cargo &>/dev/null; then
    log_info "Building taskwarrior from source with cargo..."
    cargo install --root "$HOME/.local" taskwarrior-tui

    if [[ -x "$TASK_BIN" ]]; then
        log_success "Taskwarrior installed successfully via cargo"
        exit 0
    fi
fi

# Fallback: Download pre-built binary (Linux only)
if [[ "$(uname -s)" == "Linux" ]]; then
    log_info "Downloading pre-built taskwarrior binary..."

    TASK_VERSION="3.2.0"
    TASK_URL="https://github.com/GothenburgBitFactory/taskwarrior/releases/download/v${TASK_VERSION}/task-${TASK_VERSION}.tar.gz"

    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    if curl -fsSL "$TASK_URL" | tar -xz -C "$TEMP_DIR"; then
        cd "$TEMP_DIR/task-${TASK_VERSION}"

        # Build with cmake
        if command -v cmake &>/dev/null; then
            cmake -DCMAKE_INSTALL_PREFIX="$HOME/.local" .
            make
            make install
            log_success "Taskwarrior compiled and installed"
            exit 0
        else
            log_warning "cmake not available, cannot build taskwarrior from source"
        fi
    fi
fi

log_error "Could not install taskwarrior (cargo or cmake required)"
log_info "Please install manually: https://taskwarrior.org/download/"
exit 1
```

**Step 3: Make script executable**

Chezmoi naming: `.chezmoiscripts/run_once_install-taskwarrior.sh`
→ Automatically executable

**Step 4: Test in container**

Run: `mise run test:shell`

In container:
```bash
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply --source ~/.local/share/chezmoi
~/.local/bin/task --version
```

Expected: `task 3.2.0` or similar

**Step 5: Commit**

```bash
git add .chezmoiscripts/run_once_install-taskwarrior.sh
git commit -m "feat: add taskwarrior installation script"
```

---

## Task 4: Add Taskwarrior-TUI to External Binaries

**Files:**
- Modify: `.chezmoiexternal.toml.tmpl` (add taskwarrior-tui binary)

**Step 1: Research taskwarrior-tui release URLs**

Visit https://github.com/kdheepak/taskwarrior-tui/releases

Expected pattern: `https://github.com/kdheepak/taskwarrior-tui/releases/download/v{VERSION}/taskwarrior-tui-{VERSION}-{ARCH}-{OS}.tar.gz`

**Step 2: Add taskwarrior-tui configuration**

Add to `.chezmoiexternal.toml.tmpl`:

```toml
# taskwarrior-tui - Terminal UI for taskwarrior
{{- $tasktuiArch := .chezmoi.arch }}
{{- if eq .chezmoi.arch "amd64" }}
{{-   $tasktuiArch = "x86_64" }}
{{- else if eq .chezmoi.arch "arm64" }}
{{-   $tasktuiArch = "aarch64" }}
{{- end }}
{{- $tasktuiOS := .chezmoi.os }}
{{- if eq .chezmoi.os "darwin" }}
{{-   $tasktuiOS = "apple-darwin" }}
{{- else if eq .chezmoi.os "linux" }}
{{-   $tasktuiOS = "unknown-linux-gnu" }}
{{- end }}
[".local/bin/taskwarrior-tui"]
    type = "archive-file"
    url = "https://github.com/kdheepak/taskwarrior-tui/releases/download/v0.26.3/taskwarrior-tui-{{ $tasktuiArch }}-{{ $tasktuiOS }}.tar.gz"
    executable = true
    refreshPeriod = "672h"
    path = "taskwarrior-tui"
```

**Step 3: Test template rendering**

Run: `chezmoi execute-template < .chezmoiexternal.toml.tmpl | grep -A 10 taskwarrior-tui`

Expected: Valid TOML with correct URL

**Step 4: Test in container**

Run: `mise run test:shell`

In container:
```bash
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply --source ~/.local/share/chezmoi
~/.local/bin/taskwarrior-tui --version
```

Expected: `taskwarrior-tui 0.26.3`

**Step 5: Commit**

```bash
git add .chezmoiexternal.toml.tmpl
git commit -m "feat: add taskwarrior-tui to external binaries"
```

---

## Task 5: Create Taskwarrior Configuration

**Files:**
- Create: `dot_taskrc.tmpl` (taskwarrior configuration)

**Step 1: Create basic taskrc**

Create `dot_taskrc.tmpl`:

```
# Taskwarrior configuration
# See https://taskwarrior.org/docs/configuration/

# Data location
data.location=~/.task

# Color theme (dark-256 is good for most terminals)
include /usr/share/taskwarrior/dark-256.theme

# Default command (when you type just 'task')
default.command=next

# Urgency configuration (what makes tasks important)
urgency.user.tag.next.coefficient=15.0
urgency.due.coefficient=12.0
urgency.blocking.coefficient=8.0
urgency.active.coefficient=4.0

# Report definitions
report.next.labels=ID,Active,Age,Deps,P,Project,Tag,Recur,S,Due,Until,Description,Urg
report.next.columns=id,start.age,entry.age,depends,priority,project,tags,recur,scheduled.countdown,due.relative,until.remaining,description,urgency
report.next.filter=status:pending -WAITING limit:page

# Custom reports
report.today.description=Tasks due today
report.today.columns=id,priority,project,tags,description,due
report.today.labels=ID,Pri,Project,Tags,Description,Due
report.today.filter=status:pending due:today
report.today.sort=due+,priority-,project+

# UDA for taskwarrior-tui integration
uda.taskwarrior-tui.selection.indicator=•
uda.taskwarrior-tui.selection.bold=yes
uda.taskwarrior-tui.selection.italic=no
uda.taskwarrior-tui.selection.dim=no
uda.taskwarrior-tui.selection.blink=no

# Sync configuration (disabled by default, enable when ready)
# taskd.certificate=~/.task/freecinc.cert.pem
# taskd.key=~/.task/freecinc.key.pem
# taskd.ca=~/.task/freecinc.ca.pem
# taskd.server=freecinc.com:53589
# taskd.credentials=FreeCinc/username/uuid
```

**Step 2: Test configuration**

Run: `chezmoi apply -v --dry-run`

Expected: `~/.taskrc` would be created

**Step 3: Verify taskwarrior accepts config**

In test container:
```bash
task rc:~/.taskrc diagnostics
```

Expected: No errors, shows configuration summary

**Step 4: Commit**

```bash
git add dot_taskrc.tmpl
git commit -m "feat: add taskwarrior configuration"
```

---

## Task 6: Add Zsh Integrations and Aliases

**Files:**
- Modify: `dot_zshrc.tmpl` (add productivity tool integrations)

**Step 1: Add glow integration**

Add to `dot_zshrc.tmpl` (in the "Tool integrations" section):

```bash
# ═══════════════════════════════════════════════════════════════
# Productivity Tool Integrations
# ═══════════════════════════════════════════════════════════════

# Glow - Beautiful markdown reader
if command -v glow &>/dev/null; then
    alias gmd='glow'
    alias glow-pager='glow --pager'

    # View markdown files in current directory
    alias notes='glow --pager *.md 2>/dev/null || echo "No markdown files found"'
fi

# Mods - AI on the command line
if command -v mods &>/dev/null; then
    # Quick AI helpers
    alias ai='mods'
    alias explain='mods "explain this:"'
    alias summarize='mods "summarize this:"'

    # Function to ask AI about command output
    ask() {
        if [[ -p /dev/stdin ]]; then
            # Input from pipe
            mods "$@"
        else
            # Direct question
            mods "$@"
        fi
    }
fi

# Taskwarrior shortcuts
if command -v task &>/dev/null; then
    alias t='task'
    alias ta='task add'
    alias tl='task list'
    alias td='task done'
    alias tt='taskwarrior-tui'

    # Quick reports
    alias today='task +DUETODAY'
    alias tomorrow='task due:tomorrow'
    alias week='task due:week'
    alias overdue='task overdue'
    alias late='task overdue'

    # Show task summary on new terminal (optional - comment out if too noisy)
    # task next limit:5
fi
```

**Step 2: Add helper functions**

Add productivity functions:

```bash
# Quick research function using mods
research() {
    local topic="$1"
    shift
    local output_file="$HOME/notes/research/$(date +%Y-%m-%d)-${topic// /-}.md"

    echo "# Research: $topic" > "$output_file"
    echo "" >> "$output_file"
    echo "Date: $(date)" >> "$output_file"
    echo "" >> "$output_file"

    mods "Research $topic and provide a comprehensive summary with key points. $*" >> "$output_file"

    echo "Research saved to: $output_file"
    glow "$output_file"
}

# Quick note capture
note() {
    local inbox="$HOME/notes/inbox.md"
    mkdir -p "$(dirname "$inbox")"

    echo "" >> "$inbox"
    echo "## $(date '+%Y-%m-%d %H:%M')" >> "$inbox"
    echo "" >> "$inbox"
    echo "$@" >> "$inbox"
    echo "" >> "$inbox"

    echo "Note added to inbox"
}

# View notes with glow
viewnotes() {
    local notes_dir="${1:-$HOME/notes}"
    if [[ -d "$notes_dir" ]]; then
        cd "$notes_dir" && glow --pager
    else
        echo "Notes directory not found: $notes_dir"
    fi
}
```

**Step 3: Test in interactive shell**

Run: `mise run test:interactive`

In zsh shell:
```bash
# Test glow
echo "# Test" | glow

# Test mods (if configured)
echo "test" | mods "what is this?"

# Test taskwarrior
task add "Test task"
task list
tt  # Open TUI
```

**Step 4: Commit**

```bash
git add dot_zshrc.tmpl
git commit -m "feat: add productivity tool integrations to zsh"
```

---

## Task 7: Create Notes Directory Structure

**Files:**
- Create: `dot_notes/` directory structure
- Create: `dot_notes/README.md.tmpl`
- Create: `dot_notes/inbox.md.tmpl`

**Step 1: Create notes directory with chezmoi**

Create `dot_notes/README.md.tmpl`:

```markdown
# Personal Notes

This directory contains your personal notes, research, and documentation.

## Structure

- `inbox.md` - Quick capture for thoughts and ideas
- `research/` - Deep dive research on topics
- `daily/` - Daily notes and logs
- `projects/` - Project-specific notes

## Tools

- **glow**: View markdown beautifully in terminal (`glow filename.md`)
- **mods**: AI-powered research and summarization
- **taskwarrior**: Track action items from notes

## Quick Commands

```bash
# View all notes
cd ~/notes && glow --pager

# Add quick note
note "your thought here"

# Research a topic
research "topic name" "additional context"
```
```

**Step 2: Create inbox template**

Create `dot_notes/inbox.md.tmpl`:

```markdown
# Inbox

Quick capture for thoughts, ideas, and todos that need processing.

---
```

**Step 3: Create directory structure**

```bash
mkdir -p dot_notes/research
mkdir -p dot_notes/daily
mkdir -p dot_notes/projects

# Create .keep files
touch dot_notes/research/.keep
touch dot_notes/daily/.keep
touch dot_notes/projects/.keep
```

**Step 4: Test in container**

Run: `mise run test:shell`

```bash
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply --source ~/.local/share/chezmoi
ls -la ~/notes/
cat ~/notes/README.md
```

Expected: Directory structure created with README and inbox

**Step 5: Commit**

```bash
git add dot_notes/
git commit -m "feat: add notes directory structure with templates"
```

---

## Task 8: Update Binary Verification Script

**Files:**
- Modify: `.chezmoiscripts/run_after_verify-external-binaries.sh.tmpl`

**Step 1: Add new binaries to verification**

Update the binaries array in the verification script:

```bash
# List of binaries from .chezmoiexternal.toml.tmpl
binaries=(
    "jq"
    "fzf"
    "zoxide"
    "bat"
    "gitui"
    "starship"
    "glow"
    "mods"
    "task"
    "taskwarrior-tui"
)
```

**Step 2: Test verification**

Run: `mise run test`

Expected: All binaries verified successfully

**Step 3: Commit**

```bash
git add .chezmoiscripts/run_after_verify-external-binaries.sh.tmpl
git commit -m "feat: add new productivity tools to binary verification"
```

---

## Task 9: Update Test Suite

**Files:**
- Modify: `tests/test-dotfiles.sh`

**Step 1: Add productivity tools to test**

Add after existing binary tests:

```bash
log_section "Productivity Tools Verification"

# Test glow
if [[ -x "$HOME/.local/bin/glow" ]]; then
    if glow --version &>/dev/null; then
        log_success "glow: installed and working"
    else
        log_error "glow: installed but not working"
        test_failed=1
    fi
else
    log_error "glow: not installed"
    test_failed=1
fi

# Test mods
if [[ -x "$HOME/.local/bin/mods" ]]; then
    if mods --version &>/dev/null; then
        log_success "mods: installed and working"
    else
        log_error "mods: installed but not working"
        test_failed=1
    fi
else
    log_error "mods: not installed"
    test_failed=1
fi

# Test taskwarrior
if [[ -x "$HOME/.local/bin/task" ]]; then
    if task --version &>/dev/null; then
        log_success "taskwarrior: installed and working"
    else
        log_error "taskwarrior: installed but not working"
        test_failed=1
    fi
else
    log_warning "taskwarrior: not installed (optional, requires compilation)"
fi

# Test taskwarrior-tui
if [[ -x "$HOME/.local/bin/taskwarrior-tui" ]]; then
    if taskwarrior-tui --version &>/dev/null; then
        log_success "taskwarrior-tui: installed and working"
    else
        log_error "taskwarrior-tui: installed but not working"
        test_failed=1
    fi
else
    log_warning "taskwarrior-tui: not installed (requires taskwarrior)"
fi

# Test notes directory
if [[ -d "$HOME/notes" ]]; then
    log_success "Notes directory created"
else
    log_error "Notes directory missing"
    test_failed=1
fi
```

**Step 2: Run full test suite**

Run: `mise run test`

Expected: All tests pass

**Step 3: Commit**

```bash
git add tests/test-dotfiles.sh
git commit -m "test: add productivity tools to test suite"
```

---

## Task 10: Update Documentation

**Files:**
- Modify: `CLAUDE.md`
- Modify: `AGENTS.md`
- Create: `docs/PRODUCTIVITY.md`

**Step 1: Update CLAUDE.md**

Add to "Key Information" section:

```markdown
**Productivity tools:** glow (markdown viewer), mods (AI CLI), taskwarrior + taskwarrior-tui (task management)

**Quick commands:**
```bash
glow file.md              # View markdown beautifully
mods "question"           # Ask AI anything
ai "question"             # Alias for mods
task add "todo"           # Add task
tt                        # Open taskwarrior TUI
note "capture this"       # Quick note to inbox
research "topic"          # AI research → markdown
```
```

**Step 2: Create PRODUCTIVITY.md**

Create `docs/PRODUCTIVITY.md`:

```markdown
# Productivity Tools Guide

This dotfiles setup includes powerful TUI tools for daily productivity.

## Tools Included

### Glow - Markdown Viewer
Beautiful markdown rendering in the terminal.

**Usage:**
```bash
glow README.md          # View file
glow --pager long.md    # Scroll through long files
glow *.md               # View all markdown in directory
```

**Aliases:**
- `gmd` - alias for glow
- `notes` - view all markdown files in current directory

### Mods - AI on the Command Line
CLI interface to LLMs (OpenAI, Anthropic, local models).

**Setup:**
1. First run: `mods` (will prompt for API keys)
2. Configure: `~/.config/mods/mods.yml`

**Usage:**
```bash
mods "explain docker"              # Direct question
cat error.log | mods "debug this"  # Pipe input
mods -f "summarize" < article.md   # Format mode
```

**Aliases:**
- `ai` - alias for mods
- `explain` - explain things
- `summarize` - summarize text

**Functions:**
- `ask "question"` - Ask AI with optional piped input
- `research "topic"` - Deep research saved to markdown

### Taskwarrior - Task Management
Powerful CLI task manager with GTD methodology.

**Basic Usage:**
```bash
task add "Buy groceries" +shopping due:tomorrow
task list                          # View all tasks
task 1 done                        # Complete task #1
task 1 modify +urgent              # Add tag
task +shopping                     # Filter by tag
```

**Reports:**
```bash
task next              # Smart next actions list
task today             # Tasks due today
task overdue           # Overdue tasks
task burndown.weekly   # Progress visualization
```

**Aliases:**
- `t` - alias for task
- `ta` - task add
- `td` - task done
- `today` - tasks due today
- `late` - overdue tasks

### Taskwarrior-TUI
Full-featured terminal UI for taskwarrior.

**Usage:**
```bash
tt                     # Launch TUI (alias for taskwarrior-tui)
```

**Keybindings:**
- `j/k` - Navigate up/down
- `a` - Add task
- `d` - Mark done
- `e` - Edit task
- `l` - Log completed task
- `q` - Quit
- `?` - Help

## Workflows

### Quick Note Capture
```bash
# Capture thought
note "Remember to update docs"

# Review inbox
glow ~/notes/inbox.md
```

### Research Workflow
```bash
# Research a topic (uses AI + saves to markdown)
research "rust async programming" "focus on tokio"

# Review research
cd ~/notes/research
glow --pager 2025-11-09-rust-async-programming.md

# Create tasks from research
task add "Learn tokio basics" +learning due:week
```

### Daily Planning
```bash
# Morning: Check tasks
tt                     # Open TUI
task today             # Or: quick list

# Add tasks
task add "Review PR #123" +work due:today

# Evening: Review
task completed:today   # What you finished
```

## Configuration

### Taskwarrior Config
Location: `~/.taskrc`

Key settings:
- `data.location` - Where tasks are stored
- `default.command` - Command when you type just 'task'
- `urgency.*` - How urgency is calculated
- Custom reports for common views

### Mods Config
Location: `~/.config/mods/mods.yml`

Configure:
- Default model
- API keys
- Temperature and other parameters

### Notes Directory
Location: `~/notes/`

Structure:
- `inbox.md` - Quick capture
- `research/` - Research notes
- `daily/` - Daily logs
- `projects/` - Project notes

## Tips

1. **Start simple**: Don't over-organize initially
2. **Review regularly**: Check `task next` and inbox daily
3. **Use AI wisely**: Great for research, not replacements for thinking
4. **Keyboard-driven**: Learn keybindings for speed
5. **Plain text**: Everything is markdown/text - easy to backup and version

## See Also

- [Taskwarrior Docs](https://taskwarrior.org/docs/)
- [Glow GitHub](https://github.com/charmbracelet/glow)
- [Mods GitHub](https://github.com/charmbracelet/mods)
- [Taskwarrior-TUI](https://github.com/kdheepak/taskwarrior-tui)
```

**Step 3: Update AGENTS.md**

Add to "See Also" section:

```markdown
- **[PRODUCTIVITY.md](docs/PRODUCTIVITY.md)** - Productivity tools guide (glow, mods, taskwarrior)
```

**Step 4: Commit**

```bash
git add CLAUDE.md AGENTS.md docs/PRODUCTIVITY.md
git commit -m "docs: add productivity tools documentation"
```

---

## Verification Checklist

Before considering Phase 1 complete, verify:

- [ ] Glow binary installed and working
- [ ] Mods binary installed and working
- [ ] Taskwarrior installed (or installation attempted)
- [ ] Taskwarrior-TUI installed and working
- [ ] Taskrc configuration created
- [ ] Zsh aliases and functions working
- [ ] Notes directory structure created
- [ ] All tests passing (`mise run test`)
- [ ] Documentation updated (CLAUDE.md, AGENTS.md, PRODUCTIVITY.md)
- [ ] Can view markdown with glow
- [ ] Can ask AI questions with mods (if configured)
- [ ] Can add/list tasks with taskwarrior
- [ ] Can open taskwarrior-tui

---

## Future Enhancements (Not in This Plan)

- Taskwarrior sync server setup
- Mods default model configuration
- Custom taskwarrior reports
- Integration with git hooks
- Automated daily task review
- Notes search with fzf
- Taskwarrior + Todoist sync

---

## Notes for Implementation

**Taskwarrior Installation Challenges:**
- Taskwarrior v3 requires building from source
- Requires cmake and build tools
- Alternative: Use package manager (apt, brew, etc.)
- May skip in test container if build tools unavailable

**Mods Configuration:**
- Requires API keys for LLM providers
- First run will prompt for setup
- Config stored in `~/.config/mods/mods.yml`
- Can use local models (ollama, etc.)

**Testing Strategy:**
- Test each binary installation independently
- Use @superpowers:test-driven-development for scripts
- Verify both installation and functionality
- Test in clean container environment

**Binary Verification:**
- All binaries should be in `~/.local/bin/`
- Must be executable
- Should respond to `--version` flag
- Graceful handling if optional tools missing
