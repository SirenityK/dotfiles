eval "$(zoxide init zsh)"
alias cd=z
alias c=clear
alias ls=lsd
alias ip='ip --color=auto'
alias grep='rg'
alias clone='git clone'
alias gclone='git clone https://github.com/'
alias pull='git pull'
alias push='git push'
alias commit='git commit'
alias start='xdg-open &> /dev/null'
alias rsync="rsync --progress --filter=':- .gitignore' -aW"
alias sudo='sudo '
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
