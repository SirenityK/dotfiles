clone() {
    local repo_url="$1"

    if [ -z "$repo_url" ]; then
        echo "Error: No repository specified."
        echo "Usage: clone username/repo [additional git clone options] or clone full_url [additional git clone options]"
        return 1
    fi

    shift

    if [[ "$repo_url" != http* && "$repo_url" == */* ]]; then
        repo_url="https://github.com/$repo_url"
    fi

    if [[ "$repo_url" == https://github.com/* ]]; then
        local check_url=$(echo "$repo_url" | sed 's/github.com/api.github.com\/repos/g')

        if ! curl --silent --head --fail "$check_url" >/dev/null; then
            echo "Error: No GitHub repository found at $repo_url"
            return 1
        fi
    fi

    echo "Cloning from $repo_url"
    git clone "$repo_url" "$@"

    if [ $? -eq 0 ]; then
        echo "Repository cloned successfully."
    else
        echo "Failed to clone repository."
        return 1
    fi
}

sclone() {
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
