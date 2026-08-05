# Issue 006: Add GitHub manifest validation

## Outcome

Make pull requests fail when desired state cannot render, violates Kubernetes
schemas, breaks agreed security policy, or appears to contain sensitive data.

## Scope

- Select and pin schema and security validation tools
- Render every overlay in local scripts and GitHub Actions
- Schema validation against the intended Kubernetes version
- Security/configuration scan with documented severity policy
- Secret-pattern check suitable for a public manifest repository
- Least-privilege workflow permissions and SHA-pinned actions

The workflow validates only. It does not authenticate to or deploy to a cluster.

## Acceptance criteria

- Local and CI commands are equivalent and documented.
- Every overlay is discovered explicitly or through a commented, tested loop.
- A malformed object or failed policy gate produces an understandable failure.
- Workflow permissions are read-only unless a reviewed step requires more.
- Tool versions, schema target, and exception process are recorded.
