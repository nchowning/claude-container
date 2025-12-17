.PHONY: build

build:
	docker build --build-arg CACHEBUST=$(shell date +%Y-%m-%dT%H:%M:%S) -t claude:latest .
