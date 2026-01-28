.PHONY: build

IMAGE_TAG ?= claude:latest

build:
	docker build \
		--build-arg CACHEBUST=$(shell date +%Y-%m-%dT%H:%M:%S) \
		-t $(IMAGE_TAG) .
