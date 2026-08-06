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
- Argo CD `v3.5.0` for the initial local installation

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
health probes, ServiceAccount, NetworkPolicies, and HPA. Local has one replica
and `APP_ENV: development`; staging has two replicas and `APP_ENV: staging`.

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

## Issue 005 limitations

The default-deny policy applies to ingress. The allow policy permits traffic
to the service from pods in the `containerised-service` namespace on the named
`http` port. A local Docker Desktop cluster may not have a network plugin that
enforces NetworkPolicy, so rendered policy is evidence of intent, not proof of
packet isolation. Verify the active cluster's networking implementation before
reporting enforcement.

The HPA targets 70% average CPU utilization and is bounded to one through
three replicas. It depends on metrics-server and the Deployment's CPU request
of 100m; without metrics-server it will render but cannot make scaling
decisions. HPA status and Events must be checked during the deployment issue.

The Deployment uses preferred inter-pod anti-affinity on
`kubernetes.io/hostname` for the `containerised-service` label. This asks a
multi-node cluster to spread replicas across nodes. It is deliberately
preferred rather than required so the two-replica staging overlay can still
run on the single node provided by Docker Desktop.

## Issue 006 validation gates

The pull-request workflow is validation-only. It uses `pull_request` and
`push` to `main`, grants `contents: read`, and does not authenticate to a
cluster or run deployment commands. Actions are pinned to full commit SHAs.

The selected tools and policy are:

| Gate | Tool/version | Policy |
| --- | --- | --- |
| Render | kubectl 1.36.1 / Kustomize 5.8.1 | Render `local` and `staging` independently |
| Schema | Kubeconform 0.8.0 | Strict Kubernetes `1.33.0` schemas; any invalid object fails |
| Security/configuration | KubeLinter v0.8.3 | Default checks; findings fail the workflow |
| Misconfiguration/secrets | Trivy engine 0.69.3 | HIGH and CRITICAL findings fail the workflow |
| Public-repository patterns | `scripts/check-public-secrets.sh` | Private-key and credential-assignment patterns fail |

Run the equivalent local command after installing the pinned tools:

```sh
./scripts/validate-manifests.sh
```

The script renders both overlays into a temporary directory, validates the
rendered files, scans them, checks the repository for credential patterns, and
removes the temporary files. `KUBE_SCHEMA_VERSION` can be set explicitly when
the intended cluster schema changes.

An exception requires a pull request explaining the exact finding, why it is a
false positive or accepted risk, the narrowest rule/file scope, and a review
date. Do not add a blanket ignore; update the tool configuration only with
that written rationale.

## Cluster safety procedure

Before any mutation:

1. run `kubectl config current-context`;
2. confirm that it names the intended Docker Desktop local cluster;
3. render and review the exact overlay;
4. run available validation or dry-run checks; and
5. request explicit approval for the exact mutation and namespace.

Never print or commit raw Secret objects, tokens, or kubeconfig contents.

## Issue 007 local deployment preparation

The active local target must be confirmed before any mutation:

```sh
kubectl config current-context
kubectl get nodes
```

Expected output is context `docker-desktop` and a Ready
`desktop-control-plane` node. These checks are read-only. Render and inspect
the exact local desired state before applying it:

```sh
kubectl kustomize apps/containerised-service/overlays/local
```

The deployment requires the externally managed Secret
`containerised-service-runtime` in namespace `containerised-service`. Its
value must come from a protected local file and must not be printed, committed,
or pasted into chat. Argo CD will read this public repository without a Git
credential and reconcile `apps/containerised-service/overlays/local` into the
local cluster. The selected Argo CD release is `v3.5.0`. The official release
instructions use server-side apply because the CRDs are large:

```sh
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.0/manifests/install.yaml
```

These commands install the standard non-HA Argo CD components into the local
`docker-desktop` cluster. They are cluster-changing commands and require
explicit approval before execution. After installation, apply
`argocd/applications/containerised-service-local.yaml` to create the reviewed
Application object, then inspect its status before allowing reconciliation to
deploy the local overlay.

### Issue 007 diagnostic evidence

The first reconciliation created the expected namespace, ServiceAccount,
ConfigMap, Service, Deployment, HPA, NetworkPolicies, and pod. The pod stayed
in `ImagePullBackOff`. Read-only inspection showed:

```text
GHCR digest: valid OCI image index with a linux/amd64 manifest only
Kubernetes node: arm64
Pull error: short read: expected 856 bytes but got 0: unexpected EOF
```

The corrective action is to publish a new Project 3 image for both
`linux/amd64` and `linux/arm64`, then update the Project 5 digest through Git.
The HPA also reports unavailable CPU metrics because metrics-server is not
installed in this Docker Desktop cluster; that does not cause the image pull
failure.
