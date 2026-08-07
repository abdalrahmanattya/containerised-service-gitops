# Project journal

This is the current hand-off record for humans and fresh Codex sessions. Keep
it factual and replace stale status rather than accumulating a transcript.

## Current status

- **Project:** 5 — Kubernetes Deployment and GitOps Workflow
- **State:** Issue 007 complete locally; verification evidence and the local
  metrics-server exception are being documented
- **Branch:** `feature/007-document-local-verification`
- **Remote:** `origin` points to the public GitHub Project 5 repository
- **Target:** Docker Desktop local Kubernetes; context `docker-desktop` is
  active and its control-plane node is Ready
- **Available tools:** Git, Docker Desktop 29.6.2, and kubectl 1.36.1 with
  Kustomize 5.8.1
- **Safety:** The local `docker-desktop` cluster only has approved local
  resources. The runtime Secret value remains outside Git. Argo CD and the
  application resources were installed on the local cluster; no cloud cluster
  or credential was introduced.

## Completed

- Chose a separate platform repository from the Project 3 application source.
- Chose GitHub pull requests as the review boundary.
- Defined the purpose, scope, completion gate, architecture, and eight bounded
  issues.
- Selected Kustomize, GHCR, Docker Desktop Kubernetes, and Argo CD for the
  proposed workflow, subject to issue-level verification and approval.
- Bootstrapped the previously empty GitHub repository, set `main` as its default
  branch, and removed the duplicate bootstrap feature branch.
- Verified the Project 3 image publication contract and recorded the public
  immutable image digest for the Kubernetes base.
- Completed Issue 003 with a merged Kustomize application base containing a
  Namespace, Deployment, and ClusterIP Service; it has not been applied to a
  cluster.
- Completed Issue 004 with local and staging overlays, ConfigMap-managed
  settings, and an external Secret reference; it was merged without being
  applied to a cluster.
- Completed Issue 005 with a token-disabled ServiceAccount, ingress policies,
  and a bounded CPU-based HPA; it was merged without being applied to a
  cluster.
- Completed Issue 006 with rendered-output, schema, security, and public-secret
  validation, including the reviewed KubeLinter input and replica anti-affinity
  fixes.
- Started Issue 007 after confirming the `docker-desktop` context and a Ready
  local control-plane node.
- Installed Argo CD `v3.5.0`, created the externally managed runtime Secret,
  and applied the reviewed Application to the local cluster.
- Confirmed Argo CD reports the Application `Synced` but `Degraded`. Pod
  Events report `ImagePullBackOff`; the GHCR digest is valid but publishes only
  `linux/amd64`, while the local Kubernetes node is `arm64`.
- Confirmed the HPA cannot read CPU metrics because metrics-server is absent;
  this is a separate documented Docker Desktop limitation.
- Published Project 3 `v0.1.3` with linux/amd64 and linux/arm64 manifests under
  top-level digest
  `sha256:6a9075b289a699692f60f6936b84590c8ad487071145a909ae7c3de98025f3b2`.
- Merged the Project 5 digest update and observed Argo CD replace the failed
  pod with the arm64-compatible image. The Deployment became Available and the
  pod became Ready.
- Verified `/health` returned healthy, `/version` returned `0.1.3`, and
  `/config-summary` returned the reviewed development configuration.
- Installed checksum-verified metrics-server `v0.9.0` on `docker-desktop`.
  Docker Desktop's kubelet certificate lacks an IP SAN, so the local-only
  `--kubelet-insecure-tls` exception was explicitly approved and applied.
- Verified live node and pod metrics, HPA `ScalingActive=True`, and Argo CD
  Application status `Synced` and `Healthy`.

## Decisions

- Repository files and Git history are the durable source of context.
- Project 3 owns application source and image construction.
- Project 5 owns Kubernetes desired state and GitOps operating documentation.
- Git contains Secret references but no Secret values.
- Cluster changes require an explicit context check and learner approval.
- [ADR-003](decisions/ADR-003-local-metrics-server-tls-exception.md): permit
  insecure kubelet TLS only for metrics-server on the local learning cluster.

## Resume here

Finish the Issue 007 documentation pull request, then begin Issue 008:

1. Review and merge the Issue 007 verification documentation.
2. Plan one controlled GitOps failure without changing the cluster until its
   exact target and mutation are approved.
3. Diagnose the failure from status, events, logs, and rendered desired state;
   repair through Git and test the documented rollback path.

## Open questions

- Select the controlled failure used in Issue 008.

## Session hand-off checklist

- [x] Purpose and safety boundaries are documented.
- [x] The next action is concrete and small.
- [x] Planning is separated from implementation.
- [x] Repository boundaries and GitHub use are explicit.
- [x] Issue 001 diff is reviewed and committed.
- [x] Initial GitHub `main` bootstrap is complete.
- [x] Project 3 image `0.1.3` and multi-architecture digest are recorded.
- [ ] Project 5 completion gate is met.
