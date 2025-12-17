.PHONY: build build-ubuntu build-debian build-alpine

BASE_IMAGE ?= ubuntu:24.04
CLAUDE_VERSION ?= latest
IMAGE_TAG ?= claude:latest

build:
	docker build \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg CLAUDE_CODE_VERSION=$(CLAUDE_VERSION) \
		--build-arg CACHEBUST=$(shell date +%Y-%m-%dT%H:%M:%S) \
		-t $(IMAGE_TAG) .

build-ubuntu:
	$(MAKE) build BASE_IMAGE=ubuntu:24.04 IMAGE_TAG=claude:ubuntu

build-debian:
	$(MAKE) build BASE_IMAGE=debian:trixie IMAGE_TAG=claude:debian

build-alpine:
	docker build -f Dockerfile.alpine \
		--build-arg CLAUDE_CODE_VERSION=$(CLAUDE_VERSION) \
		--build-arg CACHEBUST=$(shell date +%Y-%m-%dT%H:%M:%S) \
		-t claude:alpine .
