function fish_user_key_bindings
    bind -M insert ctrl-f accept-autosuggestion
    bind -M insert ctrl-r history-pager
    bind -M insert ctrl-p up-line
    bind -M insert ctrl-n down-line
    bind -M insert ctrl-backspace backward-kill-token
    bind ctrl-backspace backward-kill-token
end
