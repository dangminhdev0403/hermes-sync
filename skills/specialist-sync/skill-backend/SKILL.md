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

| Skill path | Skill name | Description |
|---|---|---|
| `software-development/confirmation-gated-execution` | confirmation-gated-execution | Use when a normal chat request may execute commands, edit code/files, configure local services, improve work products, fix bugs, or assign specialists/đệ. Enforces a pro-max proposal and explicit user confirmation before side effects. |
| `backend/repomix-explorer` | repomix-explorer | Use when exploring an unfamiliar or large local/remote codebase for structure, patterns, metrics, or broad discovery before planning; not for targeted edits or known-file lookups. |
| `backend/plan` | plan | Plan mode: write an actionable markdown plan to .hermes/plans/, no execution. Bite-sized tasks, exact paths, complete code. |
| `backend/nestjs-backend-integrations` | nestjs-backend-integrations | Implement external service integrations in NestJS/Prisma backends as asynchronous side effects without breaking core business writes. |
| `backend/backend-i18n` | backend-i18n | Design and implement backend multilingual support for API messages and database-backed content, especially NestJS/Prisma service catalog domains. |
| `backend/rbac-access-control-refactoring` | rbac-access-control-refactoring | Refactor role/permission systems from route-level RBAC toward business capability permissions with safer backend guards and simpler admin UIs. |
| `backend/docker-development-workflows` | docker-development-workflows | Design and implement Docker Compose development workflows for Node/NestJS/Next.js apps with databases, especially Windows + Docker Desktop + pnpm setups. |
| `backend/test-driven-development` | test-driven-development | TDD: enforce RED-GREEN-REFACTOR, tests before code. |
| `backend/systematic-debugging` | systematic-debugging | 4-phase root cause debugging: understand bugs before fixing. |
| `backend/requesting-code-review` | requesting-code-review | Pre-commit review: security scan, quality gates, auto-fix. |
| `backend/simplify-code` | simplify-code | Parallel 3-agent cleanup of recent code changes. |
| `software-development/local-code-quality-gates` | local-code-quality-gates | Use when setting up or running local static-analysis quality gates for code review, especially SonarQube-in-Docker review gates for frontend/backend cleanliness checks. |

## Operating Policy

- The confirmation gate applies to direct user chats as well as Kanban: inspect read-only, present a pro-max plan, and wait for explicit approval before any side effect.
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
C:/Users/Dangminhdev0403/AppData/Local/hermes/skills
```

The synchronized specialist profile target is:

```text
C:/Users/Dangminhdev0403/AppData/Local/hermes/profiles/backend/skills
```

## Example Skill Flags

When creating a kanban task, attach only the skills relevant to the specific card. Example full set:

```bash
--skill repomix-explorer --skill plan --skill nestjs-backend-integrations --skill backend-i18n --skill rbac-access-control-refactoring --skill docker-development-workflows --skill test-driven-development --skill systematic-debugging --skill requesting-code-review --skill simplify-code --skill local-code-quality-gates
```

Do not blindly attach every skill if a narrower task only needs a subset.


Fast selection index for this specialist is generated at:

```text
C:\Users\Dangminhdev0403\AppData\Local\hermes\profiles\backend\skills\SKILL_DESCRIPTIONS.md
```
