function __gcp_iam_role_show
    # Parse arguments
    argparse h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp iam role show <ROLE_NAME>"
        echo
        echo "Show detailed information about a specific IAM role"
        echo
        echo "Displays role name, title, description, stage, and all included permissions."
        echo
        echo "Arguments:"
        echo "  ROLE_NAME    IAM role name (required)"
        echo "               Format: roles/viewer, roles/storage.objectViewer, etc."
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  gcp iam role show roles/viewer"
        echo "  gcp iam role show roles/storage.objectViewer"
        echo "  gcp iam role show roles/compute.admin"
        echo
        echo "Note:"
        echo "  Data is read from the local IAM database. Run 'gcp iam update' to refresh."
        return 0
    end

    set -l role_name $argv[1]

    if test -z "$role_name"
        echo "Error: Role name required" >&2
        echo "Run 'gcp iam role show --help' for usage information" >&2
        return 1
    end

    set -l db_path (__gcp_iam_db_path)
    or return 1

    # Get role details
    set -l role_data (sqlite3 $db_path "SELECT name, title, description, stage FROM roles WHERE name='$role_name';")

    if test -z "$role_data"
        echo "Error: Role '$role_name' not found" >&2
        return 1
    end

    # Parse role data
    set -l fields (string split '|' $role_data)
    set -l name $fields[1]
    set -l title $fields[2]
    set -l description $fields[3]
    set -l stage $fields[4]

    # Get permission count
    set -l perm_count (sqlite3 $db_path "SELECT COUNT(*) FROM permissions WHERE role='$role_name';")

    echo "Role: $name"
    echo "Title: $title"
    echo "Description: $description"
    echo "Stage: $stage"
    echo "Permissions ($perm_count):"
    sqlite3 $db_path "SELECT permission FROM permissions WHERE role='$role_name' ORDER BY permission;" | while read -l perm
        echo "  - $perm"
    end
end
