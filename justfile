# Build and try the dotfiles in containers. Run `just` to list the recipes.

set shell := ["bash", "-euo", "pipefail", "-c"]

# The container user mirrors yours; root gets a regular "dev" user instead.
user := if `id -un` == "root" { "dev" } else { `id -un` }
distros := "arch ubuntu debian fedora rocky alma"
all_extras := "TOKEI=true PYENV=true UV=true BUN=true FNM=true CLAUDE=true CODEX=true OPENCODE=true PI=true"

_default:
    @just --list

# Answers can be preset, e.g. PYENV=true UV=false AUR_HELPER=paru-bin just build arch
# Extra arguments go to `docker build`, e.g. just build arch --no-cache
# BASE overrides the base image, e.g. BASE=almalinux:10 just build alma

# Build an image and create its container, asking which extras to install
build distro *args:
    #!/usr/bin/env bash
    set -euo pipefail
    case {{ distro }} in
    arch) file=arch base=archlinux:base-devel ;;
    ubuntu) file=debian base=ubuntu:latest ;;
    debian) file=debian base=debian:stable ;;
    fedora) file=fedora base=fedora:latest ;;
    rocky) file=fedora base=rockylinux:9 ;;
    alma) file=fedora base=almalinux:9 ;;
    *) echo "Unknown distro '{{ distro }}', choose one of: {{ distros }}" >&2; exit 1 ;;
    esac
    base=${BASE:-$base}
    extra=()
    for option in TOKEI PYENV UV BUN FNM CLAUDE CODEX OPENCODE PI; do
        value=${!option:-}
        if [ -z "$value" ]; then
            value=false
            if [ -t 0 ]; then
                read -rp "Install ${option,,} in {{ distro }}? (y/N) " reply
                [[ $reply == [yY]* ]] && value=true
            fi
        fi
        extra+=(--build-arg "$option=$value")
    done
    # Arch images get an AUR helper: paru, paru-bin, yay, yay-bin (default) or none.
    [ "$file" = arch ] && extra+=(--build-arg AUR_HELPER="${AUR_HELPER:-yay-bin}")
    docker build -t {{ user }}/{{ distro }} -f "Dockerfile.$file" \
        --build-arg BASE="$base" --build-arg USERNAME={{ user }} \
        "${extra[@]}" \
        {{ args }} .
    docker rm -f {{ distro }} >/dev/null 2>&1 || true
    gpus=()
    command -v nvidia-smi >/dev/null && gpus=(--gpus all)
    docker create "${gpus[@]}" -e TERM -e COLORTERM -e LC_ALL=C.UTF-8 -it --name {{ distro }} {{ user }}/{{ distro }} >/dev/null
    echo "Ready: just start {{ distro }}"

# Open a shell in a built container
start distro:
    docker start -i {{ distro }}

# Remove a distro's container and image
clean distro:
    -docker rm -f {{ distro }}
    -docker rmi {{ user }}/{{ distro }}

# Build every distro
build-all *args:
    for distro in {{ distros }}; do just build "$distro" {{ args }}; done

# Clean every distro
clean-all:
    for distro in {{ distros }}; do just clean "$distro"; done

# Extra arguments go to both `docker build` and `docker run`.
# TEST_EXTRAS overrides single extras, e.g. TEST_EXTRAS='BUN=false' just test fedora

# Build with every extra, then check the setup and that rerunning it changes nothing
test distro *args:
    #!/usr/bin/env bash
    set -euo pipefail
    extras="{{ all_extras }} ${TEST_EXTRAS:-}"
    env $extras just build {{ distro }} {{ args }}
    docker run --rm {{ args }} -e LC_ALL=C.UTF-8 -e EXTRAS="$extras" -v "$PWD:/tmp/dotfiles:ro" \
        {{ user }}/{{ distro }} bash /tmp/dotfiles/tests/check.sh

# Test every distro
test-all *args:
    for distro in {{ distros }}; do just test "$distro" {{ args }}; done
