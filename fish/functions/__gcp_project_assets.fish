function __gcp_project_assets
    argparse h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp project assets [PROJECT_ID]"
        echo
        echo "List all asset types in a GCP project"
        echo
        echo "Shows a count of each asset type (compute instances, storage buckets, etc.)"
        echo "found in the project using the Cloud Asset Inventory API."
        echo
        echo "Arguments:"
        echo "  PROJECT_ID    GCP project ID (optional, uses active project if not provided)"
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  gcp project assets"
        echo "  gcp project assets project_id"
        echo
        echo "Note:"
        echo "  Requires Cloud Asset API (cloudasset.googleapis.com) to be enabled"
        echo "  The API will be automatically enabled if not already active"
        return 0
    end

    set -l project_id $argv[1]

    if test -z "$project_id"
        set project_id (__gcp_get_default_project)
    end

    if test -z "$project_id"
        echo "Error: No project ID provided and no default project configured" >&2
        echo "Run 'gcp project assets --help' for usage information" >&2
        return 1
    end

    # Check if Cloud Asset API is enabled, enable it if not
    set -l api_enabled (gcloud services list --enabled --filter="name:cloudasset.googleapis.com" --format="value(name)" --project="$project_id" 2>/dev/null)
    if test -z "$api_enabled"
        echo "Cloud Asset API is not enabled. Enabling it now..." >&2
        if not gcloud services enable cloudasset.googleapis.com --project="$project_id" 2>/dev/null
            echo "Error: Failed to enable Cloud Asset API" >&2
            echo "You may need to enable it manually: gcloud services enable cloudasset.googleapis.com --project=$project_id" >&2
            return 1
        end
        echo "Cloud Asset API enabled successfully" >&2
        echo >&2
    end

    echo "Searching assets in project: $project_id"
    echo

    # Run the asset search command
    gcloud asset search-all-resources \
        --project="$project_id" \
        --format="value(assetType)" 2>/dev/null | sort | uniq -c | sort -rn
end
