# vim: shiftwidth=2 tabstop=2 noexpandtab :

DOCKER_USER    := uroesch
DOCKER_TAG     := packer
DOCKER_VERSION := latest

push: build
	docker push $(DOCKER_USER)/$(DOCKER_TAG):$(DOCKER_VERSION)

build:
	docker build \
		--tag $(DOCKER_USER)/$(DOCKER_TAG):$(DOCKER_VERSION) \
		.

build-no-cache:
	docker build \
    --no-cache \
    --tag $(DOCKER_USER)/$(DOCKER_TAG):$(DOCKER_VERSION) \
    .

force: build-no-cache

clean:
	VOLUMES="$(shell docker volume ls -qf dangling=true)"; \
	if [ -n "$${VOLUMES}" ]; then docker volume rm $${VOLUMES}; fi
	EXITED="$(shell docker ps -aqf dangling=exited)"; \
	if [ -n "$${EXITED}" ]; then  docker volume $${EXITED}; fi
	IMAGES="$(shell docker images -qf dangling=true)"; \
	if [ -n "$${IMAGES}" ]; then docker rmi $${IMAGES}; fi

all: build clean

.PHONY: all
