NAME = vila/alfresco-empty-trash
VERSION = latest
TAG = 1.0

APP_NAME=$(shell echo "$(NAME)" | tr -cd '[[:alnum:]]')_$(VERSION)
ROOT_DIR=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: Dockerfile ## Build the container
	docker build -t $(NAME):$(VERSION) .

start: ## start container
	docker run -d --name="$(APP_NAME)" \
	-v $(ROOT_DIR)/archivednodes.log:/opt/check/archivednodes.log \
	$(NAME):$(VERSION)

run: ## Run container
	docker run -it --rm --name="$(APP_NAME)" \
	-v $(ROOT_DIR)/archivednodes.log:/opt/check/archivednodes.log \
	$(NAME):$(VERSION)  /bin/bash


logs: ## Show logs
	docker logs -f "$(APP_NAME)"

shell: ## Get shell inside container
	docker exec -it -e COLUMNS="240" -e LINES="64" -e TERM="$(TERM)" "$(APP_NAME)" /bin/bash

stop: ## Stop and delete container
	docker stop "$(APP_NAME)"
	docker rm "$(APP_NAME)"

clean:  ## Remove unused images
	-docker rm `docker ps -a -q`
	-docker volume rm `docker volume ls -q`
	-docker rmi `docker images -q`

