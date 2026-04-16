# Claude Code Workspace Manager

This directory manages Claude Code workspaces. Each workspace is a subfolder under this directory.

## Workspace Management

All workspace management MUST use tmux. Follow these rules:

### Creating a New Workspace

1. Create a subfolder in this directory for the workspace (e.g., `my-project/`).
2. Initialize a git repository in the new folder:
   ```bash
   git init ~/.config/claude/workspace/<workspace-name>
   ```
3. Spawn a new tmux session named after the workspace:
   ```bash
   tmux new-session -d -s <workspace-name> -c ~/.config/claude/workspace/<workspace-name>
   ```
3. Inside that tmux session, start Claude Code with remote control and dangerously skip permissions:
   ```bash
   tmux send-keys -t <workspace-name> 'claude --dangerously-skip-permissions --remote-control --name "<Human-Readable Session Name>"' Enter
   ```
4. Wait a few seconds, then read the tmux session output to confirm Claude Code started successfully:
   ```bash
   tmux capture-pane -t <workspace-name> -p
   ```

### Conventions

- **Folder naming**: lowercase only, words separated by hyphens (e.g., `my-project`, `data-pipeline`).
- **Tmux session name** = workspace folder name.
- **Claude Code session name** (`--name`): use a human-readable name (does not need to follow the folder naming convention). E.g., folder `data-pipeline` could have session name `"Data Pipeline Refactor"`.
- Always check if a tmux session with that name already exists before creating one (`tmux has-session -t <name> 2>/dev/null`).
- Always check if the workspace subfolder already exists before creating one.
