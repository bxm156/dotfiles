# TUI Style Guide (2025)

> A comprehensive reference for designing modern, beautiful Terminal User Interfaces

## Table of Contents

- [Philosophy](#philosophy)
- [Color Palettes & Themes](#color-palettes--themes)
- [Typography & Fonts](#typography--fonts)
- [Layout Patterns](#layout-patterns)
- [Animation & Motion](#animation--motion)
- [Components](#components)
- [Best Practices](#best-practices)
- [Examples](#examples)

---

## Philosophy

Modern TUI design in 2025 emphasizes **elegance**, **functionality**, and **personality** without sacrificing **accessibility** or **performance**.

### Core Principles

1. **Glamorous Minimalism** - Beauty through restraint; every element serves a purpose
2. **Adaptive Aesthetics** - Graceful degradation across terminal capabilities (4-bit → 8-bit → 24-bit)
3. **Functional Animation** - Motion that communicates state, not decoration
4. **Balanced Tone** - Professional yet personable; technical but approachable
5. **Accessibility First** - Readable, navigable, and usable for all users

### Design Inspiration

- **Charm/Bubble Tea**: Playful emoji, modular components, "glamorous" CLI experiences
- **Claude Code**: Clean information hierarchy, balanced modern tone
- **Rose Pine Theme**: Soft, comfortable color palettes with natural aesthetics
- **Elm Architecture**: Declarative, functional UI patterns (Model-Update-View)

---

## Color Palettes & Themes

### Color Profile Support

Modern terminals support multiple color depths. Design for graceful degradation:

| Profile | Colors | Usage |
|---------|--------|-------|
| **1-bit** | 2 (B&W) | Fallback only |
| **4-bit (ANSI 16)** | 16 | Minimum viable |
| **8-bit (ANSI 256)** | 256 | Standard target |
| **24-bit (True Color)** | 16.7M | Premium experience |

### Adaptive Color Strategy

```text
┌─────────────────────────────────────┐
│ Design Priority Pyramid             │
├─────────────────────────────────────┤
│ ▲ 24-bit: Rich gradients, branding │
│ │ 8-bit: Core palette, theming     │
│ │ 4-bit: Functional contrast       │
│ └ 1-bit: Structure only            │
└─────────────────────────────────────┘
```

### Color Palette Recommendations

#### Primary Palette (8-bit Safe)

**Functional Colors:**

- Success: `#5FB45F` (ANSI 71)
- Warning: `#F5C24C` (ANSI 221)
- Error: `#E06C75` (ANSI 167)
- Info: `#61AFEF` (ANSI 75)

**Neutral Colors:**

- Text Primary: `#E8E8E8` (ANSI 253)
- Text Secondary: `#A8A8A8` (ANSI 248)
- Background Dark: `#1E1E1E` (ANSI 234)
- Background Light: `#F5F5F5` (ANSI 255)

**Accent Colors (Charm-inspired):**

- Purple: `#7D56F4` (ANSI 99)
- Pink: `#FF77D8` (ANSI 212)
- Cyan: `#56C2FF` (ANSI 81)
- Lavender: `#A39FD6` (ANSI 146)

#### Secondary Palette (24-bit Enhanced)

**Rose Pine Inspired (Soft, Natural):**

- Base: `#191724` (background)
- Surface: `#1f1d2e` (elevated surfaces)
- Overlay: `#26233a` (hover states)
- Muted: `#6e6a86` (secondary text)
- Subtle: `#908caa` (borders)
- Text: `#e0def4` (primary text)
- Love: `#eb6f92` (accents, errors)
- Gold: `#f6c177` (warnings, highlights)
- Rose: `#ebbcba` (success)
- Pine: `#31748f` (info)
- Foam: `#9ccfd8` (links, actions)
- Iris: `#c4a7e7` (special elements)

### Theme Detection

Always detect and adapt to terminal background:

```go
// Example: Lip Gloss adaptive color
style := lipgloss.NewStyle().
    Foreground(lipgloss.AdaptiveColor{
        Light: "#000000",
        Dark:  "#FFFFFF",
    })
```

### Color Usage Guidelines

1. **Contrast Ratios**: Minimum 4.5:1 for text, 3:1 for UI elements (WCAG AA)
2. **Semantic Colors**: Use consistent colors for meanings (red=error, green=success)
3. **Hierarchy**: Brighter/bolder = higher importance
4. **Backgrounds**: Prefer terminal default; use sparingly for emphasis
5. **Gradients**: Only in 24-bit contexts; avoid in functional UI

---

## Typography & Fonts

### Font Requirements

**Primary:** Monospace fonts with **Nerd Fonts** patching for maximum compatibility

**Recommended Fonts:**

- JetBrains Mono Nerd Font
- Fira Code Nerd Font
- Hack Nerd Font
- Cascadia Code Nerd Font
- SF Mono Nerd Font (macOS)

### Nerd Fonts Integration

Nerd Fonts provide **10,390+ icons** from multiple sources:

| Icon Set | Usage | Example |
|----------|-------|---------|
| **Font Awesome** | General UI icons |  (check)  (times) |
| **Devicons** | File type indicators |  (go)  (python)  (rust) |
| **Octicons** | Git/GitHub |  (repo)  (branch)  (commit) |
| **Codicons** | VS Code style |  (settings)  (search)  (file) |
| **Material Design** | Modern UI |  (folder)  (file)  (link) |
| **Powerline** | Status bars |      |
| **Weather Icons** | Contextual |  (sun)  (cloud)  (rain) |

**Best Practices:**

- Use icons to **enhance**, not replace, text labels
- Fallback to ASCII when Nerd Fonts unavailable
- Test icon rendering across terminals

### Text Formatting

#### Emphasis Hierarchy

```text
┌────────────────────────────────────┐
│ LEVEL 1: BOLD + COLOR + SIZE      │ Headers
├────────────────────────────────────┤
│ Level 2: Bold + Color              │ Subheaders
├────────────────────────────────────┤
│ Level 3: Color Only                │ Labels
├────────────────────────────────────┤
│ Level 4: Regular Weight            │ Body text
└────────────────────────────────────┘
```

#### Formatting Options

| Style | ANSI Code | Usage |
|-------|-----------|-------|
| **Bold** | `\033[1m` | Emphasis, headers |
| *Italic* | `\033[3m` | Subtle emphasis, quotes |
| <u>Underline</u> | `\033[4m` | Links, interactive elements |
| ~~Strikethrough~~ | `\033[9m` | Deprecated, completed tasks |
| Dim | `\033[2m` | Disabled, secondary info |

### Box Drawing Characters

Essential for layout structure:

#### Single Line Box

```text
┌─────────────────┐
│ Single Border   │
├─────────────────┤
│ Section Content │
└─────────────────┘
```

#### Double Line Box

```text
╔═════════════════╗
║ Double Border   ║
╠═════════════════╣
║ Section Content ║
╚═════════════════╝
```

#### Rounded Box

```text
╭─────────────────╮
│ Rounded Border  │
├─────────────────┤
│ Section Content │
╰─────────────────╯
```

#### Heavy Box

```text
┏━━━━━━━━━━━━━━━━━┓
┃ Heavy Border    ┃
┣━━━━━━━━━━━━━━━━━┫
┃ Section Content ┃
┗━━━━━━━━━━━━━━━━━┛
```

**Unicode Ranges:**

- Box Drawing: `U+2500` to `U+257F`
- Block Elements: `U+2580` to `U+259F`
- Geometric Shapes: `U+25A0` to `U+25FF`

### ASCII Art Guidelines

#### When to Use

- ✅ Logos (small, memorable)
- ✅ Banners (version info, welcome)
- ✅ Separators (section dividers)
- ❌ Large images (screen space)
- ❌ Essential info (accessibility)

#### Styles

**Minimalist:**

```text
┌─┐
│D│otfiles
└─┘
```

**Block:**

```text
██████╗  ██████╗ ████████╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝
██║  ██║██║   ██║   ██║   █████╗
██║  ██║██║   ██║   ██║   ██╔══╝
██████╔╝╚██████╔╝   ██║   ██║
╚═════╝  ╚═════╝    ╚═╝   ╚═╝
```

**Isometric:**

```text
   ___
  /   \
 /  D  \
/       \
\   F   /
 \_____/
```

**Best Practices:**

- Maximum 80 characters wide (portability)
- Avoid reliance on specific fonts
- Test in multiple terminals
- Provide `--no-ascii` flag option

---

## Layout Patterns

### Screen Organization

```text
┌─────────────────────────────────────┐
│ Header / Title / Branding        │ ← Top: Identity
├─────────────────────────────────────┤
│                                     │
│ Primary Content Area                │ ← Center: Focus
│                                     │
├─────────────────────────────────────┤
│ Footer / Status / Help           │ ← Bottom: Context
└─────────────────────────────────────┘
```

### Spacing & Rhythm

**Vertical Spacing:**

- Small gap: 1 line (related elements)
- Medium gap: 2 lines (sections)
- Large gap: 3+ lines (major divisions)

**Horizontal Spacing:**

- Padding: 2-4 spaces from edges
- Margins: 1-2 spaces between columns
- Indentation: 2-4 spaces per level

### Layout Modes

#### Full-Screen Application

```text
╔═══════════════════════════════════╗
║ App Title                   v1.0 ║
╠═══════════════════════════════════╣
║                                   ║
║   [Primary UI Components]         ║
║                                   ║
║                                   ║
╠═══════════════════════════════════╣
║ Status: Ready  │  ?=Help  │ ^C=Exit ║
╚═══════════════════════════════════╝
```

#### Inline / Embedded

```text
$ command --interactive
┌─────────────────────┐
│ Quick Prompt        │
│ › option 1         │
│   option 2         │
└─────────────────────┘
Result: option 1 selected
```

#### Mixed Mode (Recommended)

```text
$ app status

╭─────── Status Report ───────╮
│ Service: Running ✓          │
│ Uptime: 3d 14h 22m          │
╰─────────────────────────────╯

Next steps:
  • Run app deploy
  • Check app logs
```

### Component Alignment

**Left-Aligned (Default):**

```text
Options:
  --help      Show help
  --version   Show version
```

**Center-Aligned (Titles, Messages):**

```text
┌─────────────────────┐
│                     │
│   Success! ✓        │
│                     │
└─────────────────────┘
```

**Right-Aligned (Metadata, Status):**

```text
Task: Build project            [DONE]
Task: Run tests                [DONE]
Task: Deploy                [RUNNING]
```

### Tables

**Simple:**

```text
Name        Status    Time
app-1       Running   2m
app-2       Stopped   -
app-3       Running   1h
```

**Bordered:**

```text
┌─────────┬─────────┬──────┐
│ Name    │ Status  │ Time │
├─────────┼─────────┼──────┤
│ app-1   │ Running │ 2m   │
│ app-2   │ Stopped │ -    │
│ app-3   │ Running │ 1h   │
└─────────┴─────────┴──────┘
```

**Minimal:**

```text
Name      Status    Time
────      ──────    ────
app-1     Running   2m
app-2     Stopped   -
app-3     Running   1h
```

---

## Animation & Motion

### Spinner Patterns

Spinners indicate ongoing operations. Choose based on context:

#### Minimal (Fast feedback)

```text
⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏
```

Interval: 80ms

#### Dots (Universal)

```text
⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷
```

Interval: 80ms

#### Arrow (Directional)

```text
← ↖ ↑ ↗ → ↘ ↓ ↙
```

Interval: 100ms

#### Growing (Progress-like)

```text
▁ ▃ ▄ ▅ ▆ ▇ █ ▇ ▆ ▅ ▄ ▃
```

Interval: 120ms

#### Aesthetic (Charm-style)

```text
◐ ◓ ◑ ◒
```

Interval: 150ms

**Selection Criteria:**

- **CPU-intensive**: Faster spinners (60-80ms)
- **Network ops**: Moderate spinners (100-120ms)
- **Long waits**: Slower, aesthetic spinners (150ms+)

### Progress Bars

#### Indeterminate

```text
[=====>                    ] Processing...
```

#### Determinate

```text
[====================] 100% Complete
```

#### Multi-Stage

```text
1. Setup     [████████████████] ✓
2. Build     [███████▒▒▒▒▒▒▒▒▒] 45%
3. Deploy    [▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒] Pending
```

### Transitions

**Instant (Default):**

- Screen changes
- Updates to static content

**Fast (< 100ms):**

- Input feedback
- Selection changes
- Hover states (if supported)

**Slow (100-300ms):**

- Deliberate state changes
- Multi-step processes
- Success/error reveals

### Best Practices

1. **Always show feedback** for operations > 0.5s
2. **Update frequently** (60-120ms) for perceived responsiveness
3. **Clear on completion** - replace spinner with result
4. **Avoid excessive animation** - distracting, accessibility concern
5. **Provide text fallback** - not just animated characters

---

## Components

### Common UI Widgets

#### Input Fields

**Text Input:**

```text
┌─────────────────────────────┐
│ Enter username:             │
│ › user123█                  │
└─────────────────────────────┘
```

**Text Area:**

```text
┌─────────────────────────────┐
│ Enter message:              │
│ ┌─────────────────────────┐ │
│ │ Hello, this is a        │ │
│ │ multi-line input█       │ │
│ │                         │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

#### Selection Widgets

**List (Single Select):**

```text
Choose an option:
  ○ Option 1
  ● Option 2  ← Selected
  ○ Option 3
```

**Multi-Select:**

```text
Select features:
  ☑ Feature A
  ☐ Feature B
  ☑ Feature C
```

**Dropdown/Combobox:**

```text
Region: [us-east-1    ▾]

┌────────────────────┐
│ us-east-1    ✓     │
│ us-west-1          │
│ eu-central-1       │
└────────────────────┘
```

#### Confirmation Dialogs

**Simple Confirm:**

```text
╭────────────────────────╮
│ Delete this file?      │
│                        │
│  [Yes]    [No]         │
╰────────────────────────╯
```

**Dangerous Action:**

```text
╭─────────────────────────────╮
│ ⚠ Warning: Destructive     │
│                             │
│ This cannot be undone.      │
│                             │
│ Type 'confirm' to proceed:  │
│ › _                         │
╰─────────────────────────────╯
```

#### File Picker

```text
┌─ Select File ──────────────┐
│ 📁 home/                   │
│   📁 projects/             │
│     📄 README.md       ← │
│     📄 LICENSE             │
│     📁 src/                │
└────────────────────────────┘
```

#### Status Indicators

**Inline:**

```text
✓ Task completed
✗ Task failed
⚠ Warning occurred
ℹ Information available
```

**Badges:**

```text
Service [RUNNING]
Build   [FAILED]
Deploy  [PENDING]
```

### Interactive Patterns

#### Key Bindings

**Standard Conventions:**

```text
Navigation:  ↑/↓, j/k, Tab
Selection:   Enter, Space
Cancel:      Esc, q, Ctrl+C
Help:        ?, h, F1
```

**Display Help:**

```text
╭─ Keyboard Shortcuts ──────╮
│ ↑/↓  Navigate             │
│ ⏎    Select               │
│ Esc  Cancel               │
│ ?    This help            │
╰───────────────────────────╯
```

#### Mouse Support (Optional)

- Click to select
- Scroll to navigate
- Drag to reorder (advanced)

**Accessibility Note:** Always provide keyboard alternatives.

---

## Best Practices

### Accessibility

1. **Contrast**: Maintain WCAG AA minimum (4.5:1 text, 3:1 UI)
2. **No Color-Only Info**: Use icons, text, or patterns alongside color
3. **Screen Reader Support**: Provide text equivalents for visual elements
4. **Keyboard Navigation**: All functions accessible without mouse
5. **Respect Terminal Settings**: Honor user's color scheme, font size

### Performance

1. **Minimize Redraws**: Update only changed regions
2. **Throttle Updates**: Cap at 60fps (16ms intervals)
3. **Lazy Loading**: Render visible content first
4. **Efficient Diffing**: Only send changed bytes to terminal
5. **Graceful Degradation**: Reduce features on slow terminals

### Responsive Design

**Narrow (< 80 columns):**

- Single column layouts
- Abbreviated labels
- Minimal borders

**Standard (80-120 columns):**

- Two-column layouts
- Full labels
- Standard spacing

**Wide (> 120 columns):**

- Multi-column layouts
- Expanded help text
- Generous whitespace

### Error Handling

**Inline Errors:**

```text
❯ Enter email: invalid
  ✗ Must be valid email address
```

**Error Panels:**

```text
╭─ Error ──────────────────────╮
│ ✗ Failed to connect          │
│                              │
│ Could not reach server       │
│ at api.example.com:443       │
│                              │
│ Suggestions:                 │
│  • Check internet connection │
│  • Verify API endpoint       │
│  • Try again later           │
╰──────────────────────────────╯
```

### Localization

1. **Avoid Hardcoded Widths**: Text length varies by language
2. **RTL Support**: Consider right-to-left languages (Arabic, Hebrew)
3. **Unicode Everywhere**: Use UTF-8 encoding
4. **Date/Time Formats**: Use locale-aware formatting
5. **Number Formats**: Respect decimal separators (. vs ,)

### Testing

Test across:

- ✓ Multiple terminal emulators (iTerm2, Alacritty, Windows Terminal, etc.)
- ✓ Different color depths (4-bit, 8-bit, 24-bit)
- ✓ Light and dark themes
- ✓ Various window sizes
- ✓ SSH sessions (latency simulation)

---

## Examples

### Example 1: Modern Application Header

```text
╭───────────────────────────────────────────────────────╮
│                                                       │
│   ████████╗██╗   ██╗██╗                              │
│   ╚══██╔══╝██║   ██║██║                              │
│      ██║   ██║   ██║██║                              │
│      ██║   ╚██████╔╝██║                              │
│      ╚═╝    ╚═════╝ ╚═╝     v2.1.0                   │
│                                                       │
│   A powerful terminal user interface framework       │
│                                                       │
╰───────────────────────────────────────────────────────╯
```

### Example 2: Status Dashboard

```text
╭─ System Status ────────────────────────────────────╮
│                                                    │
│  Service       Status      Uptime      Memory     │
│  ───────       ──────      ──────      ──────     │
│   api         ● Running    3d 14h      1.2 GB    │
│   worker      ● Running    3d 14h      856 MB    │
│   cache       ● Running    7d 02h      512 MB    │
│   db          ⚠ Warning    7d 02h      3.8 GB    │
│                                                    │
│  Overall: 4/4 services running                     │
│                                                    │
╰────────────────────────────────────────────────────╯

 Press 'r' to refresh  │  'q' to quit  │  '?' for help
```

### Example 3: Interactive Form

```text
╭─ Configuration Wizard ─────────────────────────────╮
│                                                    │
│  Step 2 of 4: Database Setup                       │
│                                                    │
│  Database Type:                                    │
│    ○ MySQL                                         │
│    ● PostgreSQL  ✓                                 │
│    ○ SQLite                                        │
│                                                    │
│  Host: [localhost              ]                   │
│  Port: [5432                   ]                   │
│  User: [admin█                 ]                   │
│                                                    │
│  ┌──────────────────────────────────────┐          │
│  │ [Back]        [Skip]        [Next] │          │
│  └──────────────────────────────────────┘          │
│                                                    │
╰────────────────────────────────────────────────────╯
```

### Example 4: Progress Tracking

```text
Building your project...

✓ 1. Dependency resolution         2.3s
✓ 2. Source compilation            8.1s
⣾ 3. Running tests                 [████████░░░░] 67%
  4. Generating documentation       Pending
  5. Creating artifacts             Pending

Overall Progress: [███████░░░░░░░░░] 45%

Estimated time remaining: ~12s
```

### Example 5: Minimal CLI Output (Charm Style)

```text
$ gum style \
  --foreground 212 \
  --border-foreground 212 \
  --border double \
  --align center \
  --width 50 \
  --margin "1 2" \
  --padding "2 4" \
  'Hello, World!' \
  'Welcome to TUI styling.'

╔════════════════════════════════════════════════╗
║                                                ║
║                                                ║
║                Hello, World!                   ║
║         Welcome to TUI styling.                ║
║                                                ║
║                                                ║
╚════════════════════════════════════════════════╝
```

### Example 6: README Section (Glamorous CLI)

```text
┌─ Features ──────────────────────────────────────────┐
│                                                     │
│  ✨ Beautiful UI      Terminal interfaces that      │
│                      don't hurt your eyes           │
│                                                     │
│  🚀 Fast & Light      Minimal dependencies,         │
│                      maximum performance            │
│                                                     │
│  🎨 Customizable      Style it your way with        │
│                      themes and configs             │
│                                                     │
│  🔧 Developer First   Simple API, great docs,       │
│                      TypeScript support             │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Tool Integration

### Recommended Libraries & Frameworks

**Go:**

- [Bubble Tea](https://github.com/charmbracelet/bubbletea) - TUI framework
- [Lip Gloss](https://github.com/charmbracelet/lipgloss) - Styling
- [Bubbles](https://github.com/charmbracelet/bubbles) - Components
- [Glamour](https://github.com/charmbracelet/glamour) - Markdown rendering
- [Gum](https://github.com/charmbracelet/gum) - Shell script styling

**JavaScript/TypeScript:**

- [Ink](https://github.com/vadimdemedes/ink) - React for CLI
- [Blessed](https://github.com/chjj/blessed) - Full-featured TUI
- [Chalk](https://github.com/chalk/chalk) - Terminal colors
- [Ora](https://github.com/sindresorhus/ora) - Spinners
- [CLI Spinners](https://github.com/sindresorhus/cli-spinners) - Spinner collection

**Python:**

- [Rich](https://github.com/Textualize/rich) - Rich text and TUI
- [Textual](https://github.com/Textualize/textual) - TUI framework
- [Prompt Toolkit](https://github.com/prompt-toolkit/python-prompt-toolkit) - Interactive CLI

**Rust:**

- [Ratatui](https://github.com/ratatui-org/ratatui) - TUI framework
- [Crossterm](https://github.com/crossterm-rs/crossterm) - Terminal manipulation
- [Colored](https://github.com/mackwic/colored) - Terminal colors

---

## Checklist: Launching a New TUI Project

- [ ] Choose appropriate color profile support (4-bit minimum, 8-bit target, 24-bit enhanced)
- [ ] Select & document primary color palette (functional + accent colors)
- [ ] Implement theme detection (light/dark terminal background)
- [ ] Choose Nerd Font compatible font as recommended font
- [ ] Design box drawing style (single, double, rounded, or heavy)
- [ ] Create ASCII logo/banner (optional but fun)
- [ ] Define component library (input, selection, confirmation, etc.)
- [ ] Establish animation patterns (spinner styles, progress bars)
- [ ] Design keyboard shortcuts (navigation, selection, help)
- [ ] Create help documentation (? key, --help flag)
- [ ] Implement error handling patterns (inline, panels)
- [ ] Test across terminal emulators (iTerm2, Alacritty, Windows Terminal)
- [ ] Test across color depths (4-bit, 8-bit, 24-bit)
- [ ] Test across window sizes (narrow < 80, standard 80-120, wide > 120)
- [ ] Verify accessibility (contrast, keyboard navigation, screen reader)
- [ ] Document customization options (themes, colors, icons)
- [ ] Provide `--no-color` and `--no-ascii` flags
- [ ] Add performance benchmarks (render speed, memory usage)

---

## Resources

### Documentation

- [Charm Documentation](https://charm.sh)
- [ANSI Escape Codes Reference](https://en.wikipedia.org/wiki/ANSI_escape_code)
- [Unicode Box Drawing](https://en.wikipedia.org/wiki/Box-drawing_character)
- [Nerd Fonts Cheat Sheet](https://www.nerdfonts.com/cheat-sheet)

### Inspiration

- [Charm GitHub](https://github.com/charmbracelet)
- [Rose Pine Theme](https://rosepinetheme.com)
- [Awesome TUI](https://github.com/rothgar/awesome-tuis)
- [CLI Guidelines](https://clig.dev)

### Testing Tools

- [asciinema](https://asciinema.org) - Record terminal sessions
- [VHS](https://github.com/charmbracelet/vhs) - Generate terminal GIFs
- [tmux](https://github.com/tmux/tmux) - Test in split panes

---

## License & Attribution

This guide synthesizes research from:

- Charm (Bubble Tea, Lip Gloss, Gum, Glamour, Bubbles)
- Claude Code (Anthropic)
- Rose Pine Theme
- Nerd Fonts Project
- CLI Spinners Collection
- Unicode Consortium

**License:** MIT (adapt freely, attribute generously)

**Version:** 1.0.0 (2025)

---

Made with ✨ and terminal love