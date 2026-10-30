When I started learning linux I spent a lot of time installing the same system again and again, so this repository will let you install a full operating system just like I use it.
The system I use the most is `Arch Linux`
But I still use Debian, Alpine and VM's either with VMWare or VBox or Docker

These dotfiles will automatically install everything you need to have a full system with a lot of tools and configurations. Just like I use it.

Supported systems: Arch (and derivatives), Debian and Ubuntu, Fedora, Rocky and Alma (and other RHEL relatives), Gentoo and Termux.

## Install

```bash
bash run.sh
```

Run it again whenever you like: it updates the tools and regenerates `~/.zshrc` instead of appending to it.
An existing `~/.zshrc` that the script did not generate is backed up first. Put personal additions in `~/.zshrc.local`, which is never touched.

The script asks about the optional parts. To skip the questions, answer them up front with environment variables:

| Variable | Values | What it installs |
| --- | --- | --- |
| `AUR_HELPER` | `paru`, `paru-bin`, `yay`, `yay-bin`, `none` | AUR helper (Arch only) |
| `TOKEI` | `true` / `false` | tokei |
| `PYENV` | `true` / `false` | pyenv and the packages needed to build Python |
| `UV` | `true` / `false` | uv |
| `BUN` | `true` / `false` | bun (not on Termux) |
| `FNM` | `true` / `false` | fnm and the latest LTS Node; switches Node on `cd` from `.nvmrc` / `.node-version` (not on Termux) |
| `CLAUDE`, `CODEX`, `OPENCODE`, `PI` | `true` / `false` | AI coding harnesses, from their own installers so they stay current |
| `DESKTOP` | `true` / `false` | kitty and the MesloLGS NF font (asked only in a graphical session) |
| `SSHD` | `true` / `false` | sshd that starts with Termux and on boot (Termux only) |
| `STORAGE` | `true` / `false` | `termux-setup-storage` (Termux only) |

With bun installed, opencode is installed with `bun install -g`, and so are codex and pi when Node is available too (they run on Node); otherwise each uses its curl installer.

```bash
TOKEI=true PYENV=false UV=true BUN=true FNM=true CLAUDE=true bash run.sh
```

Always installed: zsh, tmux (not on Termux), neovim (`vim` is an alias for it), btop, eza, ripgrep, bat, fd, zoxide and dua.
Tools missing from a distro's repositories (`dua` outside Arch, Fedora and Termux, or `eza` and `zoxide` on older releases) are installed from their latest GitHub release into `~/.local/bin`, and updated on later runs.

Machines set up with nvm keep using it until fnm is installed.

### Termux

sshd listens on port 8022. Install the [Termux:Boot](https://wiki.termux.com/wiki/Termux:Boot) app to start it when the phone boots.
Upgrading `openssh` disables sshd again (the package reinstalls its `down` file), so every new Termux session re-enables it.
bun and fnm have no Android builds, so they are not offered. Of the AI harnesses, only codex's installer supports Android; the others warn and are skipped.

## Docker containers

The containers use [just](https://github.com/casey/just). Run `just` to list the recipes.

```bash
just build arch       # also: ubuntu, debian, fedora, rocky, alma
just start arch
just clean arch
just build-all
```

`just build` asks which extras to install; preset the answers with the variables above, e.g. `PYENV=false UV=true AUR_HELPER=paru-bin just build arch`.
`BASE` picks another base image, e.g. `BASE=almalinux:10 just build alma`.

`just test arch` builds an image with every extra, reruns the installer to check it changes nothing, and checks the shell.

# Future features planned

- Support for [Alpine Linux](https://www.alpinelinux.org)
- Support for Windows (with oh-my-posh)
- Cron jobs to sync histfiles trough a cloud, [simplify the histfile](https://github.com/sirenityk/histfilesimp), sync [zoxide](https://github.com/ajeetdsouza/zoxide)'s db
- Actions to create updated .zshrc files on changes and an utility to update the .zshrc file. This will maintain every machine's .zshrc file updated
- Add private links to download vm's for both [VBox](https://www.virtualbox.org) and [VMWare](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion); with state snapshots with tty, environments and so on already set up
- After set up VM's download support, add actions to build images of these and upload updated VMs automatically. With support for docker too

### Integrations

- Automatic integration to access termux from the internet using the [tor network](https://wiki.termux.com/wiki/Bypassing_NAT#Tor)
- Automatic desktop environment (or window manager) integrations for new virtual machines
