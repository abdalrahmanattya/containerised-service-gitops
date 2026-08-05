# Development and verification

## Current planning checks

Run from the repository root:

```sh
./scripts/test-context-resume.sh
git diff --check
git status --short --branch
```

Expected result: the context script reports all checks as `ok`, the diff has no
whitespace errors, and Git shows only the intentional Issue 001 files.

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

## Reviewed application image

Issue 002 published the public Project 3 image. Kubernetes desired state should
use the immutable digest rather than a moving tag:

```text
ghcr.io/abdalrahmanattya/containerised-service-cicd@sha256:86e1acfa46fb1edaa8d131b9c8063624eb356b6704835675e64e939b9ff6738b
```

The tag for human release identification is `0.1.2`. Verify the package page
and digest before changing the image reference. Do not add an image-pull Secret
for this public package.

## Cluster safety procedure

Before any mutation:

1. run `kubectl config current-context`;
2. confirm that it names the intended Docker Desktop local cluster;
3. render and review the exact overlay;
4. run available validation or dry-run checks; and
5. request explicit approval for the exact mutation and namespace.

Never print or commit raw Secret objects, tokens, or kubeconfig contents.
