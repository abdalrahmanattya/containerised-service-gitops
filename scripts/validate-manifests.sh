#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
schema_version="${KUBE_SCHEMA_VERSION:-1.33.0}"
rendered_directory="$(mktemp -d)"
trap 'rm -rf "${rendered_directory}"' EXIT

for command_name in kubectl kubeconform kube-linter trivy; do
  command -v "${command_name}" >/dev/null || {
    echo "required command not found: ${command_name}" >&2
    exit 127
  }
done

"${repo_root}/scripts/render-manifests.sh" "${rendered_directory}"
kubeconform \
  -strict \
  -kubernetes-version "${schema_version}" \
  -summary \
  "${rendered_directory}"
kube-linter lint "${rendered_directory}"
trivy config \
  --scanners misconfig,secret \
  --severity HIGH,CRITICAL \
  --exit-code 1 \
  "${rendered_directory}"
"${repo_root}/scripts/check-public-secrets.sh"

echo "Manifest validation passed for Kubernetes ${schema_version}"
