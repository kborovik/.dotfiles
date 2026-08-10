function __gcp_group_members
    argparse h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp group members <GROUP_EMAIL>"
        echo
        echo "List members of a Cloud Identity group"
        echo
        echo "Arguments:"
        echo "  GROUP_EMAIL    Group email address (required)"
        echo "                 Format: group-name@domain.com"
        echo
        echo "Options:"
        echo "  -h, --help     Show this help message"
        echo
        echo "Examples:"
        echo "  gcp group members admins@example.com"
        echo "  gcp group members developers@example.com"
        echo
        echo "Note:"
        echo "  Requires appropriate Cloud Identity permissions"
        return 0
    end

    set -l group_email $argv[1]

    if test -z "$group_email"
        echo "Error: Group email required" >&2
        echo "Run 'gcp group members --help' for usage information" >&2
        return 1
    end

    # Check if jq is available
    if not command -v jq >/dev/null 2>&1
        echo "Error: jq is required but not installed" >&2
        echo "Install with: brew install jq" >&2
        return 1
    end

    # Get group members
    set -l temp_file (mktemp)
    if not gcloud identity groups memberships list --group-email="$group_email" --format=json 2>/dev/null >$temp_file
        echo "Error: Failed to list group members. Check group email and permissions." >&2
        rm -f $temp_file
        return 1
    end

    set -l member_count (jq '. | length' $temp_file)

    if test "$member_count" -eq 0
        echo "No members found in group: $group_email"
        rm -f $temp_file
        return 0
    end

    echo "Group: $group_email"
    echo "Members ($member_count):"
    echo

    # Parse and aggregate roles per unique member
    jq -r '.[] |
        (.preferredMemberKey.id) as $email |
        (.type // "USER") as $type |
        (.roles | map(.name // "MEMBER") | join(",")) as $roles |
        "\($email)|\($roles)|\($type)"
    ' $temp_file | sort -u | while read -l line
        set -l fields (string split '|' $line)
        set -l email $fields[1]
        set -l roles_str $fields[2]
        set -l member_type $fields[3]

        # Convert comma-separated roles to bracketed list
        set -l roles_list (string split ',' $roles_str | string join ', ')
        printf "  %-50s [%-30s] %s\n" "$email" "$roles_list" "$member_type"
    end

    rm -f $temp_file
end
