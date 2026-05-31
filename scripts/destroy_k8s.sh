#!/usr/bin/env bash

set -euo pipefail

# ----- Fixed values -----
export REGION="eu-central-1"
export ENVIRONMENT="dev"

# ----- Helpers -----
info() { echo "[INFO] $*"; }
err()  { echo "[ERROR] $*" 1>&2; }

# Ensure we run from repo root (where components/ exists)
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

if [[ ! -d components ]]; then
  err "This script must be run within the repository root (components/ not found)."
  exit 1
fi

# Components to process in creation order (matching create_k8s.sh)
# We'll destroy in reverse order except VPC which we will apply.
COMPONENTS=(
  vpc
  eks
  eks-setup
  eks-argocd
)

run_destroy_or_apply() {
  local comp="$1"
  local comp_dir="components/$comp"

  if [[ ! -d "$comp_dir" ]]; then
    err "Component directory not found: $comp_dir"
    return 1
  fi

  pushd "$comp_dir" >/dev/null
  if [[ "$comp" == "vpc" ]]; then
    info "Applying (not destroying) component: $comp (REGION=$REGION, ENVIRONMENT=$ENVIRONMENT)"
    mage tofu:plan tofu:apply
  else
    info "Destroying component: $comp (REGION=$REGION, ENVIRONMENT=$ENVIRONMENT)"
    mage tofu:plandestroy tofu:apply
  fi
  popd >/dev/null
}

# Confirm destructive action
info "About to destroy components (except VPC will be applied) in reverse order: ${COMPONENTS[*]}"
read -r -p "Proceed? type 'yes' to continue: " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  err "Aborted by user."
  exit 1
fi

START_TS=$(date +%s)

# Iterate in reverse
for (( idx=${#COMPONENTS[@]}-1 ; idx>=0 ; idx-- )); do
  comp="${COMPONENTS[$idx]}"
  run_destroy_or_apply "$comp"
  info "Done: $comp"
  echo
done

DUR=$(( $(date +%s) - START_TS ))
info "Destroy workflow finished in ${DUR}s"

