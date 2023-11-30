BASEDIR=`dirname "$0"`

sudo pacman -S lsd bat zsh zsh-completions neovim thefuck kitty wget tmux --noconfirm

bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh

~/miniconda3/bin/conda init zsh

mkdir ~/.local/share/fonts
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -o '~/.local/share/fonts/MesloLGS NF Regular.ttf'

# Copy all repo files to home directory, subfolders are copied recursively
cp -r $BASEDIR/. ~

cat strings.txt | tee ~/.zshrc
