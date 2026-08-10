function __gcp_iam_role_diff
    # Parse arguments
    argparse h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp iam role diff <ROLE1> <ROLE2>"
        echo
        echo "Compare permissions between two IAM roles"
        echo
        echo "Shows common permissions, permissions unique to each role, and a summary"
        echo "of permission counts for both roles."
        echo
        echo "Arguments:"
        echo "  ROLE1    First IAM role name (required)"
        echo "  ROLE2    Second IAM role name (required)"
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  gcp iam role diff roles/viewer roles/editor"
        echo "  gcp iam role diff roles/storage.objectViewer roles/storage.objectAdmin"
        echo "  gcp iam role diff roles/compute.viewer roles/compute.admin"
        echo
        echo "Note:"
        echo "  Data is read from the local IAM database. Run 'gcp iam update' to refresh."
        return 0
    end

    set -l role1 $argv[1]
    set -l role2 $argv[2]

    if test -z "$role1" -o -z "$role2"
        echo "Error: Two role names required" >&2
        echo "Run 'gcp iam role diff --help' for usage information" >&2
        return 1
    end

    set -l db_path (__gcp_iam_db_path)
    or return 1

    # Verify both roles exist and get their titles
    set -l role1_title (sqlite3 $db_path "SELECT title FROM roles WHERE name='$role1';")
    set -l role2_title (sqlite3 $db_path "SELECT title FROM roles WHERE name='$role2';")

    if test -z "$role1_title"
        echo "Error: Role '$role1' not found" >&2
        return 1
    end

    if test -z "$role2_title"
        echo "Error: Role '$role2' not found" >&2
        return 1
    end

    echo "Comparing roles:"
    echo "  Role 1: $role1 ($role1_title)"
    echo "  Role 2: $role2 ($role2_title)"
    echo

    # Get counts
    set -l total1 (sqlite3 $db_path "SELECT COUNT(*) FROM permissions WHERE role='$role1';")
    set -l total2 (sqlite3 $db_path "SELECT COUNT(*) FROM permissions WHERE role='$role2';")
    set -l common_count (sqlite3 $db_path "
        SELECT COUNT(*) FROM (
            SELECT p1.permission FROM permissions p1
            INNER JOIN permissions p2 ON p1.permission = p2.permission
            WHERE p1.role='$role1' AND p2.role='$role2'
        );
    ")
    set -l unique1_count (sqlite3 $db_path "
        SELECT COUNT(*) FROM permissions
        WHERE role='$role1' AND permission NOT IN (
            SELECT permission FROM permissions WHERE role='$role2'
        );
    ")
    set -l unique2_count (sqlite3 $db_path "
        SELECT COUNT(*) FROM permissions
        WHERE role='$role2' AND permission NOT IN (
            SELECT permission FROM permissions WHERE role='$role1'
        );
    ")

    echo "Common permissions ($common_count):"
    if test "$common_count" -gt 0
        sqlite3 $db_path "
            SELECT p1.permission FROM permissions p1
            INNER JOIN permissions p2 ON p1.permission = p2.permission
            WHERE p1.role='$role1' AND p2.role='$role2'
            ORDER BY p1.permission;
        " | while read -l perm
            echo "  ✓ $perm"
        end
    end
    echo

    echo "Permissions only in '$role1' ($unique1_count):"
    if test "$unique1_count" -gt 0
        sqlite3 $db_path "
            SELECT permission FROM permissions
            WHERE role='$role1' AND permission NOT IN (
                SELECT permission FROM permissions WHERE role='$role2'
            )
            ORDER BY permission;
        " | while read -l perm
            echo "  + $perm"
        end
    end
    echo

    echo "Permissions only in '$role2' ($unique2_count):"
    if test "$unique2_count" -gt 0
        sqlite3 $db_path "
            SELECT permission FROM permissions
            WHERE role='$role2' AND permission NOT IN (
                SELECT permission FROM permissions WHERE role='$role1'
            )
            ORDER BY permission;
        " | while read -l perm
            echo "  + $perm"
        end
    end
    echo

    echo "Summary:"
    echo "  Total permissions in '$role1': $total1"
    echo "  Total permissions in '$role2': $total2"
    echo "  Common permissions: $common_count"
    echo "  Unique to '$role1': $unique1_count"
    echo "  Unique to '$role2': $unique2_count"
end
