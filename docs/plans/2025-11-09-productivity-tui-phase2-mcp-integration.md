# Productivity TUI Tools - Phase 2: MCP Integration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Integrate Claude MCP servers (Todoist, Notion, Perplexity) to create seamless research → synthesis → action workflows that bridge AI-powered research with task management and knowledge bases.

**Architecture:** Configure MCP servers in Claude Desktop, create workflow scripts that leverage MCP tools, and build helper functions that automate common patterns (research → save → create tasks).

**Tech Stack:** Claude MCP (Model Context Protocol), Todoist API, Notion API, Perplexity/Sonar API, Bash, Python (for MCP server configuration)

**Prerequisites:** Phase 1 completed (taskwarrior, mods, glow installed and configured)

---

## Task 1: Set Up Todoist MCP Server

**Files:**
- Research: Todoist MCP server documentation
- Configure: Claude Desktop MCP configuration
- Test: Todoist integration from Claude

**Step 1: Research Todoist MCP server**

Search for official Todoist MCP server:
- Check https://github.com/modelcontextprotocol/servers
- Check https://www.claudemcp.com for community servers
- Find installation instructions

Expected: Official or community-maintained Todoist MCP server with installation guide

**Step 2: Install Todoist MCP server**

Follow server-specific installation (example for typical MCP server):

```bash
# If it's an npm package:
npm install -g @modelcontextprotocol/server-todoist

# Or if it's Python:
pip install mcp-server-todoist

# Or if it's a standalone binary, download to ~/.local/bin/
```

**Step 3: Configure Todoist API token**

1. Get Todoist API token:
   - Go to https://todoist.com/app/settings/integrations
   - Find "API token" section
   - Copy token

2. Store securely (don't commit to git):
   ```bash
   # Option 1: Environment variable
   echo 'export TODOIST_API_TOKEN="your-token-here"' >> ~/.zshrc.local

   # Option 2: Secure file
   mkdir -p ~/.config/todoist
   echo "your-token-here" > ~/.config/todoist/token
   chmod 600 ~/.config/todoist/token
   ```

**Step 4: Configure Claude Desktop MCP**

Open Claude Desktop configuration:
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Linux: `~/.config/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

Add Todoist server (example configuration):

```json
{
  "mcpServers": {
    "todoist": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-todoist"],
      "env": {
        "TODOIST_API_TOKEN": "your-token-here"
      }
    }
  }
}
```

**Step 5: Test Todoist MCP in Claude**

Restart Claude Desktop, then test:

```
"Can you list my Todoist tasks for today?"
"Create a Todoist task: Review MCP integration due tomorrow"
"Show me all tasks in my Work project"
```

Expected: Claude successfully queries and creates Todoist tasks

**Step 6: Document configuration**

Create `docs/MCP_SETUP.md` with Todoist setup instructions (without exposing token).

**Step 7: Commit documentation (not secrets!)**

```bash
git add docs/MCP_SETUP.md
git commit -m "docs: add Todoist MCP server setup guide"
```

---

## Task 2: Create Todoist ↔ Taskwarrior Bridge Script

**Files:**
- Create: `dot_local/bin/executable_todoist-sync`
- Create: `dot_local/bin/executable_task-to-todoist`

**Step 1: Write todoist-sync script**

Create `dot_local/bin/executable_todoist-sync`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Sync taskwarrior tasks to Todoist via Claude MCP
# This script uses the Todoist MCP server already configured in Claude Desktop

CLAUDE_CLI="${CLAUDE_CLI:-mods}"  # Use mods as Claude CLI by default

# Check if taskwarrior is available
if ! command -v task &>/dev/null; then
    echo "Error: taskwarrior not installed"
    exit 1
fi

# Get pending tasks from taskwarrior
TASKS=$(task export status:pending)

# Ask Claude to sync to Todoist
echo "Syncing taskwarrior tasks to Todoist..."

PROMPT="I have these tasks from taskwarrior:

\`\`\`json
${TASKS}
\`\`\`

Please create corresponding tasks in Todoist if they don't already exist. Match tasks by description. For each task:
- Use the description as the task name
- Set the project from taskwarrior's project field
- Set due date from taskwarrior's due field
- Add tags from taskwarrior's tags

Only create tasks that don't already exist in Todoist. Report what you did."

if command -v mods &>/dev/null; then
    echo "$PROMPT" | mods
else
    echo "Error: mods (Charm) not installed"
    echo "Install with: brew install charmbracelet/tap/mods"
    exit 1
fi
```

**Step 2: Write task-to-todoist script**

Create `dot_local/bin/executable_task-to-todoist`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Create a Todoist task from a taskwarrior task
# Usage: task-to-todoist <task-id>

if [[ $# -eq 0 ]]; then
    echo "Usage: task-to-todoist <task-id>"
    echo "Example: task-to-todoist 42"
    exit 1
fi

TASK_ID="$1"

# Export task as JSON
TASK_JSON=$(task "$TASK_ID" export)

# Extract task details
DESCRIPTION=$(echo "$TASK_JSON" | jq -r '.[0].description')
DUE=$(echo "$TASK_JSON" | jq -r '.[0].due // empty')
PROJECT=$(echo "$TASK_JSON" | jq -r '.[0].project // "Inbox"')
TAGS=$(echo "$TASK_JSON" | jq -r '.[0].tags // [] | join(", ")')

# Build Todoist task creation prompt
PROMPT="Create a Todoist task with these details:
- Task: $DESCRIPTION
- Project: $PROJECT
- Due: ${DUE:-none}
- Labels: $TAGS

Report the task ID after creation."

echo "$PROMPT" | mods
```

**Step 3: Make scripts executable**

Chezmoi handles this via `executable_` prefix, but verify:

```bash
chmod +x dot_local/bin/executable_todoist-sync
chmod +x dot_local/bin/executable_task-to-todoist
```

**Step 4: Test sync scripts**

In terminal:
```bash
# Add test task to taskwarrior
task add "Test sync to Todoist" +test due:tomorrow

# Sync to Todoist
todoist-sync

# Check in Todoist web/app
# Expected: New task appears in Todoist
```

**Step 5: Commit**

```bash
git add dot_local/bin/executable_todoist-sync dot_local/bin/executable_task-to-todoist
git commit -m "feat: add Todoist sync scripts for taskwarrior integration"
```

---

## Task 3: Set Up Notion MCP Server

**Files:**
- Configure: Claude Desktop MCP configuration (add Notion)
- Create: Notion database templates

**Step 1: Research Notion MCP server**

Find official Notion MCP server:
- Check https://github.com/modelcontextprotocol/servers
- Look for @modelcontextprotocol/server-notion or similar

**Step 2: Create Notion integration**

1. Go to https://www.notion.so/my-integrations
2. Click "New integration"
3. Name it "Claude MCP"
4. Select workspace
5. Copy "Internal Integration Token"

**Step 3: Share Notion pages with integration**

In Notion:
1. Open the database/page you want Claude to access
2. Click "..." → "Connections" → "Connect to"
3. Select your "Claude MCP" integration

**Step 4: Configure Notion MCP server**

Update `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "todoist": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-todoist"],
      "env": {
        "TODOIST_API_TOKEN": "your-todoist-token"
      }
    },
    "notion": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-notion"],
      "env": {
        "NOTION_API_KEY": "your-notion-integration-token"
      }
    }
  }
}
```

**Step 5: Create Notion databases**

Create these databases in Notion:

**Research Database:**
- Name (Title)
- Date (Date)
- Topics (Multi-select)
- Status (Select: Inbox, In Progress, Completed)
- Summary (Text)
- Source (URL)
- Notes (Rich text)

**Knowledge Base Database:**
- Title (Title)
- Category (Select: Code, Tools, Concepts, Reference)
- Tags (Multi-select)
- Created (Date)
- Last Updated (Date)
- Content (Rich text)
- Related (Relation to other pages)

**Step 6: Test Notion MCP**

Restart Claude Desktop, then:

```
"Can you list my Notion research database?"
"Create a new research entry in Notion titled 'TUI Productivity Tools' with today's date"
"Search my Notion knowledge base for entries about 'taskwarrior'"
```

Expected: Claude can read and write to Notion databases

**Step 7: Document Notion setup**

Update `docs/MCP_SETUP.md` with Notion configuration.

**Step 8: Commit**

```bash
git add docs/MCP_SETUP.md
git commit -m "docs: add Notion MCP server setup guide"
```

---

## Task 4: Create Research Workflow Script

**Files:**
- Create: `dot_local/bin/executable_research-workflow`
- Create: `dot_zshrc.tmpl` (add research function)

**Step 1: Create research workflow script**

Create `dot_local/bin/executable_research-workflow`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Integrated research workflow: Research → Notion → Tasks
# Usage: research-workflow "topic" ["additional context"]

if [[ $# -eq 0 ]]; then
    echo "Usage: research-workflow <topic> [context]"
    echo "Example: research-workflow 'Rust async programming' 'focus on tokio'"
    exit 1
fi

TOPIC="$1"
CONTEXT="${2:-}"
DATE=$(date +%Y-%m-%d)
SAFE_TOPIC="${TOPIC// /-}"
OUTPUT_FILE="$HOME/notes/research/${DATE}-${SAFE_TOPIC}.md"

echo "═══════════════════════════════════════════════════════"
echo "  Research Workflow: $TOPIC"
echo "═══════════════════════════════════════════════════════"
echo ""

# Step 1: AI Research (using mods/Claude)
echo "→ Step 1: Conducting AI research..."
mkdir -p "$(dirname "$OUTPUT_FILE")"

RESEARCH_PROMPT="Research this topic in depth: $TOPIC

${CONTEXT:+Additional context: $CONTEXT}

Please provide:
1. A comprehensive overview
2. Key concepts and terminology
3. Practical applications or use cases
4. Best practices or common patterns
5. Resources for further learning
6. Any potential gotchas or challenges

Format as markdown with clear sections."

echo "# Research: $TOPIC" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "**Date:** $DATE" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if command -v mods &>/dev/null; then
    mods "$RESEARCH_PROMPT" >> "$OUTPUT_FILE"
    echo "✓ Research completed and saved to $OUTPUT_FILE"
else
    echo "✗ Error: mods not installed"
    exit 1
fi

echo ""

# Step 2: Save to Notion (via Claude MCP)
echo "→ Step 2: Saving to Notion knowledge base..."

NOTION_PROMPT="Save this research to my Notion knowledge base:

**Title:** $TOPIC
**Category:** Research
**Tags:** $(echo "$TOPIC" | tr ' ' ',')
**Date:** $DATE

**Content:** (Include the markdown from the file below)

\`\`\`markdown
$(cat "$OUTPUT_FILE")
\`\`\`

Create the entry and confirm it was saved."

if command -v mods &>/dev/null; then
    echo "$NOTION_PROMPT" | mods
    echo "✓ Saved to Notion"
else
    echo "⚠ Skipping Notion save (mods not configured)"
fi

echo ""

# Step 3: Extract action items and create tasks
echo "→ Step 3: Extracting action items..."

TASKS_PROMPT="Based on this research about '$TOPIC', suggest 3-5 actionable next steps or learning tasks.

For each task, provide:
- A clear, actionable task description
- Suggested priority (high/medium/low)
- Estimated effort (quick/medium/deep)

Format as a simple list."

SUGGESTED_TASKS=$(echo "$TASKS_PROMPT

Research content:
$(cat "$OUTPUT_FILE")" | mods)

echo "$SUGGESTED_TASKS"
echo ""

# Step 4: Ask if user wants to create tasks
echo "→ Step 4: Create tasks?"
read -p "Create these tasks in Todoist? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    CREATE_TASKS_PROMPT="Create these tasks in my Todoist:

$SUGGESTED_TASKS

Use project 'Learning' and add tag 'research' and tag '$SAFE_TOPIC'.
Set due dates appropriately based on priority (high=tomorrow, medium=this week, low=next week).

Report each task created."

    echo "$CREATE_TASKS_PROMPT" | mods
    echo "✓ Tasks created in Todoist"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  Research workflow complete!"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "📄 Local markdown: $OUTPUT_FILE"
echo "📝 Notion: Check your knowledge base"
echo "✅ Tasks: Check Todoist (if created)"
echo ""
echo "View with: glow $OUTPUT_FILE"
```

**Step 2: Add to zshrc**

Update `dot_zshrc.tmpl` to add alias:

```bash
# Research workflow (Phase 2 - MCP Integration)
if command -v research-workflow &>/dev/null; then
    alias research='research-workflow'
fi
```

**Step 3: Test research workflow**

```bash
research-workflow "Terminal UI frameworks" "Compare Bubble Tea and Textual"
```

Expected:
1. AI generates research
2. Saves to local markdown
3. Saves to Notion (if configured)
4. Suggests tasks
5. Optionally creates tasks in Todoist

**Step 4: Commit**

```bash
git add dot_local/bin/executable_research-workflow dot_zshrc.tmpl
git commit -m "feat: add integrated research workflow (research → Notion → tasks)"
```

---

## Task 5: Set Up Perplexity/Sonar MCP (Optional)

**Files:**
- Configure: Claude Desktop MCP configuration (add Perplexity)

**Step 1: Research Perplexity MCP server**

Find Perplexity/Sonar MCP server:
- Check https://www.claudemcp.com
- Look for Sonar API integration

Expected: MCP server that provides real-time web search via Perplexity

**Step 2: Get Perplexity API key**

1. Go to https://www.perplexity.ai/settings/api
2. Generate API key
3. Copy key

**Step 3: Configure Perplexity MCP**

Update `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "todoist": { ... },
    "notion": { ... },
    "perplexity": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-perplexity"],
      "env": {
        "PERPLEXITY_API_KEY": "your-perplexity-key"
      }
    }
  }
}
```

**Step 4: Test Perplexity MCP**

```
"Use Perplexity to search for the latest best practices in Rust async programming"
"Search Perplexity for recent TUI framework comparisons"
```

Expected: Claude uses Perplexity for real-time web search with citations

**Step 5: Document**

Update `docs/MCP_SETUP.md` with Perplexity setup.

**Step 6: Commit**

```bash
git add docs/MCP_SETUP.md
git commit -m "docs: add Perplexity MCP server setup guide (optional)"
```

---

## Task 6: Create Daily Review Script

**Files:**
- Create: `dot_local/bin/executable_daily-review`
- Create: cron job or systemd timer (optional)

**Step 1: Create daily review script**

Create `dot_local/bin/executable_daily-review`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Daily review workflow
# Shows taskwarrior tasks, Todoist summary, and recent notes

DATE=$(date +%Y-%m-%d)

echo "╔═══════════════════════════════════════════════════════╗"
echo "║           Daily Review - $DATE              ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

# Taskwarrior summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Taskwarrior Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if command -v task &>/dev/null; then
    echo "📅 Today's tasks:"
    task +DUETODAY 2>/dev/null || echo "  (none)"
    echo ""

    echo "⏰ Overdue:"
    task overdue 2>/dev/null || echo "  (none)"
    echo ""

    echo "📊 Next actions:"
    task next limit:5 2>/dev/null || echo "  (none)"
else
    echo "  Taskwarrior not installed"
fi

echo ""

# Todoist via MCP (optional)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Todoist Summary (via Claude MCP)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TODOIST_PROMPT="Provide a brief summary of my Todoist tasks:
- How many tasks due today?
- How many overdue tasks?
- Any high-priority items?

Keep it concise (2-3 sentences)."

if command -v mods &>/dev/null; then
    echo "$TODOIST_PROMPT" | mods
else
    echo "  (mods not configured)"
fi

echo ""

# Recent notes
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Recent Notes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [[ -d "$HOME/notes" ]]; then
    echo "📝 Recent research:"
    find "$HOME/notes/research" -name "*.md" -mtime -7 -type f 2>/dev/null | \
        head -5 | \
        while read -r file; do
            basename "$file"
        done || echo "  (none)"

    echo ""
    echo "📥 Inbox items:"
    if [[ -f "$HOME/notes/inbox.md" ]]; then
        lines=$(wc -l < "$HOME/notes/inbox.md")
        echo "  $lines lines in inbox"
    else
        echo "  (inbox empty)"
    fi
else
    echo "  Notes directory not found"
fi

echo ""
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo "💡 Tips:"
echo "  - Run 'tt' to manage tasks in TUI"
echo "  - Run 'glow ~/notes/inbox.md' to review notes"
echo "  - Run 'research <topic>' to start new research"
echo ""
```

**Step 2: Add alias to zshrc**

Update `dot_zshrc.tmpl`:

```bash
# Daily review
if command -v daily-review &>/dev/null; then
    alias review='daily-review'

    # Optional: Auto-run on terminal open (comment out if too noisy)
    # daily-review
fi
```

**Step 3: Test daily review**

```bash
daily-review
```

Expected: Shows consolidated view of tasks, Todoist summary, and recent notes

**Step 4: Commit**

```bash
git add dot_local/bin/executable_daily-review dot_zshrc.tmpl
git commit -m "feat: add daily review workflow script"
```

---

## Task 7: Create Knowledge Capture Script

**Files:**
- Create: `dot_local/bin/executable_capture`

**Step 1: Create capture script**

Create `dot_local/bin/executable_capture`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Quick knowledge capture with AI enhancement
# Usage: capture "thing to remember" [category]

if [[ $# -eq 0 ]]; then
    echo "Usage: capture <note> [category]"
    echo "Example: capture 'Docker networking tip: use bridge mode' docker"
    exit 1
fi

NOTE="$1"
CATEGORY="${2:-general}"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%H:%M)

# Capture to local inbox first
INBOX="$HOME/notes/inbox.md"
mkdir -p "$(dirname "$INBOX")"

echo "" >> "$INBOX"
echo "## [$TIMESTAMP] $CATEGORY" >> "$INBOX"
echo "" >> "$INBOX"
echo "$NOTE" >> "$INBOX"
echo "" >> "$INBOX"

echo "✓ Captured to inbox"

# Ask AI to enhance and categorize
ENHANCE_PROMPT="I captured this note:

Category: $CATEGORY
Note: $NOTE

Please:
1. Suggest a better category if appropriate
2. Add any relevant context or related concepts
3. Suggest 1-2 tags
4. Format as a clean markdown knowledge base entry

Keep it concise but informative."

if command -v mods &>/dev/null; then
    echo ""
    echo "→ AI enhancement:"
    ENHANCED=$(echo "$ENHANCE_PROMPT" | mods)
    echo "$ENHANCED"

    # Ask if user wants to save to Notion
    echo ""
    read -p "Save enhanced version to Notion knowledge base? (y/n) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        NOTION_PROMPT="Save this to my Notion knowledge base:

$ENHANCED

Extract the title, category, tags, and content appropriately."

        echo "$NOTION_PROMPT" | mods
        echo "✓ Saved to Notion"
    fi
fi
```

**Step 2: Add alias**

Update `dot_zshrc.tmpl`:

```bash
# Knowledge capture
if command -v capture &>/dev/null; then
    alias cap='capture'
fi
```

**Step 3: Test capture**

```bash
capture "taskwarrior urgency is calculated automatically based on due date, priority, and tags" productivity
```

Expected:
1. Saves to inbox
2. AI enhances with context
3. Optionally saves to Notion

**Step 4: Commit**

```bash
git add dot_local/bin/executable_capture dot_zshrc.tmpl
git commit -m "feat: add quick knowledge capture with AI enhancement"
```

---

## Task 8: Create MCP Health Check Script

**Files:**
- Create: `dot_local/bin/executable_mcp-check`

**Step 1: Create health check script**

Create `dot_local/bin/executable_mcp-check`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Check MCP server health and configuration

echo "╔═══════════════════════════════════════════════════════╗"
echo "║           MCP Server Health Check                    ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

# Detect OS and find config
if [[ "$(uname)" == "Darwin" ]]; then
    CONFIG_PATH="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
elif [[ "$(uname)" == "Linux" ]]; then
    CONFIG_PATH="$HOME/.config/Claude/claude_desktop_config.json"
else
    CONFIG_PATH="$APPDATA/Claude/claude_desktop_config.json"
fi

# Check if config exists
if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "✗ Claude Desktop config not found at: $CONFIG_PATH"
    echo ""
    echo "Please install Claude Desktop first."
    exit 1
fi

echo "✓ Config found: $CONFIG_PATH"
echo ""

# Parse and check servers
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Configured MCP Servers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if command -v jq &>/dev/null; then
    SERVERS=$(jq -r '.mcpServers | keys[]' "$CONFIG_PATH" 2>/dev/null || echo "")

    if [[ -z "$SERVERS" ]]; then
        echo "  No MCP servers configured"
    else
        while IFS= read -r server; do
            echo "📡 $server"

            # Check if command exists
            COMMAND=$(jq -r ".mcpServers.\"$server\".command" "$CONFIG_PATH")
            if command -v "$COMMAND" &>/dev/null; then
                echo "   ✓ Command available: $COMMAND"
            else
                echo "   ✗ Command not found: $COMMAND"
            fi

            # Check environment variables
            ENV_VARS=$(jq -r ".mcpServers.\"$server\".env | keys[]" "$CONFIG_PATH" 2>/dev/null || echo "")
            if [[ -n "$ENV_VARS" ]]; then
                while IFS= read -r var; do
                    VALUE=$(jq -r ".mcpServers.\"$server\".env.\"$var\"" "$CONFIG_PATH")
                    if [[ -n "$VALUE" && "$VALUE" != "null" ]]; then
                        echo "   ✓ $var configured"
                    else
                        echo "   ✗ $var missing"
                    fi
                done <<< "$ENV_VARS"
            fi

            echo ""
        done <<< "$SERVERS"
    fi
else
    echo "  (jq not available - install for detailed check)"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Integration Scripts"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SCRIPTS=(
    "research-workflow"
    "daily-review"
    "capture"
    "todoist-sync"
    "task-to-todoist"
)

for script in "${SCRIPTS[@]}"; do
    if command -v "$script" &>/dev/null; then
        echo "✓ $script"
    else
        echo "✗ $script (not installed)"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Dependencies"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

DEPS=(
    "mods"
    "glow"
    "task"
    "jq"
)

for dep in "${DEPS[@]}"; do
    if command -v "$dep" &>/dev/null; then
        VERSION=$("$dep" --version 2>&1 | head -n1 || echo "unknown")
        echo "✓ $dep: $VERSION"
    else
        echo "✗ $dep (not installed)"
    fi
done

echo ""
echo "╚═══════════════════════════════════════════════════════╝"
```

**Step 2: Test health check**

```bash
mcp-check
```

Expected: Shows status of all MCP servers and integration scripts

**Step 3: Commit**

```bash
git add dot_local/bin/executable_mcp-check
git commit -m "feat: add MCP server health check script"
```

---

## Task 9: Update Documentation

**Files:**
- Create: `docs/MCP_WORKFLOWS.md`
- Modify: `CLAUDE.md`
- Modify: `docs/PRODUCTIVITY.md`

**Step 1: Create MCP workflows documentation**

Create `docs/MCP_WORKFLOWS.md`:

```markdown
# MCP Integration Workflows

This guide covers integrated workflows using Claude MCP servers for productivity.

## Prerequisites

- Phase 1 tools installed (taskwarrior, mods, glow)
- Claude Desktop with MCP servers configured
- API keys for Todoist, Notion, Perplexity (as needed)

## Available MCP Servers

### Todoist
**Purpose:** Task management via Claude

**Setup:** See `docs/MCP_SETUP.md`

**Usage:**
- "List my Todoist tasks for today"
- "Create task: Review PR #123 due tomorrow"
- "Move task X to project Work"

### Notion
**Purpose:** Knowledge base management

**Setup:** See `docs/MCP_SETUP.md`

**Databases:**
- Research database (research findings)
- Knowledge base (permanent knowledge)

**Usage:**
- "Save this research to Notion"
- "Search my knowledge base for 'docker networking'"
- "Create knowledge entry about taskwarrior"

### Perplexity (Optional)
**Purpose:** Real-time web search with citations

**Usage:**
- "Use Perplexity to find latest Rust async best practices"
- "Search for recent TUI framework comparisons"

## Workflows

### 1. Research Workflow

**Goal:** Research topic → Save to Notion → Create learning tasks

**Steps:**
```bash
# Automated workflow
research-workflow "Rust async programming" "focus on tokio"

# Manual workflow with Claude
# 1. Research
mods "Research Rust async programming focusing on tokio"

# 2. Save to Notion
# In Claude: "Save this research to my Notion research database"

# 3. Create tasks
# In Claude: "Based on this research, create 3 learning tasks in Todoist"
```

**Output:**
- Local markdown file
- Notion research entry
- Todoist learning tasks

### 2. Knowledge Capture

**Goal:** Capture insight → AI enhance → Save to knowledge base

**Steps:**
```bash
# Quick capture
capture "Docker bridge networking allows containers to communicate" docker

# Interactive flow:
# 1. Saves to inbox
# 2. AI enhances with context
# 3. Option to save to Notion
```

### 3. Daily Review

**Goal:** Review tasks, notes, and priorities

**Steps:**
```bash
# Run daily review
daily-review

# Shows:
# - Taskwarrior summary
# - Todoist via MCP
# - Recent notes
```

### 4. Task Synchronization

**Goal:** Keep Taskwarrior and Todoist in sync

**Steps:**
```bash
# Sync all pending tasks
todoist-sync

# Sync specific task
task-to-todoist 42
```

### 5. Integrated Research + Action

**Manual Claude workflow:**

```
User: "I want to learn about Bubble Tea TUI framework. Research it, save findings to Notion, and create learning tasks."

Claude (with MCPs):
1. Researches Bubble Tea using web search
2. Creates comprehensive summary
3. Saves to Notion research database
4. Creates structured learning tasks in Todoist
5. Reports back with links and task IDs
```

## Script Reference

### research-workflow
**Purpose:** End-to-end research workflow

**Usage:**
```bash
research-workflow "topic" ["context"]
research-workflow "Kubernetes networking" "focus on CNI plugins"
```

**What it does:**
1. AI research via mods
2. Save to local markdown
3. Save to Notion
4. Suggest and create tasks

### capture
**Purpose:** Quick knowledge capture with AI enhancement

**Usage:**
```bash
capture "note content" [category]
capture "tmux prefix is Ctrl+b by default" tools
```

### daily-review
**Purpose:** Daily productivity review

**Usage:**
```bash
daily-review
# or use alias:
review
```

### todoist-sync
**Purpose:** Sync taskwarrior to Todoist

**Usage:**
```bash
todoist-sync
```

### mcp-check
**Purpose:** Verify MCP server configuration

**Usage:**
```bash
mcp-check
```

## Tips

1. **Start simple**: Use one MCP server at a time
2. **Iterate workflows**: Customize scripts for your needs
3. **Review regularly**: Check `mcp-check` if things break
4. **Secure credentials**: Never commit API keys to git
5. **Backup configs**: Keep backups of MCP configurations

## Troubleshooting

### MCP server not responding
```bash
# Check configuration
mcp-check

# Restart Claude Desktop
# Check logs in Claude Desktop
```

### API authentication errors
```bash
# Verify API keys in config
cat ~/.config/Claude/claude_desktop_config.json

# Check key validity in service (Todoist/Notion/etc.)
```

### Script not finding mods
```bash
# Verify mods installed
which mods

# Check PATH
echo $PATH | grep .local/bin
```

## See Also

- [MCP_SETUP.md](MCP_SETUP.md) - Server setup instructions
- [PRODUCTIVITY.md](PRODUCTIVITY.md) - Phase 1 tools guide
- [Model Context Protocol Docs](https://modelcontextprotocol.io/)
```

**Step 2: Update CLAUDE.md**

Add to Quick Reference:

```markdown
**MCP Integration (Phase 2):**
```bash
research-workflow "topic"  # Research → Notion → Tasks
capture "note" category    # Quick capture with AI
daily-review               # Daily productivity review
mcp-check                  # Verify MCP servers
todoist-sync               # Sync tasks to Todoist
```
```

**Step 3: Update PRODUCTIVITY.md**

Add section at the end:

```markdown
## Phase 2: MCP Integration

For advanced workflows integrating Claude MCP servers, see [MCP_WORKFLOWS.md](MCP_WORKFLOWS.md).

Includes:
- Research → Notion → Tasks automation
- Todoist integration
- Knowledge capture with AI enhancement
- Daily review workflows
```

**Step 4: Commit**

```bash
git add docs/MCP_WORKFLOWS.md CLAUDE.md docs/PRODUCTIVITY.md
git commit -m "docs: add MCP integration workflows documentation"
```

---

## Task 10: Final Integration Test

**Files:**
- None (testing only)

**Step 1: Test complete workflow**

End-to-end test:

```bash
# 1. Check MCP servers
mcp-check

# 2. Research workflow
research-workflow "Testing MCP integration"

# 3. Knowledge capture
capture "MCP Phase 2 testing complete" productivity

# 4. Daily review
daily-review

# 5. Task sync
todoist-sync
```

**Step 2: Verify in external services**

- Check Todoist: New tasks created
- Check Notion: Research entry exists
- Check local: Markdown files created

**Step 3: Test with Claude Desktop directly**

Ask Claude:
```
"List my Todoist tasks, show recent Notion research entries, and create a task to review today's research"
```

Expected: Claude uses MCP servers to complete request

**Step 4: Document any issues**

Create issues or notes for future improvements.

---

## Verification Checklist

Before considering Phase 2 complete, verify:

- [ ] Todoist MCP server configured and working
- [ ] Notion MCP server configured and working
- [ ] Perplexity MCP server configured (optional)
- [ ] research-workflow script works end-to-end
- [ ] capture script saves to inbox and Notion
- [ ] daily-review shows all sources
- [ ] todoist-sync syncs tasks correctly
- [ ] mcp-check reports healthy status
- [ ] Documentation complete and accurate
- [ ] Claude Desktop can access all MCP servers
- [ ] API credentials secured (not in git)

---

## Future Enhancements (Phase 3)

- Custom MCP servers for dotfiles-specific workflows
- Calendar integration (Google Calendar MCP)
- Email integration for task creation
- GitHub integration for issue/PR tracking
- Slack/Discord integration for team workflows
- Obsidian MCP for advanced note-taking
- Custom Bubble Tea TUI for unified interface
- Voice input for quick capture
- Mobile app integration
- Analytics and productivity insights

---

## Notes for Implementation

**Security Considerations:**
- NEVER commit API keys to git
- Use environment variables or secure credential storage
- Consider using password manager integration
- Rotate keys periodically

**MCP Server Stability:**
- MCP protocol is evolving
- Server implementations may change
- Keep servers updated
- Have fallback workflows

**Performance:**
- MCP calls can be slow
- Use local caching where possible
- Batch operations when appropriate
- Don't overload APIs

**Customization:**
- All scripts are templates
- Modify prompts for your style
- Adjust workflows to your needs
- Add new scripts as patterns emerge

**Testing Strategy:**
- Test each MCP server independently
- Test workflows with dummy data first
- Verify external services updated correctly
- Use dry-run modes where available
- Keep backups of important data
