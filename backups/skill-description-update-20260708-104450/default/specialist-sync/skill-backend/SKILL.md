---
name: skill-backend
description: Use when synchronizing or assigning the backend specialist profile/deệ. Lists the canonical skills, responsibilities, and quality gates that must be considered before kanban delegation.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [kanban, specialist-sync, backend, skills]
    related_skills: [hermes-agent, requesting-code-review]
---

# Backend Specialist Skill Sync

## Overview

This manifest keeps the `backend` specialist profile synchronized with the skills it needs for kanban work. Use it before creating `/kanban` tasks for `backend`, when auditing specialist readiness, or when updating specialist skills after a workflow improvement.

**Specialist role:** Backend Engineer

## When to Use

- Before assigning a kanban card to `backend`.
- When selecting skills for `backend` in a multi-agent plan.
- When checking whether `backend` has the required capabilities for a task.
- When adding or removing skills that should stay synchronized for this specialist.

## Canonical Skill Set

| Skill path | Skill name |
|---|---|
| `backend/repomix-explorer` | repomix-explorer |
| `backend/plan` | plan |
| `backend/nestjs-backend-integrations` | nestjs-backend-integrations |
| `backend/backend-i18n` | backend-i18n |
| `backend/rbac-access-control-refactoring` | rbac-access-control-refactoring |
| `backend/docker-development-workflows` | docker-development-workflows |
| `backend/test-driven-development` | test-driven-development |
| `backend/systematic-debugging` | systematic-debugging |
| `backend/requesting-code-review` | requesting-code-review |
| `backend/simplify-code` | simplify-code |
| `software-development/local-code-quality-gates` | local-code-quality-gates |

## Operating Policy

- Use repomix-explorer before planning or implementation on unfamiliar/large repositories.
- Own backend API, service boundaries, data validation, integrations, RBAC/business permissions, and backend tests.
- Run requesting-code-review before declaring backend code ready; include SonarQube only during explicit review/tester verification.

## Kanban Assignment Checklist

- [ ] Explain why `backend` is the right assignee.
- [ ] List the exact skills from this manifest that will be attached to the card.
- [ ] Confirm dependencies and acceptance criteria before dispatch.
- [ ] Ask the user for confirmation before creating or dispatching kanban tasks.
- [ ] If a required skill is missing, update this manifest and synchronize profile skills before dispatch.

## Sync Notes

The current synchronization source is the default profile skill tree:

```text
C:/Users/Admin/AppData/Local/hermes/skills
```

The synchronized specialist profile target is:

```text
C:/Users/Admin/.hermes/profiles/backend/skills
```

## Example Skill Flags

When creating a kanban task, attach only the skills relevant to the specific card. Example full set:

```bash
--skill repomix-explorer --skill plan --skill nestjs-backend-integrations --skill backend-i18n --skill rbac-access-control-refactoring --skill docker-development-workflows --skill test-driven-development --skill systematic-debugging --skill requesting-code-review --skill simplify-code --skill local-code-quality-gates
```

Do not blindly attach every skill if a narrower task only needs a subset.
