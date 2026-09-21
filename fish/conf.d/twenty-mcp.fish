# Twenty built-in MCP. Grok expands Authorization Bearer ${TWENTY_API_KEY}
# in ~/github/crm/.grok/config.toml. The secret stays in the gitignored .env.
set -l envfile $HOME/github/crm/.env
if test -f $envfile
    set -l line (command grep -E '^TWENTY_API_KEY=' $envfile | command head -n 1)
    if test -n "$line"
        set -l value (string replace -r '^TWENTY_API_KEY=' '' -- $line)
        set value (string replace -r '^"(.*)"$' '$1' -- $value)
        set value (string replace -r "^'(.*)'\$" '$1' -- $value)
        if test -n "$value"
            set --global --export TWENTY_API_KEY $value
        end
    end
end
