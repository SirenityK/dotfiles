#!/bin/env bash

set -e

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
    append '' $1
}

yn() {
    if [ -f /.dockerenv ]; then
        return false
    fi
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

if [ -f '/etc/debian_version' ]; then
    DEBIAN=true
elif [ -f '/etc/arch-release' ]; then
    ARCH=true
elif [ -d '/data/data/com.termux' ]; then
    TERMUX=true
elif [ -f '/etc/gentoo-release' ]; then
    GENTOO=true
fi

(yn "Install pyenv?" || [ $PYENV ]) && {
    append_endline
    append '# pyenv'
    append 'export PYENV_ROOT="$HOME/.pyenv"'
    append '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
    append 'eval "$(pyenv init - zsh)"'
    append 'eval "$(pyenv virtualenv-init -)"'
    append '# end pyenv'
    append_endline
    curl https://pyenv.run | bash
    if [ $DEBIAN ]; then
        sudo apt install -y build-essential libssl-dev zlib1g-dev \
            libbz2-dev libreadline-dev libsqlite3-dev curl git \
            libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    fi
}

(yn "Install uv?" || [ $UV ]) && {
    if [ $TERMUX ]; then
        apt install uv
    elif [ $ARCH ]; then
        sudo pacman -S --needed --noconfirm uv
    elif [ $DEBIAN ]; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    elif [ $GENTOO ]; then
        cargo install --git https://github.com/astral-sh/uv uv
    fi

    append '# uv'
    if ! [ $ARCH ]; then
        append 'eval "$(uv generate-shell-completion zsh)"'
    fi
    append 'eval "$(uvx --generate-shell-completion zsh)"'
    append "alias uvp='UV_SYSTEM_PYTHON=true uv pip'"
    append '# end uv'
    append_endline
}

(yn "Install nvm?" || [ $NVM ]) && {
    append '# nvm'
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
    append '# end nvm'
    append_endline
}

if [ $TERMUX ]; then
    yn "Setup storage?" && {
        termux-setup-storage
    }
    yn "Initialize ssh-server?" && {
        FLAG_FILE=~/.termux-setup-continue.sh
        touch $FLAG_FILE
        pkg install -y termux-services openssh
        mkdir -p ~/.termux/boot
        append "sv-enable sshd" $FLAG_FILE
        append 'echo "Setup complete!"' $FLAG_FILE
        append '# services'
        append "[ -f $FLAG_FILE ] && source $FLAG_FILE && rm $FLAG_FILE"
        append '# end services'
        append '#!/data/data/com.termux/files/usr/bin/sh' ~/.termux/boot/start-services
        append 'termux-wake-lock' ~/.termux/boot/start-services
        append '. $PREFIX/etc/profile' ~/.termux/boot/start-services
        append_endline ~/.termux/boot/start-services
        yn "Update the password" && {
            passwd
        }
        yn "To continue, you need to restart termux. Continue?" && {
            am startservice -a com.termux.service_stop com.termux/.app.TermuxService
        }
    }
fi
