#!/bin/bash

set -e

BASEDIR=$(dirname "$0")

find_distribution() {
    if [ -f '/etc/debian_version' ]; then
        echo 'debian'
    elif [ -f '/etc/arch-release' ]; then
        echo 'arch'
    elif [ -d '/data/data/com.termux' ]; then
        echo 'termux'
    elif [ -f '/etc/gentoo-release' ]; then
        echo 'gentoo'
    else
        echo 'unknown'
    fi
}

append() {
    if [ -f "$BASEDIR/$1" ]; then
        cat $BASEDIR/$1 >>~/.zshrc
    else
        echo $1 >>~/.zshrc
    fi
}

GENERAL_PACKAGES="zsh curl lsd ripgrep bat wget tmux vim"
TERMUX_PACKAGES=$GENERAL_PACKAGES" zoxide fd-find zsh-completions dua"
DEBIAN_PACKAGES=$GENERAL_PACKAGES" fd-find kitty thefuck"
ARCH_PACKAGES=$GENERAL_PACKAGES" zoxide dua-cli zsh-completions kitty thefuck fd"
DISTRO=$(find_distribution)

# detect if termux
if [ "$DISTRO" = 'termux' ]; then
    TERMUX=true
    echo 'Termux detected'
    pkg update -y
    pkg upgrade -y
    pkg install -y $TERMUX_PACKAGES

# detect if debian
elif [ "$DISTRO" = 'debian' ]; then
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
elif [ "$DISTRO" = 'arch' ]; then
    echo 'Arch detected'
    sudo pacman -Syuv --noconfirm --needed $ARCH_PACKAGES

# detect if gentoo
elif [ "$DISTRO" = 'gentoo' ]; then
    echo 'Gentoo detected'
    sudo emerge -n zsh zsh-completions neovim kitty wget tmux
    cargo install lsd bat fd-find dua-cli zoxide ripgrep17
fi

if [ ! $TERMUX ]; then
    cp -r $BASEDIR/.config ~
    sudo chsh sirenityk -s $(cat /etc/shells | grep zsh | tail -1)
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -P ~/.local/share/fonts/
else
    chsh -s zsh
fi

# zinit
yes | bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

cp $BASEDIR/p10k/.p10k.zsh ~/.p10k.zsh
append .extensions.sh
append .zshrc

# arch
if [ "$DISTRO" = 'arch' ]; then
    append .zshrc-arch.sh
fi
# debian
if [ "$DISTRO" = 'debian' ]; then
    append .zshrc-debian.sh
else
    append "alias cat=bat"
    append "alias find=fd"
fi

append aliases.sh
append .zshrc-end.sh

exit 0
