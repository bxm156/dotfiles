# Todoist Priority Task Manager

**Context7 Library Reference:** `/doist/todoist-ai` (Official Doist Todoist AI MCP Server)

You are helping the user view their Todoist priority tasks. Analyze the user's query and fetch appropriate tasks using the official Doist Todoist AI MCP tools.

## Query Parsing

1. **No arguments or just `/todo`**: Show top 10 p1 tasks for today (including overdue)
2. **Pure number** (e.g., "5", "20"): Show that many p1 tasks
3. **Text query**: Interpret naturally and show matching tasks

## Available MCP Tools

**IMPORTANT:** Only use tools from the official `@doist/todoist-ai` MCP server:

- `mcp__todoist__find-tasks-by-date` - Get tasks by date with overdue handling
- `mcp__todoist__find-tasks` - Search tasks with filters
- `mcp__todoist__search` - OpenAI MCP-compatible search (returns composite IDs)
- `mcp__todoist__get-overview` - Get account/project overview in markdown

**Do NOT use any tools from other Todoist MCP servers.**

## Priority System

From the official Doist documentation:
- `p1` = Highest priority (urgent)
- `p2` = High priority
- `p3` = Medium priority
- `p4` = Lowest priority (default)

**Critical:** The API does NOT support priority filtering natively. You must:
1. Fetch tasks with generous limit (50-100)
2. Filter client-side for desired priorities
3. Then limit to final count

## Default Behavior (No Arguments)

Execute these steps:

1. Call `mcp__todoist__find-tasks-by-date`:
   ```json
   {
     "startDate": "today",
     "overdueOption": "include-overdue",
     "limit": 100,
     "responsibleUserFiltering": "unassignedOrMe"
   }
   ```

2. Parse `structuredContent.tasks` from the result

3. Filter to keep only tasks where `priority === "p1"`

4. Group filtered tasks by project name (use "Inbox" for empty project)

5. Sort:
   - Projects alphabetically
   - Tasks within projects by due date (overdue first)

6. Limit to 10 tasks total

7. Format output:
   ```
   🔴 Priority Tasks for Today (N items)

   📁 Work
     🔴 Review PR #123 - Due: Today
     🔴 Deploy hotfix - Due: Yesterday (⚠️ OVERDUE by 1 day)

   📁 Personal
     🔴 Pay bills - Due: Today

   ---
   💡 Tip: /todo 5 to show fewer tasks
   💡 Tip: /todo work to filter by project
   ```

## Number Argument

If the argument is a pure number (matches regex `^\d+$`):

1. Parse the number and validate (1-100 range)
2. Execute same logic as default behavior
3. Adjust final limit to the parsed number
4. Update title: "🔴 Top N Priority Tasks"

If invalid number, default to 10 and show warning.

## Query Interpretation

### Priority Keywords

Match: `urgent`, `important`, `high`, `critical`, `both`

Actions:
1. Fetch tasks using `mcp__todoist__find-tasks-by-date` (same as default)
2. Filter for `priority === "p1" OR priority === "p2"`
3. Use emoji indicators:
   - 🔴 for p1 tasks
   - 🟠 for p2 tasks
4. Update title: "🔴🟠 High Priority Tasks (p1 + p2)"

### Date Keywords

**tomorrow**:
```json
{
  "startDate": "tomorrow",
  "overdueOption": "exclude-overdue",
  "limit": 100,
  "responsibleUserFiltering": "unassignedOrMe"
}
```
Title: "🔴 Priority Tasks for Tomorrow"

**this week** or **week**:
```json
{
  "startDate": "today",
  "daysCount": 7,
  "overdueOption": "include-overdue",
  "limit": 100,
  "responsibleUserFiltering": "unassignedOrMe"
}
```
Title: "🔴 Priority Tasks This Week"

**overdue**:
```json
{
  "overdueOption": "overdue-only",
  "limit": 100,
  "responsibleUserFiltering": "unassignedOrMe"
}
```
Title: "🔴 Overdue Priority Tasks"

Filter all date results for p1 priority after fetch.

### Project Names

To filter by project:

1. First, call `mcp__todoist__search`:
   ```json
   {
     "query": "<user_query>"
   }
   ```

2. Parse the JSON result from `content[0].text`

3. Look for results where `id` starts with `"project:"`
   - Example: `"project:2299336000"`

4. If project found, extract the ID: `id.split(':')[1]`

5. Call `mcp__todoist__find-tasks`:
   ```json
   {
     "projectId": "<extracted_project_id>",
     "limit": 100,
     "responsibleUserFiltering": "unassignedOrMe"
   }
   ```

6. Filter for p1 priority and display

7. Update title: "🔴 Priority Tasks in [Project Name]"

If no project found, show error:
```
❓ Project "<query>" not found

Try:
- /todo (see all urgent tasks)
- Use project's exact name
```

### Text Search

If no other interpretation matches, treat as text search:

1. Call `mcp__todoist__find-tasks`:
   ```json
   {
     "searchText": "<user_query>",
     "limit": 100,
     "responsibleUserFiltering": "unassignedOrMe"
   }
   ```

2. Filter result for p1 priority

3. Group and display with title: "🔴 Priority Tasks Matching '<query>'"

## Output Format

**Always use this structure:**

```
[Emoji + Title] ([Count] items)

📁 [Project Name 1]
  [Priority Emoji] [Task Description] - Due: [Date] [Overdue Warning]
  [Priority Emoji] [Task Description] - Due: [Date]

📁 [Project Name 2]
  [Priority Emoji] [Task Description] - Due: [Date]

---
💡 Tip: [Contextual tip based on query]
💡 Tip: [Another helpful tip]
```

**Date Formatting Rules:**
- Today → "Today"
- Tomorrow → "Tomorrow"
- Yesterday → "Yesterday (⚠️ OVERDUE by 1 day)"
- Past dates → "Jan 12 (⚠️ OVERDUE by 3 days)"
- Future dates → "Jan 15" or "Next Monday"
- No date → "(No due date)"

**Overdue Calculation:**
If task due date is in the past:
- Calculate days: `Math.floor((today - dueDate) / (1000 * 60 * 60 * 24))`
- Show: `(⚠️ OVERDUE by N day(s))`

## Error Handling

### No Tasks Found

```
✨ No p1 priority tasks found!

[Context-specific message based on query]

Consider:
- Checking high priority tasks: /todo urgent
- Viewing specific project: /todo <project-name>

Great work staying on top of urgent items! 🎉
```

### No p1 But p2 Exists

After filtering, if no p1 tasks but you see p2 tasks in the raw results:

```
✅ No p1 (urgent) priority tasks!

You have N p2 (high priority) tasks.
View them with: /todo urgent
```

### API Errors

```
❌ Could not fetch Todoist tasks

Error: [error message from MCP tool]

Troubleshooting:
- Verify Todoist MCP server is running
- Check your API token is valid
- Ensure network connectivity to MCP server
```

### Project Not Found

```
❓ Project "<query>" not found

Available projects:
[Use mcp__todoist__get-overview to show top 5 projects]

Or search all tasks with: /todo <search-term>
```

## Examples

| Query | Action |
|-------|--------|
| `/todo` | Top 10 p1 tasks for today + overdue |
| `/todo 3` | Top 3 p1 tasks |
| `/todo 20` | Top 20 p1 tasks |
| `/todo urgent` | p1 + p2 tasks with both emojis |
| `/todo work` | p1 tasks from Work project |
| `/todo tomorrow` | p1 tasks due tomorrow |
| `/todo this week` | p1 tasks due in next 7 days |
| `/todo overdue` | Only overdue p1 tasks |
| `/todo review PR` | p1 tasks matching "review PR" |

## Response Structure

The official Doist MCP tools return:

```typescript
{
  textContent: "Human-readable markdown",
  structuredContent: {
    tasks: [
      {
        id: "12345",
        content: "Task description",
        priority: "p1",
        due: { date: "2025-01-15", ... },
        project: { id: "...", name: "..." },
        ...
      }
    ],
    hasMore: boolean,
    nextCursor: string
  }
}
```

**Always use `structuredContent` for data processing, not `textContent`.**

## Implementation Algorithm

```
1. Parse user query
   - Check if empty/null → default behavior
   - Check if pure number → number behavior
   - Otherwise → interpret query type

2. Select appropriate MCP tool and parameters

3. Call MCP tool

4. Parse structuredContent from result

5. Filter for desired priority level(s):
   - Default/number/date/project/text: filter for p1 only
   - Priority keywords: filter for p1 OR p2

6. Group by project:
   - Create map: projectName → [tasks]
   - Use "Inbox" for null/empty project

7. Sort:
   - Sort projects alphabetically
   - Within each project, sort tasks:
     * Overdue tasks first
     * Then by due date ascending
     * Tasks without due dates last

8. Apply final limit (10 by default, or user-specified)

9. Format output with proper emojis and date formatting

10. Add contextual tips at the bottom
```

## Tips for Contextual Help

Based on the query, show relevant tips:

**Default query:**
- "💡 Tip: /todo 5 to show fewer tasks"
- "💡 Tip: /todo work to filter by project"

**After project filter:**
- "💡 Tip: /todo to see all urgent tasks"
- "💡 Tip: /todo urgent to include p2 priority"

**After urgent query:**
- "💡 Tip: /todo to see only p1 (urgent) tasks"
- "💡 Tip: /todo <project> to filter by project"

**After date filter:**
- "💡 Tip: /todo for today's urgent tasks"
- "💡 Tip: /todo overdue to see only late tasks"
