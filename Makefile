DISTROS := arch ubuntu

export USERNAME := $(shell whoami)

define build_image
	set_env_var() { \
		read -p "Install $$1 in $(1)? (y/n) " yn; \
		if [ "$$yn" = "y" ]; then \
			echo "true"; \
		else \
			echo "false"; \
		fi; \
	}; \
	PYENV=$$(set_env_var pyenv); \
	UV=$$(set_env_var uv); \
	NVM=$$(set_env_var nvm); \
	docker build --build-arg PYENV=$$PYENV --build-arg UV=$$UV --build-arg NVM=$$NVM -t $(USERNAME)/$(1) -f Dockerfile.$(1) . && \
	docker run -d --gpus all -e TERM -e COLORTERM -e LC_ALL=C.UTF-8 -it --name $(1) $(USERNAME)/$(1) && \
	docker kill $(1)
endef

define start_container
	docker start -i $(1)
endef

define clean_image
	-docker stop $(1) || true
	-docker rm $(1) || true
	-docker rmi $(USERNAME)/$(1) || true
endef

build-arch:
	$(call build_image,arch)

build-ubuntu:
	$(call build_image,ubuntu)

start-arch:
	$(call start_container,arch)

start-ubuntu:
	$(call start_container,ubuntu)

clean-arch:
	$(call clean_image,arch)

clean-ubuntu:
	$(call clean_image,ubuntu)

build-all:
	$(foreach distro,$(DISTROS),$(call build_image,$(distro));)

clean-all:
	$(foreach distro,$(DISTROS),$(call clean_image,$(distro));)
