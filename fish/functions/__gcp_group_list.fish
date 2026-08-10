function __gcp_group_list
    argparse 'p/project=' 'o/organization=' 't/type=' h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp group list [OPTIONS]"
        echo
        echo "List Cloud Identity groups"
        echo
        echo "Options:"
        echo "  -p, --project PROJECT      GCP project ID"
        echo "  -o, --organization ORG     Organization ID or domain"
        echo "  -t, --type TYPE            Filter by type: all, discussion, security (default: discussion)"
        echo "  -h, --help                 Show this help message"
        echo
        echo "Examples:"
        echo "  gcp group list"
        echo "  gcp group list --type security"
        echo "  gcp group list --type all"
        echo "  gcp group list --organization 270030255763"
        return 0
    end

    # Get current project for API enablement check
    set -l current_project (__gcp_get_default_project)
    if test -z "$current_project"
        echo "Error: No active GCP project configured" >&2
        echo "Run 'gcloud config set project PROJECT_ID' to set a project" >&2
        return 1
    end

    # Check if Cloud Identity API is enabled, enable it if not
    set -l api_enabled (gcloud services list --enabled --filter="name:cloudidentity.googleapis.com" --format="value(name)" --project="$current_project" 2>/dev/null)
    if test -z "$api_enabled"
        echo "Cloud Identity API is not enabled. Enabling it now..." >&2
        if not gcloud services enable cloudidentity.googleapis.com --project="$current_project" 2>/dev/null
            echo "Error: Failed to enable Cloud Identity API" >&2
            echo "You may need to enable it manually: gcloud services enable cloudidentity.googleapis.com" >&2
            return 1
        end
        echo "Cloud Identity API enabled successfully" >&2
    end

    # Get organization if not provided
    set -l org
    if set -q _flag_organization
        set org $_flag_organization
    else
        set org (__gcp_get_default_org)
    end

    if test -z "$org"
        echo "Error: No organization ID provided and no default organization found" >&2
        return 1
    end

    # Build labels filter based on type (default: discussion)
    set -l labels
    set -l group_type discussion

    if set -q _flag_type
        set group_type $_flag_type
    end

    switch $group_type
        case discussion
            set labels "cloudidentity.googleapis.com/groups.discussion_forum"
        case security
            set labels "cloudidentity.googleapis.com/groups.security"
        case all
            # No label filter for all
        case '*'
            echo "Error: Invalid type '$group_type'. Must be: all, discussion, security" >&2
            return 1
    end

    # Build command
    set -l cmd gcloud identity groups search --organization="$org"

    if set -q _flag_project
        set cmd $cmd --project="$_flag_project"
    end

    if test -n "$labels"
        set cmd $cmd --labels="$labels"
    end

    set cmd $cmd --format=json

    # Execute and parse
    if not command -v jq >/dev/null 2>&1
        echo "Error: jq is required but not installed" >&2
        echo "Install with: brew install jq" >&2
        return 1
    end

    eval $cmd 2>/dev/null | jq -r '.groups[]?.groupKey.id // empty'
end
