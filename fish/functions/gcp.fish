function gcp --description 'Unified GCP CLI for IAM and audit operations'
    # Helpers live in functions/__gcp_*.fish (autoloaded once).

    # Main command dispatcher
    if test (count $argv) -eq 0; or test "$argv[1]" = --help; or test "$argv[1]" = -h
        echo "Usage: gcp <command> <subcommand> [options]"
        echo
        echo "Unified GCP CLI for IAM and audit operations"
        echo
        echo "Commands:"
        echo "  org members [ORG_ID]                List all members with org-level IAM permissions"
        echo "  org roles <MEMBER> [ORG_ID]         List IAM roles for a member at org level"
        echo "  project members [PROJECT_ID]        List all members with project-level IAM permissions"
        echo "  project roles <MEMBER> [PROJECT_ID] List IAM roles for a member at project level"
        echo "  project audit <PROJECT_ID> [--days N] Audit project access from logs"
        echo "  project assets [PROJECT_ID]         List all asset types in a project"
        echo "  project services [PROJECT_ID]       List all enabled services in a project"
        echo "  group list [OPTIONS]                List Cloud Identity groups"
        echo "  group members <GROUP_EMAIL>         List members of a Cloud Identity group"
        echo "  vpn show <PROJECT_ID> <REGION>      Show VPN configuration details"
        echo
        echo "IAM Database Commands (offline queries):"
        echo "  iam info                            Show IAM database statistics"
        echo "  iam update [--force]                Update IAM roles from GCP (resumes by default)"
        echo "  iam role show <ROLE>                Show role details and permissions"
        echo "  iam role search <QUERY>             Search for roles by name/title"
        echo "  iam role diff <ROLE1> <ROLE2>       Compare permissions between two roles"
        echo "  iam permission show <PERMISSION>    List all roles with a permission"
        echo "  iam permission search <QUERY>       Search for permissions"
        echo
        echo "Options:"
        echo "  -h, --help                          Show this help message"
        echo
        echo "Examples:"
        echo "  gcp org members"
        echo "  gcp org roles user:john@example.com"
        echo "  gcp project members project_id"
        echo "  gcp project roles serviceAccount:bot@project.iam.gserviceaccount.com"
        echo "  gcp project audit project_id --days 30"
        echo "  gcp project assets"
        echo "  gcp project services"
        echo "  gcp group list"
        echo "  gcp group list --type security"
        echo "  gcp group members admins@example.com"
        echo "  gcp vpn show my-project us-central1"
        echo "  gcp iam update                      # Resume from last state"
        echo "  gcp iam update --force              # Force full refresh"
        echo "  gcp iam info"
        echo "  gcp iam role show storage.objectViewer"
        echo "  gcp iam role search storage"
        echo "  gcp iam role diff storage.objectViewer storage.objectAdmin"
        echo "  gcp iam permission show storage.objects.get"
        echo "  gcp iam permission search compute.instances"
        return 0
    end

    set -l command $argv[1]
    set -l subcommand $argv[2]

    switch "$command"
        case org
            switch "$subcommand"
                case members
                    __gcp_org_members $argv[3..-1]
                case roles
                    __gcp_org_roles $argv[3..-1]
                case ''
                    # No subcommand provided - show org help
                    echo "Usage: gcp org <subcommand> [options]"
                    echo
                    echo "Organization-level IAM operations"
                    echo
                    echo "Subcommands:"
                    echo "  members [ORG_ID]           List all members with org-level IAM permissions"
                    echo "  roles <MEMBER> [ORG_ID]    List IAM roles for a specific member"
                    echo
                    echo "Options:"
                    echo "  -h, --help                 Show subcommand help (use: gcp org <subcommand> --help)"
                    echo
                    echo "Examples:"
                    echo "  gcp org members"
                    echo "  gcp org members 123456789012"
                    echo "  gcp org roles user:john@example.com"
                    return 1
                case '*'
                    echo "Error: Unknown subcommand 'org $subcommand'" >&2
                    echo "Run 'gcp org' to see available subcommands" >&2
                    return 1
            end
        case project
            switch "$subcommand"
                case members
                    __gcp_project_members $argv[3..-1]
                case roles
                    __gcp_project_roles $argv[3..-1]
                case audit
                    __gcp_project_audit $argv[3..-1]
                case assets
                    __gcp_project_assets $argv[3..-1]
                case services
                    __gcp_project_services $argv[3..-1]
                case ''
                    # No subcommand provided - show project help
                    echo "Usage: gcp project <subcommand> [options]"
                    echo
                    echo "Project-level IAM operations"
                    echo
                    echo "Subcommands:"
                    echo "  members [PROJECT_ID]              List all members with project-level IAM permissions"
                    echo "  roles <MEMBER> [PROJECT_ID]       List IAM roles for a specific member"
                    echo "  audit <PROJECT_ID> [--days N]     Audit project access from logs"
                    echo "  assets [PROJECT_ID]               List all asset types in a project"
                    echo "  services [PROJECT_ID]             List all enabled services in a project"
                    echo
                    echo "Options:"
                    echo "  -h, --help                        Show subcommand help (use: gcp project <subcommand> --help)"
                    echo
                    echo "Examples:"
                    echo "  gcp project members"
                    echo "  gcp project members project_id"
                    echo "  gcp project roles user:john@example.com"
                    echo "  gcp project audit project_id --days 30"
                    echo "  gcp project assets project_id"
                    echo "  gcp project services project_id"
                    return 1
                case '*'
                    echo "Error: Unknown subcommand 'project $subcommand'" >&2
                    echo "Run 'gcp project' to see available subcommands" >&2
                    return 1
            end
        case group
            switch "$subcommand"
                case list
                    __gcp_group_list $argv[3..-1]
                case members
                    __gcp_group_members $argv[3..-1]
                case ''
                    # No subcommand provided - show group help
                    echo "Usage: gcp group <subcommand> [options]"
                    echo
                    echo "Cloud Identity group operations"
                    echo
                    echo "Subcommands:"
                    echo "  list [OPTIONS]            List Cloud Identity groups"
                    echo "  members <GROUP_EMAIL>     List members of a group"
                    echo
                    echo "Options:"
                    echo "  -h, --help                Show subcommand help (use: gcp group <subcommand> --help)"
                    echo
                    echo "Examples:"
                    echo "  gcp group list"
                    echo "  gcp group list --type security"
                    echo "  gcp group members admins@example.com"
                    return 1
                case '*'
                    echo "Error: Unknown subcommand 'group $subcommand'" >&2
                    echo "Run 'gcp group' to see available subcommands" >&2
                    return 1
            end
        case iam
            set -l iam_resource $argv[2]
            set -l iam_action $argv[3]
            switch "$iam_resource"
                case info
                    __gcp_iam_info $argv[3..-1]
                case update
                    __gcp_iam_update $argv[3..-1]
                case role
                    switch "$iam_action"
                        case show
                            __gcp_iam_role_show $argv[4..-1]
                        case search
                            __gcp_iam_role_search $argv[4..-1]
                        case diff
                            __gcp_iam_role_diff $argv[4..-1]
                        case ''
                            # No action provided - show iam role help
                            echo "Usage: gcp iam role <action> [arguments]"
                            echo
                            echo "IAM role operations (offline database queries)"
                            echo
                            echo "Actions:"
                            echo "  show <ROLE>           Show role details and permissions"
                            echo "  search <QUERY>        Search for roles by name or title"
                            echo "  diff <R1> <R2>        Compare permissions between two roles"
                            echo
                            echo "Options:"
                            echo "  -h, --help            Show action help (use: gcp iam role <action> --help)"
                            echo
                            echo "Examples:"
                            echo "  gcp iam role show roles/viewer"
                            echo "  gcp iam role search storage"
                            echo "  gcp iam role diff roles/viewer roles/editor"
                            return 1
                        case '*'
                            echo "Error: Unknown action 'iam role $iam_action'" >&2
                            echo "Run 'gcp iam role' to see available actions" >&2
                            return 1
                    end
                case permission
                    switch "$iam_action"
                        case show
                            __gcp_iam_permission_show $argv[4..-1]
                        case search
                            __gcp_iam_permission_search $argv[4..-1]
                        case ''
                            # No action provided - show iam permission help
                            echo "Usage: gcp iam permission <action> [arguments]"
                            echo
                            echo "IAM permission operations (offline database queries)"
                            echo
                            echo "Actions:"
                            echo "  show <PERMISSION>     List all roles with a specific permission"
                            echo "  search <QUERY>        Search for permissions by name"
                            echo
                            echo "Options:"
                            echo "  -h, --help            Show action help (use: gcp iam permission <action> --help)"
                            echo
                            echo "Examples:"
                            echo "  gcp iam permission show storage.objects.get"
                            echo "  gcp iam permission search compute.instances"
                            echo "  gcp iam permission show --help"
                            return 1
                        case '*'
                            echo "Error: Unknown action 'iam permission $iam_action'" >&2
                            echo "Run 'gcp iam permission' to see available actions" >&2
                            return 1
                    end
                case ''
                    # No resource provided - show iam help
                    echo "Usage: gcp iam <subcommand> [options]"
                    echo
                    echo "IAM database operations (offline queries)"
                    echo
                    echo "Subcommands:"
                    echo "  info                      Show IAM database statistics"
                    echo "  update [--force]          Update IAM database from GCP"
                    echo "  role <action> [args]      Query IAM roles (show, search, diff)"
                    echo "  permission <action> [args] Query IAM permissions (show, search)"
                    echo
                    echo "Options:"
                    echo "  -h, --help                Show subcommand help (use: gcp iam <subcommand> --help)"
                    echo
                    echo "Examples:"
                    echo "  gcp iam info"
                    echo "  gcp iam update"
                    echo "  gcp iam update --force"
                    echo "  gcp iam role show roles/viewer"
                    echo "  gcp iam permission search storage"
                    echo "  gcp iam update --help"
                    return 1
                case '*'
                    echo "Error: Unknown subcommand 'iam $iam_resource'" >&2
                    echo "Run 'gcp iam' to see available subcommands" >&2
                    return 1
            end
        case vpn
            set -l vpn_action $argv[2]
            switch "$vpn_action"
                case show
                    __gcp_vpn_show $argv[3..-1]
                case ''
                    # No action provided - show vpn help
                    echo "Usage: gcp vpn <subcommand> [options]"
                    echo
                    echo "VPN operations"
                    echo
                    echo "Subcommands:"
                    echo "  show <PROJECT_ID> <REGION>    Show VPN configuration details"
                    echo
                    echo "Options:"
                    echo "  -h, --help                    Show subcommand help (use: gcp vpn <subcommand> --help)"
                    echo
                    echo "Examples:"
                    echo "  gcp vpn show my-project us-central1"
                    echo "  gcp vpn show my-project europe-west1"
                    return 1
                case '*'
                    echo "Error: Unknown subcommand 'vpn $vpn_action'" >&2
                    echo "Run 'gcp vpn' to see available subcommands" >&2
                    return 1
            end
        case '*'
            echo "Error: Unknown command '$command'" >&2
            echo "Valid commands: org, project, group, vpn, iam" >&2
            echo "Run 'gcp --help' for usage information" >&2
            return 1
    end
end
