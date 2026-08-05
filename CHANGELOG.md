# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

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
