# TODO - Dotfiles Improvements

## Configuration Organization

- [ ] Move `data/mcp.json.tmpl` to `dot_config/claude/` or another appropriate location

## Testing Infrastructure

- [ ] Migrate shell script tests to a real testing framework that can run automatically

## Shell & CLI Improvements

### High Priority

- [ ] Add Atuin - Magical shell history with full-text search and sync across machines
- [ ] Add Git Delta - Syntax-highlighted git diffs with side-by-side view
- [ ] Mise offers examples for how to boostrap github actions, using `mise generate bootstrap -l -w`
- [ ] Apply improvements made in Work dotfiles to personal

### Medium Priority

- [ ] Add fd - Better find command (faster, respects .gitignore)
- [ ] Add eza - Better ls with git integration and tree view
- [ ] Add useful oh-my-zsh plugins: sudo, extract, copypath, copybuffer
- [ ] Configure Starship to show command duration in prompt
- [ ] Both mise and chezmoi offer a way to generate an install.sh file, this is better for security, than downloading and running .sh files
- [ ] Automatically manage and handle https://mise.jdx.dev/direnv.html

### Nice to Have

- [ ] Add tldr - Simpler man pages with practical examples
- [ ] Add ripgrep (rg) - Better grep (faster, respects .gitignore)
- [ ] Add session manager - tmux or zellij for terminal multiplexing
- [ ] Add direnv - Auto-load project environments when entering directories