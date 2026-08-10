function __gcp_get_default_org
    # Check for configured default org first
    if set -q GCP_DEFAULT_ORG
        echo $GCP_DEFAULT_ORG
    else
        gcloud organizations list --format='value(name)' --limit=1 2>/dev/null
    end
end
