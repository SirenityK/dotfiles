# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

alias cat=bat
alias c=clear
alias ls=lsd
alias ..='cd ..'
alias ip='ip --color=auto'
export EDITOR=nvim
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
# eval "$(ssh-agent -s | sed 's/^echo/# echo/')"; ssh-add ~/.ssh/github

# source ~/venv/bin/activate  # commented out by conda initialize

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY}" ] && [ -z "${TMUX}" ]; then
	exec tmux new-session -A -s ${USER} >/dev/null 2>&1
 	# exec tmux new-session
fi

eval $(thefuck --alias)
