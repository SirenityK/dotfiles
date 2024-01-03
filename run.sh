#!/bin/bash

BASEDIR=`dirname "$0"`

# install python environment?
read -p 'Install python virtual environment? [textToConfirm]: ' install_python
if [ -n $install_python ]; then
    venv=python-virtualenv
    dvenv=python3-virtualenv
    tvenv=python
fi

# detect if termux
if [ -d '/data/data/com.termux' ]; then
    TERMUX=true
    echo 'Termux detected'
    pkg update -y
    pkg upgrade -y
    pkg install lsd bat zsh zsh-completions neovim wget tmux fd ugrep dua $tvenv -y

# detect if debian
elif [ -f '/etc/debian_version' ]; then
    echo 'Debian detected'
    apt update -y
    apt upgrade -y
    sudo apt install lsd bat zsh zsh-completions neovim thefuck kitty wget tmux fd-find ugrep $dvenv -y
    mkdir ~/.local/share/fonts
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -P ~/.local/share/fonts/

# detect if arch
elif [ -f '/etc/arch-release' ]; then
    echo 'Arch detected'
    sudo pacman -Syuv lsd bat zsh zsh-completions neovim thefuck kitty wget tmux dua-cli fd ugrep $venv --noconfirm
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

#mkdir -p ~/miniconda3
#wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
#bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
#rm -rf ~/miniconda3/miniconda.sh

#~/miniconda3/bin/conda init zsh

mkdir ~/.local/share/fonts
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -P ~/.local/share/fonts/

# Copy all repo files to home directory, subfolders are copied recursively
cp $BASEDIR/p10k/.p10k_desktop.zsh ~/.p10k.zsh
cp $BASEDIR/.xprofile ~
cp -r $BASEDIR/.config ~

cp $BASEDIR/p10k/.p10k.zsh ~/.p10k.zsh
cat $BASEDIR/extensions.txt >> ~/.zshrc
cat $BASEDIR/.zshrc >> ~/.zshrc

if [ -n $install_python ]; then
    python3 -m pip install -U pip wheel setuptools virtualenv
    virtualenv ~/.venv
    echo 'source ~/.venv/bin/activate' >> ~/.zshrc
    
    read -p 'Install life-elemental python packages? [textToConfirm]: ' pip
    if [ -n $pip ]; then
        source ~/.venv/bin/activate
        pip install yt-dlp
        # room for more
    fi
fi

exit
