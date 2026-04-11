# .config

Dotfiles managed via `~/.config` with a deny-by-default `.gitignore`.

## 1. Quick Start

```bash
cd ~/.config
git init
git remote add origin git@github.com:kefhuang/.config.git
git fetch
git checkout master
```

## 2. Project Structure

| Path | Purpose |
|------|---------|
| `zsh/` | Zsh config — Zim framework + Powerlevel10k |
| `vim/` | `.vimrc` |
| `tmux/` | Tmux config |
| `aerospace/` | AeroSpace window manager (macOS) |
| `sketchybar/` | SketchyBar status bar (macOS) |
| `ghostty/` | Ghostty terminal (macOS) |
| `raycast/scripts/` | Raycast scripts (macOS) |
| `claude/` | Claude Code config (settings, hooks, scripts) |
| `agents/skills/` | AI agent skills (Claude Code, Codex, Gemini) |

Platform-specific setup: [MAC.md](MAC.md) | [UBUNTU.md](UBUNTU.md)

## 3. Zsh

Zim as the module framework, Powerlevel10k for the prompt.

```bash
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.bak
echo 'source ~/.config/zsh/zshrc' > ~/.zshrc
exec zsh
```

Zim and all modules install automatically on first launch.

### Config Files

| File | Purpose |
|------|---------|
| `zshrc` | Entrypoint — sources all other files |
| `init.zsh` | P10k instant prompt, Zim bootstrap, conda/nvm lazy-load |
| `env.zsh` | `XDG_CONFIG_HOME`, `PATH` |
| `zimrc` | Zim module list (p10k, completions, fzf-tab, zsh-z, syntax highlighting, autosuggestions) |
| `prompt.zsh` | Powerlevel10k lean config |
| `alias.zsh` | Shell aliases |
| `mappings.zsh` | Key bindings |

### Zim Commands

```bash
zimfw install   # install newly added modules
zimfw update    # update all modules
```

## 4. Vim

```bash
[ -f ~/.vimrc ] && mv ~/.vimrc ~/.vimrc.bak
ln -sf ~/.config/vim/.vimrc ~/.vimrc
```

## 5. Tmux

```bash
[ -f ~/.tmux.conf ] && mv ~/.tmux.conf ~/.tmux.conf.bak
ln -sf ~/.config/tmux/tmux.conf ~/.tmux.conf
```

## 6. Miniconda

```bash
mkdir -p ~/Apps/Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-$(uname -s)-$(uname -m).sh -O /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -u -p ~/Apps/Miniconda
rm /tmp/miniconda.sh
~/Apps/Miniconda/bin/conda init zsh
conda config --set auto_activate_base false
```

## 7. Claude Code

```bash
[ -f ~/.claude/settings.json ] && mv ~/.claude/settings.json ~/.claude/settings.json.bak
ln -sf ~/.config/claude/settings.json ~/.claude/settings.json
ln -sf ~/.config/claude/hooks ~/.claude/hooks
ln -sf ~/.config/claude/scripts ~/.claude/scripts
```

### Local Config

`~/.claude/settings.local.json` is for machine-specific settings that should not be tracked in git. Same format as `settings.json`, takes higher priority.

Currently used for:
- `env.OBSIDIAN_VAULT` — Obsidian vault path, used by the worklog hook and skill

Example:
```json
{
  "env": {
    "OBSIDIAN_VAULT": "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/MyVault"
  }
}
```

## 8. Agents

Custom AI agent skills in `agents/skills/`, usable by Claude Code, Codex, and Gemini.

```bash
ln -sf ~/.config/agents/skills ~/.claude/skills
```

## 9. .gitignore

This repo uses a deny-by-default `.gitignore` — everything is ignored unless explicitly whitelisted. To track a new directory:

```gitignore
!newdir/
!newdir/**
```
