all: docker_info docker_build docker_tag docker_push 
build: docker_build

DOCKER_ADDITIONAL_REGISTRY := $(DOCKER_CI_REGISTRY)
DOCKER_ADDITIONAL_REGISTRY_MIRROR_1 := $(DOCKER_CI_REGISTRY_MIRROR_1)
DOCKER_ADDITIONAL_REGISTRY_MIRRORS_LIST:= $(DOCKER_CI_REGISTRY_MIRRORS_LIST)
DOCKER_IMAGE_NAME := $(shell grep -r 'image' docker-compose.yml | awk -F\image: '{print $$2}' | sed 's~[^-:._[:alnum:]/]\+~~g')
DOCKER_IMAGE_WITHOUT_REGISTRY := $(shell grep -r 'image:' docker-compose.yml | awk -F\image: '{print $$2}' | sed 's~[^-:._[:alnum:]/]\+~~g' | awk -F"/" '{print $$NF}')
DOCKER_IMAGE_NAME_LATEST := $(shell grep -r 'image:' docker-compose.yml | awk -F\image: '{print $$2}' | cut -d\: -f1 | sed 's~[^-:._[:alnum:]/]\+~~g' | awk '{print $$0":latest"}')
DOCKER_BUILD_DATE := $(shell date -u "+%Y_%m_%d__%H__%S")
TARGETOS="linux"
TARGETARCH="amd64"
docker_info:$(eval SHELL:=/usr/bin/env bash)
		@echo "--------------- docker_info started ---------------"
		@echo "DOCKER_CI_REGISTRYY=$$DOCKER_CI_REGISTRY"
		@echo "DOCKER_IMAGE_NAME=$(DOCKER_IMAGE_NAME)"
		@echo "DOCKER_IMAGE_NAME_LATEST=$(DOCKER_IMAGE_NAME_LATEST)"
		@echo "DOCKER_ADDITIONAL_REGISTRY_MIRRORS_LIST=$(DOCKER_ADDITIONAL_REGISTRY_MIRRORS_LIST)"
		@echo "--------------- docker_info finished ---------------"

docker_build:$(eval SHELL:=/usr/bin/env bash)
		@echo "--------------- DOCKER_BUILD_DATE=$(DOCKER_BUILD_DATE) ---------------"
		DOCKER_BUILDKIT=1 docker-compose build  --build-arg=TARGETOS="$(TARGETOS)" --build-arg=TARGETARCH="$(TARGETARCH)" --build-arg DOCKER_BUILD_DATE="$(DOCKER_BUILD_DATE)" --build-arg CUSTOM_REGISTRYS="$(c)"

