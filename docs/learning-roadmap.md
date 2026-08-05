# Project 5 learning roadmap

## Place in the programme

Project 5 follows the completed containerised service and cloud cost analysis
projects. It focuses on Kubernetes deployment diagnosis, GitOps reconciliation,
and rollback. Project 6, a secure cloud platform blueprint, begins only after
this project's completion gate is met and the learner agrees to proceed.

## Goal

Deploy the service from Project 3 to a local Kubernetes environment using
versioned, reviewable configuration.

## Scope

- Application manifests and environment overlays
- Resource requests and limits
- Health probes, ConfigMaps, and Secret references
- Network policy and horizontal scaling configuration
- Pull-request validation, GitOps reconciliation, and rollback instructions

## Learning focus

- Application and platform repository boundaries
- GitOps-style environment changes
- Safe manifest generation and deployment testing
- Evidence-led diagnosis and rollback

## Ordered implementation

1. Project scaffold and architecture
2. Versioned Project 3 image publication contract
3. Kubernetes application base
4. Configuration and environment overlays
5. Workload hardening, network policy, and scaling
6. GitHub CI manifest validation
7. Local deployment and Argo CD reconciliation
8. Controlled failure, rollback, documentation, and release

## Failure exercise

Introduce one reviewed failure, such as an invalid image tag or readiness
probe. Rank likely causes and cite pod status, events, logs, and rendered
manifests before changing desired state. Repair through Git and test the
documented rollback path.

## Completion gate

- Manifests render and validate locally.
- Health, resources, configuration, and access controls are reviewed.
- GitHub pull requests enforce the agreed validation gates.
- The local cluster reconciles the reviewed desired state.
- At least one failure is diagnosed from evidence before repair.
- A tested Git-based rollback procedure is documented.
- Another engineer can follow the README without receiving a secret.
