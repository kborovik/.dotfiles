function __gcp_project_roles
    # Parse arguments
    argparse h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp project roles <MEMBER> [PROJECT_ID]"
        echo
        echo "List IAM roles assigned to a specific member at project level"
        echo
        echo "Arguments:"
        echo "  MEMBER        Member identifier (required)"
        echo "                Format: user:email@example.com, serviceAccount:name@project.iam.gserviceaccount.com,"
        echo "                        group:group@example.com, or domain:example.com"
        echo "  PROJECT_ID    GCP project ID (optional, uses active project if not provided)"
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  gcp project roles user:john@example.com"
        echo "  gcp project roles serviceAccount:bot@project.iam.gserviceaccount.com project_id-id"
        echo "  gcp project roles group:developers@example.com"
        echo
        echo "Environment:"
        echo "  Uses gcloud config's active project (core.project) as default"
        return 0
    end

    set -l member $argv[1]
    set -l project_id $argv[2]

    if test -z "$member"
        echo "Usage: gcp project roles <MEMBER> [PROJECT_ID]"
        echo
        echo "List IAM roles assigned to a specific member at project level"
        echo
        echo "Arguments:"
        echo "  MEMBER        Member identifier (required)"
        echo "                Format: user:email@example.com, serviceAccount:name@project.iam.gserviceaccount.com,"
        echo "                        group:group@example.com, or domain:example.com"
        echo "  PROJECT_ID    GCP project ID (optional, uses active project if not provided)"
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  gcp project roles user:john@example.com"
        echo "  gcp project roles serviceAccount:bot@project.iam.gserviceaccount.com project_id-id"
        echo "  gcp project roles group:developers@example.com"
        echo
        echo "Environment:"
        echo "  Uses gcloud config's active project (core.project) as default"
        return 1
    end

    if test -z "$project_id"
        set project_id (__gcp_get_default_project)
    end

    if test -z "$project_id"
        echo "Error: No project ID provided and no default project configured" >&2
        echo "Run 'gcp project roles --help' for usage information" >&2
        return 1
    end

    gcloud projects get-iam-policy $project_id \
        --flatten="bindings[].members" \
        --filter="bindings.members:$member" \
        --format="table(bindings.role)"
end
