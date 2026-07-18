# zsh env — sourced for ALL zsh invocations (interactive, non-interactive,
# scripts). Keep minimal: PATH + agent handoff. Interactive config lives in .zshrc.
#
# The user's daily shell is fish (~/.config/fish/config.fish). This file
# exists so non-interactive zsh (agent tools, cron, `ssh host cmd`) sees the
# same brew-first tool PATH as fish and bash.

# Shared brew-first PATH (same file bash loads via BASH_ENV → bashenv → pathenv).
# emulate sh so pathenv stays POSIX and single-source.
emulate sh -c '. "${HOME}/.pathenv"'

# Non-interactive bash children (Grok/Claude tools) re-apply PATH via bashenv.
export BASH_ENV="${HOME}/.bashenv"
