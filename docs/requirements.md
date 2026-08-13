# GitOps repository requirements

## Outcome

Run the released application service on a local Kubernetes cluster from
Git-versioned desired state. A reviewer must be able to understand the rendered
workload, verify it before synchronization, diagnose a failed rollout from
evidence, and return to a known-good Git revision.

## Repository and artifact contract

- `containerised-service-cicd` owns service source, tests, Dockerfile, semantic
  version, and image publication.
- This repository owns Kubernetes configuration and GitOps operations.
- The deployment references a versioned public GHCR image. Production-like
  overlays should prefer an immutable digest after publication is verified.
- No workflow silently rebuilds the application inside this repository.

## Workload requirements

- Run the container as a non-root user with privilege escalation disabled.
- Use a Deployment with an explicit rolling-update strategy and revision
  history.
- Expose container port `8000` through a ClusterIP Service.
- Use HTTP liveness and readiness probes against `GET /health`.
- Define CPU and memory requests and limits with documented assumptions.
- Avoid mounting a Kubernetes API token unless the workload needs one.
- Add stable labels used consistently by selectors, policies, and operations.

## Configuration requirements

- Supply `SERVICE_NAME`, `APP_ENV`, and `LOG_LEVEL` through reviewed
  environment configuration.
- Use Kustomize bases for shared desired state and overlays for intentional
  environment differences.
- Demonstrate a Secret reference without committing a Secret value.
- Missing required configuration must become visible during validation or
  rollout diagnosis.

## Network and scaling requirements

- Define default-deny ingress and the minimum ingress needed to reach the
  service inside the chosen namespace.
- Document whether the local cluster's networking enforces NetworkPolicy.
- Define an HPA with explicit minimum/maximum replicas and CPU target.
- Document that HPA behaviour depends on metrics-server availability.

## Validation and GitHub requirements

- Pull requests render every overlay and fail on malformed Kustomize input.
- Rendered manifests receive Kubernetes schema validation and the agreed
  security/configuration checks.
- Third-party GitHub Actions are pinned to reviewed commit SHAs.
- Workflows use minimum required permissions and do not deploy from pull
  requests.
- Local commands equivalent to CI are documented and reproducible.

## GitOps and operations requirements

- Argo CD observes this public repository and reconciles only the agreed local
  namespace and overlay.
- Bootstrap and cluster mutation remain explicit operator actions; repository
  access alone must not authorize an arbitrary cloud deployment.
- Health, rollout status, events, logs, rendered manifests, and Argo CD status
  are part of the diagnostic workflow.
- Rollback uses a reviewed Git revert to restore known-good desired state; any
  emergency runtime rollback is documented as temporary drift.

## Acceptance criteria

- All overlays render deterministically and validate locally and in GitHub CI.
- The local deployment reaches Available and all three service endpoints return
  the documented application responses.
- Health, resources, configuration, identity, network access, and scaling are
  reviewed with evidence.
- One deliberate failure is diagnosed from Kubernetes evidence before repair.
- Argo CD applies the repaired Git state and a tested rollback is documented.
- No credentials, kubeconfig, token, or Secret value is committed.

## Non-goals

- A managed or production Kubernetes cluster
- Ingress, public DNS, TLS certificates, or internet exposure
- A service mesh, database, persistent volume, or cloud-provider integration
- Building application images in this repository
- Storing encrypted or plaintext Secret values in Git
- Automatic promotion to staging or production
