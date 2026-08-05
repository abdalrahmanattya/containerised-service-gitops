# Development and verification

## Current planning checks

Run from the repository root:

```sh
./scripts/test-context-resume.sh
git diff --check
git status --short --branch
```

Expected result: the context script reports all checks as `ok`, the diff has no
whitespace errors, and Git shows only the intentional feature files.

## Planned toolchain

- `kubectl` with built-in Kustomize for rendering and cluster operations
- a pinned Kubernetes schema validator selected in Issue 006
- a pinned manifest security scanner selected in Issue 006
- GitHub Actions for pull-request validation
- Docker Desktop Kubernetes as the only initial deployment target
- Argo CD for local reconciliation after explicit installation approval

Exact installation versions and commands will be selected and verified in the
issue that introduces each tool. Do not copy an unverified `latest` install
command into the workflow.

## Planned local validation shape

The eventual local workflow will include commands equivalent to:

```sh
kubectl kustomize apps/containerised-service/overlays/local
kubectl kustomize apps/containerised-service/overlays/staging
```

Schema and security commands are intentionally deferred until their versions,
inputs, and failure policies are reviewed in Issue 006.

## Issue 003 base validation

Render the reusable workload without contacting a cluster:

```sh
kubectl kustomize apps/containerised-service/base
```

Expected result: one Namespace, one Deployment, and one ClusterIP Service. The
Deployment and Service use `app.kubernetes.io/name: containerised-service` as
their shared selector label; both health probes call `/health` through the
named `http` port (`8000`).

The base requests 100m CPU and 128Mi memory to reserve a small, predictable
amount for this HTTP service, and limits it to 500m CPU and 256Mi memory to
prevent a single replica from consuming the local cluster. These values are a
learning-environment starting point and will be reviewed with real evidence in
the deployment issue.

The pod runs as numeric user and group `10001`, disables Kubernetes API-token
mounting and privilege escalation, drops Linux capabilities, uses the runtime
default seccomp profile, and makes its root filesystem read-only. The image is
pinned by its reviewed immutable digest.

## Reviewed application image

Issue 002 published the public Project 3 image. Kubernetes desired state should
use the immutable digest rather than a moving tag:

```text
ghcr.io/abdalrahmanattya/containerised-service-cicd@sha256:86e1acfa46fb1edaa8d131b9c8063624eb356b6704835675e64e939b9ff6738b
```

The tag for human release identification is `0.1.2`. Verify the package page
and digest before changing the image reference. Do not add an image-pull Secret
for this public package.

## Issue 004 overlay validation

Render and test both environments without contacting a cluster:

```sh
./scripts/test-overlays.sh
kubectl kustomize apps/containerised-service/overlays/local
kubectl kustomize apps/containerised-service/overlays/staging
```

Expected result: the script prints `Overlay renders passed: local, staging`.
Each output contains one ConfigMap, one Deployment, one Service, and the base
health probes. Local has one replica and `APP_ENV: development`; staging has
two replicas and `APP_ENV: staging`.

The overlays reference the externally managed Secret
`containerised-service-runtime`, key `APP_RUNTIME_SECRET`, with
`optional: false`. No Secret object or value is committed. Before an approved
deployment, create the Secret from a protected local file:

```sh
kubectl -n containerised-service create secret generic containerised-service-runtime \
  --from-file=APP_RUNTIME_SECRET=/secure/local/path/app-runtime-secret
```

This command is a documented cluster-changing procedure and must not be run
until the active context, namespace, and exact mutation are explicitly
approved. If the Secret is missing, inspect pod Events and expect
`CreateContainerConfigError`.

## Cluster safety procedure

Before any mutation:

1. run `kubectl config current-context`;
2. confirm that it names the intended Docker Desktop local cluster;
3. render and review the exact overlay;
4. run available validation or dry-run checks; and
5. request explicit approval for the exact mutation and namespace.

Never print or commit raw Secret objects, tokens, or kubeconfig contents.
