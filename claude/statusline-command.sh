#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Get username and hostname
user=$(whoami)
host=$(hostname -s)

# Get current directory basename for display
dir_name=$(basename "$current_dir")

# Get git branch if in a git repo (skip optional locks for performance)
git_branch=""
if git -C "$current_dir" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$current_dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        # Check for git status indicators
        git_status=$(git -C "$current_dir" --no-optional-locks status --porcelain 2>/dev/null)
        status_char=""
        if [ -n "$git_status" ]; then
            # Check for different types of changes
            if echo "$git_status" | grep -q '^??'; then
                status_char="${status_char}^"  # untracked
            fi
            if echo "$git_status" | grep -q '^ M\|^MM\|^ T'; then
                status_char="${status_char}!"  # modified
            fi
            if echo "$git_status" | grep -q '^M\|^A\|^D\|^R\|^C'; then
                status_char="${status_char}+"  # staged
            fi
        fi

        git_branch=" ($branch$status_char)"
    fi
fi

# Build context info
context_info=""
if [ -n "$remaining" ]; then
    context_info=" [ctx:${remaining}%]"
fi

# Build output style info if not default
style_info=""
if [ "$output_style" != "default" ] && [ "$output_style" != "null" ]; then
    style_info=" [$output_style]"
fi

# Combine all parts (no trailing prompt character)
printf "%s@%s %s%s%s%s" "$user" "$host" "$dir_name" "$git_branch" "$context_info" "$style_info"
