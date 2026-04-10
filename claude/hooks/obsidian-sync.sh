#!/bin/bash

input=$(cat)
transcript_path=$(echo "$input" | jq -r '.transcript_path')
session_id=$(echo "$input" | jq -r '.session_id')
cwd=$(echo "$input" | jq -r '.cwd')

[ -z "$transcript_path" ] || [ "$transcript_path" = "null" ] && exit 0

project=$(cd "$cwd" 2>/dev/null && git remote get-url origin 2>/dev/null \
  | sed 's#.*/##;s#\.git$##')
[ -z "$project" ] && project=$(basename "$cwd")

pid_file="/tmp/claude-obsidian-${session_id}.pid"
if [ -f "$pid_file" ]; then
  old_pid=$(cat "$pid_file")
  kill "$old_pid" 2>/dev/null
  wait "$old_pid" 2>/dev/null
fi

(
  sleep 3600

  vault="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/KefengsObsidian"
  date_str=$(date +%Y-%m-%d)
  target_dir="$vault/WorkLog/$project"
  mkdir -p "$target_dir"

  claude -p --allowedTools "Read,Write" \
    "使用 obsidian-worklog skill 同步工作日志。transcript 文件：$transcript_path，项目：$project，日期：$date_str，目标目录：$target_dir"

  rm -f "$pid_file"
) &

echo $! > "$pid_file"
