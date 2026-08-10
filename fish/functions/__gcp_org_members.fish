function __gcp_org_members
    # Parse arguments
    argparse h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp org members [ORG_ID]"
        echo
        echo "List all members with organization-level IAM permissions"
        echo
        echo "Arguments:"
        echo "  ORG_ID    Organization ID (optional, uses default if not provided)"
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  gcp org members"
        echo "  gcp org members 123456789012"
        echo
        echo "Environment:"
        echo "  Set GCP_DEFAULT_ORG to configure a default organization"
        return 0
    end

    set -l org_id $argv[1]

    if test -z "$org_id"
        set org_id (__gcp_get_default_org)
    end

    if test -z "$org_id"
        echo "Error: No organization ID provided and no default organization found" >&2
        echo "Run 'gcp org members --help' for usage information" >&2
        return 1
    end

    gcloud organizations get-iam-policy $org_id \
        --flatten="bindings[].members" \
        --format='value(bindings.members)' | sort -u
end
