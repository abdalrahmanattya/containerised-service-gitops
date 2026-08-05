# Issue 003: Add the Kubernetes application base

## Outcome

Define the reusable Kubernetes workload and service for the immutable Project 3
image.

## Scope

- Namespace, Deployment, and ClusterIP Service
- Stable labels and selectors
- Container port `8000`
- HTTP liveness and readiness probes on `/health`
- Rolling-update strategy and revision history
- CPU/memory requests and limits with rationale
- Non-root, restricted container security settings
- Kustomize base that renders deterministically

## Acceptance criteria

- The base renders with the reviewed kubectl/Kustomize version.
- Deployment and Service selectors match.
- Probes target the documented service port and health path.
- Image uses the reviewed GHCR version/digest from Issue 002.
- The pod cannot request privilege escalation or run as root.
- No cluster mutation occurs in this issue.
