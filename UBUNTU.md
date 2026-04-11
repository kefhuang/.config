# Ubuntu Setup

## 1. Essentials

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git vim zsh
chsh -s $(which zsh)
```

```bash
git config --global user.name "kefhuang"
git config --global user.email "kefhuang@outlook.com"
git config --global core.editor vim
```

## 2. Font

Install Maple Mono NF CN:
```bash
wget -O /tmp/maple-font.zip https://github.com/subframe7536/maple-font/releases/latest/download/MapleMono-NF-CN.zip
unzip /tmp/maple-font.zip -d /tmp/maple-font
sudo mkdir -p /usr/share/fonts/truetype/maple-mono
sudo mv /tmp/maple-font/*.ttf /usr/share/fonts/truetype/maple-mono/
fc-cache -f -v
rm -rf /tmp/maple-font /tmp/maple-font.zip
```

## 3. Nvidia Driver

```bash
sudo ubuntu-drivers autoinstall
sudo reboot
```

Verify:
```bash
nvidia-smi
```

## 4. Remote Access

### SSH
```bash
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
sudo ufw allow ssh
```

### XRDP
```bash
sudo apt install -y xrdp
sudo systemctl enable xrdp
sudo systemctl start xrdp
sudo adduser xrdp ssl-cert
sudo ufw allow 3389
```
