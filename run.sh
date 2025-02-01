#!/bin/bash

set -e

BASEDIR=$(dirname "$0")

append() {
    if [ -f "$BASEDIR/$1" ]; then
        cat $BASEDIR/$1 >>~/.zshrc
    else
        echo $1 >>~/.zshrc
    fi
}

GENERAL_PACKAGES="zsh curl lsd ripgrep bat wget tmux vim"
TERMUX_PACKAGES=$GENERAL_PACKAGES" zoxide fd zsh-completions dua"
DEBIAN_PACKAGES=$GENERAL_PACKAGES" fd-find kitty thefuck"
ARCH_PACKAGES=$GENERAL_PACKAGES" zoxide dua-cli zsh-completions kitty thefuck fd"
if [ -f '/etc/debian_version' ]; then
    DEBIAN=true
elif [ -f '/etc/arch-release' ]; then
    ARCH=true
elif [ -d '/data/data/com.termux' ]; then
    TERMUX=true
elif [ -f '/etc/gentoo-release' ]; then
    GENTOO=true
fi

# detect if termux
if [ $TERMUX ]; then
    echo 'Termux detected'
    pkg update -y
    pkg upgrade -y
    yes | pkg install -y $TERMUX_PACKAGES

# detect if debian
elif [ $DEBIAN ]; then
    echo 'Debian detected'
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install -y $DEBIAN_PACKAGES
    # zoxide
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    # dua
    curl -LSfs https://raw.githubusercontent.com/Byron/dua-cli/master/ci/install.sh |
        sh -s -- --git Byron/dua-cli --target x86_64-unknown-linux-musl --crate dua --tag v2.29.0

# detect if arch
elif [ $ARCH ]; then
    echo 'Arch detected'
    sudo pacman -Syuv --noconfirm --needed $ARCH_PACKAGES

# detect if gentoo
elif [ $GENTOO ]; then
    echo 'Gentoo detected'
    sudo emerge -n zsh zsh-completions neovim kitty wget tmux
    cargo install lsd bat fd-find dua-cli zoxide ripgrep17
fi

LINK=https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
if [ ! $TERMUX ]; then
    cp -r $BASEDIR/.config ~
    sudo chsh sirenityk -s $(cat /etc/shells | grep zsh | tail -1)
    wget $LINK -P ~/.local/share/fonts/
else
    wget $LINK -O ~/.termux/font.ttf
    termux-reload-settings
    chsh -s zsh
fi

# zinit
yes | bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

cp $BASEDIR/p10k/.p10k.zsh ~/.p10k.zsh
append .extensions.sh
append .zshrc

# unique aliases
[ $ARCH ] && append .zshrc-arch.sh
[ $TERMUX ] && append .zshrc-termux.sh

# special aliases due to debian's funky package names
if [ $DEBIAN ]; then
    append .zshrc-debian.sh
else
    append "alias cat=bat"
    append "alias find=fd"
fi

append aliases.sh
append .zshrc-end.sh

zsh -ic 'source ~/.local/share/zinit/plugins/romkatv---powerlevel10k/gitstatus/install'

source $BASEDIR/tools/prompt.sh

if [ $TERMUX ]; then
    echo 'Restart termux to apply changes'
else
    echo 'Restart your session to apply changes'
fi

exit 0
