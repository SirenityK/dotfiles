When I started learning linux I spent a lot of time installing the same system again and again, so this repository will let you install a full operating system just like I use it.
The system I use the most is `Arch Linux`
But I still use Debian, Alpine and VM's either with VMWare or VBox or Docker

These dotfiles will automatically install

## To install, make sure you don't have a .zshrc file, then run:

```bash
bash run.sh
```

## Create a container with Docker:

Archlinux and Ubuntu containers are currently supported

### Make (recommended)

```bash
make build-arch
```

```bash
make build-ubuntu
```

```bash
make build-all
```

### Bash

```bash
export DISTRO=arch # Select a base container, in this case we're using archlinux
```

```bash
docker build -t sirenityk/$DISTRO -f Dockerfile.$DISTRO .
docker run -e TERM -e COLORTERM -e LC_ALL=C.UTF-8 -it --name $DISTRO sirenityk/$DISTRO
```

### Running the container

```bash
make start-$DISTRO
```

```bash
docker start -i $DISTRO

# Future features planned
- Support for [Alpine Linux](https://www.alpinelinux.org)
- Support for Windows (with oh-my-posh)
- Actions to create updated .zshrc files on changes and an utility to update the .zshrc file. This will maintain every machine's .zshrc file updated

# Future integrations planned
- Automatic integration to access termux from the internet using the [tor network](https://wiki.termux.com/wiki/Bypassing_NAT#Tor)
- Automatic desktop environment (or window manager) integrations for new virtual machines
```
