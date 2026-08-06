# Containerised Service Kubernetes and GitOps

This repository is Project 5 of the AI-assisted cloud engineering learning
roadmap. It holds the versioned Kubernetes desired state for the service built
in Project 3 and demonstrates how a reviewed Git change becomes a local
deployment through GitHub, Kustomize, and Argo CD.

## What this project will do

The project will deploy the Project 3 HTTP service to Docker Desktop's local
Kubernetes cluster. It will define:

- a Kubernetes Deployment and Service;
- liveness and readiness probes for `GET /health`;
- runtime configuration through a ConfigMap and references to externally
  supplied Secrets;
- resource requests and limits, a restricted security context, NetworkPolicy,
  and horizontal scaling;
- Kustomize bases and environment overlays;
- pull-request checks that render and validate the desired state; and
- an Argo CD application with documented synchronization and rollback.

The deployed service exposes `GET /health`, `GET /version`, and
`GET /config-summary`. Its source and container build remain in the separate
[`containerised-service-cicd`](https://github.com/abdalrahmanattya/containerised-service-cicd)
application repository.

## Why this is useful

Kubernetes configuration is operational code. A wrong port, image tag, probe,
permission, or resource value can prevent a healthy application from serving
traffic. This project makes those changes reviewable and teaches how to use
rendered manifests, pod status, events, and logs to diagnose deployment
failures before editing files.

The intended delivery path is:

```text
Project 3 release -> GHCR image
                         |
GitHub pull request -> validated Kustomize desired state
                         |
                     merge to main
                         |
                 Argo CD reconciliation
                         |
              local Kubernetes deployment
```

## Safety boundaries

- The initial target is a local Docker Desktop Kubernetes cluster only.
- No cloud cluster, paid service, or production environment is required.
- No token, password, kubeconfig, private key, or Secret value belongs in Git.
- Secret manifests may contain references or documented placeholders only.
- Cluster-changing commands require explicit approval of the command and local
  target before execution.
- GitHub publication and image publication use reviewed workflows and scoped
  repository permissions.

## Planned user workflow

Once implemented, a contributor will:

1. change an environment overlay on a feature branch;
2. open a GitHub pull request;
3. review the rendered and validated manifests;
4. merge the approved desired-state change;
5. observe Argo CD synchronize the local cluster; and
6. verify health, version, configuration, events, and rollout status.

To inspect an environment without changing a cluster, render its Kustomize
overlay from the repository root:

```sh
kubectl kustomize apps/containerised-service/overlays/local
kubectl kustomize apps/containerised-service/overlays/staging
```

The `local` overlay uses one replica and `APP_ENV=development`. The `staging`
overlay uses two replicas and `APP_ENV=staging`. Both overlays preserve the
base selectors and probes and load `SERVICE_NAME`, `APP_ENV`, and `LOG_LEVEL`
from a generated ConfigMap.

The base also defines a token-disabled ServiceAccount, default-deny ingress,
same-namespace access to the service, and an HPA bounded to one through three
replicas. The HPA needs a metrics-server; the local Docker Desktop cluster may
not enforce NetworkPolicy, so those controls must be verified explicitly.

Both overlays reference an external Secret named
`containerised-service-runtime`; the Secret value is deliberately not stored
in this repository. Create it only in the target namespace from a protected
local file when deployment is approved:

```sh
kubectl -n containerised-service create secret generic containerised-service-runtime \
  --from-file=APP_RUNTIME_SECRET=/secure/local/path/app-runtime-secret
```

If that Secret is absent, Kubernetes reports `CreateContainerConfigError` and
the pod does not start. Diagnose with `kubectl describe pod` and its Events;
do not place the Secret value in Git or paste it into logs.

Exact behaviour is defined in [`docs/requirements.md`](docs/requirements.md),
and component boundaries are described in
[`docs/architecture.md`](docs/architecture.md).

## Repository map

| Path | Purpose |
| --- | --- |
| `AGENTS.md` | Safe collaboration instructions for Codex |
| `docs/requirements.md` | Deployment, validation, GitOps, and safety contracts |
| `docs/architecture.md` | Repository boundaries, components, and delivery flow |
| `docs/development.md` | Planned and verified local commands |
| `docs/issues/` | Ordered, bounded implementation issues |
| `docs/decisions/` | Durable decisions and trade-offs |
| `docs/project-journal.md` | Current state and exact resume point |
| `docs/learning-roadmap.md` | Project 5 phase and completion gate |
| `CHANGELOG.md` | Notable user-visible changes |

## Current status and next step

Issues 001–006 are complete on `main`. Issue 007 is in progress on the
`feature/007-local-deployment-argocd` branch. The next step is to prepare the
local Docker Desktop deployment and Argo CD reconciliation; no cluster
resources have been changed yet. The reviewed Project 3 image is available
publicly in GHCR and is pinned by immutable digest in the base.

Published image:

```text
ghcr.io/abdalrahmanattya/containerised-service-cicd:0.1.2
```

Immutable digest:

```text
sha256:86e1acfa46fb1edaa8d131b9c8063624eb356b6704835675e64e939b9ff6738b
```
