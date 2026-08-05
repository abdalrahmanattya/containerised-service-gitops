# Project journal

This is the current hand-off record for humans and fresh Codex sessions. Keep
it factual and replace stale status rather than accumulating a transcript.

## Current status

- **Project:** 5 — Kubernetes Deployment and GitOps Workflow
- **State:** Issue 001 complete; ready to plan Issue 002
- **Branch:** `main`, synchronized with `origin/main`
- **Remote:** `origin` points to the public GitHub Project 5 repository
- **Target:** Docker Desktop local Kubernetes; no cluster currently configured
- **Available tools:** Git, Docker Desktop 29.6.2, and kubectl 1.36.1 with
  Kustomize 5.8.1
- **Safety:** No credentials, Secret values, cluster mutation, image
  publication, or deployment has occurred

## Completed

- Chose a separate platform repository from the Project 3 application source.
- Chose GitHub pull requests as the review boundary.
- Defined the purpose, scope, completion gate, architecture, and eight bounded
  issues.
- Selected Kustomize, GHCR, Docker Desktop Kubernetes, and Argo CD for the
  proposed workflow, subject to issue-level verification and approval.
- Bootstrapped the previously empty GitHub repository, set `main` as its default
  branch, and removed the duplicate bootstrap feature branch.

## Decisions

- Repository files and Git history are the durable source of context.
- Project 3 owns application source and image construction.
- Project 5 owns Kubernetes desired state and GitOps operating documentation.
- Git contains Secret references but no Secret values.
- Cluster changes require an explicit context check and learner approval.

## Resume here

Begin Issue 002:

1. Re-orient in both this repository and the Project 3 application repository.
2. Decide whether image publication retains application version `0.1.0` or
   requires a new patch release.
3. Agree on workflow permissions, tag trigger, image name, and verification.
4. Create a meaningful Project 3 feature branch for the reviewed release
   workflow; do not publish an image until the destination and permissions are
   approved.

## Open questions

- Confirm whether the public GHCR package should use tag `0.1.0` or a new
  Project 3 patch release after the release workflow is added.
- Select and pin the manifest schema and security validation tools in Issue 006.

## Session hand-off checklist

- [x] Purpose and safety boundaries are documented.
- [x] The next action is concrete and small.
- [x] Planning is separated from implementation.
- [x] Repository boundaries and GitHub use are explicit.
- [x] Issue 001 diff is reviewed and committed.
- [x] Initial GitHub `main` bootstrap is complete.
- [ ] Project 5 completion gate is met.
