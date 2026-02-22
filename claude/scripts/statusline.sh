#!/bin/bash
input=$(cat)
dir=$(echo "$input" | jq -r '.workspace.current_dir')

dim='\033[2m'
yellow='\033[33m'
cyan='\033[36m'
green='\033[32m'
magenta='\033[35m'
red='\033[31m'
reset='\033[0m'

usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
  current=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
  size=$(echo "$input" | jq '.context_window.context_window_size')
  pct=$((current * 100 / size))
  color=$green
  [ "$pct" -ge 50 ] && color=$yellow
  [ "$pct" -ge 80 ] && color=$red
  printf "${color}%d%%${reset}${dim} context${reset} | " "$pct"
fi

printf "${cyan}%s${reset} in ${magenta}%s${reset}" \
  "$(echo "$input" | jq -r '.model.display_name')" \
  "$(echo "$dir" | sed 's|^/Users/kefhuang|~|')"

if git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
  changes=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  printf " ${dim}|${reset} ${green}%s${reset}" "$branch"
  [ "$changes" != "0" ] && printf " ${red}+%s${reset}" "$changes"
fi
