# Shell secrets: ~/.secrets/env (mode 600).
# ~/.secrets is the existing private directory (mode 700).
# Export is global, never universal, so values stay out of fish_variables.

function secret --description 'Read and update secrets in ~/.secrets/env'
    set -l export_flag 0
    set -l positionals
    set -l ended 0
    for arg in $argv
        if test $ended -eq 1
            set -a positionals $arg
            continue
        end
        switch $arg
            case --
                set ended 1
            case -h --help
                __secret_usage
                return 0
            case -e --export
                set export_flag 1
            case '-*'
                echo "secret: unknown option $arg" >&2
                __secret_usage
                return 2
            case '*'
                set -a positionals $arg
        end
    end

    if test (count $positionals) -eq 0
        __secret_usage
        return 2
    end
    set -l cmd $positionals[1]
    set -e positionals[1]

    switch $cmd
        case read
            __secret_cmd_read $export_flag $positionals
            return $status
        case update
            if test $export_flag -eq 1
                echo "secret: --export applies to read" >&2
                return 2
            end
            __secret_cmd_update $positionals
            return $status
        case '*'
            __secret_usage
            return 2
    end
end

function __secret_usage
    echo "Usage: secret read [--export] [NAME]" >&2
    echo "       secret update NAME [VALUE]" >&2
    echo "File: ~/.secrets/env" >&2
end

function __secret_lock
    if test -d $HOME/.secrets
        chmod 700 $HOME/.secrets 2>/dev/null
    end
    if test -f $HOME/.secrets/env
        chmod 600 $HOME/.secrets/env 2>/dev/null
    end
end

# Sets the caller's secret_key and secret_value. Those locals must already exist.
function __secret_take --no-scope-shadowing --argument-names line
    set -l raw (string replace -r -- '\r$' '' $line)
    set raw (string replace -r -- '^[[:space:]]+' '' $raw)
    if test -z "$raw"
        return 1
    end
    if string match -qr -- '^#' $raw
        return 1
    end
    set raw (string replace -r -- '^export[[:space:]]+' '' $raw)
    if not string match -qr -- '^[A-Za-z_][A-Za-z0-9_]*=' $raw
        return 1
    end
    set -l parsed_key (string replace -r -- '=.*$' '' $raw)
    set -l raw_value (string replace -r -- '^[A-Za-z_][A-Za-z0-9_]*=' '' $raw)
    set -l decoded $raw_value
    set -l n (string length -- $raw_value)
    if test $n -ge 2
        set -l first (string sub --length 1 -- $raw_value)
        set -l last (string sub --start -1 --length 1 -- $raw_value)
        if test "$first" = "'" -a "$last" = "'"
            set decoded (string sub --start 2 --end -1 -- $raw_value)
        else if test "$first" = '"' -a "$last" = '"'
            set -l body (string sub --start 2 --end -1 -- $raw_value)
            set -l out ""
            set -l i 1
            set n (string length -- $body)
            while test $i -le $n
                set -l ch (string sub --start $i --length 1 -- $body)
                if test "$ch" = "\\"
                    set i (math $i + 1)
                    if test $i -gt $n
                        set out "$out\\"
                        break
                    end
                    set -l nxt (string sub --start $i --length 1 -- $body)
                    switch $nxt
                        case n
                            set out "$out"\n
                        case t
                            set out "$out"\t
                        case '*'
                            set out "$out$nxt"
                    end
                else
                    set out "$out$ch"
                end
                set i (math $i + 1)
            end
            set decoded $out
        end
    end
    set secret_key $parsed_key
    set secret_value $decoded
    return 0
end

function __secret_ignorable --argument-names line
    set -l raw (string replace -r -- '\r$' '' $line)
    set raw (string replace -r -- '^[[:space:]]+' '' $raw)
    test -z "$raw"
    or string match -qr -- '^#' $raw
end

# Prints the one-line file encoding. Newlines stay escaped so the caller can
# capture this with command substitution.
function __secret_format_value --argument-names value
    if test (count $value) -eq 0
        echo
        return 0
    end
    # No extra "--" before $value: string match would treat it as a candidate.
    if string match -qr -- '^[A-Za-z0-9._@:/+=-]*$' $value
        printf '%s\n' $value
        return 0
    end
    set -l out ""
    # read -n 1 stops at a newline and returns an empty chunk for it.
    printf '%s' $value | while read -n 1 ch
        if test (string length -- $ch) -eq 0
            set out "$out\\n"
            continue
        end
        switch $ch
            case \\
                set out "$out\\\\"
            case '"'
                set out "$out\\\""
            case '$'
                set out "$out\\\$"
            case '`'
                set out "$out\\`"
            case \t
                set out "$out\\t"
            case '*'
                set out "$out$ch"
        end
    end
    printf '"%s"\n' $out
end

function __secret_cmd_read
    set -l export_flag $argv[1]
    set -e argv[1]
    if test (count $argv) -gt 1
        echo "secret: read takes at most one name" >&2
        __secret_usage
        return 2
    end

    set -l want ""
    if test (count $argv) -eq 1
        set want $argv[1]
        if not string match -qr -- '^[A-Za-z_][A-Za-z0-9_]*$' $want
            echo "secret: invalid name '$want'" >&2
            return 2
        end
    end

    __secret_lock
    set -l file $HOME/.secrets/env
    if not test -f $file
        if test -n "$want"
            echo "secret: $want is not in ~/.secrets/env" >&2
            return 1
        end
        return 0
    end

    set -l found 0
    set -l found_value ""
    while read -l line
        set -l secret_key ""
        set -l secret_value ""
        if not __secret_take $line
            if test -z "$want"
                if not __secret_ignorable $line
                    echo "secret: skipped a malformed line in ~/.secrets/env" >&2
                end
            end
            continue
        end
        if test -n "$want"
            if test "$secret_key" = "$want"
                set found 1
                set found_value $secret_value
            end
            continue
        end
        if test "$export_flag" = 1
            # Global on purpose. Universal would write the value into fish_variables.
            set --global --export -- $secret_key $secret_value
        else
            printf '%s\n' $secret_key
        end
    end < $file

    if test -z "$want"
        return 0
    end
    if test $found -eq 0
        echo "secret: $want is not in ~/.secrets/env" >&2
        return 1
    end
    if test "$export_flag" = 1
        set --global --export -- $want $found_value
    else
        printf '%s\n' $found_value
    end
    return 0
end

function __secret_cmd_update
    if test (count $argv) -lt 1
        echo "secret: update needs a name" >&2
        __secret_usage
        return 2
    end
    set -l name $argv[1]
    if not string match -qr -- '^[A-Za-z_][A-Za-z0-9_]*$' $name
        echo "secret: invalid name '$name'" >&2
        return 2
    end

    # Keep this function-scoped. `read -l` is block-local and would be discarded.
    set -l new_value ""
    if test (count $argv) -ge 2
        set new_value $argv[2]
        set -l i 3
        while test $i -le (count $argv)
            set new_value "$new_value $argv[$i]"
            set i (math $i + 1)
        end
    else if not isatty stdin
        read new_value
        or set new_value ""
    else
        printf 'Value for %s: ' $name >&2
        read -s new_value
        or return 1
        echo >&2
    end

    if not test -d $HOME/.secrets
        mkdir -p $HOME/.secrets
        or return 1
    end
    chmod 700 $HOME/.secrets
    or return 1

    set -l file $HOME/.secrets/env
    # Leading dot keeps blank lines intact: fish drops empty list elements.
    set -l stored
    if test -f $file
        while read -l line
            set -a stored ".$line"
        end < $file
    end

    set -l formatted (__secret_format_value $new_value | string collect)
    set -l out
    if not test -f $file
        set out \
            ".# Local secrets for fish. Mode 600. Outside the repo." \
            ".# secret read [NAME]" \
            ".# secret update NAME [VALUE]"
    end

    set -l replaced 0
    for item in $stored
        set -l line (string sub --start 2 -- $item)
        set -l secret_key ""
        set -l secret_value ""
        if __secret_take $line
            if test "$secret_key" = "$name"
                if test $replaced -eq 0
                    set -a out ".$name=$formatted"
                    set replaced 1
                end
                continue
            end
        end
        set -a out $item
    end
    if test $replaced -eq 0
        set -a out ".$name=$formatted"
    end

    __secret_write $out
    or return 1
    echo "updated $name in ~/.secrets/env" >&2
    return 0
end

function __secret_write
    set -l file $HOME/.secrets/env
    set -l tmp (mktemp $HOME/.secrets/.env.XXXXXX)
    or return 1
    chmod 600 $tmp
    or begin
        rm -f $tmp
        return 1
    end
    begin
        for item in $argv
            set -l line (string sub --start 2 -- $item)
            printf '%s\n' $line
        end
    end > $tmp
    or begin
        rm -f $tmp
        return 1
    end
    mv $tmp $file
    or begin
        rm -f $tmp
        return 1
    end
    chmod 600 $file
end
