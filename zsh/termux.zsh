# Upgrading openssh reinstalls its "down" file, which disables sshd. run.sh leaves
# this marker when sshd was set up, so every new session turns it back on.
if [[ -f ~/.config/dotfiles/termux-sshd ]] && (( $+commands[sv] )); then
    rm -f $PREFIX/var/service/sshd/down
    SVDIR=$PREFIX/var/service sv up sshd &>/dev/null &!
fi
