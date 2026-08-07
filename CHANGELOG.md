# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.1.0] - 2026-08-07

### Added

- Initial Project 5 purpose, architecture, requirements, working rules, and
  bounded issue plan.
- Issue 002's reviewed public Project 3 image reference and immutable digest.
- Issue 003's Kustomize application base with a Namespace, Deployment, and
  ClusterIP Service pinned to the reviewed Project 3 image digest.
- Issue 004's local and staging overlays with ConfigMap-managed settings and
  an external Secret reference without committed Secret values.
- Issue 005's token-disabled ServiceAccount, ingress policies, and bounded
  CPU-based HPA with documented local-cluster limitations.
- Issue 006's pull-request-only rendering, schema, security, and secret-pattern
  validation gates with read-only permissions.
- Issue 006's Deployment anti-affinity rule for spreading multiple replicas
  when the cluster has more than one node.
- Issue 007's local Docker Desktop and Argo CD reconciliation preparation,
  including the explicit cluster-mutation safety procedure.
- Issue 007's evidence-led diagnosis of the arm64 local image-pull failure and
  the separate metrics-server limitation.
- Issue 007's desired-state update to the reviewed Project 3 `v0.1.3`
  multi-architecture image digest.
- Issue 007's successful local rollout, endpoint verification, metrics-server
  setup, active HPA metrics, and Healthy Argo CD reconciliation evidence.
- Issue 008's controlled image-pull failure, evidence-led diagnosis, focused
  repair, and tested two-step Git-revert recovery through Argo CD.
- Complete setup, validation, service verification, diagnosis, rollback, and
  local-cluster cleanup instructions for the first Project 5 release.
