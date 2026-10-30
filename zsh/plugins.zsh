# zinit, installed on first use.
ZINIT_HOME=${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git
if [[ ! -f $ZINIT_HOME/zinit.zsh ]]; then
    mkdir -p ${ZINIT_HOME:h} && git clone --depth 1 https://github.com/zdharma-continuum/zinit.git $ZINIT_HOME
fi
source $ZINIT_HOME/zinit.zsh

zinit ice depth=1
zinit light romkatv/powerlevel10k

# Loaded right after the first prompt is drawn ("turbo mode"), which keeps startup
# fast. compinit runs here too, after zsh-completions has extended fpath.
zinit wait lucid light-mode depth=1 for \
    atinit'zicompinit; zicdreplay' \
        zdharma-continuum/fast-syntax-highlighting \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    atload'!_zsh_autosuggest_start' \
        zsh-users/zsh-autosuggestions
