VERSION=v0.0.0
REGISTRY?=quay.io
NAME?=garyellis/container-build
GIT_SHORT_COMMIT=$$(git rev-parse --short HEAD)
GIT_BRANCH=$$(git rev-parse --abbrev-ref HEAD)

IMAGE_NAME=$(REGISTRY)/$(NAME)
IMAGE_TAG_COMMIT=$(IMAGE_NAME):$(GIT_SHORT_COMMIT)
IMAGE_TAG_BRANCH=$(IMAGE_NAME):$(GIT_BRANCH)

SHELL := /bin/bash

export VERSION REGISTRY NAME GIT_SHORT_COMMIT IMAGE_NAME IMAGE_TAG_COMMIT IMAGE_TAG_BRANCH

.PHONY: help
	.DEFAULT_GOAL := help

help: ## show this message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


registry-login: ## login to the container registry
	docker login $(REGISTRY) -u "$$REGISTRY_USERNAME" -p "$$REGISTRY_PASSWORD"

build: ## build the binary
	docker pull  $(IMAGE_TAG_COMMIT) || \
	docker build --build-arg VERSION=$(VERSION) -t $(IMAGE_TAG_COMMIT) .

push-registry: ## push the image to the registry
	docker push $(IMAGE_TAG_COMMIT)
	docker tag $(IMAGE_TAG_COMMIT) $(IMAGE_TAG_BRANCH)
	docker push $(IMAGE_TAG_BRANCH)


release: ## "retags an image created by the most recently merged pull request
	. ./scripts/functions.sh && release_from_merged_commit
