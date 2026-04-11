# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

macOS/Linux dotfiles repo living at `~/.config`. Configuration is deployed via symlinks from this repo to their expected locations.

## Key Conventions

- **Deny-by-default `.gitignore`** — everything is ignored unless explicitly whitelisted with `!dir/` + `!dir/**`. New directories must be added to `.gitignore` before they can be tracked.
- **Shell scripts must be executable** — always `chmod +x` after creating.
- **`~/.claude/settings.local.json` is not tracked** — machine-specific config (e.g. Obsidian vault path) goes there.
- **`agents/skills/`** is platform-agnostic — skills work with Claude Code, Codex, and Gemini.

## Reload Commands

| Tool | Command |
|------|---------|
| AeroSpace | `aerospace reload-config` |
| SketchyBar | `sketchybar --reload` |
| Zsh | `source ~/.config/zsh/zshrc` |

## Zsh Sourcing Chain

`~/.zshrc` → `zsh/zshrc` → `init.zsh` → `env.zsh` → `alias.zsh` → `mappings.zsh` → `prompt.zsh`

Zim bootstraps automatically on first launch. Modules are declared in `zsh/zimrc`.

## Symlink Deployment

```
~/.zshrc                    → sources ~/.config/zsh/zshrc (not a symlink, contains one line)
~/.vimrc                    → vim/.vimrc
~/.tmux.conf                → tmux/tmux.conf
~/.claude/settings.json     → claude/settings.json
~/.claude/hooks             → claude/hooks/
~/.claude/scripts           → claude/scripts/
~/.claude/skills            → agents/skills/
```
