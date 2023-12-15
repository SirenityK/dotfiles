BASEDIR=`dirname "$0"`

# install python environment?
read -p 'Install python virtual environment? [y/n]: ' install_python
if [ $python = 'y' ]; then
    python=python3
    venv=virtualenv
fi

# detect if termux
if [ -d '/data/data/com.termux' ]; then
    TERMUX=true
    echo 'Termux detected'
    pkg install lsd bat zsh zsh-completions neovim wget tmux $python $venv -y

# detect if debian
elif [ -f '/etc/debian_version' ]; then
    sudo apt install lsd bat zsh zsh-completions neovim thefuck kitty wget tmux $python $venv -y
fi

# detect if arch
elif [ -f '/etc/arch-release' ]; then
    echo 'Arch detected'
    sudo pacman -Sv lsd bat zsh zsh-completions neovim thefuck kitty wget tmux $python $venv --noconfirm
    mkdir ~/.local/share/fonts
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -P ~/.local/share/fonts/

if [ ! $TERMUX ]; then
    cp $BASEDIR/.xprofile ~
    cp -r $BASEDIR/.config ~
fi

# zinit
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

cp $BASEDIR/p10k/.p10k.zsh ~/.p10k.zsh
cat $BASEDIR/extensions.txt >> ~/.zshrc
cat $BASEDIR/.zshrc >> ~/.zshrc

if [ $install_python ]; then
    virtualenv .venv
    echo 'source ~/.venv/bin/activate' >> .zshrc
fi

read -p 'Install life-elemental python packages?' pip
if [ $pip ]; then
    pip install yt-dlp
    # room for more
    
fi
