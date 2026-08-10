function __gcp_project_services
    argparse h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp project services [PROJECT_ID]"
        echo
        echo "List all enabled services in a GCP project"
        echo
        echo "Displays service name, title, and documentation summary for each"
        echo "enabled service in the project."
        echo
        echo "Arguments:"
        echo "  PROJECT_ID    GCP project ID (optional, uses active project if not provided)"
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  gcp project services"
        echo "  gcp project services project_id"
        echo
        echo "Environment:"
        echo "  Uses gcloud config's active project (core.project) as default"
        return 0
    end

    set -l project_id $argv[1]

    if test -z "$project_id"
        set project_id (__gcp_get_default_project)
    end

    if test -z "$project_id"
        echo "Error: No project ID provided and no default project configured" >&2
        echo "Run 'gcp project services --help' for usage information" >&2
        return 1
    end

    # Check if jq is available
    if not command -v jq >/dev/null 2>&1
        echo "Error: jq is required but not installed" >&2
        echo "Install with: brew install jq" >&2
        return 1
    end

    echo "Enabled services in project: $project_id"
    echo

    # Get enabled services as JSON and parse
    set -l temp_file (mktemp)
    if not gcloud services list --enabled --project="$project_id" --format=json 2>/dev/null >$temp_file
        echo "Error: Failed to list services. Check project ID and permissions." >&2
        rm -f $temp_file
        return 1
    end

    set -l service_count (jq '. | length' $temp_file)
    echo "Found $service_count enabled services"
    echo

    # Parse and display services
    jq -r '.[] |
        (.config.name // "N/A") as $name |
        (.config.title // "N/A") as $title |
        ((.config.documentation.summary // "No summary available") | gsub("\\n"; " ") | gsub("  +"; " ") | gsub("^[[:space:]]+|[[:space:]]+$"; "")) as $summary |
        "\($name)\u001F\($title)\u001F\($summary)"
    ' $temp_file | while read -l line
        set -l fields (string split \u001F $line)
        set -l name $fields[1]
        set -l title $fields[2]
        set -l summary $fields[3]

        # Skip if name is empty or just whitespace
        if test -z "$name" -o "$name" = N/A
            continue
        end

        printf "Service: %s\n" "$name"
        printf "  Title:   %s\n" "$title"
        printf "  Summary: %s\n" "$summary"
        echo
    end

    rm -f $temp_file
end
