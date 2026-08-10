function __gcp_project_members
    # Parse arguments
    argparse h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp project members [PROJECT_ID]"
        echo
        echo "List all members with project-level IAM permissions"
        echo
        echo "Arguments:"
        echo "  PROJECT_ID    GCP project ID (optional, uses active project if not provided)"
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  gcp project members"
        echo "  gcp project members project_id-id"
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
        echo "Run 'gcp project members --help' for usage information" >&2
        return 1
    end

    gcloud projects get-iam-policy $project_id \
        --flatten="bindings[].members" \
        --format='value(bindings.members)' | sort -u
end
