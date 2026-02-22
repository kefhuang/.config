# .config

Dotfiles managed via `~/.config` with Zim as the zsh framework and Powerlevel10k as the prompt.

## 1. Quick Start

```bash
git clone git@github.com:kefhuang/.config.git ~/.config
echo 'source ~/.config/zsh/zshrc' > ~/.zshrc
exec zsh
```

Zim and all modules install automatically on first launch.

## 2. Prerequisites

Install Homebrew:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Install and configure git:
```bash
brew install git
git config --global user.name "kefhuang"
git config --global user.email "kefhuang@outlook.com"
git config --global core.editor vim
```

Ensure writable paths:
```bash
mkdir -p ~/.local/bin ~/.zim ~/.cache
```

## 3. Symlinks

```bash
ln -sf ~/.config/vim/.vimrc ~/.vimrc
```

## 4. Brew Packages

Formulae:
```bash
brew install git ripgrep fd fzf bat jq tree coreutils yazi neovim tmux wget gh htop dust gemini-cli
```

Casks:
```bash
brew install --cask claude codex
```

## 5. Zsh Setup

The shell is configured through `~/.config/zsh/` with Zim as the module framework and Powerlevel10k for the prompt.

`~/.zshrc` contains a single line — `source ~/.config/zsh/zshrc` — which sources everything below.

### Config Files

| File | Purpose |
|------|---------|
| `zshrc` | Entrypoint — sources all other files |
| `init.zsh` | P10k instant prompt, Zim bootstrap (auto-downloads `zimfw.zsh`), conda/nvm lazy-load |
| `env.zsh` | `XDG_CONFIG_HOME`, `PATH` |
| `zimrc` | Zim module list (p10k, completions, fzf-tab, zsh-z, syntax highlighting, autosuggestions) |
| `prompt.zsh` | Powerlevel10k lean config |
| `alias.zsh` | Shell aliases |
| `mappings.zsh` | Key bindings (`^y` → autosuggest-accept) |

### Day-to-Day Zim Commands

Zim bootstraps itself on first shell launch (`init.zsh` downloads `zimfw.zsh` and compiles modules automatically). These commands are for after you edit `zimrc`:

```bash
zimfw install   # install newly added modules
zimfw update    # update all modules
```

## 6. upgrade-all Spec

`bin/upgrade-all` should be an idempotent setup-and-update script:

1. **Pre-flight** — verify Homebrew and git are installed, writable paths exist (`~/.local/bin`, `~/.zim`, `~/.cache`)
2. **Config** — ensure `source ~/.config/zsh/zshrc` is the first line in `~/.zshrc`; ensure `~/.vimrc` symlink points to `~/.config/vim/.vimrc`
3. **Brew** — install any missing formulae/casks from Section 4, then `brew update && brew upgrade --greedy`
4. **Zim** — ensure `~/.zim/zimfw.zsh` exists (download if missing), then `zimfw install && zimfw update`
5. **Parallel** — brew update and zim update can run concurrently (with spinner UI)

### .gitignore

The repo uses a deny-by-default `.gitignore`. To track `bin/upgrade-all`, add:
```gitignore
!bin/
!bin/**
```
