#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

findings=0

if rg -n --hidden --glob '!.git/**' -- '-----BEGIN (RSA|EC|OPENSSH|PRIVATE) KEY-----' "${repo_root}"; then
  findings=1
fi

if rg -n -i --hidden --glob '!.git/**' \
  -P '(password|passwd|api[_-]?key|access[_-]?token)\s*[:=]\s*[A-Za-z0-9+/=_-]{16,}' \
  "${repo_root}"; then
  findings=1
fi

if [[ "${findings}" -ne 0 ]]; then
  echo "Potential credential material found; remove it or review the pattern before merging." >&2
  exit 1
fi

echo "Public secret-pattern check passed"
