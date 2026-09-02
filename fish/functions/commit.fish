function commit --description 'git commit staged changes via Gemini'
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Error: not a git repository" >&2
        return 1
    end

    if test (git diff --cached --name-only | count) -eq 0
        echo "Error: no staged changes" >&2
        return 1
    end

    if not command -q curl
        echo "Error: curl is required" >&2
        return 1
    end

    if not command -q jq
        echo "Error: jq is required" >&2
        return 1
    end

    set -l key_file ~/.config/gemini/api-key
    if not test -r $key_file
        echo "Error: missing readable $key_file (mode 600; first line is the Gemini API key)" >&2
        return 1
    end

    set -l api_key (head -n1 $key_file | string trim)
    if test -z "$api_key"
        echo "Error: empty API key in $key_file" >&2
        return 1
    end

    set -l git_status (git status --short | string collect)
    set -l git_diff (git diff --cached | string collect)

    # Cap diff so the request stays within model context limits.
    set -l max_diff_chars 100000
    if test (string length -- $git_diff) -gt $max_diff_chars
        set git_diff (string sub --length $max_diff_chars -- $git_diff)
        set git_diff $git_diff\n\n[diff truncated]
    end

    set -l prompt (
        printf '%s\n' \
            "Write a git commit message for the staged changes below." \
            "Follow Conventional Commits 1.0.0: https://www.conventionalcommits.org/en/v1.0.0/" \
            "" \
            "Rules:" \
            "- Output ONLY the commit message text — no markdown fences, no commentary, no quotes." \
            "- Subject line: type(optional-scope): description" \
            "- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert" \
            "- Subject ≤72 chars, imperative mood, no trailing period." \
            "- Add a body only when the why is not obvious from the subject; separate with a blank line." \
            "- Do not stage files. Do not add AI/tool attribution, Signed-off-by, or other trailers." \
            "" \
            "git status:" \
            $git_status \
            "" \
            "git diff --cached:" \
            $git_diff \
        | string collect
    )

    set -l payload (jq -n --arg text "$prompt" '{
        contents: [{ parts: [{ text: $text }] }],
        generationConfig: {
            temperature: 0.2,
            maxOutputTokens: 1024,
            thinkingConfig: { thinkingBudget: 1 }
        }
    }' | string collect)

    set -l model gemini-3.7-flash
    set -l url "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent"

    set -l response (curl -sS --fail-with-body \
        -H "Content-Type: application/json" \
        -H "x-goog-api-key: $api_key" \
        -d "$payload" \
        "$url" | string collect)
    set -l curl_status $pipestatus[1]

    if test $curl_status -ne 0
        echo "Error: Gemini API request failed" >&2
        printf '%s\n' $response >&2
        return 1
    end

    set -l msg (printf '%s\n' $response | jq -r '.candidates[0].content.parts[0].text // empty' | string collect)
    if test -z "$msg"
        echo "Error: empty commit message from Gemini" >&2
        printf '%s\n' $response >&2
        return 1
    end

    # Strip accidental markdown fences.
    set msg (printf '%s\n' $msg | sed -e '1{/^```/d;}' -e '${/^```/d;}' | string collect)
    set msg (string trim -- $msg)

    if test -z "$msg"
        echo "Error: commit message empty after cleanup" >&2
        return 1
    end

    printf '%s\n' $msg
    echo "---"
    printf '%s\n' $msg | git commit -F -
end
