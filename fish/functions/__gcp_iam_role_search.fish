function __gcp_iam_role_search
    # Parse arguments
    argparse h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp iam role search <QUERY>"
        echo
        echo "Search for IAM roles by name or title"
        echo
        echo "Searches both role names and titles for matches. The query is"
        echo "case-sensitive and uses SQL LIKE matching (supports wildcards)."
        echo
        echo "Arguments:"
        echo "  QUERY    Search query (required)"
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  gcp iam role search storage"
        echo "  gcp iam role search compute"
        echo "  gcp iam role search viewer"
        echo
        echo "Note:"
        echo "  Data is read from the local IAM database. Run 'gcp iam update' to refresh."
        return 0
    end

    set -l query $argv[1]

    if test -z "$query"
        echo "Error: Search query required" >&2
        echo "Run 'gcp iam role search --help' for usage information" >&2
        return 1
    end

    set -l db_path (__gcp_iam_db_path)
    or return 1

    set -l count (sqlite3 $db_path "SELECT COUNT(*) FROM roles WHERE name LIKE '%$query%' OR title LIKE '%$query%';")

    if test "$count" -eq 0
        echo "No roles found matching '$query'"
        return 0
    end

    echo "Found $count roles matching '$query':"

    sqlite3 $db_path "SELECT name, title FROM roles WHERE name LIKE '%$query%' OR title LIKE '%$query%' ORDER BY name;" | while read -l line
        set -l fields (string split '|' $line)
        printf "  - %-45s %s\n" $fields[1] $fields[2]
    end
end
