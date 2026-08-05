# Repository instructions for Codex

## Mission

Help the learner practise a safe, reviewable, AI-assisted Kubernetes and GitOps
workflow. Prefer teaching, evidence, and small verified changes over generating
a complete platform at once.

## Start every new session by orienting

Before proposing or making changes:

1. Read `README.md`.
2. Read `docs/learning-roadmap.md` for the current issue and completion gate.
3. Read `docs/project-journal.md`, especially **Resume here**.
4. Read relevant files in `docs/decisions/` and `docs/architecture.md`.
5. Inspect `git status --short --branch`, remotes, and the recent Git log.
6. Summarize the current state, intended next task, and uncommitted work.

Repository files and Git history are the durable source of context.

## Working rules

- Agree on a small outcome and acceptance criteria before implementation.
- Follow the ordered issues and Project 5 completion gate.
- Keep application source in the Project 3 repository and deployment desired
  state in this repository unless an issue explicitly approves a cross-repo
  change.
- Use meaningful branches named `feature/<issue-number>-<short-outcome>`.
- Preserve user changes and never discard or overwrite them without permission.
- Show and review the diff before committing.
- Run the smallest relevant verification after each change.
- Keep commits focused and use pull requests for changes merged to `main`.
- Pin third-party GitHub Actions to reviewed commit SHAs.
- Update `docs/project-journal.md` whenever current state or next step changes.
- Add an ADR for durable decisions with meaningful trade-offs.
- Update `CHANGELOG.md` for notable user-visible changes.
- Keep the root README's purpose and step-by-step usage current.
- At the end of every feature, explain what was accomplished and give exact
  test commands with expected or observed results.
- Give non-obvious functions concise docstrings. Comment non-trivial loops to
  explain their purpose or invariant, not their syntax.

## Kubernetes and GitOps safety

- Never commit credentials, kubeconfigs, tokens, private keys, real Secret
  values, or decoded Secret output.
- Confirm the active Kubernetes context before any cluster-changing command.
- Do not run `kubectl apply`, `delete`, `rollout undo`, Helm mutation, Argo CD
  synchronization, or equivalent without explicit approval of the exact action
  and target.
- Prefer rendering, schema validation, diffs, and server-side dry runs before
  mutation.
- Do not use a cloud cluster or configure paid infrastructure without explicit
  approval.
- Do not push, publish an image, create a release, or change GitHub settings
  without explicit approval.
- Diagnose failures from status, events, logs, and rendered manifests before
  proposing a repair.
- Keep secret values outside Git; manifests may reference a pre-created Secret.
- Pause before destructive or difficult-to-reverse operations.

## Verification during planning

Run:

```sh
./scripts/test-context-resume.sh
git diff --check
git status --short --branch
git log --oneline --decorate -5
```

As tools are selected, record exact render, format, schema, policy, security,
smoke-test, and rollback commands in `docs/development.md`.
