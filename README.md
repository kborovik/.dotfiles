# Forgotten Art of Makefile

Personal macOS development environment managed with GNU Make 3.81.

## Requirements

- macOS (Apple Silicon)
- `/usr/bin/make` (GNU Make 3.81, ships with macOS)

## Quick Start

```shell
cd ~/.dotfiles
make init     # Install Homebrew
make base     # Install base tools
```

## Targets

| Target        | Description                                                  |
| ------------- | ------------------------------------------------------------ |
| `make init`   | Install Homebrew                                             |
| `make base`   | Fish, Git, Vim, GPG, gitui, coreutils, gnu-sed, jq, pass, gh |
| `make zed`    | Zed editor with Vim mode and Claude integration              |
| `make claude` | Claude Code CLI with custom GitHub skills                    |
| `make pgsql`  | PostgreSQL 18 with pgcli and performance tuning              |
| `make ssh`    | SSH config and keys from pass                                |

## Structure

```
.dotfiles/
├── Makefile        # Build system (macOS Make 3.81)
├── fish/           # Fish shell config
├── vim/            # Vim config and plugins
├── zed/            # Zed editor config
├── claude/         # Claude Code settings and skills
├── gitui/          # gitui theme and keybindings
├── gnupg/          # GPG config
├── ssh/            # SSH config
├── pgsql/          # PostgreSQL tuning and pgcli config
├── bat/            # bat config and theme
├── glamour/        # Glamour markdown rendering
└── gitconfig       # Git global config
```

## Theme

[Catppuccin Macchiato](https://github.com/catppuccin/catppuccin) across all tools.

## Design

- **Idempotent** - Each tool checks its binary path before installing
- **Modular** - Install only what you need with individual targets
- **Compatible** - Uses default macOS `/usr/bin/make` (GNU Make 3.81)
- **Symlink-based** - Configs stay in the repo, symlinked to standard locations
