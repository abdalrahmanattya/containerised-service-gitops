# Development and verification

## Repository checks

Run from the repository root:

```sh
./scripts/test-overlays.sh
./scripts/check-public-secrets.sh
git diff --check
git status --short --branch
```

Expected result: both overlays render, public-secret patterns are absent, the
diff has no whitespace errors, and Git shows only intentional changes.

## Toolchain and validation

- `kubectl` with built-in Kustomize for rendering and cluster operations
- Kubeconform `0.8.0`, KubeLinter `0.8.3`, and Trivy `0.69.3` in CI
- GitHub Actions for pull-request validation
- Docker Desktop Kubernetes as the only deployment target
- Argo CD for local reconciliation after explicit installation approval
- Argo CD `v3.5.0` for the local installation

The versions and commands in this document and the workflow are the reviewed
baseline. Do not replace them with an unverified `latest` install command.

Render both overlays without contacting a cluster:

```sh
kubectl kustomize apps/containerised-service/overlays/local
kubectl kustomize apps/containerised-service/overlays/staging
```

The complete validation script requires the pinned tools above; when they are
not installed locally, run the render, overlay, and public-secret checks and
rely on the GitHub workflow for the full gate.

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
prevent a single replica from consuming the local cluster. These values are the
reviewed local baseline.

The pod runs as numeric user and group `10001`, disables Kubernetes API-token
mounting and privilege escalation, drops Linux capabilities, uses the runtime
default seccomp profile, and makes its root filesystem read-only. The image is
pinned by its reviewed immutable digest.

## Reviewed application image

Issue 002 published the public Project 3 image. Kubernetes desired state should
use the immutable digest rather than a moving tag:

```text
ghcr.io/abdalrahmanattya/containerised-service-cicd@sha256:6a9075b289a699692f60f6936b84590c8ad487071145a909ae7c3de98025f3b2
```

The tag for human release identification is `0.1.3`. Verify the package page
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

Project 3 release `v0.1.3` corrected the architecture mismatch by publishing
both `linux/amd64` and `linux/arm64` manifests under top-level digest
`sha256:6a9075b289a699692f60f6936b84590c8ad487071145a909ae7c3de98025f3b2`.
Project 5 updated that digest through Git and Argo CD reconciled it. The new
pod became Ready and the Deployment became Available.

### Local metrics-server

The local HPA needs the Kubernetes Metrics API. Metrics-server `v0.9.0` was
selected for Kubernetes 1.36. Its official `components.yaml` SHA-256 is:

```text
1cec29a5267809306a2c6ec74a3e449abbb705b4a8beed0c8a1963910f72c79b
```

After confirming context `docker-desktop`, the standard manifest was downloaded,
verified, and installed with:

```sh
curl --fail --silent --show-error --location \
  --output /private/tmp/metrics-server-v0.9.0-components.yaml \
  https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.9.0/components.yaml
shasum -a 256 /private/tmp/metrics-server-v0.9.0-components.yaml
kubectl apply -f /private/tmp/metrics-server-v0.9.0-components.yaml
```

The observed checksum matched the reviewed value above before `kubectl apply`
was approved and run.

Docker Desktop's kubelet certificate does not contain the node IP as a subject
alternative name. Metrics-server therefore failed certificate verification.
For this local cluster only, the following explicitly approved patch
was applied:

```sh
kubectl -n kube-system patch deployment metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
```

This disables kubelet certificate verification and must not be copied to a
production cluster. Verification commands and observed results were:

```sh
kubectl top nodes
kubectl -n containerised-service top pods
kubectl -n containerised-service get hpa containerised-service
kubectl -n argocd get application containerised-service-local
```

The Metrics API returned node and pod usage, the HPA reported
`ScalingActive=True` with CPU below its 70% target, and Argo CD reported the
Application `Synced` and `Healthy`.

## Issue 008 controlled image-pull failure

Pull request 12 deliberately replaced the known-good image digest with a
syntactically valid but nonexistent all-zero digest. After merge revision
`bb359db`, Argo CD reconciled that desired state to the approved local
`docker-desktop` cluster. The following read-only commands captured evidence
before any repair:

```sh
kubectl -n argocd get application containerised-service-local
kubectl -n containerised-service get deployment containerised-service
kubectl -n containerised-service rollout status deployment/containerised-service --timeout=1s
kubectl -n containerised-service get pods \
  -l app.kubernetes.io/name=containerised-service -o wide
kubectl -n containerised-service describe pod <failed-pod-name>
kubectl -n containerised-service logs <failed-pod-name>
kubectl kustomize apps/containerised-service/overlays/local
kubectl -n containerised-service get hpa containerised-service
```

Observed evidence:

- Argo CD was `Synced` and `Degraded`, proving the cluster matched the failing
  Git revision rather than suffering from reconciliation drift.
- The new pod was `ImagePullBackOff`; its Events reported `NotFound` for the
  exact all-zero digest.
- The live Deployment and locally rendered overlay contained the same invalid
  digest, directly connecting desired state to the pull failure.
- The Deployment reported `ProgressDeadlineExceeded` but remained Available.
  Its rolling-update settings retained the previous Ready pod, preserving one
  serving replica while the replacement failed.
- Logs were unavailable because the image never pulled and the container never
  started. This is expected evidence, not a separate logging failure.
- The HPA remained active at 6% of its 70% CPU target, so scaling was not the
  rollout blocker.

Cause ranking before repair:

1. **Demonstrated:** the desired image digest does not exist in GHCR. The
   rendered value, live value, and registry `NotFound` Event agree.
2. **Unlikely:** registry credentials or general registry access. The existing
   pod previously pulled the public repository at the known-good digest.
3. **Ruled out as the immediate cause:** scheduling, probes, Secret
   configuration, and HPA. The pod scheduled successfully but its container
   never started, so startup configuration and probes were never reached.

The repair must be a later focused Git commit restoring the reviewed digest:

```text
sha256:6a9075b289a699692f60f6936b84590c8ad487071145a909ae7c3de98025f3b2
```

### Focused repair result

Pull request 14 restored the known-good digest and merged as revision
`6ed8ef2`. Argo CD reconciled without an imperative rollout command. Observed
results were:

```text
Argo CD:   Synced, Healthy
Deployment: 1/1 Ready, 1 Available, NewReplicaSetAvailable
Pod:       1/1 Running
HPA:       CPU 5%/70%, one replica
/health:   {"status":"healthy"}
/version:  {"version":"0.1.3"}
```

`/config-summary` also returned the reviewed service name, `development`
environment, and `INFO` log level. Kubernetes reused the retained healthy
ReplicaSet, so recovery did not require a fresh image pull. The service was
verified through a temporary localhost port-forward, which was stopped after
the checks.

The remaining rollback test will use Git history rather than `kubectl rollout
undo`: revert the repair merge to reintroduce the known failure, observe Argo
CD reconciliation, then revert that revert to restore the known-good desired
state. Each revert must be reviewed and merged separately so its effect is
observable.

### Tested Git-revert rollback result

Pull request 16 merged commit `0500536`, which reverted the repair merge. Argo
CD detected revision `bcd224b`, reconciled the all-zero digest, and created a
replacement pod. The pod reproduced `ErrImagePull` and `ImagePullBackOff`; its
Events again reported GHCR `NotFound`. The prior Ready pod preserved service
availability.

Pull request 17 then merged commit `79a66bb`, a revert of that revert. Argo CD
detected recovery revision `d5cc2b7` and returned to `Synced` and `Healthy`.
Final observed results were:

```text
Deployment: 1/1 Ready, 1 Available, NewReplicaSetAvailable
Pod:        1/1 Running, zero restarts
HPA:        CPU 13%/70%, one replica
Image:      sha256:6a9075b289a699692f60f6936b84590c8ad487071145a909ae7c3de98025f3b2
/health:    {"status":"healthy"}
/version:   {"version":"0.1.3"}
```

`/config-summary` returned the reviewed development configuration. No
`kubectl rollout undo`, direct Deployment edit, or forced Argo CD sync was
used. The temporary localhost port-forward was stopped after verification.
