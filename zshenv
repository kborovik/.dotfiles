# zsh env — sourced for ALL zsh invocations (interactive, non-interactive,
# scripts). Keep minimal: PATH only. Interactive config lives in .zshrc.
#
# The user's daily shell is fish (~/.config/fish/config.fish). This file
# exists primarily so non-interactive zsh invocations (e.g. Claude Code /
# agent Bash tools, cron, `ssh host cmd`) see the same global tool paths fish has.

# Homebrew + keg-only tools that need explicit PATH entries ahead of /usr/bin:
#   - GNU Make 4.x (macOS ships GNU Make 3.81 in /usr/bin/make, which has
#     broken .ONESHELL: and fast-path-bypass-shell bugs). Prefer `gmake` or
#     this gnubin `make`.
#   - PostgreSQL 18 client tools (psql, dropdb, createdb).
path=(
    /opt/homebrew/opt/make/libexec/gnubin
    /opt/homebrew/opt/postgresql@18/bin
    /opt/homebrew/bin
    /opt/homebrew/sbin
    $HOME/.local/bin
    $HOME/go/bin
    $HOME/.grok/bin
    $path
)
export PATH
