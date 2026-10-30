#!/usr/bin/env bash
# Sets up zsh and the command line tools. Safe to run again at any time: it
# updates what is installed and regenerates ~/.zshrc instead of appending to it.

set -euo pipefail

BASEDIR=$(cd "$(dirname "$0")" && pwd)
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$HOME/.opencode/bin:$PATH"

. "$BASEDIR/lib/common.sh"
. "$BASEDIR/lib/packages.sh"
. "$BASEDIR/lib/extras.sh"

detect_os
info "Detected $OS_ID ($OS)"

install_packages
install_aur_helper
install_tokei
install_pyenv
install_uv
# bun comes before the node tools so they can be installed with it.
install_bun
install_fnm
install_harnesses
if [ "$OS" = termux ]; then
    termux_extras
else
    install_desktop
fi

# ~/.zshrc is assembled from the parts that apply to this system.
parts=()
# tmux starts first so the shell inside it does the rest. Not on Termux, where tmux is unwanted.
[ "$OS" != termux ] && parts+=("$BASEDIR/zsh/tmux.zsh")
parts+=("$BASEDIR/zsh/init.zsh" "$BASEDIR/zsh/plugins.zsh" "$BASEDIR/zsh/tools.zsh" "$BASEDIR/zsh/aliases.zsh")
[ -f "$BASEDIR/zsh/$OS.zsh" ] && parts+=("$BASEDIR/zsh/$OS.zsh")
parts+=("$BASEDIR/zsh/end.zsh")
write_zshrc "${parts[@]}"
cp "$BASEDIR/p10k/.p10k.zsh" ~/.p10k.zsh

# Download zinit, the plugins and gitstatusd now rather than on the first prompt.
info 'Installing zsh plugins'
DOTFILES_NO_TMUX=1 zsh -ic '@zinit-scheduler burst' </dev/null
zsh -c '. ~/.local/share/zinit/plugins/romkatv---powerlevel10k/gitstatus/install' </dev/null

# Make zsh the login shell.
zsh_path=$(command -v zsh)
if [ "$OS" = termux ]; then
    [ "$(basename "$(readlink -f ~/.termux/shell 2>/dev/null)")" = zsh ] || chsh -s zsh
else
    user=$(id -un)
    if [ "$(getent passwd "$user" | cut -d: -f7)" != "$zsh_path" ]; then
        grep -qx "$zsh_path" /etc/shells || echo "$zsh_path" | as_root tee -a /etc/shells >/dev/null
        as_root usermod -s "$zsh_path" "$user"
    fi
fi

if [ "$OS" = termux ]; then
    info 'Done. Restart Termux to apply the changes.'
else
    info 'Done. Log out and back in (or run `exec zsh`) to apply the changes.'
fi
