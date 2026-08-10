function __gcp_iam_permission_search
    # Parse arguments
    argparse h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp iam permission search <QUERY>"
        echo
        echo "Search for IAM permissions by name"
        echo
        echo "Searches permission names for matches. The query is case-sensitive"
        echo "and uses SQL LIKE matching (supports wildcards)."
        echo
        echo "Arguments:"
        echo "  QUERY    Search query (required)"
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  gcp iam permission search storage.objects"
        echo "  gcp iam permission search compute.instances"
        echo "  gcp iam permission search iam.roles"
        echo
        echo "Note:"
        echo "  Data is read from the local IAM database. Run 'gcp iam update' to refresh."
        return 0
    end

    set -l query $argv[1]

    if test -z "$query"
        echo "Error: Search query required" >&2
        echo "Run 'gcp iam permission search --help' for usage information" >&2
        return 1
    end

    set -l db_path (__gcp_iam_db_path)
    or return 1

    set -l count (sqlite3 $db_path "SELECT COUNT(DISTINCT permission) FROM permissions WHERE permission LIKE '%$query%';")

    if test "$count" -eq 0
        echo "No permissions found matching '$query'"
        return 0
    end

    echo "Found $count permissions matching '$query':"

    sqlite3 $db_path "SELECT DISTINCT permission FROM permissions WHERE permission LIKE '%$query%' ORDER BY permission;" | while read -l perm
        echo "  - $perm"
    end
end
