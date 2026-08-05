# Project journal

This is the current hand-off record for humans and fresh Codex sessions. Keep
it factual and replace stale status rather than accumulating a transcript.

## Current status

- **Project:** 5 — Kubernetes Deployment and GitOps Workflow
- **State:** Issue 002 complete; ready to plan Issue 003
- **Branch:** `main`, synchronized with `origin/main`
- **Remote:** `origin` points to the public GitHub Project 5 repository
- **Target:** Docker Desktop local Kubernetes; no cluster currently configured
- **Available tools:** Git, Docker Desktop 29.6.2, and kubectl 1.36.1 with
  Kustomize 5.8.1
- **Safety:** No credentials, Secret values, cluster mutation, or deployment
  has occurred; the reviewed public image was published by Project 3's
  GitHub Actions workflow

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

## Decisions

- Repository files and Git history are the durable source of context.
- Project 3 owns application source and image construction.
- Project 5 owns Kubernetes desired state and GitOps operating documentation.
- Git contains Secret references but no Secret values.
- Cluster changes require an explicit context check and learner approval.

## Resume here

Begin Issue 003:

1. Create a feature branch for the Kubernetes application base.
2. Reference the reviewed image by digest:
   `ghcr.io/abdalrahmanattya/containerised-service-cicd@sha256:86e1acfa46fb1edaa8d131b9c8063624eb356b6704835675e64e939b9ff6738b`.
3. Define the Namespace, Deployment, Service, probes, resources, and
   restricted security settings without mutating a cluster.

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
