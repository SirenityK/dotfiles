# Arch maintenance. ua-update-all runs the other steps in order.
ua-update-mirrors() {
    local tmpfile
    tmpfile=$(mktemp) && sudo -v &&
        rate-mirrors --save=$tmpfile arch --max-delay=21600 &&
        sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup &&
        sudo install -m 644 $tmpfile /etc/pacman.d/mirrorlist
    rm -f $tmpfile
}

# The AUR helper in use: paru or yay, or plain pacman without one.
_ua-aur() {
    if (( $+commands[paru] )); then paru "$@"
    elif (( $+commands[yay] )); then yay "$@"
    else return 1
    fi
}

ua-drop-caches() {
    sudo paccache -rk3
    _ua-aur -Sc --aur --noconfirm || true
}

ua-update-packages() {
    _ua-aur -Syyu --noconfirm || sudo pacman -Syyu --noconfirm
}

ua-update-all() {
    ua-update-mirrors && ua-drop-caches && ua-update-packages
}
