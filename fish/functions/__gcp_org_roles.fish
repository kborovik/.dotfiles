function __gcp_org_roles
    # Parse arguments
    argparse h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp org roles <MEMBER> [ORG_ID]"
        echo
        echo "List IAM roles assigned to a specific member at organization level"
        echo
        echo "Arguments:"
        echo "  MEMBER    Member identifier (required)"
        echo "            Format: user:email@example.com, serviceAccount:name@project.iam.gserviceaccount.com,"
        echo "                    group:group@example.com, or domain:example.com"
        echo "  ORG_ID    Organization ID (optional, uses default if not provided)"
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  gcp org roles user:john@example.com"
        echo "  gcp org roles serviceAccount:bot@project.iam.gserviceaccount.com 123456789012"
        echo "  gcp org roles group:admins@example.com"
        echo
        echo "Environment:"
        echo "  Set GCP_DEFAULT_ORG to configure a default organization"
        return 0
    end

    set -l member $argv[1]
    set -l org_id $argv[2]

    if test -z "$member"
        echo "Error: Member identifier required" >&2
        echo "Run 'gcp org roles --help' for usage information" >&2
        return 1
    end

    if test -z "$org_id"
        set org_id (__gcp_get_default_org)
    end

    if test -z "$org_id"
        echo "Error: No organization ID provided and no default organization found" >&2
        echo "Run 'gcp org roles --help' for usage information" >&2
        return 1
    end

    gcloud organizations get-iam-policy $org_id \
        --flatten="bindings[].members" \
        --filter="bindings.members:$member" \
        --format="table(bindings.role)"
end
