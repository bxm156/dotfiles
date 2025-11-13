# Prime Config ASCII Art Assets

Colorful ASCII art banners for terminal display.

## Files

### `prime-config-banner.sh`

Full banner with box border and stars. Perfect for login screens or welcome messages.

**Usage:**

```bash
# Display directly
bash assets/prime-config-banner.sh

# Or source it
source assets/prime-config-banner.sh

# Add to your .zshrc or .bashrc
cat assets/prime-config-banner.sh >> ~/.zshrc
```

### `prime-config-banner-simple.sh`

Simplified banner without box border. More compact, great for quick display.

**Usage:**

```bash
# Display directly
bash assets/prime-config-banner-simple.sh

# Or source it
source assets/prime-config-banner-simple.sh
```

## Color Scheme

- **Purple (Magenta)** - PRIME text
- **Cyan** - CONFIG text
- **Yellow** - Tagline
- **Bright White** - Large stars (✦)
- **Dim** - Small stars (·) and box border

## Examples

### Add to shell startup

```bash
# Add to ~/.zshrc or ~/.bashrc
if [ -f "$HOME/.local/share/chezmoi/assets/prime-config-banner-simple.sh" ]; then
    source "$HOME/.local/share/chezmoi/assets/prime-config-banner-simple.sh"
fi
```

### Add to SSH login

```bash
# Add to ~/.profile or /etc/motd (as root)
bash /path/to/assets/prime-config-banner.sh
```

### Create an alias

```bash
# Add to your aliases
alias banner='bash ~/.local/share/chezmoi/assets/prime-config-banner.sh'
alias logo='bash ~/.local/share/chezmoi/assets/prime-config-banner-simple.sh'
```

## ANSI Color Codes Used

- `[1;35m` - Bold Magenta (Purple)
- `[1;36m` - Bold Cyan
- `[1;33m` - Bold Yellow
- `[1;97m` - Bright White
- `[2m` - Dim
- `[0m` - Reset