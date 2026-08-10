function commit --description 'git commit staged changes'
    grok -p 'Commit the staged git changes only (do not stage anything). Write the commit message in Conventional Commits format using the steno skill: a concise type(scope): subject line, and a body only if the changes need explanation. Do not add any Claude/AI attribution or trailers.' \
        --always-approve \
        --no-ask-user \
        --no-subagents \
        --disable-web-search
end
