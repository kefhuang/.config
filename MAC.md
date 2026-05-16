# macOS Setup

## 1. Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 2. Packages

Formulae:
```bash
brew install git ripgrep fd fzf bat jq tree coreutils yazi neovim tmux wget gh htop dust gemini-cli
```

Casks:
```bash
brew install --cask ghostty claude codex
```

Font:
```bash
brew install --cask font-maple-mono-nf-cn
```

## 3. Karabiner Elements

Map CapsLock to both Ctrl (held) and Esc (tapped):

1. Install [Karabiner Elements](https://karabiner-elements.pqrs.org/)
2. Import [Caps Lock to Esc, Ctrl and Numpad](https://ke-complex-modifications.pqrs.org/#CapsLockToEscCtrlNumPad)
3. Enable the modification

## 4. Dock

Hide the dock with a 2-second delay:
```bash
defaults write com.apple.dock autohide-delay -float 2; killall Dock
```

To restore:
```bash
defaults delete com.apple.dock autohide-delay; killall Dock
```
