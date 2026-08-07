# Issue 008: Diagnose a failure, test rollback, and release v0.1.0

## Outcome

Demonstrate evidence-led diagnosis and GitOps recovery before documenting the
first complete Project 5 release.

## Scope

- Introduce one bounded failure through a reviewed branch, preferably a broken
  image tag or readiness probe
- Capture Argo CD status, rollout state, pod status, events, logs, and rendered
  desired state
- Rank likely causes from that evidence before editing files
- Repair through a focused Git change and observe reconciliation
- Reintroduce and reverse the change with a tested Git revert rollback
- Complete user, operations, release, and learning documentation
- Tag `v0.1.0` after all gates pass and publication is approved

## Acceptance criteria

- Failure evidence and diagnosis precede the repair commit.
- Repair addresses the demonstrated cause without unrelated changes.
- Git revert restores known-good desired state through Argo CD.
- README includes setup, use, diagnosis, rollback, and cleanup steps.
- All completion-gate checks pass and observed results are recorded.
- Release and tag creation occur only after explicit approval.

## Completion evidence

- Pull request 12 introduced a reviewed nonexistent image digest. Argo CD
  reconciled it, and status, rollout, pod, Event, log-availability, and
  rendered-manifest evidence identified the cause before repair.
- Pull requests 13 and 14 recorded the diagnosis and restored only the
  reviewed known-good digest. Argo CD returned to `Synced` and `Healthy`.
- Pull request 16 used a Git revert to reproduce the failure. Pull request 17
  reverted that revert, restoring the known-good state through Argo CD without
  an imperative Kubernetes rollback.
- The final Deployment is Available, its pod is Ready, the HPA receives CPU
  metrics, and `/health`, `/version`, and `/config-summary` return the expected
  responses.
- Pull request 18 completed setup, use, diagnosis, rollback, and cleanup
  documentation. Its pinned render, schema, security, and secret validation
  workflow passed at merge commit `0cc01fc`.
- Repository secret-pattern checks passed, and no Secret value, token,
  kubeconfig, or credential was committed.

All acceptance criteria are met. After explicit approval, annotated tag
`v0.1.0` was created on validated release commit `cdf7303` and pushed to
`origin`.
