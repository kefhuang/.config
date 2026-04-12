#!/bin/bash

input=$(cat)
transcript_path=$(echo "$input" | jq -r '.transcript_path')
session_id=$(echo "$input" | jq -r '.session_id')
cwd=$(echo "$input" | jq -r '.cwd')

[ -z "$transcript_path" ] || [ "$transcript_path" = "null" ] && exit 0

project=$(cd "$cwd" 2>/dev/null && git remote get-url origin 2>/dev/null \
  | sed 's#.*/##;s#\.git$##')
[ -z "$project" ] && project=$(basename "$cwd")
project="${project#.}"

log_file="$HOME/.claude/logs/obsidian-sync.log"
mkdir -p "$(dirname "$log_file")"

pid_file="/tmp/claude-obsidian-${session_id}.pid"
if [ -f "$pid_file" ]; then
  old_pid=$(cat "$pid_file")
  kill "$old_pid" 2>/dev/null
  wait "$old_pid" 2>/dev/null
fi

nohup bash -c '
  log_file="'"$log_file"'"
  transcript_path="'"$transcript_path"'"
  project="'"$project"'"
  session_id="'"$session_id"'"
  pid_file="'"$pid_file"'"

  echo "[$(date)] [$session_id] scheduled: project=$project" >> "$log_file"
  sleep 3600
  echo "[$(date)] [$session_id] woke up, starting sync" >> "$log_file"

  if [ -f "$HOME/.claude/settings.local.json" ]; then
    vault=$(jq -r ".env.OBSIDIAN_VAULT // empty" "$HOME/.claude/settings.local.json" | sed "s#^~#$HOME#")
  fi
  vault="${vault:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/KefengsObsidian}"
  date_str=$(date +%Y-%m-%d)
  target_dir="$vault/WorkLog/$project"
  mkdir -p "$target_dir"

  claude -p "使用 obsidian-worklog skill 同步工作日志。transcript 文件：$transcript_path，项目：$project，日期：$date_str，目标目录：$target_dir" \
    --allowedTools "Read,Write" \
    >> "$log_file" 2>&1

  echo "[$(date)] [$session_id] sync finished (exit=$?)" >> "$log_file"
  rm -f "$pid_file"
' </dev/null >> "$log_file" 2>&1 &

disown $!
echo $! > "$pid_file"
