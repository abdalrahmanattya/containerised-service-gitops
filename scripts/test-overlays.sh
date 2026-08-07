#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"${repo_root}/scripts/check-public-secrets.sh"

for environment in local staging; do
  # Render each overlay independently so one environment cannot hide a broken sibling.
  rendered="$(kubectl kustomize "${repo_root}/apps/containerised-service/overlays/${environment}")"
  grep -q 'kind: ConfigMap' <<<"${rendered}"
  grep -q 'name: containerised-service-config' <<<"${rendered}"
  grep -q 'name: containerised-service-runtime' <<<"${rendered}"
  grep -q 'path: /health' <<<"${rendered}"
  grep -q 'containerised-service-cicd@sha256:6a9075b289a699692f60f6936b84590c8ad487071145a909ae7c3de98025f3b2' <<<"${rendered}"
  grep -q 'kind: ServiceAccount' <<<"${rendered}"
  grep -q 'automountServiceAccountToken: false' <<<"${rendered}"
  grep -q 'kind: HorizontalPodAutoscaler' <<<"${rendered}"
  grep -q 'kind: NetworkPolicy' <<<"${rendered}"
done

local_render="$(kubectl kustomize "${repo_root}/apps/containerised-service/overlays/local")"
staging_render="$(kubectl kustomize "${repo_root}/apps/containerised-service/overlays/staging")"

grep -q 'APP_ENV: development' <<<"${local_render}"
grep -q 'APP_ENV: staging' <<<"${staging_render}"
grep -q '^  replicas: 1$' <<<"${local_render}"
grep -q '^  replicas: 2$' <<<"${staging_render}"

echo "Overlay renders passed: local, staging"
