# Issue 001: Establish the GitOps repository scaffold and architecture

## Outcome

Create durable project context that explains what will be built, why it is
useful, how repository and trust boundaries work, and how implementation will
be divided into reviewable issues.

## Scope

- Root README, working instructions, changelog, requirements, and architecture
- Requirements, architecture, development plan, and accepted ADRs
- Ordered issue specifications and pull-request template
- Structural documentation verification

No Kubernetes manifests, workflow execution, image publication, cluster setup,
or deployment is included.

## Acceptance criteria

- A fresh session can reconstruct purpose, rules, status, and exact next step.
- The `containerised-service-cicd` and `containerised-service-gitops` ownership
  boundaries are explicit.
- Completion gate, safety boundaries, and rollback direction are documented.
- `git diff --check` passes.
- The complete diff is reviewed before commit.

## Verification

```sh
git diff --check
git status --short --branch
```
