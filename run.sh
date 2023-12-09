BASEDIR=`dirname "$0"`

sudo pacman -S lsd bat zsh zsh-completions neovim thefuck kitty wget tmux --noconfirm

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

cat $BASEDIR/.zshrc >> ~/.zshrc
cat $BASEDIR/strings.txt >> ~/.zshrc
