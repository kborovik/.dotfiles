function __gcp_iam_permission_show
    # Parse arguments
    argparse h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp iam permission show <PERMISSION>"
        echo
        echo "List all IAM roles that include a specific permission"
        echo
        echo "Displays the permission name and all roles that grant this permission."
        echo
        echo "Arguments:"
        echo "  PERMISSION    Permission name (required)"
        echo "                Format: storage.objects.get, compute.instances.list, etc."
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  gcp iam permission show storage.objects.get"
        echo "  gcp iam permission show compute.instances.list"
        echo "  gcp iam permission show iam.roles.create"
        echo
        echo "Note:"
        echo "  Data is read from the local IAM database. Run 'gcp iam update' to refresh."
        return 0
    end

    set -l permission $argv[1]

    if test -z "$permission"
        echo "Error: Permission name required" >&2
        echo "Run 'gcp iam permission show --help' for usage information" >&2
        return 1
    end

    set -l db_path (__gcp_iam_db_path)
    or return 1

    set -l count (sqlite3 $db_path "
        SELECT COUNT(DISTINCT r.name)
        FROM roles r
        INNER JOIN permissions p ON r.name = p.role
        WHERE p.permission = '$permission';
    ")

    echo "Permission: $permission"

    if test "$count" -eq 0
        echo "No roles found with this permission"
        return 0
    end

    echo "Roles with this permission ($count):"

    sqlite3 $db_path "
        SELECT DISTINCT r.name, r.title
        FROM roles r
        INNER JOIN permissions p ON r.name = p.role
        WHERE p.permission = '$permission'
        ORDER BY r.name;
    " | while read -l line
        set -l fields (string split '|' $line)
        printf "  - %-45s %s\n" $fields[1] $fields[2]
    end
end
