typeset -U path fpath
path=(~/.local/bin ~/.cargo/bin ~/.bun/bin ~/.opencode/bin $path)
if (( $+commands[nvim] )); then
    export EDITOR=nvim
    alias vim=nvim
else
    export EDITOR=vim
fi

# Init scripts of external tools are cached and only regenerated when the tool's
# binary changes, instead of spawning each tool on every shell start.
_dotfiles_cache=${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles
fpath=($_dotfiles_cache/completions ~/.bun $fpath)

# _cached_source NAME COMMAND...: sources COMMAND's output.
_cached_source() {
    local bin=${commands[$2]} file=$_dotfiles_cache/$1.zsh
    [[ -n $bin ]] || return 1
    if [[ ! -s $file || $bin -nt $file ]]; then
        mkdir -p $_dotfiles_cache && "${@:2}" >| $file || return 1
    fi
    source $file
}

# _cached_completion NAME COMMAND...: saves COMMAND's output as the completion for NAME.
# compinit only notices a new completion when its dump is rebuilt, so the dump is
# removed whenever one is written.
_cached_completion() {
    local bin=${commands[$2]} file=$_dotfiles_cache/completions/_$1
    [[ -n $bin ]] || return 1
    if [[ ! -s $file || $bin -nt $file ]]; then
        mkdir -p ${file:h} && "${@:2}" >| $file || { rm -f $file; return 1 }
        rm -f ${ZINIT[ZCOMPDUMP_PATH]:-${ZDOTDIR:-$HOME}/.zcompdump}{,.zwc}
    fi
}

_cached_completion uv uv generate-shell-completion zsh
_cached_completion uvx uvx --generate-shell-completion zsh
(( $+commands[uv] )) && alias uvp='UV_SYSTEM_PYTHON=true uv pip'

export PYENV_ROOT=${PYENV_ROOT:-$HOME/.pyenv}
if [[ -d $PYENV_ROOT/bin ]]; then
    path=($PYENV_ROOT/bin $path)
    _cached_source pyenv pyenv init - zsh
    [[ -d $PYENV_ROOT/plugins/pyenv-virtualenv ]] && _cached_source pyenv-virtualenv pyenv virtualenv-init -
fi

[[ -d ~/.local/share/fnm ]] && path=(~/.local/share/fnm $path)
if (( $+commands[fnm] )); then
    # Not cached: the output names a directory unique to each shell. --use-on-cd
    # switches Node when entering a directory with .nvmrc or .node-version.
    eval "$(fnm env --use-on-cd --version-file-strategy=recursive --shell zsh)"
    _cached_completion fnm fnm completions --shell zsh
fi

# yt-dlp comes from a uv venv in $HOME (see install_ytdlp). ytdw downloads the URL on
# the clipboard; get-post then re-encodes it with autoencode.
_clipboard_paste() {
    if (( $+commands[termux-clipboard-get] )); then
        termux-clipboard-get
    elif [[ -n $WAYLAND_DISPLAY ]] && (( $+commands[wl-paste] )); then
        wl-paste
    elif (( $+commands[xclip] )); then
        xclip -o -selection clipboard
    else
        print -u2 'no clipboard tool found (wl-paste, xclip or termux-clipboard-get)'
        return 1
    fi
}
if [[ -x ~/.venv/bin/yt-dlp ]]; then
    ytdw() {
        local url
        url=$(_clipboard_paste) || return
        ~/.venv/bin/yt-dlp --force-overwrites -S br "$url" --cookies ~/Documents/cookies.txt \
            --remux-video mp4 -o video.mp4 "$@"
    }
    alias get-post='ytdw && autoencode video.mp4 && rm video.mp4'
fi
