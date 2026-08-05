# ADR-001: Use repository files, Git, and pull requests as durable context

- **Status:** Accepted
- **Date:** 2026-08-05
- **Decision owners:** Learner and project maintainer

## Context

Conversation and terminal state are temporary. Kubernetes changes are also
easy to apply but difficult to explain later if requirements, rendered output,
and rollback intent are not versioned together.

## Decision

Use repository files and Git history as the durable source of project context.
Use focused feature branches and GitHub pull requests as the review boundary
before changes enter `main`. Keep a factual project journal with an exact resume
point, document durable trade-offs in ADRs, and verify each feature locally.

## Consequences

Changes remain auditable and recoverable, and a fresh session can resume safely.
The cost is maintaining documentation and reviewing small changes before merge.

## Alternatives considered

- Relying on conversation history was rejected because it is not durable.
- Applying local YAML before committing was rejected because cluster state
  would become the primary record rather than reviewed Git state.
- Large generated commits were rejected because they obscure cause and rollback.

## Verification

`scripts/test-context-resume.sh` verifies the required hand-off files. Feature
pull requests must include exact validation evidence and rollback impact.
