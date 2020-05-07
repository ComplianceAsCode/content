PROFILE?=
CONTENT_IMAGE?=
export ROOT_DIR=$(shell git rev-parse --show-toplevel)
export GOFLAGS=-mod=vendor
TEST_DIR=$(ROOT_DIR)/tests/unit/kubernetes
TEST_FLAGS?=-v -count=1

.PHONY: all
all: unit

.PHONY: unit
unit: ## Run the unit tests.
	pushd $(TEST_DIR) && \
	go test $(TEST_FLAGS) .

.PHONY: help
help: ## Show this help screen
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@echo 'Available targets are:'
	@echo ''
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
