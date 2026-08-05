# Issue 005: Add workload hardening, network policy, and scaling

## Outcome

Add reviewable access and scaling controls while documenting what the local
cluster can and cannot prove.

## Scope

- Dedicated ServiceAccount with token automount disabled
- Pod-level security context and dropped Linux capabilities
- Default-deny ingress and minimum allow policy
- HorizontalPodAutoscaler with explicit range and CPU target
- Documentation of NetworkPolicy enforcement and metrics-server prerequisites

## Acceptance criteria

- Workload has no unnecessary Kubernetes API credential.
- NetworkPolicy selectors match the deployed workload and intended client.
- HPA references the correct Deployment and has bounded replicas.
- Resource requests make the CPU scaling target meaningful.
- Local limitations are stated rather than reported as passing controls.
- Rendered objects pass the checks available at this stage.
