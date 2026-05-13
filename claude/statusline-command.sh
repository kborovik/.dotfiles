#!/bin/sh
# Claude Code statusline: dir | branch | git counts

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty')
[ -z "$cwd" ] && cwd=$(pwd)

dir=$(basename "$cwd")

if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
  porcelain=$(git -C "$cwd" -c core.fsmonitor= status --porcelain 2>/dev/null)

  unstaged=0
  staged=0
  untracked=0
  ahead=0
  behind=0

  if upstream=$(git -C "$cwd" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null); then
    counts=$(git -C "$cwd" rev-list --count --left-right "${upstream}...HEAD" 2>/dev/null)
    if [ -n "$counts" ]; then
      behind=${counts%%	*}
      ahead=${counts##*	}
    fi
  fi

  while IFS= read -r line; do
    [ -z "$line" ] && continue
    x=${line%${line#?}}   # index (col 1)
    y=${line#?}; y=${y%${y#?}}  # worktree (col 2)

    if [ "$x" = "?" ] && [ "$y" = "?" ]; then
      untracked=$((untracked + 1))
    else
      [ "$x" != " " ] && [ "$x" != "?" ] && staged=$((staged + 1))
      [ "$y" != " " ] && [ "$y" != "?" ] && unstaged=$((unstaged + 1))
    fi
  done <<EOF
$porcelain
EOF

  CYAN='\033[96m'
  MAGENTA='\033[95m'
  GREEN='\033[32m'
  YELLOW='\033[33m'
  RED='\033[31m'
  BLUE='\033[34m'
  RESET='\033[0m'

  printf "${CYAN}%s${RESET}  ${MAGENTA}%s${RESET}  ${GREEN}+%d${RESET} ${YELLOW}~%d${RESET} ${RED}?%d${RESET}  ${BLUE}↑%d ↓%d${RESET}" \
    "$dir" "$branch" "$staged" "$unstaged" "$untracked" "$ahead" "$behind"
else
  CYAN='\033[96m'
  RESET='\033[0m'
  printf "${CYAN}%s${RESET}" "$dir"
fi
