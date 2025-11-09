# Phase 2: Self-Hosted Productivity Infrastructure

**Status:** Proposed
**Created:** 2025-11-09
**Supersedes:** `2025-11-09-productivity-tui-phase2-mcp-integration.md` (cloud-based, not suitable for user's workflow)

## Overview

This phase focuses on self-hosted and local-first productivity infrastructure that integrates with the Phase 1 TUI tools
(taskwarrior, glow, mods) without relying on cloud services.

**User Workflow Context:**
- Uses Claude Code (not Claude Desktop)
- Separate git repository for knowledge base
- Prefers self-hosted or local solutions over cloud services
- `~/notes/` directory for quick capture and local notes

## Goals

1. **Self-hosted task sync** - TaskChampion server for multi-device taskwarrior synchronization
2. **Git automation** - Smart tools for knowledge base and notes management
3. **Local search** - Fast, privacy-respecting search across notes and knowledge base
4. **Integration** - Tie together taskwarrior, notes, and knowledge base workflows
5. **Zero cloud dependencies** - Everything runs locally or on user's own servers

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Local Workstation                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐      │
│  │ Taskwarrior  │  │  ~/notes/    │  │ Knowledge   │      │
│  │   + hooks    │  │  (quick cap) │  │ Base Repo   │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘      │
│         │                  │                  │             │
│         │                  │                  │             │
│  ┌──────▼──────────────────▼──────────────────▼──────┐     │
│  │         Local Search (ripgrep + fzf)              │     │
│  └───────────────────────────────────────────────────┘     │
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Git Automation (auto-commit, sync, templates)    │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
└────────────────────┬────────────────────────────────────────┘
					│
					│ TaskChampion Protocol
					│
			┌──────▼──────────┐
			│  TaskChampion   │
			│  Sync Server    │
			│  (self-hosted)  │
			└─────────────────┘
```

## Implementation Plan

### Task 1: TaskChampion Sync Server Setup (Optional)

**Goal:** Enable multi-device taskwarrior synchronization via self-hosted server

**Files:**
- `docs/taskchampion-server-setup.md` - Installation and configuration guide
- `.config/task/taskchampion.toml.tmpl` - Client configuration for sync

**Implementation:**
- Document server installation (Docker or standalone)
- Configure client sync settings
- Add server URL as chezmoi template variable
- Test sync between devcontainer and test container

**Skip if:** User only uses single device

---

### Task 2: Notes Git Automation

**Goal:** Automatic versioning and sync for `~/notes/` directory

**Files:**
- `.config/notes/hooks/post-save.sh` - Auto-commit on note changes
- `.config/notes/notes.conf.tmpl` - Configuration for git behavior
- `bin/note` - Smart wrapper for creating/editing notes

**Features:**
- Auto-commit changes with timestamps
- Optional auto-push to git remote
- Conflict detection and warning
- Integration with `glow` for rendering

**Example Usage:**
```bash
note daily           # Opens today's daily note
note inbox           # Quick capture to inbox
note project/foo     # Opens/creates project note
```

---

### Task 3: Knowledge Base Integration

**Goal:** Seamless access to separate knowledge base repo from anywhere

**Files:**
- `.zshrc.d/knowledge-base.zsh.tmpl` - Aliases and functions
- `bin/kb` - Knowledge base helper script
- `.config/kb/config.toml.tmpl` - KB location and settings

**Template Variables:**
- `{{ .knowledgeBasePath }}` - Path to separate knowledge repo

**Features:**
- Quick search across knowledge base
- Create new entries with templates
- Link between notes and knowledge base
- Fast navigation with fzf

**Example Usage:**
```bash
kb search "docker compose"    # Search knowledge base
kb new tech/tool-name          # Create new entry
kb link                        # Link current note to KB entry
```

---

### Task 4: Unified Search

**Goal:** Search across taskwarrior, notes, and knowledge base in one command

**Files:**
- `bin/search` - Unified search interface
- `.config/search/config.toml.tmpl` - Search scope configuration

**Search Targets:**
- Taskwarrior tasks (using `task export`)
- `~/notes/` markdown files
- Knowledge base repository
- Recently accessed files (via zoxide)

**Features:**
- Live preview with `fzf` and `glow`
- Filter by source (tasks/notes/kb/files)
- Open results in editor or browser
- Fuzzy matching with ripgrep

**Example Usage:**
```bash
search "deployment"           # Search everything
search --tasks "urgent"       # Search only tasks
search --notes "meeting"      # Search only notes
```

---

### Task 5: Taskwarrior Note Integration

**Goal:** Link taskwarrior tasks to notes and knowledge base entries

**Files:**
- `.config/task/hooks/on-modify.taskwarrior-notes.sh` - Hook for note linking
- `bin/task-note` - Helper for creating task-linked notes

**Features:**
- Automatic note creation for tasks with `+note` tag
- Link notes to tasks via UDA (User Defined Attribute)
- Quick jump from task to note
- Backlink from note to task

**Example Usage:**
```bash
task add "Research deployment strategies" +note
# Creates task and opens note ~/notes/tasks/1234.md
task 42 note              # Open note for task 42
task 42 annotate "See note"  # Auto-links if note exists
```

---

### Task 6: Git Smart Sync

**Goal:** Intelligent git operations for notes and knowledge base

**Files:**
- `bin/git-smart-sync` - Pull, merge, push with conflict handling
- `.config/git/hooks/pre-commit.notes` - Pre-commit checks for notes
- `.config/git/hooks/post-merge.notes` - Post-merge notifications

**Features:**
- Auto-pull before push (rebase strategy)
- Conflict detection with user-friendly errors
- Notification of remote changes
- Optional daily auto-sync via cron/systemd timer

**Example Usage:**
```bash
git-smart-sync ~/notes           # Sync notes repo
git-smart-sync "$KB_PATH"        # Sync knowledge base
```

---

### Task 7: Daily Review Workflow

**Goal:** Streamlined daily review combining tasks, notes, and knowledge

**Files:**
- `bin/daily-review` - Interactive daily review script
- `.config/daily-review/template.md.tmpl` - Daily note template

**Workflow:**
1. Show overdue tasks
2. Show today's tasks
3. Review yesterday's daily note
4. Create today's daily note
5. Prompt for quick captures

**Integration:**
- Uses `taskwarrior-tui` for task review
- Uses `glow` for note rendering
- Uses `fzf` for quick navigation
- Auto-commits daily notes

---

### Task 8: Template System for Notes

**Goal:** Quick note creation with structured templates

**Files:**
- `.config/notes/templates/` - Note templates
- `daily.md.tmpl` - Daily note format
- `meeting.md.tmpl` - Meeting notes
- `project.md.tmpl` - Project overview
- `research.md.tmpl` - Research notes
- `bin/note` (enhance) - Template selection with fzf

**Templates Include:**
- YAML frontmatter with metadata
- Taskwarrior task references
- Knowledge base links
- Common sections (e.g., "Next Steps", "Questions")

**Example:**
```bash
note new meeting            # Prompts for template
note new --template research "Topic Name"
```

---

### Task 9: Knowledge Base Contribution Workflow

**Goal:** Easy workflow for creating/updating knowledge base entries

**Files:**
- `bin/kb-contribute` - Interactive KB contribution helper
- `.config/kb/templates/` - KB entry templates
- `.config/kb/hooks/pre-commit` - Quality checks

**Features:**
- Template-based entry creation
- Link checking (no broken references)
- Metadata validation
- Preview before commit
- Auto-generate index/TOC

**Workflow:**
```bash
kb contribute tech/docker        # Create new tech entry
# Opens template, validates, commits, pushes
```

---

### Task 10: Testing and Documentation

**Goal:** Comprehensive testing and user documentation

**Files:**
- `tests/test-phase2-selfhosted.sh` - Test all Phase 2 features
- `docs/WORKFLOWS.md` - Common workflow documentation
- `docs/SELFHOSTED.md` - Self-hosted component setup
- Update `tests/test-dotfiles.sh` - Add Phase 2 checks

**Test Coverage:**
- Note creation and git automation
- Knowledge base integration
- Unified search functionality
- Taskwarrior hooks and linking
- Daily review workflow

**Documentation:**
- Setup guide for each component
- Common workflows and examples
- Troubleshooting guide
- Configuration reference

---

## Template Variables Needed

Add to `.chezmoi.toml.tmpl`:

```toml
[data]
	# Knowledge base configuration
	knowledgeBasePath = "~/path/to/knowledge-base"
	knowledgeBaseRemote = "git@github.com:user/kb.git"

	# Notes configuration
	notesAutoCommit = true
	notesAutoPush = false

	# TaskChampion sync (optional)
	taskchampionEnabled = false
	taskchampionServer = "https://tasks.example.com"
	taskchampionCert = "/path/to/client-cert.pem"

	# Daily review
	dailyReviewTime = "09:00"  # For systemd timer
```

## Dependencies

**Required from Phase 1:**
- taskwarrior, taskwarrior-tui
- glow (markdown rendering)
- fzf (fuzzy finding)
- ripgrep (fast search)
- git

**Additional Tools:**
- `entr` - Run commands when files change (for auto-commit)
- `jq` - JSON parsing (for taskwarrior export)
- `pandoc` (optional) - Convert between markup formats

**Install via `.chezmoiexternal.toml.tmpl`:**
```toml
[".local/bin/entr"]
	type = "archive-file"
	url = "https://eradman.com/entrproject/code/entr-5.6.tar.gz"
	# ... extraction config
```

## Success Criteria

- [ ] Can sync taskwarrior across devices (if TaskChampion enabled)
- [ ] Notes auto-commit when changed
- [ ] Can search across tasks, notes, and knowledge base in one command
- [ ] Can create task-linked notes
- [ ] Daily review workflow is smooth and fast
- [ ] Knowledge base contribution is streamlined
- [ ] All features work offline (except sync)
- [ ] Zero reliance on cloud services
- [ ] Comprehensive test coverage
- [ ] User documentation complete

## Migration from Phase 1

Phase 1 tools remain unchanged. Phase 2 adds:
- Configuration files in `.config/`
- Helper scripts in `bin/` (new directory)
- Taskwarrior hooks in `.config/task/hooks/`
- Templates in `.config/notes/templates/`

No breaking changes to existing Phase 1 setup.

## Optional Enhancements

**If user wants more automation:**
- Systemd timers for daily review reminders
- Automatic knowledge base backups
- Local LLM integration with Ollama (for `mods` backend)
- Taskwarrior burndown charts and reports

**If user wants mobile access:**
- Termux setup on Android (taskwarrior + sync)
- SSH access scripts for quick mobile capture

## Notes

This plan is designed for:
- Self-hosted infrastructure (user controls all data)
- Local-first operation (works offline)
- Git-based workflows (familiar, reliable)
- Integration with existing tools (taskwarrior, glow, fzf)
- User's actual workflow (Claude Code, separate KB repo)

**Unlike the original Phase 2 (MCP integration)**, this plan:
- ✅ Works with Claude Code (not just Desktop)
- ✅ Respects separate knowledge base repo
- ✅ No cloud dependencies
- ✅ User owns all infrastructure
- ✅ Privacy-focused (no data leaves user's control)

## Questions for User

Before implementing:
1. **Knowledge base location:** Where is your knowledge base repo? (for template variable)
2. **Multi-device sync:** Do you need TaskChampion server? (Task 1)
3. **Auto-push notes:** Should notes auto-push to git remote? (security consideration)
4. **Systemd timers:** Want automated daily review reminders?
5. **Priority:** Which tasks are most valuable? (can implement subset)

## Estimated Effort

- **Tasks 1-6:** Core functionality (2-3 hours)
- **Tasks 7-9:** Enhanced workflows (2 hours)
- **Task 10:** Testing and docs (1 hour)
- **Total:** ~5-6 hours implementation + user testing/refinement

Can be done in phases:
- **Phase 2A:** Tasks 2-4 (notes, KB, search) - Most immediately useful
- **Phase 2B:** Tasks 5-7 (integration, sync, review) - Enhanced workflows
- **Phase 2C:** Tasks 8-10 (templates, contribution, testing) - Polish>