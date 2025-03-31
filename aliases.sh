clone() {
    if [[ $1 =~ ^https://github\.com/ ]]; then

        REPO_URL=$1
    else

        REPO_URL="https://github.com/$1"
    fi

    git clone "$REPO_URL" "${@:2}"

    if [[ $? -ne 0 ]]; then
        echo "Error: No GitHub repository found at $REPO_URL"
        return 1
    fi
}

sclone() {
    # shallow clone
    clone --depth 1 "$@"
}

eval "$(zoxide init zsh)"
alias cd=z
alias c=clear
alias ls=lsd
alias ip='ip --color=auto'
alias grep='rg'
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
