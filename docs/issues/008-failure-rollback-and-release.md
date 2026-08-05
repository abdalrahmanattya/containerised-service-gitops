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
