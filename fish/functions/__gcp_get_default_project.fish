function __gcp_get_default_project
    gcloud config list --format='value(core.project)' 2>/dev/null
end
