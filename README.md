# Containerised Service Kubernetes and GitOps

This repository is the Kubernetes desired-state and GitOps operations half of
the Containerised Service case study. It deploys the HTTP service built in the
separate Project 3 application repository to a Docker Desktop Kubernetes
cluster. A reviewed Git change is rendered by Kustomize and reconciled by Argo
CD; this repository does not build the application image.

## What this project does

The project deploys the Project 3 HTTP service to Docker Desktop's local
Kubernetes cluster. It defines:

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

Together, these repositories form the **Secure Container Delivery & GitOps**
case study. CICD owns source, tests, image construction, scanning, and the
multi-architecture GHCR release. This repository owns reviewed Kubernetes
desired state, environment validation, Argo CD reconciliation, and rollback.

## How it works

Kubernetes configuration is operational code. A wrong port, image tag, probe,
permission, or resource value can prevent a healthy application from serving
traffic. This project makes those changes reviewable and teaches how to use
rendered manifests, pod status, events, and logs to diagnose deployment
failures before editing files.

The delivery path and ownership boundaries are shown in the companion
[architecture diagram](docs/architecture.svg) (generated from the
[Mermaid source](docs/architecture.mmd)). The public GitHub/GHCR boundary ends
at desired state and an immutable image digest; the local operator owns the
kubeconfig, runtime Secret, Argo CD, and Docker Desktop cluster.

## Safety boundaries

- The supported target is a local Docker Desktop Kubernetes cluster only.
- No cloud cluster, paid service, or production environment is required.
- No token, password, kubeconfig, private key, or Secret value belongs in Git.
- Secret manifests may contain references or documented placeholders only.
- Cluster-changing commands require explicit approval of the command and local
  target before execution.
- GitHub publication and image publication use reviewed workflows and scoped
  repository permissions.

## Contributor workflow

A contributor:

1. changes an environment overlay on a feature branch;
2. opens a GitHub pull request;
3. reviews the rendered and validated manifests;
4. merges the approved desired-state change;
5. observes Argo CD synchronize the local cluster; and
6. verifies health, version, configuration, events, and rollout status.

## Validate without changing a cluster

From the repository root, run the lightweight repository checks:

```sh
./scripts/test-overlays.sh
./scripts/check-public-secrets.sh
git diff --check
```

With kubectl, Kubeconform `0.8.0`, KubeLinter `0.8.3`, and Trivy `0.69.3`
installed, run the same complete validation shape used by CI:

```sh
./scripts/validate-manifests.sh
```

Expected result: both overlays render and the schema, security, configuration,
and public-secret checks pass.

## Set up the local deployment

The tested target is Docker Desktop Kubernetes. Every command in this section
changes that local cluster and should be run only after confirming the target:

```sh
kubectl config current-context
kubectl get nodes
```

Expected result: context `docker-desktop` and a Ready local node. Install Argo
CD `v3.5.0`, create the application namespace, and create your own runtime
Secret from a protected local file:

```sh
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.0/manifests/install.yaml
kubectl create namespace containerised-service
kubectl -n containerised-service create secret generic containerised-service-runtime \
  --from-file=APP_RUNTIME_SECRET=/secure/local/path/app-runtime-secret
kubectl apply -f argocd/applications/containerised-service-local.yaml
```

The protected file contains a value chosen by the local operator; nobody needs
to send you a shared Secret. Do not place that file or its value in this
repository. The `APP_RUNTIME_SECRET` reference documents external Secret
handling and missing-Secret diagnosis; the simple service does not return or
log its value. Metrics-server is also required for HPA metrics. The pinned,
checksum-verified Docker Desktop procedure and its local-only TLS exception are
documented in [`docs/development.md`](docs/development.md#local-metrics-server).

Argo CD watches `main` and reconciles the local overlay. Allow its normal
repository refresh, then verify:

```sh
kubectl -n argocd get application containerised-service-local
kubectl -n containerised-service rollout status deployment/containerised-service
kubectl -n containerised-service get pods
kubectl -n containerised-service get hpa containerised-service
```

Expected result: the Application is `Synced` and `Healthy`, the Deployment is
Available, the pod is Ready, and the HPA has a CPU metric.

## Verify the service

Open a temporary local port-forward:

```sh
kubectl -n containerised-service port-forward service/containerised-service 8001:8000
```

In another terminal, run:

```sh
curl --fail http://127.0.0.1:8001/health
curl --fail http://127.0.0.1:8001/version
curl --fail http://127.0.0.1:8001/config-summary
```

Expected responses report healthy status, application version `0.1.3`, and the
local development configuration. Stop the port-forward with `Ctrl-C`.

## Diagnose a failed rollout

Gather evidence before editing desired state:

```sh
kubectl -n argocd get application containerised-service-local
kubectl -n containerised-service get deployment containerised-service
kubectl -n containerised-service get pods -o wide
kubectl -n containerised-service get events --sort-by=.metadata.creationTimestamp
kubectl -n containerised-service describe pod <pod-name>
kubectl -n containerised-service logs <pod-name>
kubectl kustomize apps/containerised-service/overlays/local
```

Compare Argo's Git revision, the rendered manifest, live image, pod state, and
Events. Logs may legitimately be unavailable when a container never starts.
Rank likely causes from this evidence, then make the smallest repair through a
reviewed pull request.

## Roll back through Git

Use a revert commit so history remains visible and Argo CD receives a reviewed
desired-state change:

```sh
git switch main
git pull --ff-only
git switch -c feature/008-rollback-<short-reason>
git revert <faulty-commit>
```

Push that branch, review and merge its pull request, then wait for Argo CD and
repeat the deployment and endpoint checks. For a merged pull request whose
merge commit must be reverted, use `git revert -m 1 <merge-commit>`. Do not use
`kubectl rollout undo` as the normal repair because Argo CD would treat that as
drift and restore Git's still-faulty state.

## Clean up the local cluster

First confirm context `docker-desktop`. These commands remove the Application,
workload namespace including its external Secret, metrics-server, and Argo CD:

```sh
kubectl delete -f argocd/applications/containerised-service-local.yaml
kubectl delete namespace containerised-service
kubectl delete -f /private/tmp/metrics-server-v0.9.0-components.yaml
kubectl delete namespace argocd
```

Run the metrics-server deletion only if the checksum-verified manifest still
exists at that path. Namespace deletion removes local data and is intentionally
separate from normal GitOps operation; review the targets before running it.

## Environment overlays

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
| `docs/requirements.md` | Deployment, validation, GitOps, and safety contracts |
| `docs/architecture.md` | Repository boundaries, components, and delivery flow |
| `docs/development.md` | Verified local commands and operational evidence |
| `docs/issues/` | Ordered, bounded implementation issues |
| `docs/decisions/` | Durable decisions and trade-offs |
| `CHANGELOG.md` | Notable user-visible changes |
| `LICENSE` | MIT license for the repository |

## Release status

Version `v0.1.0` is complete and released. A controlled
nonexistent-image failure was diagnosed from Argo CD, rollout, pod, Event,
log-availability, and rendered manifest evidence before repair. A two-step
Git-revert test reproduced and then recovered that failure through Argo CD.
The final state is `Synced` and `Healthy`; the Deployment is Available, its pod
is Ready, the HPA has CPU metrics, and all endpoints return the expected
`v0.1.3` responses. Project 5 release `v0.1.0` is published as an annotated Git
tag on validated commit `cdf7303`.

Published image:

```text
ghcr.io/abdalrahmanattya/containerised-service-cicd:0.1.3
```

Immutable digest:

```text
sha256:6a9075b289a699692f60f6936b84590c8ad487071145a909ae7c3de98025f3b2
```
