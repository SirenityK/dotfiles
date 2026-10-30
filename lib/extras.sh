# Optional components. Each one asks first, or reads its answer from the
# environment (TOKEI, PYENV, UV, BUN, FNM, CLAUDE, CODEX, OPENCODE, PI, DESKTOP,
# STORAGE, SSHD set to true or false, and AUR_HELPER set to paru, paru-bin, yay,
# yay-bin or none).
# The zshrc only loads a tool when it is installed, so answering no on a later
# run never breaks an earlier install.

# AUR helper for Arch, built from the AUR. Skipped when one is already installed.
install_aur_helper() {
    [ "$OS" = arch ] || return 0
    command -v paru >/dev/null || command -v yay >/dev/null && return 0
    local helper tmp
    helper=$(choose AUR_HELPER 'Install an AUR helper?' paru paru-bin yay yay-bin none)
    case $helper in
    none) return 0 ;;
    paru | paru-bin | yay | yay-bin) ;;
    *)
        warn "unknown AUR helper '$helper', skipping"
        return 0
        ;;
    esac
    as_root pacman -S --noconfirm --needed base-devel git
    tmp=$(mktemp -d)
    # A failed build only skips the helper; the rest of the setup goes on.
    if ! { git clone --depth 1 "https://aur.archlinux.org/$helper.git" "$tmp" &&
        (cd "$tmp" && makepkg -si --noconfirm); }; then
        warn "$helper failed to build"
    fi
    rm -rf "$tmp"
}

install_tokei() {
    want TOKEI 'Install tokei?' || return 0
    case $OS in
    termux) pkg install -y tokei ;;
    arch) as_root pacman -S --noconfirm --needed tokei ;;
    debian) try_install apt_install tokei ;;
    fedora) try_install dnf_install tokei ;;
    gentoo) as_root emerge --noreplace --quiet dev-util/tokei || true ;;
    esac
    command -v tokei >/dev/null && return 0
    # Recent tokei releases publish no Linux binaries, so build it when the repos lack it.
    if command -v cargo >/dev/null; then
        cargo install --locked tokei
    else
        warn 'tokei is not in the repositories; install Rust (rustup) and rerun to build it'
    fi
}

install_pyenv() {
    want PYENV 'Install pyenv?' || return 0
    # Build dependencies from the pyenv wiki, so `pyenv install` can compile Python.
    case $OS in
    debian)
        apt_install build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
            libsqlite3-dev libncurses-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
            libffi-dev liblzma-dev
        ;;
    fedora)
        dnf_install make gcc patch zlib-devel bzip2 bzip2-devel readline-devel sqlite \
            sqlite-devel openssl-devel tk-devel libffi-devel xz-devel libuuid-devel
        ;;
    arch) as_root pacman -S --noconfirm --needed base-devel openssl zlib xz tk ;;
    esac
    if [ -d ~/.pyenv ]; then
        PYENV_ROOT=~/.pyenv ~/.pyenv/bin/pyenv update
    else
        curl -fsSL https://pyenv.run | bash
    fi
}

install_uv() {
    want UV 'Install uv?' || return 0
    case $OS in
    termux) pkg install -y uv ;;
    arch) as_root pacman -S --noconfirm --needed uv ;;
    *)
        if [ -x ~/.local/bin/uv ]; then
            ~/.local/bin/uv self update
        else
            curl -fsSL https://astral.sh/uv/install.sh | UV_NO_MODIFY_PATH=1 sh
        fi
        ;;
    esac
}

install_bun() {
    # Bun has no Android build.
    [ "$OS" = termux ] && return 0
    want BUN 'Install bun?' || return 0
    if command -v bun >/dev/null; then
        bun upgrade || warn 'bun upgrade failed'
        return 0
    fi
    command -v unzip >/dev/null || install_unzip
    curl -fsSL https://bun.com/install | bash
}

# AI coding harnesses update too often for distro repos, so each comes from its own
# installer, which also updates it on later runs. Packages published to npm are
# installed with bun instead when bun is installed, since it is faster. codex and pi
# run on Node, so for them that also needs Node (from fnm, for example).
install_harnesses() {
    local bun_node=false
    command -v bun >/dev/null && command -v node >/dev/null && bun_node=true
    if want CLAUDE 'Install Claude Code?'; then
        curl -fsSL https://claude.ai/install.sh | bash || warn 'Claude Code failed to install'
    fi
    if want CODEX 'Install Codex?'; then
        if $bun_node; then
            bun install -g @openai/codex@latest
        else
            curl -fsSL https://chatgpt.com/codex/install.sh | sh
        fi || warn 'Codex failed to install'
    fi
    if want OPENCODE 'Install opencode?'; then
        if command -v bun >/dev/null; then
            # --trust runs the postinstall script that puts the native binary in place.
            bun install -g --trust @opencode/cli@latest
        else
            curl -fsSL https://opencode.ai/v2/install | bash -s -- --no-modify-path
        fi || warn 'opencode failed to install'
    fi
    if want PI 'Install pi?'; then
        if $bun_node; then
            bun install -g @earendil-works/pi-coding-agent@latest
        else
            curl -fsSL https://pi.dev/install.sh | sh
        fi || warn 'pi failed to install'
    fi
}

# fnm replaces nvm: faster, and it switches Node versions on cd from .nvmrc or
# .node-version files. The first install also installs the latest LTS Node.
install_fnm() {
    # fnm has no Android build; Termux has Node as the nodejs package.
    [ "$OS" = termux ] && return 0
    want FNM 'Install fnm (Node version manager)?' || return 0
    if [ "$OS" = arch ]; then
        as_root pacman -S --noconfirm --needed fnm
    else
        command -v unzip >/dev/null || install_unzip
        # The installer replaces the binary with the latest release on every run.
        curl -fsSL https://fnm.vercel.app/install |
            bash -s -- --install-dir ~/.local/share/fnm --skip-shell || {
            warn 'fnm failed to install'
            return 0
        }
        export PATH="$HOME/.local/share/fnm:$PATH"
    fi
    if [ -z "$(fnm list 2>/dev/null | grep -v system)" ]; then
        { fnm install --lts && fnm default lts-latest; } || warn 'installing Node with fnm failed'
    fi
    # Puts the default Node on PATH for the steps that follow (bun, pi).
    eval "$(fnm env --shell bash)"
}

install_unzip() {
    case $OS in
    termux) pkg install -y unzip ;;
    arch) as_root pacman -S --noconfirm --needed unzip ;;
    debian) apt_install unzip ;;
    fedora) dnf_install unzip ;;
    gentoo) as_root emerge --noreplace --quiet app-arch/unzip ;;
    esac
}

# Graphical extras: the kitty terminal and its config, plus the MesloLGS NF font
# powerlevel10k is designed for. Only offered when a graphical session is running.
install_desktop() {
    if [ -z "${DESKTOP:-}" ] && [ -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
        return 0
    fi
    want DESKTOP 'Install desktop apps (kitty, MesloLGS NF font)?' || return 0
    case $OS in
    arch) as_root pacman -S --noconfirm --needed kitty fontconfig ;;
    debian) apt_install kitty fontconfig ;;
    fedora) try_install dnf_install kitty fontconfig ;;
    gentoo) as_root emerge --noreplace --quiet x11-terms/kitty media-libs/fontconfig ;;
    esac
    mkdir -p ~/.config/kitty
    cp "$BASEDIR/.config/kitty/kitty.conf" ~/.config/kitty/kitty.conf
    local style base=https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master
    for style in Regular Bold Italic 'Bold Italic'; do
        fetch_once "$base/MesloLGS%20NF%20${style// /%20}.ttf" ~/.local/share/fonts/"MesloLGS NF $style.ttf"
    done
    command -v fc-cache >/dev/null && fc-cache -f ~/.local/share/fonts
}

termux_extras() {
    local font=https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Regular.ttf
    mkdir -p ~/.termux
    if [ ! -s ~/.termux/font.ttf ]; then
        fetch_once "$font" ~/.termux/font.ttf
        termux-reload-settings || true
    fi

    if [ ! -d ~/storage ] && want STORAGE 'Set up storage access?'; then
        termux-setup-storage
    fi

    want SSHD 'Set up sshd (starts with Termux and on boot)?' || return 0
    pkg install -y termux-services openssh
    # The zshrc and the boot script re-enable sshd while this marker exists, because
    # upgrading openssh reinstalls the package's "down" file and silently disables it.
    mkdir -p ~/.config/dotfiles ~/.termux/boot
    touch ~/.config/dotfiles/termux-sshd
    cat >~/.termux/boot/start-services <<'EOF'
#!/data/data/com.termux/files/usr/bin/sh
# Generated by dotfiles/run.sh. Runs at boot when the Termux:Boot app is installed.
termux-wake-lock
rm -f /data/data/com.termux/files/usr/var/service/sshd/down
. /data/data/com.termux/files/usr/etc/profile
EOF
    chmod +x ~/.termux/boot/start-services
    export SVDIR=$PREFIX/var/service LOGDIR=$PREFIX/var/log
    rm -f "$SVDIR/sshd/down"
    service-daemon start >/dev/null 2>&1 || true
    sv up sshd 2>/dev/null || true
    info "sshd listens on port 8022. Install the Termux:Boot app to start it on boot."
    if want PASSWD 'Change the password used for ssh?'; then
        passwd
    fi
}
