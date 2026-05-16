# AGENTS.md

This file gives AI coding agents the repo context needed to work safely in this dotfiles repository.

## Overview

This is a macOS/Linux dotfiles repo rooted at `~/.config`. It stores portable configuration files and deploys them to the locations expected by each tool, usually with symlinks.

The repo intentionally uses a deny-by-default `.gitignore`: files are ignored unless they are explicitly whitelisted. That keeps local caches, app state, secrets, and machine-specific files out of git.

## Managed Config

| Path | Purpose |
|------|---------|
| `zsh/` | Zsh startup files, Zim modules, aliases, key mappings, and Powerlevel10k prompt |
| `vim/` | Vim config |
| `tmux/` | Tmux config |
| `ghostty/` | Ghostty terminal config |
| `claude/` | Claude Code settings, hooks, scripts, and workspace instructions |
| `agents/skills/` | Shared AI agent skills usable across compatible agents |

Platform setup notes live in `MAC.md` and `UBUNTU.md`.

## Install

Clone or restore the repo at `~/.config`:

```bash
git clone git@github.com:kefhuang/.config.git ~/.config
```

If `~/.config` already exists, initialize in place:

```bash
cd ~/.config
git init
git remote add origin git@github.com:kefhuang/.config.git
git fetch
git checkout master
```

Install the shell entrypoint:

```bash
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.bak
echo 'source ~/.config/zsh/zshrc' > ~/.zshrc
exec zsh
```

Install symlinks for the tracked configs you want on the machine:

```bash
[ -f ~/.vimrc ] && mv ~/.vimrc ~/.vimrc.bak
ln -sf ~/.config/vim/.vimrc ~/.vimrc

[ -f ~/.tmux.conf ] && mv ~/.tmux.conf ~/.tmux.conf.bak
ln -sf ~/.config/tmux/tmux.conf ~/.tmux.conf

[ -f ~/.claude/settings.json ] && mv ~/.claude/settings.json ~/.claude/settings.json.bak
ln -sf ~/.config/claude/settings.json ~/.claude/settings.json
ln -sf ~/.config/claude/hooks ~/.claude/hooks
ln -sf ~/.config/claude/scripts ~/.claude/scripts
ln -sf ~/.config/agents/skills ~/.claude/skills
```

Zim bootstraps automatically on first Zsh launch. To update Zim modules later:

```bash
zimfw install
zimfw update
```

## Local Files

Keep machine-specific config outside git. For Claude Code, use `~/.claude/settings.local.json`; this is currently where `env.OBSIDIAN_VAULT` belongs for the Obsidian worklog hook.

Do not commit app caches, local session state, telemetry, generated history, or secrets. If a new config should be tracked, add a targeted whitelist rule to `.gitignore`.

## Editing Rules

- Keep changes scoped to the managed config files.
- Shell scripts must be executable after creation or modification.
- Follow the existing symlink-based deployment pattern.
- Do not add broad `.gitignore` allow rules; whitelist only the directory or file that should be tracked.

## Reload Commands

| Tool | Command |
|------|---------|
| Zsh | `source ~/.config/zsh/zshrc` |
| Tmux | `tmux source-file ~/.config/tmux/tmux.conf` |
