ORG=bossjones
NAME=workstation-docker
VERSION?=$(shell cat VERSION)
ROOT_DIR = $(shell pwd)
GIT_BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
GIT_SHA     = $(shell git rev-parse HEAD)
BUILD_DATE  = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
_ARCH       = $(shell uname -p)

RPI_BUILD ?= 'false'
ifeq (${_ARCH}, x86_64)
	override RPI_BUILD = 'false'
# @echo $(value RPI_BUILD)
else
	override RPI_BUILD = 'true'
# @echo $(value RPI_BUILD)
endif

all: build size

.PHONY: dockerfile
dockerfile: ## Update Dockerfiles
	@echo "===> dockerfile..."
# @sed -i.bu 's/FROM golang:[0-9.]\{5\}-alpine/FROM golang:$(VERSION)-alpine/' Dockerfile

build: dockerfile ## Build docker image
ifeq "$(VERSION)" "ubuntu"
	docker build -f Dockerfile.ubuntu  --build-arg VCS_REF=$(GIT_SHA) --build-arg BUILD_DATE=$(VERSION) --build-arg RPI_BUILD=$(RPI_BUILD) --build-arg BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ') -t $(ORG)/$(NAME):ubuntu .
else
	docker build -f Dockerfile.focal --build-arg VCS_REF=$(GIT_SHA) --build-arg BUILD_DATE=$(VERSION) --build-arg RPI_BUILD=$(RPI_BUILD) --build-arg BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ') -t $(ORG)/$(NAME):$(VERSION) .
endif

.PHONY: size
size: ## Update docker image size in README.md
	sed -i.bu 's/docker%20image-.*-blue/docker%20image-$(shell docker images --format "{{.Size}}" $(ORG)/$(NAME):$(VERSION)| cut -d' ' -f1)-blue/' README.md

# .PHONY: run
# run: ## Run docker image
# 	@echo "===> Running $(ORG)/$(NAME):$(VERSION)..."
# 	@docker run --init -it --rm -v $(GOPATH):/go $(ORG)/$(NAME):$(VERSION)

.PHONY: ssh
ssh: ## SSH into docker image
ifeq "$(VERSION)" "ubuntu"
	docker run -ti --rm $(ORG)/$(NAME):ubuntu
else
	docker run -ti --rm $(ORG)/$(NAME):$(VERSION)
endif

.PHONY: push
push: build ## Push docker image to docker registry
	@echo "===> Pushing $(ORG)/$(NAME):$(VERSION) to docker hub..."
	@docker push $(ORG)/$(NAME):$(VERSION)

clean: ## Clean docker image and stop all running containers
	docker-clean stop
	docker rmi $(ORG)/$(NAME):$(VERSION) || true
	docker rmi $(ORG)/$(NAME):ubuntu || true

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: alias
alias:
	echo 'alias docker-gvim="docker run --init -it --rm -v \$(pwd):/code -v $$GOPATH:/go -v /etc/localtime:/etc/localtime:ro -v $$HOME/.docker_go_dev_zsh_history:/root/.zsh_history:rw $(ORG)/$(NAME):$(VERSION)"'

.PHONY: run
run: ## Run docker image
	@echo "===> Running $(ORG)/$(NAME):$(VERSION)..."
	docker run --init -it --rm -v $(ROOT_DIR):/code -v $$GOPATH:/go -v /etc/localtime:/etc/localtime:ro -v $$HOME/.docker_go_dev_zsh_history:/root/.zsh_history:rw $(ORG)/$(NAME):$(VERSION)


.DEFAULT_GOAL := help
