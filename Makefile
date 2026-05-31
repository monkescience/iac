# Task runner for the Atmos-managed IaC monorepo.
# Tool versions are pinned in mise.toml -- run `make install` once to get them.
#
# Most targets act on a single component in a single stack:
#   make plan   COMPONENT=organization STACK=monke-root
#   make apply  COMPONENT=vpc          STACK=monke-dev
#   make deploy COMPONENT=sso          STACK=monke-root
#
# Stack names follow atmos.yaml's name_pattern "{namespace}-{stage}":
#   monke-dev  monke-prod  monke-root  monkescience-global

.DEFAULT_GOAL := help

TF_DIRS := components/terraform modules

# AWS auth via the repo's SSO config. The profile is derived from the stack's
# stage (e.g. STACK=monke-dev -> monke-eu-central-1-dev-admin). Override by
# passing AWS_PROFILE=... on the command line. Run `aws sso login` first.
export AWS_CONFIG_FILE := $(CURDIR)/configs/aws.config.ini
STAGE := $(lastword $(subst -, ,$(STACK)))
export AWS_PROFILE ?= monke-eu-central-1-$(STAGE)-admin

.PHONY: help
help: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install: ## Install pinned tools (opentofu, atmos, tflint) via mise
	mise install

.PHONY: list
list: ## List the stacks and components Atmos knows about
	atmos list stacks
	atmos list components

.PHONY: validate
validate: ## Validate stack configuration
	atmos validate stacks

.PHONY: fmt
fmt: ## Format all OpenTofu files
	tofu fmt -recursive $(TF_DIRS)

.PHONY: lint
lint: ## Lint OpenTofu components with tflint
	tflint --recursive --chdir=components/terraform

guard-%:
	@if [ -z '$($*)' ]; then echo "Missing required variable: $*"; exit 1; fi

.PHONY: plan
plan: guard-COMPONENT guard-STACK ## Plan a component in a stack (COMPONENT= STACK=)
	atmos terraform plan $(COMPONENT) -s $(STACK)

.PHONY: apply
apply: guard-COMPONENT guard-STACK ## Apply a component in a stack
	atmos terraform apply $(COMPONENT) -s $(STACK)

.PHONY: deploy
deploy: guard-COMPONENT guard-STACK ## Plan + apply a component in a stack
	atmos terraform deploy $(COMPONENT) -s $(STACK)

.PHONY: destroy
destroy: guard-COMPONENT guard-STACK ## Destroy a component in a stack
	atmos terraform destroy $(COMPONENT) -s $(STACK)

.PHONY: clean
clean: ## Remove local .terraform dirs, planfiles, and generated backend files
	find components/terraform -type d -name '.terraform' -prune -exec rm -rf {} +
	find components/terraform -type f \
		\( -name '*.planfile' -o -name 'backend.tf.json' -o -name '*.terraform.tfvars.json' \) -delete
