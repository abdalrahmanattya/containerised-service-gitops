# ADR-003: Allow insecure kubelet TLS only for local metrics-server

- **Status:** Accepted
- **Date:** 2026-08-07
- **Decision owners:** Learner and project maintainer

## Context

The local HPA requires the Kubernetes Metrics API. The checksum-verified
metrics-server `v0.9.0` manifest installed successfully, but Docker Desktop's
kubelet certificate does not contain its node IP as a subject alternative
name. Metrics-server refused to scrape the node, so the Metrics API and HPA
remained unavailable and Argo CD reported the Application Degraded.

## Decision

Install metrics-server `v0.9.0` only on the `docker-desktop` learning cluster
and add `--kubelet-insecure-tls` to its Deployment. This exception is not part
of the application manifests and must not be used for a production cluster.

## Consequences

- The HPA receives CPU metrics and Argo CD can report the Application Healthy.
- Metrics-server does not verify the kubelet serving certificate, weakening
  protection against an attacker impersonating the kubelet on the local
  network path.
- Resetting Docker Desktop Kubernetes removes this local prerequisite; the
  documented pinned installation and patch must then be repeated.

## Alternatives considered

### Keep strict TLS verification

Preferred for production, but the Docker Desktop kubelet certificate cannot
be validated by node IP without changing the local cluster's certificate
configuration.

### Remove the HPA

Rejected because CPU-based autoscaling is an explicit Project 5 learning
outcome.

### Accept a permanently Degraded Application

Rejected because it hides real failures behind an expected warning and weakens
the reconciliation exercise.
