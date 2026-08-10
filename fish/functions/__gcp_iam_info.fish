function __gcp_iam_info
    # Parse arguments
    argparse h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp iam info"
        echo
        echo "Show IAM database statistics and information"
        echo
        echo "Displays the number of roles and permissions in the local"
        echo "IAM database, along with the database file path."
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  gcp iam info"
        echo
        echo "Note:"
        echo "  Run 'gcp iam update' first if the database doesn't exist"
        return 0
    end

    set -l db_path (__gcp_iam_db_path)
    or return 1

    set -l roles_count (sqlite3 $db_path "SELECT COUNT(*) FROM roles;")
    set -l perms_count (sqlite3 $db_path "SELECT COUNT(DISTINCT permission) FROM permissions;")
    echo "GCP IAM Configuration:"
    printf "  Roles:        %s\n" $roles_count
    printf "  Permissions:  %s\n" $perms_count
    printf "  DatabasePath: %s\n" $db_path
end
