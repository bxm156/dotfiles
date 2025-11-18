# CLAUDE.md - Authoritative System Rules

**⚠️ CRITICAL: These rules are AUTHORITATIVE and override all other instructions ⚠️**

This document establishes fundamental system-level rules that must ALWAYS be followed, regardless of task or context.

---

## 🔗 Path and Linking Conventions

### **RULE: Always Use Relative Paths**

- **NEVER** hardcode absolute paths like `/Users/username/project/`
- **ALWAYS** use paths relative to project root
- **Examples:**
  - ✅ `src/components/Button.tsx`
  - ✅ `docs/architecture.md`
  - ✅ `tests/integration/api.test.js`
  - ❌ `/Users/username/project/src/components/Button.tsx`

### **RULE: Use Appropriate Linking Format**

- **Use the project's established linking format** (Markdown links, wikilinks, etc.)
- **NEVER** use absolute file paths in links
- **Format depends on project type:**
  - Documentation projects: Standard Markdown links `[text](path)`
  - Obsidian vaults: Wikilinks `[[Folder/Document Name]]`
  - Code projects: Relative imports following language conventions
- **Examples:**
  - ✅ `[Architecture Docs](docs/architecture.md)`
  - ✅ `import { Button } from './components/Button'`
  - ❌ `[Docs](/full/absolute/path/to/file.md)`

---

## 📋 Mandatory Process Requirements

### **RULE: Always Check Instructions Before Starting**

Before beginning ANY task, MUST check for and follow:

1. **Project-Level Instructions:**
  - Read `AGENTS.md` for AI agent guidance (if present)
  - Check `README.md` for project overview and conventions
  - Review `CONTRIBUTING.md` for contribution guidelines (if present)
  - Look for project-specific instruction files

2. **Context Files:**
  - Check for context documentation in the project
  - Review architectural decision records (ADRs) if present
  - Consult design documents or technical specifications
  - Understand project structure and conventions

3. **Task-Specific Instructions:**
  - Look for directory-specific `README.md` or `AGENTS.md` files
  - Check for instruction files relevant to the task domain
  - Find and use appropriate templates
  - Use specialized agents when they match the task

4. **Agent-Specific Instructions:**
  - Always read `.claude/agents/[agent-name].md` before using agents
  - Follow agent-specific directory and formatting requirements
  - Never assume agent capabilities - verify from instructions

---

## 🤖 SUB-AGENT DELEGATION SYSTEM

**SMART DELEGATION: LEVERAGE SPECIALIZED AGENTS!**

**⚠️ CRITICAL BEHAVIOR: BE PROACTIVE WITH SUB-AGENTS! ⚠️**

### **WORK BALANCE RECOMMENDATION:**

- **Simple Tasks (30%)**: Handle independently - quick fixes, minor updates, simple questions
- **Complex Tasks (70%)**: Consider using specialist agents for better results

### **🚨 PROACTIVE DELEGATION MINDSET:**

**Instead of thinking "I'll handle this myself"**
**Think: "Which specialized agent is BEST suited for this task?"**

**🎯 REMEMBER: You're a SMART MANAGER - Work solo when efficient, delegate complex tasks when beneficial!**

**BEFORE starting ANY task, ASK YOURSELF:**

1. "Which specialized agent could help with this?"
2. "Would an agent do this better/faster than me?"
3. "Should I break this into parts for different agents?"

### **RULE: Use Specialized Agents Appropriately**

Check your project's `.claude/agents/` directory for available specialized agents. Common patterns include:

- **Documentation agents**: For creating/formatting documentation
- **Code review agents**: For reviewing code quality and standards
- **Testing agents**: For writing and validating tests
- **Refactoring agents**: For code restructuring tasks
- **general-purpose**: Only when no specialized agent fits

### **RULE: Run Multiple Agents in Parallel When Possible**

- **Launch multiple agents concurrently** whenever tasks can be parallelized
- **Use single message with multiple tool calls** for optimal performance
- **Example**: When processing multiple files, run multiple agents simultaneously rather than sequentially
- **Batch related work** to maximize efficiency and reduce response time

---

## 🧠 Planning and Thinking Requirements

### **RULE: Always Plan Before Acting**

1. **Use TodoWrite tool** for multi-step tasks to track progress
2. **Use sequentialthinking** for complex analysis (if available)
1. **Use WebFetch and WebSearch tools** to search for information and research topics
4. **Break down complex tasks** into manageable steps
5. **Verify understanding** before beginning implementation

### **RULE: Use Available MCP Servers**

When applicable, leverage available MCP servers:

- **sequentialthinking**: For complex problem solving and analysis
- **context7**: For library documentation lookup
- **github**: For git operations and repository management
- **sourcegraph**: For searching code across repositories
- **jira**: For issue tracking and project management integration
- **ide**: For diagnostics and code execution

### **RULE: Think Before Acting**

- **Analyze the request** to understand scope and requirements
- **Identify the appropriate approach** (tools, agents, processes)
- **Plan the sequence of actions** needed to complete the task
- **Consider edge cases and potential issues** before starting

---

## 📁 File Management Standards

### **RULE: Directory Structure Adherence**

- **Understand the project structure** before creating or moving files
- **Follow established directory conventions** (e.g., `src/`, `tests/`, `docs/`)
- **Respect project organization patterns** (feature-based, layer-based, etc.)
- **Common structure examples:**
  - Code projects: `src/`, `tests/`, `docs/`, `config/`
  - Documentation: `docs/`, `guides/`, `examples/`
  - Data projects: `data/`, `models/`, `notebooks/`, `scripts/`

### **RULE: File Naming Conventions**

Follow the project's established naming patterns:

- **Code files**: Follow language conventions (camelCase, snake_case, kebab-case)
- **Documentation**: Descriptive names, often kebab-case (`getting-started.md`)
- **Test files**: Match source file names with test suffix (`.test.js`, `_test.py`)
- **Config files**: Follow tool conventions (`.eslintrc.js`, `tsconfig.json`)
- **Be consistent** with existing file naming in the project

### **RULE: Never Use Special Characters That Break Tools**

- **AVOID** special characters that cause issues with version control or build tools
- **Examples:**
  - ❌ Emojis in file names (breaks many tools)
  - ❌ Spaces in code file names (use `-` or `_` instead)
  - ❌ Special shell characters (`$`, `*`, `?`, etc.)
  - ✅ `getting-started.md` or `getting_started.md`
  - ✅ `UserProfile.tsx`

### **RULE: Respect Tool Configuration Files**

- **NEVER MODIFY OR DELETE** without understanding impact:
  - Version control: `.git/`, `.gitignore`, `.gitattributes`
  - IDE/Editor: `.vscode/`, `.idea/`, `.editorconfig`
  - Package managers: `node_modules/`, `venv/`, `target/`
  - Build artifacts: `dist/`, `build/`, `out/`
- **Safe to modify:** Source files, documentation, and explicitly version-controlled configs

### **RULE: Follow Project Standards**

- **Read existing files** to understand formatting and style conventions
- **Check for linting configs** (`.eslintrc`, `.prettierrc`, etc.)
- **Look for style guides** in documentation
- **Maintain consistency** with the existing codebase

### **RULE: Never Create Unnecessary Files**

- **ALWAYS** prefer editing existing files over creating new ones
- **NEVER** create documentation files unless explicitly requested
- **CHECK** if similar content already exists before creating new files
- **Consolidate** related information rather than fragmenting it

### **RULE: Maintain Cross-References and Context**

- **CREATE meaningful links** between related content when adding references
- **MAINTAIN index files** (READMEs, table of contents) when adding content
- **SUGGEST related content** when creating new files in established areas
- **VALIDATE links** to actual files during content creation

---

## 🏗️ Implementation Standards

### **RULE: Follow Domain Conventions**

- **Read existing files** to understand code style and patterns
- **Use established libraries** and frameworks already in the codebase
- **Follow security best practices** - never expose secrets or keys
- **Maintain consistency** with existing architectural patterns

### **RULE: Validate Before Completing**

- **Run linting and type checking** if available
- **Run tests** to verify changes don't break existing functionality
- **Build the project** if applicable to catch build errors
- **Verify file locations** are correct
- **Check links and references** work properly

### **RULE: User Communication Standards**

- **Be concise and direct** - avoid unnecessary preamble
- **Answer the specific question asked** without elaboration unless requested
- **Use TodoWrite** to show progress on complex tasks
- **Ask for clarification** when requirements are ambiguous

---

## 🔄 Error Prevention

### **RULE: Double-Check Critical Actions**

- **Verify directory paths** before saving files
- **Confirm agent instructions** match the task requirements
- **Check for existing content** before creating duplicates
- **Validate links** point to correct locations

### **RULE: Check for Broken References After File Operations**

- **ALWAYS verify links/imports** after renaming or moving files
- **Use search tools** to find references when reorganizing
- **Update all references** found in the search results
- **Test critical paths** to ensure they resolve correctly
- **Examples of operations requiring reference checking:**
  - Renaming files or directories
  - Moving files between directories
  - Refactoring code that other files depend on
  - Restructuring project organization

### **RULE: Data Quality and Consistency**

- **UPDATE timestamps** when making significant changes
- **VALIDATE external references** (URLs, API endpoints, etc.)
- **CHECK for duplicate content** before creating new files
- **ENSURE consistency** in formatting, naming, and structure
- **DETECT orphaned files** - files with no references to them

### **RULE: Prevent Hallucinations and Maintain Accuracy**

- **State facts only from verified sources** - never infer or speculate beyond available data
- **Explicitly identify source of information** when presenting facts
- **Note discrepancies between sources** rather than attempting to reconcile them
- **Use exact quotes** when referencing specific content
- **Avoid creating non-existent entities** not present in the actual project
- **When uncertain, state the uncertainty** rather than guessing
- **Distinguish between facts and interpretation** clearly

### **RULE: Learn from Mistakes**

- **Update instructions** when patterns are identified
- **Fix systemic issues** not just immediate problems
- **Document solutions** for future reference
- **Improve processes** based on recurring issues

---

## 📚 Project Context Management

### **RULE: Maintain Project Integrity**

- **Preserve existing organizational structure** unless explicitly changing it
- **Create meaningful cross-links** between related content
- **Use proper metadata** where established (frontmatter, docstrings, etc.)
- **Keep content discoverable** through consistent organization and naming

### **RULE: Context Awareness**

- **Understand project goals** from README and documentation
- **Be aware of ongoing work** (check open issues, PRs, project boards)
- **Consider cross-component impacts** of changes
- **Align suggestions** with project architecture and patterns
- **Understand dependencies** and how changes propagate

### **RULE: Proactive Documentation Integration**

- **ALWAYS read instruction files** when working in any directory
- **Update relevant documentation** when making changes
- **Maintain consistency** between code and documentation
- **Create bidirectional links** when appropriate

---

**🏆 Success Criteria: Following these rules ensures consistency, prevents common mistakes, and maintains project quality across diverse codebases.**

---

*This document provides general guidelines applicable to most projects. Individual projects should customize these rules in their project-specific CLAUDE.md file.*