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

# Atmos names the plan file "<stack>-<component>.planfile" with slashes replaced by
# dashes (e.g. aws/ecr -> ...-aws-ecr.planfile). Mirror that so `make apply` finds it.
PLANFILE = $(subst /,-,$(STACK)-$(COMPONENT)).planfile

# run_tf: run an atmos terraform subcommand, resolving the state-encryption passphrase
# for components that have an encryption.tf (organization, bootstrap, github/repositories).
# The passphrase comes from $TOFU_STATE_PASSPHRASE if set (e.g. sourced from a password
# manager: TOFU_STATE_PASSPHRASE=$$(pass tofu/state) make ...), otherwise you are prompted
# silently. It is never echoed, exported to your shell, or written to your shell history.
# $(1) = subcommand, $(2) = extra args
define run_tf
pass="$$TOFU_STATE_PASSPHRASE"; \
if [ -f "components/terraform/$(COMPONENT)/encryption.tf" ]; then \
if [ -z "$$pass" ]; then read -rs -p "tofu state passphrase for $(COMPONENT): " pass </dev/tty; echo; fi; \
export TF_ENCRYPTION="key_provider \"pbkdf2\" \"default\" { passphrase = \"$$pass\" }"; \
fi; \
atmos terraform $(1) $(COMPONENT) -s $(STACK) $(2)
endef

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
lint: ## Lint OpenTofu components and modules with tflint
	tflint --recursive --chdir=components/terraform
	tflint --recursive --chdir=modules

guard-%:
	@if [ -z '$($*)' ]; then echo "Missing required variable: $*"; exit 1; fi

.PHONY: plan
plan: guard-COMPONENT guard-STACK ## Plan a component and save a plan file (COMPONENT= STACK=)
	@$(call run_tf,plan)

.PHONY: apply
apply: guard-COMPONENT guard-STACK ## Apply the plan file from `make plan` (no re-plan)
	@$(call run_tf,apply,--planfile $(PLANFILE))

.PHONY: deploy
deploy: guard-COMPONENT guard-STACK ## Plan + apply in one shot, auto-approved (skips the review step)
	@$(call run_tf,deploy)

.PHONY: destroy
destroy: guard-COMPONENT guard-STACK ## Destroy a component in a stack
	@$(call run_tf,destroy)

.PHONY: clean
clean: ## Remove local .terraform dirs, planfiles, and generated backend files
	find components/terraform -type d -name '.terraform' -prune -exec rm -rf {} +
	find components/terraform -type f \
		\( -name '*.planfile' -o -name 'backend.tf.json' -o -name '*.terraform.tfvars.json' \) -delete
