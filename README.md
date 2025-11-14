<div align="center">

```text
╭────────────────────────────────────────────────────────────╮
│                                                      ·   ✦ │
│   ██████╗ ██████╗ ██╗███╗   ███╗███████╗          ·       │
│   ██╔══██╗██╔══██╗██║████╗ ████║██╔════╝    ✦            │
│   ██████╔╝██████╔╝██║██╔████╔██║█████╗              ·     │
│ · ██╔═══╝ ██╔══██╗██║██║╚██╔╝██║██╔══╝       ✦            │
│   ██║     ██║  ██║██║██║ ╚═╝ ██║███████╗                  │
│   ╚═╝     ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝         ·        │
│ ✦                                                          │
│    ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗    ·     │
│   ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝          │
│ · ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗    ✦    │
│   ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║         │
│   ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝  ·      │
│    ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝          │
│     ✦                                               ·      │
│              🖖 Configuration, the Prime way               │
│          ·                                            ✦    │
╰────────────────────────────────────────────────────────────╯
```

**💡 Tip:** For a gorgeous colorful version, try: `glow README.terminal.md`

</div>

## What is This?

Your **perfect development environment** that follows you everywhere. One command sets up your shell, installs tools, and configures everything with a beautiful UI that makes you actually *enjoy* the terminal. Work on your Mac, jump to a Linux server, spin up a dev container—same powerful setup, same muscle memory, zero fuss.

Stop copy-pasting configs between machines. Stop wondering "wait, how did I set this up last time?" Update once, deploy everywhere, and get back to building things that matter. Your terminal, but **gorgeous** and **smart**.

```bash
# Enhanced install (recommended - beautiful UI):
bash <(curl -fsLS https://raw.githubusercontent.com/bxm156/dotfiles/main/install.sh)

# Direct install (quick & simple):
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply bxm156
```

---

## Quick Reference

| What | How | Why |
|------|-----|-----|
| **Install** | `bash <(curl ...)` | Get configured in seconds |
| **Quick Mode** | Add `--safe` flag | Skip fancy UI, just install |
| **Custom Path** | `--bootstrap ~/.local/bin` | Choose where tools live |
| **Preview Changes** | `chezmoi diff` | See before applying |
| **Apply Updates** | `chezmoi-apply` or `cm-apply` | Beautiful progress UI |
| **Test Safely** | `mise run test` | Validate in container first |
| **Edit Config** | `chezmoi edit <file>` | Modify source files |
| **View Docs** | `glow README.md` | Beautiful markdown |
| **AI Help** | `ai "question"` | Instant assistance |
| **Tasks** | `tt` or `/todo` | Manage work beautifully |
| **Quick Note** | `note "idea"` | Capture thoughts |

---

## What You Can Do

### Supercharged Shell

```bash
# Lightning-fast ZSH with beautiful prompts
# Smart aliases that know your OS
# Git status at a glance
# Work/home mode switching
```

### AI Everywhere

```bash
ai "explain this error"          # Get instant help
research "kubernetes patterns"   # Deep dive with sources
```

### Beautiful Task Management

```bash
task add "Ship feature X"        # Command line
tt                               # Full TUI
/todo                            # Todoist sync
```

### Instant Notes

```bash
note "brilliant idea at 2am"     # Never forget
```

### Pretty Documents

```bash
glow README.md                   # Markdown reader
```

---

## For Developers

### AI Agents

See [CLAUDE.md](CLAUDE.md) for quick reference and [AGENTS.md](AGENTS.md) for detailed workflows.

### Humans

```bash
# Make changes in source directory
vim ~/.local/share/chezmoi/dot_zshrc.tmpl

# Test in isolated container
mise run test

# Apply to your system
chezmoi apply
```

### Key Rules

1. **NEVER** edit `~/` files directly (edit source instead)
2. **ALWAYS** test in container first (`mise run test`)
3. **NEVER** commit secrets (syncs across machines)
4. Templates use Go syntax: `{{ .variable }}`

---

## The Fun Part

### Your Terminal's New Superpowers

```text
   ╭──────────────────────────────────────────────╮
   │                                              │
   │   "I used to fear the terminal.             │
   │    Now I live in it."                        │
   │                                              │
   │             — You, in 5 minutes              │
   │                                              │
   ╰──────────────────────────────────────────────╯
```

**Try these after installing:**

```bash
# See how pretty your shell can be
echo "Hello, beautiful terminal!"

# Ask AI anything
ai "what should I build next?"

# View this README the fancy way
glow README.md

# See your tasks beautifully
tt

# Check what changed
chezmoi diff

# Make your cursor dance with spinners
chezmoi-apply
```

### Easter Eggs

Hidden throughout your new environment:

- Smart aliases that save you hours
- Git shortcuts you didn't know you needed
- OS-specific configs that "just work"
- Beautiful error messages (yes, really)
- Task management that doesn't suck

### Confession Time

This entire README was written by AI (Claude), styled with AI, and probably read by you while procrastinating on actual work. But now you can procrastinate in a *beautiful terminal* instead.

> "To boldly go where no config has gone before... across all your machines." 🖖

---

<div align="center">

```text
╭────────────────────────────────────────╮
│                                        │
│   Made with ❤️  and terminal magic     │
│                                        │
│   Questions? Check the docs above ↑    │
│                                        │
╰────────────────────────────────────────╯
```

**[⬆ Back to Top](#)**

</div>