#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 OUTPUT_DIRECTORY" >&2
  exit 2
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output_directory="$1"
mkdir -p "${output_directory}"

for environment in local staging; do
  # Keep one rendered file per overlay so each environment is validated independently.
  kubectl kustomize "${repo_root}/apps/containerised-service/overlays/${environment}" \
    >"${output_directory}/${environment}.yaml"
done

echo "Rendered overlays into ${output_directory}"
