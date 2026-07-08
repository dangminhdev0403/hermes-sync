# Session note: specialist skill synchronization

## Context

The user established a kanban operating policy for specialist agents (`backend`, `frontend`, `dev-ops`, `tester`):

- Always build a detailed plan before kanban side effects.
- List selected skills for each specialist.
- Ask for confirmation before creating/dispatching kanban tasks.
- Keep `skill-<specialist>` manifests synchronized so specialists do not miss required skills.
- The orchestrator may update specialist skills after careful review when it materially improves project strength or reliability.

## Concrete setup performed

Created default-profile manifest skills:

- `specialist-sync/skill-backend/SKILL.md`
- `specialist-sync/skill-frontend/SKILL.md`
- `specialist-sync/skill-dev-ops/SKILL.md`
- `specialist-sync/skill-tester/SKILL.md`

Copied relevant skill directories into specialist profile skill roots:

- `C:/Users/Admin/.hermes/profiles/backend/skills`
- `C:/Users/Admin/.hermes/profiles/frontend/skills`
- `C:/Users/Admin/.hermes/profiles/dev-ops/skills`
- `C:/Users/Admin/.hermes/profiles/tester/skills`

Verified manifest frontmatter and approximate profile skill counts after sync:

- backend: 12 SKILL.md files
- frontend: 17 SKILL.md files
- dev-ops: 9 SKILL.md files
- tester: 11 SKILL.md files

## Important nuance

`dev-ops/azure-kubernetes-automatic-readiness` is nested under:

```text
skills/dev-ops/azure-kubernetes/azure-kubernetes-automatic-readiness
```

not directly under `skills/dev-ops/`. When synchronizing DevOps skills, preserve that nested path.

## SonarQube tester policy

`tester` should run SonarQube only for explicit code review/tester verification, not during ordinary implementation. Local helper:

```bash
~/AppData/Local/hermes/scripts/sonarqube-review.sh "$(pwd)" "$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')"
```
