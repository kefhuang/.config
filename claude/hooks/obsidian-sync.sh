#!/bin/bash

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id')
cwd=$(echo "$input" | jq -r '.cwd')

[ -z "$session_id" ] || [ "$session_id" = "null" ] && exit 0

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

export OBSIDIAN_SYNC_LOG="$log_file"
export OBSIDIAN_SYNC_PROJECT="$project"
export OBSIDIAN_SYNC_SESSION="$session_id"
export OBSIDIAN_SYNC_PID_FILE="$pid_file"

nohup bash -c '
  echo "[$(date)] [$OBSIDIAN_SYNC_SESSION] scheduled: project=$OBSIDIAN_SYNC_PROJECT" >> "$OBSIDIAN_SYNC_LOG"
  sleep 3600
  echo "[$(date)] [$OBSIDIAN_SYNC_SESSION] woke up, starting sync" >> "$OBSIDIAN_SYNC_LOG"

  if [ -f "$HOME/.claude/settings.local.json" ]; then
    vault=$(jq -r ".env.OBSIDIAN_VAULT // empty" "$HOME/.claude/settings.local.json" | sed "s#^~#$HOME#")
  fi
  vault="${vault:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/KefengsObsidian}"
  date_str=$(date +%Y-%m-%d)
  target_file="$vault/Raw/WorkLog/$date_str.md"
  mkdir -p "$(dirname "$target_file")"

  claude -p --resume "$OBSIDIAN_SYNC_SESSION" --fork-session \
    --allowedTools "Read,Write" \
    --model sonnet \
    "使用 obsidian-worklog skill 同步工作日志。项目：$OBSIDIAN_SYNC_PROJECT，日期：$date_str，目标文件：$target_file" \
    >> "$OBSIDIAN_SYNC_LOG" 2>&1

  echo "[$(date)] [$OBSIDIAN_SYNC_SESSION] sync finished (exit=$?)" >> "$OBSIDIAN_SYNC_LOG"
  rm -f "$OBSIDIAN_SYNC_PID_FILE"
' </dev/null >> "$log_file" 2>&1 &

disown $!
echo $! > "$pid_file"
