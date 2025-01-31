command -v dua >/dev/null && alias du='dua'
export EDITOR=vim
# eval "$(ssh-agent -s | sed 's/^echo/# echo/')"; ssh-add ~/.ssh/github

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY}" ] && [ -z "${TMUX}" ] && [ -z "${VSCODE_INJECTION}" ]; then
    exec tmux new-session -A -s ${USER} >/dev/null 2>&1
fi
