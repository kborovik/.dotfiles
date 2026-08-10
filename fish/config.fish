# Always — inherited by Grok / Claude / non-interactive fish / child processes.
# Keep this outside `is-interactive` so agent tool shells get brew-first PATH.
# Bash children: BASH_ENV → ~/.bashenv → ~/.pathenv
# Zsh children: always source ~/.zshenv → ~/.pathenv (no env var needed)
# Keep pathenv in sync with the fish_add_path block below.
set --global --export HOMEBREW_PREFIX /opt/homebrew
set --global --export PNPM_HOME ~/Library/pnpm
set --global --export BASH_ENV $HOME/.bashenv

if test -x $HOMEBREW_PREFIX/bin/brew
    $HOMEBREW_PREFIX/bin/brew shellenv | source
end

# --move: put these ahead of /usr/bin even if already on PATH.
# Order matches pathenv (first entry = highest priority).
# PNPM: official layout uses $PNPM_HOME; some tools also install into $PNPM_HOME/bin.
fish_add_path --global --move --path \
    ~/.claude/local \
    ~/.grok/bin \
    ~/go/bin \
    ~/.cargo/bin \
    ~/.local/bin \
    ~/.opencode/bin \
    ~/.bun/bin \
    ~/.npm-global/bin \
    $HOMEBREW_PREFIX/opt/make/libexec/gnubin \
    $HOMEBREW_PREFIX/opt/postgresql@18/bin \
    $PNPM_HOME \
    $PNPM_HOME/bin

set --global --export EDITOR vim
set --global --export VISUAL vim
set --global --export PAGER "less -R -F -i"
set --global --export GLAMOUR_STYLE ~/.dotfiles/glamour/glamour-custom.json
set --global --export OPENCODE_DISABLE_CLAUDE_CODE_SKILLS 1

if status is-interactive

    set --global __fish_git_prompt_show_informative_status true
    set --global __fish_git_prompt_showcolorhints true
    set --global __fish_git_prompt_showstashstate true
    set --global __fish_git_prompt_showuntrackedfiles true

    set --global __fish_git_prompt_char_stateseparator ' '
    set --global __fish_git_prompt_char_untrackedfiles '^'
    set --global __fish_git_prompt_char_dirtystate '!'
    set --global __fish_git_prompt_char_stagedstate '+'
    set --global __fish_git_prompt_char_invalidstate '#'
    set --global __fish_git_prompt_char_stashstate '&'

    set --global __fish_git_prompt_color_branch 8bd5ca
    set --global __fish_git_prompt_color_untrackedfiles c6a0f6
    set --global __fish_git_prompt_color_upstream 8aadf4
    set --global __fish_git_prompt_color_stashstate eed49f
    set --global __fish_git_prompt_color_cleanstate a6da95
    set --global __fish_git_prompt_color_merging c6a0f6

    # Catppuccin Macchiato palette for `glo`/`gloa` git log format
    set --global __fish_git_log_color_hash b7bdf8 # Lavender
    set --global __fish_git_log_color_decorate eed49f # Yellow
    set --global __fish_git_log_color_date b8c0e0 # Subtext1
    set --global __fish_git_log_color_author 7dc4e4 # Sapphire
    set --global __fish_git_log_color_subject cad3f5 # Text

    # Abbreviations (auto-expanded on Space/Enter for interactive clarity & completion)
    abbr -a gaa 'git add --all'
    abbr -a gc 'git commit'
    abbr -a gd 'git difftool'
    abbr -a gs 'git difftool --staged'
    abbr -a gl 'git fetch --prune --prune-tags --all --tags'
    abbr -a gk 'git pull --prune --all --tags'
    abbr -a glo "git log --pretty=format:'%C(#$__fish_git_log_color_hash)%h %C(#$__fish_git_log_color_decorate)%d%Creset %C(#$__fish_git_log_color_date)(%cr)%Creset %C(#$__fish_git_log_color_author)%an %Creset %C(#$__fish_git_log_color_subject)%s'"
    abbr -a gloa "git log --graph --all --pretty=format:'%C(#$__fish_git_log_color_hash)%h %C(#$__fish_git_log_color_decorate)%d%Creset %C(#$__fish_git_log_color_date)(%cr)%Creset %C(#$__fish_git_log_color_author)%an %Creset %C(#$__fish_git_log_color_subject)%s'"
    abbr -a gp 'git push'
    abbr -a gst 'git status'

    abbr -a la 'ls -ha'
    abbr -a ll 'ls -hlF'
    abbr -a tree 'tree -C'

    if type -q -f shred
        abbr -a shred 'shred -ufv'
    end

    if test (uname) = Darwin
        if test -x $HOMEBREW_PREFIX/bin/gln
            function ln --description 'GNU ln replacement'
                $HOMEBREW_PREFIX/bin/gln $argv
            end
        end

        abbr -a top 'top -stats command,cpu,time,mem,state,user'
    end

end
