function __gcp_iam_db_path
    set -l db_path "$HOME/.config/gcp-fish/iam.sqlite"
    if not test -f "$db_path"
        echo "Error: IAM database not found at $db_path" >&2
        echo "Run 'gcp iam update' to create and populate the database" >&2
        return 1
    end
    echo $db_path
end
