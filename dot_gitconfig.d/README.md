# Git Configuration Directory

This directory contains modular git configuration files that get included by `~/.gitconfig`.

## Setup

**Automatic!** When you run `chezmoi apply`, a script automatically adds the include directive to your `~/.gitconfig`:

```ini
[include]
	path = ~/.gitconfig.d/default
```

The script preserves any existing content in your `~/.gitconfig`.

## Files

- **default** - Default git configuration (identity, signing, core settings)
- **work** *(future)* - Work-specific overrides
- **personal** *(future)* - Personal project overrides

## Usage

The `~/.gitconfig` file includes these configs, allowing you to:
- Keep base settings in `default`
- Add machine-specific settings directly in `~/.gitconfig`
- Override settings in later includes (last value wins)

Example `~/.gitconfig` structure:
```ini
# Machine-specific aliases and preferences
[alias]
	st = status
	co = checkout

# Include managed default config (takes priority over above)
[include]
	path = ~/.gitconfig.d/default

# Optional: work-specific overrides (takes priority over default)
[includeIf "gitdir:~/work/"]
	path = ~/.gitconfig.d/work
```
