#!/bin/sh

set -eu

test_number=0

check_file() {
  test_number=$((test_number + 1))
  description=$1
  path=$2

  if [ -f "$path" ]; then
    printf 'ok %s - %s\n' "$test_number" "$description"
  else
    printf 'not ok %s - %s\n' "$test_number" "$description"
    return 1
  fi
}

check_text() {
  test_number=$((test_number + 1))
  description=$1
  pattern=$2
  path=$3

  if grep -q "$pattern" "$path"; then
    printf 'ok %s - %s\n' "$test_number" "$description"
  else
    printf 'not ok %s - %s\n' "$test_number" "$description"
    return 1
  fi
}

printf 'TAP version 13\n'

check_file 'repository purpose is documented' README.md
check_file 'Codex instructions exist' AGENTS.md
check_file 'current hand-off exists' docs/project-journal.md
check_file 'Project 5 roadmap exists' docs/learning-roadmap.md
check_file 'requirements exist' docs/requirements.md
check_file 'architecture exists' docs/architecture.md
check_file 'durable-context decision exists' \
  docs/decisions/ADR-001-durable-context-and-review.md
check_file 'deployment-stack decision exists' \
  docs/decisions/ADR-002-kustomize-ghcr-argocd-local.md
check_file 'first issue exists' \
  docs/issues/001-project-scaffold-and-architecture.md
check_file 'final issue exists' \
  docs/issues/008-failure-rollback-and-release.md
check_text 'README identifies Project 5' 'Project 5' README.md
check_text 'journal contains Resume here' 'Resume here' docs/project-journal.md
check_text 'completion gate requires failure diagnosis' \
  'failure is diagnosed from evidence' docs/learning-roadmap.md
check_text 'instructions protect Secret values' \
  'Never commit credentials' AGENTS.md
check_text 'architecture separates application ownership' \
  'Project 3 application repository' docs/architecture.md

printf '1..%s\n' "$test_number"
printf 'Durable Project 5 context is ready. Follow Resume here next.\n'
