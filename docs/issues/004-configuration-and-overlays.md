# Issue 004: Add configuration and environment overlays

## Outcome

Express local and staging-style environment differences without duplicating the
base workload or committing sensitive values.

## Scope

- `local` and `staging` Kustomize overlays
- ConfigMap-managed `SERVICE_NAME`, `APP_ENV`, and `LOG_LEVEL`
- One documented external Secret reference and safe local creation procedure
- Namespace and replica differences where justified
- Rendered-output tests for both overlays

## Acceptance criteria

- Both overlays render independently and preserve base selectors and probes.
- Configuration matches the application service validation contract.
- No Secret value, placeholder that resembles a credential, or generated
  Secret object is committed.
- Missing external Secret behaviour and diagnosis are documented.
- The README explains how a user selects and inspects an overlay.
