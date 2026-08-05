# Issue 002: Publish a versioned Project 3 application image

## Outcome

Establish a reviewed application-artifact contract by publishing the Project 3
service to public GHCR from its owning repository.

## Scope

- Plan and review a narrowly scoped Project 3 release workflow
- Authenticate with GitHub's short-lived workflow token
- Build from the reviewed Project 3 revision
- Publish a semantic version tag and immutable digest
- Record package visibility, provenance, permissions, and pull verification

This is an explicitly approved cross-repository change. It does not add
Kubernetes manifests or deploy the image.

## Acceptance criteria

- Project 3 remains the only image-build owner.
- Workflow permissions are minimum necessary and actions are SHA-pinned.
- No personal token or registry credential is committed.
- The selected image tag/version matches the application version policy.
- The public image can be pulled and its digest is recorded for Issue 003.
- Project 3 documentation, tests, security scan, and release notes remain valid.
