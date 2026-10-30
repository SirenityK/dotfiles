# zoxide asks to be initialized last.
_cached_source zoxide zoxide init zsh

(( $+commands[dua] )) && alias du='dua'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local
