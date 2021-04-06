ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PROJECT_NAME := $(filter-out $@,$(MAKECMDGOALS))

.PHONY: deploy
deploy:
	helm upgrade --dry-run -i \
		-n $(filter-out $@,$(MAKECMDGOALS)) \
		--create-namespace \
		$(filter-out $@,$(MAKECMDGOALS))-gitops \
		$(ROOT_DIR)/projects/$(filter-out $@,$(MAKECMDGOALS))

%:
	@:
