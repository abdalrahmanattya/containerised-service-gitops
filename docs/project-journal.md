# Project journal

This is the current hand-off record for humans and fresh Codex sessions. Keep
it factual and replace stale status rather than accumulating a transcript.

## Current status

- **Project:** 5 — Kubernetes Deployment and GitOps Workflow
- **State:** Issues 001–008 and the Project 5 completion gate are complete;
  annotated release tag `v0.1.0` is published
- **Branch:** `feature/008-record-v0.1.0-release`
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
- Merged the Issue 007 verification documentation through pull request 11.
- Selected a syntactically valid but nonexistent image digest as the bounded
  Issue 008 failure. The feature branch changes only the Deployment image;
  the known-good digest remains recorded in Git history and documentation.
- Merged pull request 12 at revision `bb359db`; Argo CD reconciled the invalid
  digest and reported `Synced` and `Degraded`.
- Observed the replacement pod in `ImagePullBackOff`. Events report that GHCR
  cannot find the all-zero digest, while the rendered overlay and live
  Deployment both contain that digest. The Deployment exceeded its progress
  deadline but remained Available because the previous healthy pod stayed
  Ready. Container logs were unavailable because the image never pulled and
  the replacement container never started.
- Ranked the invalid digest as the demonstrated cause. Registry credentials,
  scheduling, probes, Secret configuration, and HPA were ruled out or shown
  not to be reached; the HPA remained healthy at 6% of its 70% CPU target.
- Merged the diagnosis evidence through pull request 13 before editing desired
  state. Prepared a focused repair restoring the reviewed multi-architecture
  digest for Project 3 release `v0.1.3`.
- Merged the focused repair through pull request 14 at revision `6ed8ef2`.
  Argo CD returned to `Synced` and `Healthy`; the Deployment reported
  Available and `NewReplicaSetAvailable`, the retained known-good pod remained
  Ready, and the HPA reported 5% of its 70% CPU target.
- Verified `/health`, `/version`, and `/config-summary` returned the expected
  healthy, `0.1.3`, and development responses after recovery. The temporary
  localhost port-forward was stopped after verification.
- Merged the first rollback-test revert through pull request 16 at revision
  `bcd224b`. Argo CD reconciled that revision, created a replacement pod, and
  reproduced `ErrImagePull` and `ImagePullBackOff` with GHCR `NotFound` for the
  all-zero digest. The previous healthy pod remained Ready.
- Prepared a second Git revert that reverses commit `0500536` and restores the
  known-good digest. No imperative Kubernetes rollback command was used.
- Merged the recovery revert through pull request 17 at revision `d5cc2b7`.
  Argo CD reconciled that exact revision and returned to `Synced` and
  `Healthy`; the Deployment, pod, HPA, and all three endpoints passed final
  verification on the known-good digest.
- Completed README procedures for setup, validation, use, diagnosis, Git
  rollback, and local cleanup without sharing a Secret value.
- Final context, overlay, public-secret, and whitespace checks pass locally.
  The complete local validation script cannot run because Kubeconform,
  KubeLinter, and Trivy are not installed; the pull-request workflow installs
  pinned versions and remains the required full gate.
- Merged the complete operations documentation through pull request 18 at
  `0cc01fc`. GitHub's pinned render, schema, security, and secret check
  completed successfully for that merge.
- Rechecked the local cluster: Argo CD remained `Synced` and `Healthy`, the
  Deployment was 1/1 Available, the pod was Ready with zero restarts, and the
  HPA reported a valid CPU metric.
- Reviewed every Project 5 completion-gate criterion and recorded its evidence
  in Issue 008. Prepared the `v0.1.0` changelog entry without creating a tag.
- Merged the release metadata through pull request 19 at validated commit
  `cdf7303`. After explicit approval, created annotated tag `v0.1.0` on that
  commit and pushed only that tag to `origin`; remote verification resolved
  the annotated tag to `cdf7303`.

## Decisions

- Repository files and Git history are the durable source of context.
- Project 3 owns application source and image construction.
- Project 5 owns Kubernetes desired state and GitOps operating documentation.
- Git contains Secret references but no Secret values.
- Cluster changes require an explicit context check and learner approval.
- [ADR-003](decisions/ADR-003-local-metrics-server-tls-exception.md): permit
  insecure kubelet TLS only for metrics-server on the local learning cluster.

## Resume here

Review and merge this post-release status update. Project 5 is then complete;
begin another project only after the learner agrees to proceed.

## Open questions

- None. The controlled failure is a nonexistent image digest.

## Session hand-off checklist

- [x] Purpose and safety boundaries are documented.
- [x] The next action is concrete and small.
- [x] Planning is separated from implementation.
- [x] Repository boundaries and GitHub use are explicit.
- [x] Issue 001 diff is reviewed and committed.
- [x] Initial GitHub `main` bootstrap is complete.
- [x] Project 3 image `0.1.3` and multi-architecture digest are recorded.
- [x] Project 5 completion gate is met.
