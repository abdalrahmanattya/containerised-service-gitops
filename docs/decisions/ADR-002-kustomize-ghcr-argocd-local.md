# ADR-002: Use Kustomize, GHCR, Argo CD, and a local Kubernetes target

- **Status:** Accepted
- **Date:** 2026-08-05
- **Decision owners:** Learner and project maintainer

## Context

Project 5 needs realistic, reviewable deployment configuration without a cloud
account. It must preserve the boundary between Project 3 application delivery
and Project 5 environment desired state, while giving concrete GitOps and
rollback practice.

## Decision

- Keep Project 5 in the separate public `containerised-service-gitops`
  repository.
- Keep application source and image construction in Project 3.
- Publish the reviewed Project 3 release image to public GHCR using a GitHub
  workflow with scoped repository permissions.
- Use Kustomize bases and overlays, rendered by the Kustomize version embedded
  in the reviewed kubectl toolchain.
- Use Docker Desktop Kubernetes as the only initial target.
- Use Argo CD to read the public repository and reconcile the local overlay.
- Treat Git revert to a known-good revision as the normal rollback mechanism.

## Consequences

### Benefits

- The application artifact and environment configuration have clear owners.
- Kustomize supports overlays without a templating language or chart packaging.
- Public GitHub and GHCR require no repository or image-pull credential in the
  local learning setup.
- Argo CD makes drift and reconciliation visible.
- A local cluster avoids cloud cost and provider credentials.

### Costs and risks

- A public repository and image cannot contain proprietary code or data.
- Docker Desktop networking may not enforce NetworkPolicy exactly like a
  production CNI.
- HPA needs metrics-server, which may require separate local setup.
- Argo CD adds components and concepts beyond direct `kubectl apply`.
- Git revert is deliberate but slower than an emergency imperative rollback.

## Alternatives considered

### Helm

Deferred because this project has one small service and environment overlays;
Kustomize exposes the Kubernetes objects directly with less packaging overhead.

### Direct kubectl deployment only

Useful for validation but insufficient for practising continuous Git
reconciliation and visible drift.

### Managed Kubernetes

Rejected for the initial project because it adds credentials, cost, provider
resources, and cleanup obligations unrelated to the completion gate.

### Store Secret values in Git

Rejected even with base64 encoding because encoding is not encryption. External
secret-management integration is a separate future decision.

## Verification

The decision is satisfied when a GHCR release image is referenced by reviewed
Kustomize desired state, CI validates every overlay, Argo CD reconciles the
local overlay, and a known-good Git revision restores a failed rollout.
