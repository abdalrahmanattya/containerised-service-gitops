# Project journal

This is the current hand-off record for humans and fresh Codex sessions. Keep
it factual and replace stale status rather than accumulating a transcript.

## Current status

- **Project:** 5 — Kubernetes Deployment and GitOps Workflow
- **State:** Issue 007 in progress; Argo CD is synced but the workload is
  degraded because the image lacks an arm64 manifest
- **Branch:** `feature/007-diagnose-arm64-image`
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

## Decisions

- Repository files and Git history are the durable source of context.
- Project 3 owns application source and image construction.
- Project 5 owns Kubernetes desired state and GitOps operating documentation.
- Git contains Secret references but no Secret values.
- Cluster changes require an explicit context check and learner approval.

## Resume here

Continue Issue 007:

1. Publish a reviewed Project 3 release for both `linux/amd64` and
   `linux/arm64`, after explicit approval of the cross-repository publication.
2. Record the new immutable digest in Project 5 through a pull request.
3. Let Argo CD reconcile the digest change and verify rollout, endpoints, image
   architecture, configuration, events, and logs.

## Open questions

- Confirm the Project 3 package remains public before Argo CD deployment.
- Select and pin the manifest schema and security validation tools in Issue 006.

## Session hand-off checklist

- [x] Purpose and safety boundaries are documented.
- [x] The next action is concrete and small.
- [x] Planning is separated from implementation.
- [x] Repository boundaries and GitHub use are explicit.
- [x] Issue 001 diff is reviewed and committed.
- [x] Initial GitHub `main` bootstrap is complete.
- [x] Project 3 image `0.1.2` and immutable digest are recorded.
- [ ] Project 5 completion gate is met.
