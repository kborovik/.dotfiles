function __secret_completing_name
    set -l pos
    for t in (commandline -opc)
        switch $t
            case '-*'
                continue
            case '*'
                set -a pos $t
        end
    end
    test (count $pos) -eq 2
end

function __secret_complete_names
    test -r $HOME/.secrets/env
    or return 0
    while read -l line
        set -l raw (string replace -r -- '^[[:space:]]+' '' $line)
        set raw (string replace -r -- '^export[[:space:]]+' '' $raw)
        if string match -qr -- '^[A-Za-z_][A-Za-z0-9_]*=' $raw
            string replace -r -- '=.*$' '' $raw
        end
    end < $HOME/.secrets/env
end

complete -c secret -f
complete -c secret -n '__fish_use_subcommand' -a read -d 'Print a secret, or list names'
complete -c secret -n '__fish_use_subcommand' -a update -d 'Set a secret in ~/.secrets/env'
complete -c secret -n '__fish_seen_subcommand_from read' -s e -l export -d 'Export instead of printing'
complete -c secret -n '__secret_completing_name' -a '(__secret_complete_names)' -d Secret
