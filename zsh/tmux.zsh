# Start (or attach to) tmux before anything else in graphical terminals, so the
# rest of this file only runs once, inside tmux.
if (( $+commands[tmux] )) && [[ -n $DISPLAY$WAYLAND_DISPLAY && -z $TMUX && -z $VSCODE_INJECTION && -z $DOTFILES_NO_TMUX ]]; then
    exec tmux new-session -A -s ${USER} >/dev/null 2>&1
fi
