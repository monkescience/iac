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

# Components to process in order
COMPONENTS=(
  vpc
  eks
  eks-setup
  eks-argocd
)

run_component() {
  local comp="$1"
  local comp_dir="components/$comp"

  if [[ ! -d "$comp_dir" ]]; then
    err "Component directory not found: $comp_dir"
    return 1
  fi

  info "Processing component: $comp (REGION=$REGION, ENVIRONMENT=$ENVIRONMENT)"
  pushd "$comp_dir" >/dev/null
  # Mage will find magefiles/tofu.go and use OpenTofu under the hood.
  mage tofu:plan tofu:apply
  popd >/dev/null
}

START_TS=$(date +%s)
info "Starting plan+apply for components: ${COMPONENTS[*]}"

for comp in "${COMPONENTS[@]}"; do
  run_component "$comp"
  info "Done: $comp"
  echo
done

DUR=$(( $(date +%s) - START_TS ))
info "All components finished in ${DUR}s"

