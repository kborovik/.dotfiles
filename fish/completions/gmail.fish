# static gmail completions — fish autoload; no interpreter on Tab (V1)
complete -c gmail -e
complete -c gmail -f

complete -c gmail -n '__fish_use_subcommand' -a auth -d 'browser OAuth; write token mode 0600'
complete -c gmail -n '__fish_use_subcommand' -a pull -d 'ingest + advance SyncCursor'
complete -c gmail -n '__fish_use_subcommand' -a send -d 'Gmail send + ingest'
complete -c gmail -n '__fish_use_subcommand' -a status -d 'JSON cursor/lease/account'
complete -c gmail -n '__fish_use_subcommand' -a show -d 'Gmail get JSON (not graph)'

complete -c gmail -l help -d 'this catalog; exit 0'
complete -c gmail -l format -d 'stdout format json|text'

complete -c gmail -n '__fish_seen_subcommand_from pull' -l max -d 'cap messages'
complete -c gmail -n '__fish_seen_subcommand_from pull' -l label -d 'Gmail label id'
complete -c gmail -n '__fish_seen_subcommand_from pull show' -l full -d 'full payload'

complete -c gmail -n '__fish_seen_subcommand_from send' -l to -d 'recipient'
complete -c gmail -n '__fish_seen_subcommand_from send' -l cc -d 'cc'
complete -c gmail -n '__fish_seen_subcommand_from send' -l subject -d 'subject'
complete -c gmail -n '__fish_seen_subcommand_from send' -l body -d 'body'
complete -c gmail -n '__fish_seen_subcommand_from send' -l thread-id -d 'Gmail thread id'
