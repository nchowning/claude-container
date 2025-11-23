.PHONY: build

build:
	docker build \
		--build-arg CACHEBUST=$(shell date +%Y-%m-%d) \
		-t claude:latest \
		.
