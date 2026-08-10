function __gcp_project_audit
    argparse 'd/days=' h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp project audit <PROJECT_ID> [--days N]"
        echo
        echo "Audit GCP project access by querying audit logs"
        echo
        echo "Arguments:"
        echo "  PROJECT_ID              The GCP project ID to audit"
        echo
        echo "Options:"
        echo "  -d, --days N           Number of days to look back (default: 7)"
        echo "  -h, --help             Show this help message"
        echo
        echo "Examples:"
        echo "  gcp project audit project_id"
        echo "  gcp project audit project_id --days 30"
        return 0
    end

    set -l project_id $argv[1]
    set -l days 7

    if set -q _flag_days
        set days $_flag_days
        if not string match -qr '^\d+$' "$days"
            echo "Error: --days must be a positive integer" >&2
            return 1
        end
    end

    if test -z "$project_id"
        echo "Error: PROJECT_ID is required" >&2
        echo "Usage: gcp project audit <PROJECT_ID> [--days N]" >&2
        return 1
    end

    set -l end_date (date -u +"%Y-%m-%dT%H:%M:%SZ")
    set -l start_date (date -u -v-"$days"d +"%Y-%m-%dT%H:%M:%SZ")

    echo "Auditing project: $project_id"
    echo "Time range: $start_date to $end_date ($days days)"
    echo

    set -l filter "protoPayload.authenticationInfo.principalEmail:* AND timestamp>=\"$start_date\" AND timestamp<=\"$end_date\""

    # Stream logs and extract emails (no limit, handles pagination automatically)
    set -l temp_emails (mktemp)
    if not gcloud logging read "$filter" \
        --project="$project_id" \
        --format='value(protoPayload.authenticationInfo.principalEmail)' 2>/dev/null >$temp_emails
        echo "Error: Failed to read audit logs. Check project ID and permissions." >&2
        rm -f $temp_emails
        return 1
    end

    set -l total_entries (wc -l < $temp_emails | string trim)
    echo "Found $total_entries audit log entries"
    echo

    echo "=== Users ==="
    grep -v '\.iam\.gserviceaccount\.com$' $temp_emails \
        | sort | uniq -c | sort -rn \
        | while read -l count email
            printf "%6d  %s\n" $count $email
        end

    echo
    echo "=== Service Accounts ==="
    grep '\.iam\.gserviceaccount\.com$' $temp_emails \
        | sort | uniq -c | sort -rn \
        | while read -l count email
            printf "%6d  %s\n" $count $email
        end

    rm -f $temp_emails
end
