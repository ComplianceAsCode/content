PROFILE?=
# Defines the product that the test aims to test
# Since we already have test for RHCOS4, this is the default for now.
PRODUCT?=rhcos4
CONTENT_IMAGE?=
export ROOT_DIR=$(shell git rev-parse --show-toplevel)
TEST_DIR=$(ROOT_DIR)/tests/ocp4e2e
TEST_FLAGS?=-v -timeout 120m
# Skip pushing the container to your cluster
SKIP_CONTAINER_PUSH?=false
# Should the test attempt to install the operator?
INSTALL_OPERATOR?=true

.PHONY: all
all: e2e

.PHONY: e2e
e2e: image-to-cluster ## Run the e2e tests. This requires that the PROFILE and PRODUCT environment variables be set. This will upload images to the cluster as part of the run with the `image-to-cluster` target.
	pushd $(TEST_DIR) && \
	go test $(TEST_FLAGS) . -profile="$(PROFILE)" -product="$(PRODUCT)" -content-image="$(CONTENT_IMAGE)" -install-operator=$(INSTALL_OPERATOR)

.PHONY: image-to-cluster
image-to-cluster: ## Upload a content image to the cluster. The SKIP_CONTAINER_PUSH environment variable skips this step; the CONTENT_IMAGE environment variable takes a pre-uploaded image into use.
ifdef IMAGE_FORMAT
	$(eval component = ocp4-content-ds)
	$(eval CONTENT_IMAGE = $(IMAGE_FORMAT))
	@echo "IMAGE_FORMAT variable detected. Using image '$(CONTENT_IMAGE)'"
else ifeq ($(SKIP_CONTAINER_PUSH), true)
	@echo "Skipping content image upload, will use '$(CONTENT_IMAGE)'"
else
	@echo "Building content image"
	$(ROOT_DIR)/utils/build_ds_container.sh
	$(eval CONTENT_IMAGE = image-registry.openshift-image-registry.svc:5000/openshift-compliance/openscap-ocp4-ds:latest)
	@echo "Content image built and available through: $(CONTENT_IMAGE)"
endif

.PHONY: help
help: ## Show this help screen
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@echo 'Available targets are:'
	@echo ''
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
