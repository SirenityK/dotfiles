alias cd=z
alias cat=bat
alias find=fd
alias c=clear
alias ls='eza --icons'
alias ip='ip --color=auto'
alias grep='rg'
alias pull='git pull'
alias push='git push'
alias commit='git commit'
alias start='xdg-open &> /dev/null'

# rsync: skips gitignored and untracked files (run from the repo root; aliases keep rsync's completions)
alias rsync='command rsync -av --progress --exclude=/.git --filter=":- .gitignore" --exclude-from=<(git ls-files --others --directory 2>/dev/null | sed "s|^|/|")'

# rsync-all: ignores git, but skips generated files
alias rsync-all='command rsync -av --progress --exclude={node_modules,target,__pycache__,.venv,venv,dist,build,.next,.cache,"*.pyc"}'
alias sudo='sudo '
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
