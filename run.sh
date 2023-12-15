BASEDIR=`dirname "$0"`

# install python environment?
read -p 'Install python virtual environment? [textToConfirm]: ' install_python
if [ -n $install_python ]; then
    venv=python-virtualenv
    dvenv=python3-virtualenv
fi

# detect if termux
if [ -d '/data/data/com.termux' ]; then
    TERMUX=true
    echo 'Termux detected'
    pkg install lsd bat zsh zsh-completions neovim wget tmux $dvenv -y

# detect if debian
elif [ -f '/etc/debian_version' ]; then
    echo 'Debian detected'
    sudo apt install lsd bat zsh zsh-completions neovim thefuck kitty wget tmux $dvenv -y
    mkdir ~/.local/share/fonts
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -P ~/.local/share/fonts/

# detect if arch
elif [ -f '/etc/arch-release' ]; then
    echo 'Arch detected'
    sudo pacman -Sv lsd bat zsh zsh-completions neovim thefuck kitty wget tmux $venv --noconfirm
    mkdir ~/.local/share/fonts
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -P ~/.local/share/fonts/
fi

if [ ! $TERMUX ]; then
    cp $BASEDIR/.xprofile ~
    cp -r $BASEDIR/.config ~
fi

# zinit
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

cp $BASEDIR/p10k/.p10k.zsh ~/.p10k.zsh
cat $BASEDIR/extensions.txt >> ~/.zshrc
cat $BASEDIR/.zshrc >> ~/.zshrc

if [ -n $install_python ]; then
    python3 -m pip install -U pip wheel setuptools virtualenv
    virtualenv .venv
    echo 'source ~/.venv/bin/activate' >> .zshrc
    
    read -p 'Install life-elemental python packages? [textToConfirm]: ' pip
    if [ -n $pip ]; then
        source ~/.venv/bin/activate
        pip install yt-dlp
        # room for more
    fi
fi
