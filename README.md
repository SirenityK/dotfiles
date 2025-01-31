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
```
