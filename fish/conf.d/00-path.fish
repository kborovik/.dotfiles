# PATH, in three layers. Always runs — inherited by Grok / Claude /
# non-interactive fish / child processes. conf.d runs before config.fish,
# and 00- sorts first, so every later file sees the final PATH.
# Bash children: BASH_ENV → ~/.bashenv → ~/.pathenv (same layers).
# Zsh children: always source ~/.zshenv → ~/.pathenv (no env var needed)
set --global --export HOMEBREW_PREFIX /opt/homebrew
set --global --export PNPM_HOME ~/Library/pnpm
set --global --export BASH_ENV $HOME/.bashenv

# 1. Base: Homebrew bin and sbin.
if test -x $HOMEBREW_PREFIX/bin/brew
    $HOMEBREW_PREFIX/bin/brew shellenv fish | source
end

# 2. Tools: ~/.dotfiles/paths. --move puts them ahead of brew and /usr/bin.
# --global only: a universal fish_user_paths would outlive this file.
fish_add_path --global --move --path \
    (string match --regex --invert '^\s*(#|$)' < ~/.dotfiles/paths | string replace --regex '^~' $HOME)

# 3. Per-project overrides: fnm switches Node on cd from .nvmrc.
# pathenv keeps $FNM_MULTISHELL_PATH/bin first for bash and zsh children.
# Quiet outside interactive shells: "Using Node vX" would land in agent output.
if type -q fnm
    set --local fnm_log quiet
    status is-interactive; and set fnm_log info
    fnm env --use-on-cd --version-file-strategy=recursive --log-level=$fnm_log --shell fish | source
end
