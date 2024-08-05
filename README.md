## To install, make sure you don't have a .zshrc file, then run:
```bash
bash run.sh
```

## Create a container with Docker:
```bash
export DISTRO=arch # Select a base container: arch | ubuntu; in this case we're using archlinux
```
```bash
docker build -t sirenityk/$DISTRO -f Dockerfile.$DISTRO .
docker run -e TERM -e COLORTERM -e LC_ALL=C.UTF-8 -it --name $DISTRO sirenityk/$DISTRO
```

### Running the container (if saved)
```bash
docker start -i $DISTRO
```