# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Installation

### Pretty Install (Recommended)

Enhanced installation with visual feedback using [gum](https://github.com/charmbracelet/gum):

```bash
bash <(curl -fsLS https://raw.githubusercontent.com/bxm156/dotfiles/main/install.sh)
```

### Safe Mode

Standard chezmoi installation without gum UI:

```bash
bash <(curl -fsLS https://raw.githubusercontent.com/bxm156/dotfiles/main/install.sh) --safe
```

### Traditional Install

Direct chezmoi installation:

```bash
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply bxm156
```

### Custom Bootstrap Path

Install gum to a custom location (persists after installation):

```bash
bash <(curl -fsLS https://raw.githubusercontent.com/bxm156/dotfiles/main/install.sh) --bootstrap ~/.local/bin
```

## Development

See [CLAUDE.md](CLAUDE.md) for AI agent instructions and [AGENTS.md](AGENTS.md) for detailed workflows.
