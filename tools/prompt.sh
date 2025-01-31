#!/bin/bash

set -e

find_distribution() {
    if [ -f '/etc/debian_version' ]; then
        DEBIAN=true
    elif [ -f '/etc/arch-release' ]; then
        ARCH=true
    elif [ -d '/data/data/com.termux' ]; then
        TERMUX=true
    elif [ -f '/etc/gentoo-release' ]; then
        GENTOO=true
    fi
}

append() {
    if [ $2 ]; then
        if ! [ -f $2 ]; then
            touch $2
        fi
        echo $1 >>$2
    else
        echo $1 >>~/.zshrc
    fi
}

append_endline() {
    echo >>~/.zshrc
}

yn() {
    local prompt="$1"
    local default="${2:-n}"
    local response

    while true; do
        read -p "$prompt (y/n) " response
        case $response in
        [yY]*)
            return 0
            ;;
        [nN]*)
            return 1
            ;;
        *)
            if [ -z "$response" ]; then
                case $default in
                [yY]*)
                    return 0
                    ;;
                [nN]*)
                    return 1
                    ;;
                esac
            fi
            ;;
        esac
    done
}

yn "Install pyenv?" && {
    curl https://pyenv.run | bash
    append 'export PYENV_ROOT="$HOME/.pyenv"'
    append '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
    append 'eval "$(pyenv init - bash)"'
    append 'eval "$(pyenv virtualenv-init -)"'
}

yn "Install uv?" && {
    if [ $TERMUX || $DEBIAN ]; then
        apt install uv
    elif [ $ARCH]; then
        sudo pacman -S --needed --noconfirm uv
    elif [ $GENTOO ]; then
        cargo install --git https://github.com/astral-sh/uv uv
    fi

    append '# uv'
    append 'eval "$(uv generate-shell-completion zsh)"'
    append 'eval "$(uvx --generate-shell-completion zsh)"'
    append 'alias uvp='uv pip --system''
    append '# end uv'
    append_endline
}

yn "Install nvm?" && {
    append '# start nvm'
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    append '# end nvm'
    append_endline
}

if [ $TERMUX ]; then
    yn "Install ssh-server?" && {
        pkg install -y termux-services openssh
        mkdir -p ~/.termux/boot
        sv-enable sshd
        append '#!/data/data/com.termux/files/usr/bin/sh' ~/.termux/boot/start-services
        append 'termux-wake-lock' ~/.termux/boot/start-services
        append '. $PREFIX/etc/profile' ~/.termux/boot/start-services
    }
fi
