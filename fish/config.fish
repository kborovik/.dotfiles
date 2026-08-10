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

    # Wrappers (functions so args append and non-interactive agents can call them too
    # if this block is ever moved outside is-interactive)
    function gaa --description 'git add --all'
        git add --all $argv
    end
    function gc --description 'git commit'
        git commit $argv
    end
    function gd --description 'git difftool'
        git difftool $argv
    end
    function gs --description 'git difftool --staged'
        git difftool --staged $argv
    end
    function gl --description 'git fetch --prune --prune-tags --all --tags'
        git fetch --prune --prune-tags --all --tags $argv
    end
    function gk --description 'git pull --prune --all --tags'
        git pull --prune --all --tags $argv
    end
    function glo --description 'git log (pretty, colored)'
        git log --pretty=format:"%C(#$__fish_git_log_color_hash)%h %C(#$__fish_git_log_color_decorate)%d%Creset %C(#$__fish_git_log_color_date)(%cr)%Creset %C(#$__fish_git_log_color_author)%an %Creset %C(#$__fish_git_log_color_subject)%s" $argv
    end
    function gloa --description 'git log --graph --all (pretty, colored)'
        git log --graph --all --pretty=format:"%C(#$__fish_git_log_color_hash)%h %C(#$__fish_git_log_color_decorate)%d%Creset %C(#$__fish_git_log_color_date)(%cr)%Creset %C(#$__fish_git_log_color_author)%an %Creset %C(#$__fish_git_log_color_subject)%s" $argv
    end
    function gp --description 'git push'
        git push $argv
    end
    function gst --description 'git status'
        git status $argv
    end

    function la --description 'ls -ha'
        ls -ha $argv
    end
    function ll --description 'ls -hlF'
        ls -hlF $argv
    end
    function tree --description 'tree -C'
        command tree -C $argv
    end

    if type -q -f shred
        function shred --description 'shred -ufv'
            command shred -ufv $argv
        end
    end

    if test (uname) = Darwin
        if test -x $HOMEBREW_PREFIX/bin/gln
            function ln --description 'GNU ln replacement'
                $HOMEBREW_PREFIX/bin/gln $argv
            end
        end

        function top --description 'top with custom stats columns'
            command top -stats command,cpu,time,mem,state,user $argv
        end
    end

end
