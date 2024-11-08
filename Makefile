PROJECT_NAME := $(shell basename $(PWD))

DOCKER := $(shell command -v docker || which docker)

ifndef DOCKER
$(error Can't find docker)
endif

BASE_IMAGE ?= debian
BASE_IMAGE_TAG ?= bookworm-20240926-slim
BAZEL_VERSION ?= 7.3.1
REPRODUCIBLE_CONTAINERS_VERSION ?= 0.1.4
BAZELISK_VERSION ?= 1.20.0

GH_OWNER := jjmaestro
GH_REPO := $(GH_OWNER)/$(PROJECT_NAME)
IMAGE_SOURCE := https://github.com/$(GH_REPO)

REGISTRY := ghcr.io
IMAGE_NAME := $(GH_REPO)/$(BASE_IMAGE)
IMAGE_VERSION ?= $(shell date +%Y%m%d)
TAG := $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_VERSION)


all: gen-image

.PHONY: all

push-image: gen-image
	@echo "\nPushing $(TAG) and tagging as :latest" && \
	echo "\n\nEnter a GH Personal Access Token with (at least) write:packages scope:" && \
	$(DOCKER) login --username $(USER) $(REGISTRY)  && \
	$(DOCKER) image push $(TAG) && \
	$(DOCKER) image tag $(TAG) $(REGISTRY)/$(IMAGE_NAME):latest && \
	$(DOCKER) image push $(REGISTRY)/$(IMAGE_NAME):latest \

.PHONY: push-image

gen-image: .Dockerfile

.PHONY: gen-image

.Dockerfile: Dockerfile
	$(DOCKER) build \
		--platform linux/amd64,linux/arm64 \
		--file "$<" \
		--build-arg BASE_IMAGE="$(BASE_IMAGE)" \
		--build-arg BASE_IMAGE_TAG="$(BASE_IMAGE_TAG)"\
		--build-arg REPRODUCIBLE_CONTAINERS_VERSION="$(REPRODUCIBLE_CONTAINERS_VERSION)" \
		--build-arg BAZELISK_VERSION="$(BAZELISK_VERSION)" \
		--build-arg BAZEL_VERSION="$(BAZEL_VERSION)" \
		--label "org.opencontainers.image.source=$(IMAGE_SOURCE)" \
		--tag "$(TAG)" \
		. && \
	cp "$<" "$@"


.PHONY: clean test
