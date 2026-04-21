# zsh env — sourced for ALL zsh invocations (interactive, non-interactive,
# scripts). Keep minimal: PATH only. Interactive config lives in .zshrc.
#
# The user's daily shell is fish (~/.config/fish/config.fish). This file
# exists primarily so non-interactive zsh invocations (e.g. Claude Code's
# Bash tool, cron, `ssh host cmd`) see the same global tool paths fish has.

# Homebrew keg-only tools that need explicit PATH entries:
#   - GNU Make 4.x (macOS ships GNU Make 3.81 in /usr/bin/make, which has
#     broken .ONESHELL: and fast-path-bypass-shell bugs).
#   - PostgreSQL 18 client tools (psql, dropdb, createdb).
path=(
    /opt/homebrew/opt/make/libexec/gnubin
    /opt/homebrew/opt/postgresql@18/bin
    /opt/homebrew/bin
    /opt/homebrew/sbin
    $HOME/.local/bin
    $HOME/go/bin
    $path
)
export PATH
