# Task runner for the Atmos-managed IaC monorepo.
# Tool versions are pinned in mise.toml -- run `make install` once to get them.
#
# Most targets act on a single component in a single stack. If STACK or
# COMPONENT is unset, you will be prompted to select from Atmos' known values:
#   make plan
#   STACK=monke-dev COMPONENT=aws/vpc make deploy
#
# Stack names follow atmos.yaml's name_pattern "{namespace}-{stage}":
#   monke-dev  monke-prod  monke-root  monkescience-global

.DEFAULT_GOAL := help

TF_DIRS := components/terraform modules

# AWS auth via the repo's SSO config. The profile is derived at runtime from the
# selected stack's stage (e.g. STACK=monke-dev -> monke-eu-central-1-dev-admin).
# Override by setting AWS_PROFILE=... before running make. Run `aws sso login` first.
export AWS_CONFIG_FILE := $(CURDIR)/configs/aws.config.ini

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

.PHONY: kubeconfig
kubeconfig: ## Write the homelab Kubernetes kubeconfig to ./kubeconfig
	atmos terraform output proxmox/talos-cluster -s monke-homelab -raw kubeconfig --skip-init --logs-level Off > kubeconfig
	chmod 600 kubeconfig

.PHONY: talosconfig
talosconfig: ## Write the homelab Talos config to ./talosconfig
	atmos terraform output proxmox/talos-cluster -s monke-homelab -raw talosconfig --skip-init --logs-level Off > talosconfig
	chmod 600 talosconfig

.PHONY: fmt
fmt: ## Format all OpenTofu files
	tofu fmt -recursive $(TF_DIRS)

.PHONY: lint
lint: ## Lint OpenTofu components and modules with tflint
	tflint --recursive --chdir=components/terraform
	tflint --recursive --chdir=modules

.PHONY: plan
plan: ## Plan a component and save a plan file (prompts when STACK/COMPONENT are unset)
	@STACK="$(STACK)" COMPONENT="$(COMPONENT)" scripts/atmos-tf plan

.PHONY: apply
apply: ## Apply the plan file from `make plan` (no re-plan)
	@STACK="$(STACK)" COMPONENT="$(COMPONENT)" scripts/atmos-tf apply

.PHONY: deploy
deploy: ## Plan + apply in one shot, auto-approved (skips the review step)
	@STACK="$(STACK)" COMPONENT="$(COMPONENT)" scripts/atmos-tf deploy

.PHONY: destroy
destroy: ## Destroy a component in a stack
	@STACK="$(STACK)" COMPONENT="$(COMPONENT)" scripts/atmos-tf destroy

.PHONY: clean
clean: ## Remove local .terraform dirs, planfiles, and generated backend files
	find components/terraform -type d -name '.terraform' -prune -exec rm -rf {} +
	find components/terraform -type f \
		\( -name '*.planfile' -o -name 'backend.tf.json' -o -name '*.terraform.tfvars.json' \) -delete
