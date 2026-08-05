# Issue 001: Establish the Project 5 scaffold and architecture

## Outcome

Create durable project context that explains what will be built, why it is
useful, how repository and trust boundaries work, and how implementation will
be divided into reviewable issues.

## Scope

- Root README, working instructions, changelog, roadmap, and project journal
- Requirements, architecture, development plan, and accepted ADRs
- Ordered issue specifications and pull-request template
- Structural context-resume verification

No Kubernetes manifests, workflow execution, image publication, cluster setup,
or deployment is included.

## Acceptance criteria

- A fresh session can reconstruct purpose, rules, status, and exact next step.
- Project 3 and Project 5 ownership boundaries are explicit.
- Completion gate, safety boundaries, and rollback direction are documented.
- `./scripts/test-context-resume.sh` and `git diff --check` pass.
- The complete diff is reviewed before commit.

## Verification

```sh
./scripts/test-context-resume.sh
git diff --check
git status --short --branch
```
