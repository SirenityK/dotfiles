#!/usr/bin/env bash
# Runs inside a container built by `just test`: reruns the installer, checks that
# it changed nothing, then checks the resulting shell.

set -euo pipefail
export LC_ALL=C.UTF-8
fail=0
check() {
    if eval "$2" >/dev/null 2>&1; then
        echo "ok   $1"
    else
        echo "FAIL $1"
        fail=1
    fi
}

snapshot() {
    {
        md5sum ~/.zshrc ~/.p10k.zsh
        ls ~/.local/bin
        ls -a ~ | grep -v '^\.cache$'
        getent passwd "$(id -un)" | cut -d: -f7
    } 2>&1
}

before=$(snapshot)
env $EXTRAS bash /tmp/dotfiles/run.sh >/tmp/rerun.log 2>&1 || {
    tail -30 /tmp/rerun.log
    exit 1
}
after=$(snapshot)
check 'rerunning run.sh changes nothing' '[ "$before" = "$after" ]'
[ "$before" = "$after" ] || diff <(echo "$before") <(echo "$after") || true
check 'no ~/.zshrc backups' '! ls ~/.zshrc.backup-*'
check 'zshrc starts tmux on desktops' 'grep -q "exec tmux" ~/.zshrc'
check 'login shell is zsh' '[ "$(getent passwd "$(id -un)" | cut -d: -f7)" = "$(command -v zsh)" ]'

# An interactive shell, with the deferred (turbo) plugins forced to load.
zsh_check() { zsh -ic "@zinit-scheduler burst; $1" </dev/null; }
errors=$(zsh -ic '@zinit-scheduler burst' 2>&1 >/dev/null </dev/null)
check 'zsh starts without errors' '[ -z "$errors" ]'
[ -z "$errors" ] || echo "$errors"
# Tools of the extras that EXTRAS enables (e.g. "BUN=true FNM=false").
declare -A extra_tools=([TOKEI]=tokei [PYENV]=pyenv [UV]='uv uvx' [BUN]=bun [FNM]='fnm node'
    [CLAUDE]=claude [CODEX]=codex [OPENCODE]=opencode [PI]=pi)
declare -A enabled=()
for assignment in $EXTRAS; do enabled[${assignment%%=*}]=${assignment#*=}; done
tools='eza rg bat fd zoxide dua tmux nvim git'
for extra in "${!extra_tools[@]}"; do
    [ "${enabled[$extra]:-}" = true ] && tools+=" ${extra_tools[$extra]}"
done
# Arch's btop has file capabilities that Docker's default capability set refuses to exec.
check 'btop is installed' "zsh_check 'whence btop'"
for cmd in $tools; do
    check "$cmd runs" "zsh_check '$cmd --version || $cmd -V'"
done
check 'cat is bat' "zsh_check 'cat --version' | grep -q '^bat'"
check 'find is fd' "zsh_check 'find --version' | grep -q '^fd'"
check 'vim is neovim' "zsh_check 'vim --version' | grep -q '^NVIM'"
check 'ls is eza' "zsh_check 'whence ls' | grep -q eza"
check 'EDITOR is nvim' "zsh_check 'echo \$EDITOR' | grep -qx nvim"
[ "${enabled[FNM]:-}" = true ] && check 'fnm completion is registered' "zsh_check '[[ \${_comps[fnm]} = _fnm ]]'"
[ "${enabled[FNM]:-}" = true ] && check 'fnm switches node on cd' "mkdir -p /tmp/nodetest && echo 20 >/tmp/nodetest/.nvmrc && zsh_check 'fnm install 20 >/dev/null 2>&1; cd /tmp/nodetest && node --version' | grep -q '^v20'"
check 'cd is zoxide' "zsh_check 'whence -w __zoxide_z'"
check 'history keeps unique commands' "zsh_check '[[ -o HIST_IGNORE_ALL_DUPS && -o HIST_FIND_NO_DUPS ]]'"
check 'completion is initialized' "zsh_check 'whence -w compdef | grep -q function'"
[ "${enabled[UV]:-}" = true ] && check 'uv completion is registered' "zsh_check '[[ \${_comps[uv]} = _uv ]]'"
check 'autosuggestions loaded' "zsh_check 'whence -w _zsh_autosuggest_start'"
check 'syntax highlighting loaded' "zsh_check 'whence -w _zsh_highlight || whence -w -- -fast-highlight-process'"
check 'powerlevel10k loaded' "zsh_check 'whence -w prompt_powerlevel9k_setup'"
check 'gitstatusd downloaded' 'ls ~/.cache/gitstatus/gitstatusd-*'
if command -v pacman >/dev/null; then
    check 'AUR helper installed' 'command -v paru || command -v yay'
    check 'arch maintenance functions' "zsh_check 'whence -w ua-update-all ua-update-mirrors ua-drop-caches ua-update-packages'"
fi

exit $fail
