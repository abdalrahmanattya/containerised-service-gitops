# Project journal

This is the current hand-off record for humans and fresh Codex sessions. Keep
it factual and replace stale status rather than accumulating a transcript.

## Current status

- **Project:** 5 — Kubernetes Deployment and GitOps Workflow
- **State:** Issue 007 in progress; local deployment and Argo CD reconciliation
  are being prepared
- **Branch:** `feature/007-local-deployment-argocd`
- **Remote:** `origin` points to the public GitHub Project 5 repository
- **Target:** Docker Desktop local Kubernetes; context `docker-desktop` is
  active and its control-plane node is Ready
- **Available tools:** Git, Docker Desktop 29.6.2, and kubectl 1.36.1 with
  Kustomize 5.8.1
- **Safety:** No credentials, Secret values, cluster mutation, or deployment
  has occurred; Argo CD is not installed yet. The reviewed public image was
  published by Project 3's GitHub Actions workflow

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
  local control-plane node. No cluster-changing command has been run.

## Decisions

- Repository files and Git history are the durable source of context.
- Project 3 owns application source and image construction.
- Project 5 owns Kubernetes desired state and GitOps operating documentation.
- Git contains Secret references but no Secret values.
- Cluster changes require an explicit context check and learner approval.

## Resume here

Continue Issue 007:

1. Review the rendered `local` overlay and add the Argo CD Application desired
   state for the public Project 5 repository.
2. Select and verify a pinned Argo CD installation version.
3. Before mutation, confirm `docker-desktop`, the `containerised-service`
   namespace, and the exact Secret creation, Argo CD installation, and sync
   commands.
4. Create the runtime Secret from a protected local file, install Argo CD, and
   synchronize only after explicit approval of those exact local mutations.
5. Verify rollout, endpoints, image digest, configuration, events, and logs.

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
