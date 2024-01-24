#!/bin/bash

BASEDIR=`dirname "$0"`

sudo true
# detect if termux
if [ -d '/data/data/com.termux' ]; then
    TERMUX=true
    echo 'Termux detected'
    pkg update -y
    pkg upgrade -y
    pkg install lsd bat zsh zsh-completions neovim wget tmux fd-find ugrep curl wget -y

# detect if debian
elif [ -f '/etc/debian_version' ]; then
    echo 'Debian detected'
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install lsd bat zsh zsh-completions neovim thefuck kitty wget tmux fd-find ugrep curl wget -y
    mkdir ~/.local/share/fonts
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -P ~/.local/share/fonts/

# detect if arch
elif [ -f '/etc/arch-release' ]; then
    echo 'Arch detected'
    sudo pacman -Syuv --noconfirm lsd bat zsh zsh-completions neovim thefuck kitty wget tmux dua-cli fd ugrep curl wget
    mkdir ~/.local/share/fonts
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -P ~/.local/share/fonts/
fi

if [ ! $TERMUX ]; then
    cp $BASEDIR/.xprofile ~
    cp -r $BASEDIR/.config ~
    chsh -s `command -v zsh`
else
    chsh -s zsh
fi

# zinit
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

mkdir ~/.local/share/fonts
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -P ~/.local/share/fonts/

# Copy all repo files to home directory, subfolders are copied recursively
cp $BASEDIR/.xprofile ~
cp -r $BASEDIR/.config ~

cp $BASEDIR/p10k/.p10k.zsh ~/.p10k.zsh
cat $BASEDIR/extensions.txt >> ~/.zshrc
cat $BASEDIR/.zshrc >> ~/.zshrc

exit
