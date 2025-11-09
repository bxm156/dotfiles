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
