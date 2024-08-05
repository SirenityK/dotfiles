#!/bin/bash

set -e

BASEDIR=$(dirname "$0")

# detect if termux
if [ -d '/data/data/com.termux' ]; then
    TERMUX=true
    echo 'Termux detected'
    pkg update -y
    pkg upgrade -y
    pkg install lsd bat zsh zsh-completions neovim wget tmux fd-find ripgrep dua curl wget zoxide -y

# detect if debian
elif [ -f '/etc/debian_version' ]; then
    echo 'Debian detected'
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install lsd bat zsh neovim thefuck kitty wget tmux fd-find ripgrep curl wget -y
    # zoxide
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    # dua
    curl -LSfs https://raw.githubusercontent.com/Byron/dua-cli/master/ci/install.sh |
        sh -s -- --git Byron/dua-cli --target x86_64-unknown-linux-musl --crate dua --tag v2.17.4

# detect if arch
elif [ -f '/etc/arch-release' ]; then
    echo 'Arch detected'
    sudo pacman -Syuv --noconfirm --needed lsd bat zsh zsh-completions neovim thefuck kitty wget tmux dua-cli fd ripgrep curl wget zoxide

# detect if gentoo
elif [ -f '/etc/gentoo-release' ]; then
    echo 'Gentoo detected'
    sudo emerge -n zsh zsh-completions neovim kitty wget tmux
    cargo install lsd bat fd-find dua-cli zoxide ripgrep
fi

if [ ! $TERMUX ]; then
    cp -r $BASEDIR/.config ~
    sudo chsh sirenityk -s `cat /etc/shells | grep zsh | tail -1`
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -P ~/.local/share/fonts/
else
    chsh -s zsh
fi

# zinit
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

cp $BASEDIR/p10k/.p10k.zsh ~/.p10k.zsh
cat $BASEDIR/extensions.txt >>~/.zshrc
cat $BASEDIR/.zshrc >>~/.zshrc

exit 0
