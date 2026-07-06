---
name: skill-frontend
description: Use when synchronizing or assigning the frontend specialist profile/deệ. Lists the canonical skills, responsibilities, and quality gates that must be considered before kanban delegation.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [kanban, specialist-sync, frontend, skills]
    related_skills: [hermes-agent, requesting-code-review]
---

# Frontend Specialist Skill Sync

## Overview

This manifest keeps the `frontend` specialist profile synchronized with the skills it needs for kanban work. Use it before creating `/kanban` tasks for `frontend`, when auditing specialist readiness, or when updating specialist skills after a workflow improvement.

**Specialist role:** Frontend Engineer

## When to Use

- Before assigning a kanban card to `frontend`.
- When selecting skills for `frontend` in a multi-agent plan.
- When checking whether `frontend` has the required capabilities for a task.
- When adding or removing skills that should stay synchronized for this specialist.

## Canonical Skill Set

| Skill path | Skill name |
|---|---|
| `frontend/repomix-explorer` | repomix-explorer |
| `frontend/plan` | plan |
| `frontend/next-best-practices` | next-best-practices |
| `frontend/frontend-design` | frontend-design |
| `frontend/design-taste-frontend` | design-taste-frontend |
| `frontend/ui-ux-pro-max` | ui-ux-pro-max |
| `frontend/frontend-marketing-sites` | frontend-marketing-sites |
| `frontend/management-module-frontend-integration` | management-module-frontend-integration |
| `frontend/operational-dashboard-implementation` | operational-dashboard-implementation |
| `frontend/guestos-frontend-i18n` | guestos-frontend-i18n |
| `frontend/node-inspect-debugger` | node-inspect-debugger |
| `frontend/test-driven-development` | test-driven-development |
| `frontend/systematic-debugging` | systematic-debugging |
| `frontend/requesting-code-review` | requesting-code-review |
| `frontend/simplify-code` | simplify-code |
| `software-development/local-code-quality-gates` | local-code-quality-gates |

## Operating Policy

- Use repomix-explorer before planning or implementation on unfamiliar/large repositories.
- Own frontend UI, Next.js conventions, accessibility, UX polish, integration with backend/internal APIs, and frontend tests.
- Avoid generic/sloppy UI; use design-taste-frontend/frontend-design/ui-ux-pro-max when building or reviewing interfaces.
- Run requesting-code-review before declaring frontend code ready; include SonarQube only during explicit review/tester verification.

## Kanban Assignment Checklist

- [ ] Explain why `frontend` is the right assignee.
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
C:/Users/Admin/.hermes/profiles/frontend/skills
```

## Example Skill Flags

When creating a kanban task, attach only the skills relevant to the specific card. Example full set:

```bash
--skill repomix-explorer --skill plan --skill next-best-practices --skill frontend-design --skill design-taste-frontend --skill ui-ux-pro-max --skill frontend-marketing-sites --skill management-module-frontend-integration --skill operational-dashboard-implementation --skill guestos-frontend-i18n --skill node-inspect-debugger --skill test-driven-development --skill systematic-debugging --skill requesting-code-review --skill simplify-code --skill local-code-quality-gates
```

Do not blindly attach every skill if a narrower task only needs a subset.
