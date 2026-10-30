# Command line packages for every supported platform. Package managers already
# skip what is installed, so these functions are safe to rerun.

pkg_install() { pkg install -y "$@"; }
apt_install() { as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"; }
dnf_install() { as_root dnf install -y "$@"; }

# try_install INSTALL_FN PACKAGE...
# Installs the whole list at once, or each package the repositories have if that fails.
try_install() {
    local fn=$1 pkg
    shift
    "$fn" "$@" >/dev/null 2>&1 && return 0
    for pkg in "$@"; do
        "$fn" "$pkg" >/dev/null 2>&1 || info "$pkg is not in the repositories"
    done
}

install_packages() {
    case $OS in
    termux)
        pkg update -y
        { yes || :; } | pkg upgrade -y
        pkg_install zsh curl wget git neovim eza ripgrep bat fd zoxide dua termux-api
        # btop is not built for every architecture.
        try_install pkg_install btop
        ;;
    arch)
        as_root pacman -Syu --noconfirm --needed zsh curl wget git tmux neovim btop \
            eza ripgrep bat fd zoxide dua-cli pacman-contrib rate-mirrors
        ;;
    debian)
        as_root env DEBIAN_FRONTEND=noninteractive apt-get update
        as_root env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
        apt_install zsh curl wget git tmux ca-certificates
        try_install apt_install neovim btop eza ripgrep bat fd-find zoxide dua-cli
        ;;
    fedora)
        # Rocky and Alma ship most of the CLI tools (and neovim, btop) in EPEL.
        if [ "$OS_ID" != fedora ] && ! rpm -q epel-release >/dev/null 2>&1; then
            dnf_install epel-release || warn 'EPEL is unavailable, using GitHub releases instead'
        fi
        # Minimal images ship curl-minimal, which conflicts with the full curl package.
        local base=(zsh wget git tmux tar gzip findutils)
        command -v curl >/dev/null || base+=(curl)
        dnf_install "${base[@]}"
        try_install dnf_install neovim btop eza ripgrep bat fd-find zoxide dua-cli
        ;;
    gentoo)
        as_root emerge --noreplace --quiet app-shells/zsh net-misc/curl net-misc/wget \
            dev-vcs/git app-misc/tmux app-editors/neovim sys-process/btop sys-apps/eza sys-apps/ripgrep \
            sys-apps/bat sys-apps/fd app-shells/zoxide
        ;;
    esac

    # Whatever the distro lacks (dua outside Arch, Fedora and Termux; most tools on
    # older releases) comes from the projects' GitHub releases.
    local musl='{arch}-unknown-linux-musl.tar.gz'
    ensure_tool eza-community/eza eza '' "eza_$musl" 'eza_{arch}-unknown-linux-gnu.tar.gz'
    ensure_tool BurntSushi/ripgrep rg '' "ripgrep-{tag}-$musl"
    ensure_tool sharkdp/bat bat batcat "bat-{tag}-$musl"
    ensure_tool sharkdp/fd fd fdfind "fd-{tag}-$musl"
    ensure_tool ajeetdsouza/zoxide zoxide '' "zoxide-{version}-$musl"
    ensure_tool Byron/dua-cli dua '' "dua-{tag}-$musl"
}

# ensure_tool OWNER/REPO BINARY RENAMED ASSET...
# RENAMED is the name a distro gives the binary instead (Debian's batcat and fdfind),
# or empty. ASSET is passed to github_binary.
ensure_tool() {
    local repo=$1 bin=$2 renamed=$3 found
    shift 3
    found=$(command -v "$bin" || true)
    if [ -z "$found" ] && [ -n "$renamed" ] && command -v "$renamed" >/dev/null; then
        mkdir -p ~/.local/bin
        ln -sf "$(command -v "$renamed")" ~/.local/bin/"$bin"
        return
    fi
    # Binaries from the package manager are kept; ones downloaded by github_binary are updated.
    if [ -n "$found" ] && { [ "$found" != "$HOME/.local/bin/$bin" ] || [ -L "$found" ]; }; then
        return
    fi
    github_binary "$repo" "$bin" "$@"
}
