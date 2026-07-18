# CLAUDE.md

Dotfiles repo for macOS (Apple Silicon). Managed with GNU Make, deployed via symlinks.

## Structure

Each directory is a tool config symlinked into place by `make base` (or its own target).
The Makefile uses binary-path prerequisites for idempotent installs.

## Conventions

- Theme: Catppuccin Macchiato everywhere
- Shell: fish (vim mode)
- Secrets managed via `pass` and GPG — never commit plaintext secrets
- Makefile must stay compatible with macOS `/usr/bin/make` (GNU Make 3.81)
- Use `/bin/ln -fs` for symlinks (not GNU ln) to keep Makefile portable
- `gitconfig` is at repo root (not in a subdirectory) — symlinked to `~/.gitconfig`
- Fish is the primary shell; `pathenv` is the shared brew-first PATH for agents
- `bashenv` (via `BASH_ENV`) and `zshenv` both source `pathenv` for non-interactive bash/zsh
- Git pager uses `riff` (not less/delta) for syntax-highlighted diffs
