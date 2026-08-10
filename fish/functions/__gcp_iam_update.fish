function __gcp_iam_update
    # Parse arguments
    argparse f/force h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp iam update [--force]"
        echo
        echo "Update IAM roles database from GCP"
        echo
        echo "Options:"
        echo "  -f, --force    Force full refresh (clear all data and re-download)"
        echo "  -h, --help     Show this help message"
        echo
        echo "By default, resumes from previous state (only fetches missing roles)."
        echo "Use --force to start fresh and re-download all roles."
        return 0
    end

    # Check prerequisites
    if not command -v gcloud >/dev/null 2>&1
        echo "Error: gcloud is required but not installed" >&2
        echo "Install from: https://cloud.google.com/sdk/docs/install" >&2
        return 1
    end

    if not command -v jq >/dev/null 2>&1
        echo "Error: jq is required but not installed" >&2
        echo "Install with: brew install jq" >&2
        return 1
    end

    if not command -v sqlite3 >/dev/null 2>&1
        echo "Error: sqlite3 is required but not installed" >&2
        return 1
    end

    # Setup database directory and path
    set -l db_dir "$HOME/.config/gcp-fish"
    set -l db_path "$db_dir/iam.sqlite"

    echo "Setting up IAM database..."
    mkdir -p "$db_dir"

    # Initialize database schema
    sqlite3 "$db_path" "
        CREATE TABLE IF NOT EXISTS roles (
            name TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            stage TEXT,
            deleted BOOLEAN DEFAULT FALSE,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS permissions (
            permission TEXT,
            role TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (permission, role),
            FOREIGN KEY (role) REFERENCES roles(name) ON DELETE CASCADE
        );

        CREATE INDEX IF NOT EXISTS idx_permissions_role ON permissions(role);
        CREATE INDEX IF NOT EXISTS idx_permissions_permission ON permissions(permission);
    "

    echo "Fetching IAM roles from GCP..."

    # Fetch all role names
    set -l temp_roles (mktemp)
    if not gcloud iam roles list --format="value(name)" 2>/dev/null >$temp_roles
        echo "Error: Failed to fetch roles. Check gcloud authentication." >&2
        rm -f $temp_roles
        return 1
    end

    set -l total_roles (wc -l < $temp_roles | string trim)
    echo "Found $total_roles roles from GCP"

    # Clear existing data if --force flag is set
    if set -q _flag_force
        echo "Force refresh: clearing existing data..."
        sqlite3 "$db_path" "
            BEGIN TRANSACTION;
            DELETE FROM permissions;
            DELETE FROM roles;
            COMMIT;
        "
    end

    # Check how many roles already exist in DB
    set -l existing_count (sqlite3 "$db_path" "SELECT COUNT(*) FROM roles;")
    echo "Database contains $existing_count roles"
    echo

    # Process each role
    set -l counter 0
    set -l skipped 0
    set -l processed 0
    set -l failed 0
    set -l temp_json (mktemp)
    set -l last_line_length 0

    while read -l role_name
        set counter (math $counter + 1)

        # Check if role already exists (skip if resuming and not forcing)
        if not set -q _flag_force
            set -l role_name_check (string replace -a "'" "''" $role_name)
            set -l exists (sqlite3 "$db_path" "SELECT COUNT(*) FROM roles WHERE name='$role_name_check';")
            if test "$exists" -gt 0
                set skipped (math $skipped + 1)
                # Update progress line (clear previous line with spaces)
                set -l status_msg (printf "[%d/%d] Processed: %d | Skipped: %d | Failed: %d" $counter $total_roles $processed $skipped $failed)
                set -l spaces (string repeat -n $last_line_length " ")
                printf "\r%s\r%s" $spaces $status_msg
                set last_line_length (string length $status_msg)
                continue
            end
        end

        # Fetch role details
        if not gcloud iam roles describe "$role_name" --format=json 2>/dev/null >$temp_json
            set failed (math $failed + 1)
            # Print failed roles on new line for visibility
            set -l spaces (string repeat -n $last_line_length " ")
            printf "\r%s\r" $spaces
            printf "[%d/%d] FAILED: %s\n" $counter $total_roles $role_name
            set last_line_length 0
            continue
        end

        # Parse role data
        set -l role_title (jq -r '.title // ""' $temp_json)
        set -l role_desc (jq -r '.description // ""' $temp_json)
        set -l role_stage (jq -r '.stage // "GA"' $temp_json)

        # Escape single quotes for SQL
        set role_name_escaped (string replace -a "'" "''" $role_name)
        set role_title_escaped (string replace -a "'" "''" $role_title)
        set role_desc_escaped (string replace -a "'" "''" $role_desc)
        set role_stage_escaped (string replace -a "'" "''" $role_stage)

        # Delete existing permissions for this role first (for updates)
        sqlite3 "$db_path" "DELETE FROM permissions WHERE role='$role_name_escaped';"

        # Insert role
        sqlite3 "$db_path" "
            INSERT OR REPLACE INTO roles (name, title, description, stage, updated_at)
            VALUES ('$role_name_escaped', '$role_title_escaped', '$role_desc_escaped', '$role_stage_escaped', CURRENT_TIMESTAMP);
        "

        # Insert permissions
        set -l permissions (jq -r '.includedPermissions[]? // empty' $temp_json)
        if test -n "$permissions"
            # Build SQL script in a temporary file to execute in single transaction
            set -l sql_file (mktemp)
            echo "BEGIN TRANSACTION;" >$sql_file

            for perm in $permissions
                set perm_escaped (string replace -a "'" "''" $perm)
                echo "INSERT OR REPLACE INTO permissions (permission, role, created_at) VALUES ('$perm_escaped', '$role_name_escaped', CURRENT_TIMESTAMP);" >>$sql_file
            end

            echo "COMMIT;" >>$sql_file

            # Execute all statements in a single sqlite3 invocation
            sqlite3 "$db_path" <$sql_file
            rm -f $sql_file
        end

        set processed (math $processed + 1)

        # Update progress line (clear previous line with spaces)
        set -l status_msg (printf "[%d/%d] Processed: %d | Skipped: %d | Failed: %d" $counter $total_roles $processed $skipped $failed)
        set -l spaces (string repeat -n $last_line_length " ")
        printf "\r%s\r%s" $spaces $status_msg
        set last_line_length (string length $status_msg)
    end <$temp_roles

    # Cleanup
    rm -f $temp_roles $temp_json

    # Clear the progress line and move to next line
    set -l spaces (string repeat -n $last_line_length " ")
    printf "\r%s\r" $spaces
    echo
    echo "Update complete!"
    echo
    echo "Summary:"
    echo "  Processed: $processed"
    echo "  Skipped:   $skipped"
    echo "  Failed:    $failed"
    echo

    # Show statistics
    set -l roles_count (sqlite3 "$db_path" "SELECT COUNT(*) FROM roles;")
    set -l perms_count (sqlite3 "$db_path" "SELECT COUNT(DISTINCT permission) FROM permissions;")

    echo "Database: $db_path"
    echo "  Roles:       $roles_count"
    echo "  Permissions: $perms_count"
end
