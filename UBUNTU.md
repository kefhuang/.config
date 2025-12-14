# Ubuntu Setup
Last Modified: 14/12/2025

## Step by Step

### Nvidia Driver
1. Update software sources
    ```
    sudo apt update
    sudo apt upgrade -y
    ```
2. Automatically detect and install recommended drivers: This is the safest method, as the system will automatically match the graphics card model
    ```
    sudo ubuntu-drivers autoinstall
    ```
3. Reboot Computer
    ```
    sudo reboot
    ```
4. Verify installation with
    ```
    nvidia-smi
    ```

### Remote Access
1. Install SSH Service
    ```
    sudo apt install -y openssh-server
    sudo systemctl enable ssh
    sudo systemctl start ssh
    ```
2. Install XRDP
    ```
    sudo apt install -y xrdp
    sudo systemctl enable xrdp
    sudo systemctl start xrdp
    ```
3. Fix potential XRDP black screen/crash issues on Ubuntu (configure ssl-cert user group)
    ```
    sudo adduser xrdp ssl-cert
    ```
4. Allow traffic through the firewall
    ```
    sudo ufw allow ssh
    sudo ufw allow 3389
    ```

### Essentials
```
sudo apt install curl git vim

git config --global user.name "kefhuang"
git config --global user.email "aqr.kefhuang@gmail.com"
git config --global core.editor vim
```

#### ZSH
1. Install ZSH
    ```
    sudo apt install zsh
    chsh -s $(which zsh)
    ```
2. Install OMZ
    ```
    # Oh my Zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ```
3. Install Font
    ```
    wget -O "$HOME/Downloads/MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    wget -O "$HOME/Downloads/MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    wget -O "$HOME/Downloads/MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    wget -O "$HOME/Downloads/MesloLGS NF Bold Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
    sudo mkdir -p /usr/share/fonts/truetype/MesloLGS
    sudo mv "$HOME/Downloads/MesloLGS NF Regular.ttf" /usr/share/fonts/truetype/MesloLGS/MesloLGS\ NF\ Regular.ttf
    sudo mv "$HOME/Downloads/MesloLGS NF Bold.ttf" /usr/share/fonts/truetype/MesloLGS/MesloLGS\ NF\ Bold.ttf
    sudo mv "$HOME/Downloads/MesloLGS NF Italic.ttf" /usr/share/fonts/truetype/MesloLGS/MesloLGS\ NF\ Italic.ttf
    sudo mv "$HOME/Downloads/MesloLGS NF Bold Italic.ttf" /usr/share/fonts/truetype/MesloLGS/MesloLGS\ NF\ Bold\ Italic.ttf
    fc-cache -f -v
    ```
4. Install P10K
    ```
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    ```
5. OMZ Extensions
    ```
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    ```
6. Import Configs
    ```
    mkdir ~/Apps
    cd ~/Apps
    git clone https://github.com/kefhuang/config.git

    cd ~/Apps/config
    if [ -f "$HOME/.zshrc" ]; then
        rm "$HOME/.zshrc"
    fi
    ln -s `pwd`/configs/.common.zshrc $HOME/.common.zshrc
    ln -s `pwd`/configs/.p10k.zsh $HOME/.p10k.zsh
    ln -s `pwd`/configs/.vimrc $HOME/.vimrc
    ```
7. Setup `.zshrc`
    ```
    echo 'if [ -f ~/.common.zshrc ]; then
        source ~/.common.zshrc
    fi' >> $HOME/.zshrc
    ```

#### Miniconda
1. Install Miniconda
    ```
    mkdir -p ~/Apps/Miniconda
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/Apps/Miniconda/miniconda.sh
    bash ~/Apps/Miniconda/miniconda.sh -b -u -p ~/Apps/Miniconda
    rm ~/Apps/Miniconda/miniconda.sh
    ```
2. Shell Initialization
    ```
    source ~/Apps/Miniconda/bin/activate
    conda init zsh
    ```
3. Prevent auto activate base
    ```
    conda config --set auto_activate false
    ```

#### 1Password
```
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/ curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
sudo apt update && sudo apt install 1password
```
Source: https://support.1password.com/install-linux/#debian-or-ubuntu

#### Dropbox
Source: https://www.dropbox.com/install-linux


#### Docker
```
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker run --rm hello-world
```

#### Nvidia-Container Toolkit
```
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
```


## System

### Modify Keyboard
Install `xcape`
```bash
sudo apt install xcape
```

```
echo "setxkbmap -option 'caps:ctrl_modifier' && xcape -e 'Caps_Lock=Escape'" >> ~/.zshrc.local
```

### Remove Desktop Icon
```bash
gsettings set org.gnome.shell.extensions.desktop-icons show-home false
gsettings set org.gnome.shell.extensions.desktop-icons show-trash false
```

### Natural Scrolling
```bash
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true
```

### Chinese Input
```bash
sudo apt install fcitx5
sudo apt install fcitx5-chinese-addons
sudo apt install fcitx5-frontend-gtk4 fcitx5-frontend-gtk3 fcitx5-frontend-gtk2 fcitx5-frontend-qt5
```

Download chinese dict
```bash
wget https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/0.2.5/zhwiki-20240909.dict
mkdir -p  ~/.local/share/fcitx5/pinyin/dictionaries/
mv zhwiki-20240909.dict  ~/.local/share/fcitx5/pinyin/dictionaries/
```

Change Input Method to fcitx5
```bash
im-confg
```

Change `/etc/profile`
```bash
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
```

remove ibus
```
sudo apt remove ibus
```

Then go to settings -> Region & Language -> Manage Installed Languages ->
Keyboard Input method system -> fcitx

Logout and login again

## Packages


# Windows Management

```
sudo apt install gnome-tweaks gnome-shell-extensions
```

save gtile config
```
dconf dump /org/gnome/shell/extensions/gtile/ > my-custom-gtile-configs.conf
```


load gtile config
```
dconf load /org/gnome/shell/extensions/gtile/ < my-custom-gtile-configs.conf
```
