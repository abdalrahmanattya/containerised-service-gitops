# Issue 007: Deploy locally and establish Argo CD reconciliation

## Outcome

Run the reviewed local overlay in Docker Desktop Kubernetes and have Argo CD
reconcile it from GitHub.

## Scope

- Verify or enable Docker Desktop Kubernetes with learner participation
- Confirm exact kubectl context and namespace before mutation
- Install a reviewed Argo CD version after explicit approval
- Add an Argo CD Application restricted to the Project 5 repository and local
  overlay
- Synchronize the reviewed desired state
- Verify rollout, pods, events, logs, image, configuration, and three endpoints
- Document normal observation and cleanup commands

## Acceptance criteria

- Every mutation names and confirms the local target first.
- Argo CD reads the public repository without a stored Git credential.
- Deployment reaches Available and pods are Ready.
- `/health`, `/version`, and `/config-summary` return expected responses.
- Deployed image digest and configuration match reviewed desired state.
- No cloud cluster or credential is introduced.
