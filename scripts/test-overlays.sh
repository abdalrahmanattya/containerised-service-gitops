#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for environment in local staging; do
  # Render each overlay independently so one environment cannot hide a broken sibling.
  rendered="$(kubectl kustomize "${repo_root}/apps/containerised-service/overlays/${environment}")"
  grep -q 'kind: ConfigMap' <<<"${rendered}"
  grep -q 'name: containerised-service-config' <<<"${rendered}"
  grep -q 'name: containerised-service-runtime' <<<"${rendered}"
  grep -q 'path: /health' <<<"${rendered}"
  grep -q 'containerised-service-cicd@sha256:86e1acfa46fb1edaa8d131b9c8063624eb356b6704835675e64e939b9ff6738b' <<<"${rendered}"
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
