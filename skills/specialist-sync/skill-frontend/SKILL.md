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

| Skill path | Skill name | Description |
|---|---|---|
| `impeccable` | impeccable | Use when designing, redesigning, auditing, polishing, or hardening frontend interfaces: UX hierarchy, accessibility, responsive behavior, visual taste, states, copy, and anti-slop refinement. |
| `frontend/repomix-explorer` | repomix-explorer | Use when exploring an unfamiliar or large local/remote codebase for structure, patterns, metrics, or broad discovery before planning; not for targeted edits or known-file lookups. |
| `frontend/plan` | plan | Plan mode: write an actionable markdown plan to .hermes/plans/, no execution. Bite-sized tasks, exact paths, complete code. |
| `frontend/next-best-practices` | next-best-practices | Next.js best practices - file conventions, RSC boundaries, data patterns, async APIs, metadata, error handling, route handlers, image/font optimization, bundling |
| `frontend/frontend-design` | frontend-design | Use when creating distinctive production-grade web pages, components, dashboards, landing pages, or HTML/CSS/React UI that should look polished rather than generic. |
| `frontend/design-taste-frontend` | design-taste-frontend | Use when building, redesigning, or reviewing frontend experiences that need stronger taste, anti-template design direction, hierarchy, and interface polish. |
| `frontend/ui-ux-pro-max` | ui-ux-pro-max | Use when planning, building, reviewing, or improving web/mobile UI/UX across design styles, palettes, accessibility, layouts, components, charts, and product patterns. |
| `frontend/frontend-marketing-sites` | frontend-marketing-sites | Build or redesign public marketing websites and landing pages inside an existing web app without breaking product/auth routes. |
| `frontend/management-module-frontend-integration` | management-module-frontend-integration | Implement management/admin module frontend integrations for CRUD lists, synchronization actions, and file imports against existing backend/internal API layers. |
| `frontend/operational-dashboard-implementation` | operational-dashboard-implementation | Build operational dashboards that help staff decide what to do next, with domain-oriented aggregate APIs and actionable frontend sections. |
| `frontend/guestos-frontend-i18n` | guestos-frontend-i18n | Add frontend-only multilingual support to GuestOS/guest-facing flows without touching admin/owner/staff pages or backend translation APIs. |
| `frontend/node-inspect-debugger` | node-inspect-debugger | Debug Node.js via --inspect + Chrome DevTools Protocol CLI. |
| `frontend/test-driven-development` | test-driven-development | TDD: enforce RED-GREEN-REFACTOR, tests before code. |
| `frontend/systematic-debugging` | systematic-debugging | 4-phase root cause debugging: understand bugs before fixing. |
| `frontend/requesting-code-review` | requesting-code-review | Pre-commit review: security scan, quality gates, auto-fix. |
| `frontend/simplify-code` | simplify-code | Parallel 3-agent cleanup of recent code changes. |
| `software-development/local-code-quality-gates` | local-code-quality-gates | Use when setting up or running local static-analysis quality gates for code review, especially SonarQube-in-Docker review gates for frontend/backend cleanliness checks. |

## Operating Policy

- Use repomix-explorer before planning or implementation on unfamiliar/large repositories.
- Use impeccable for frontend interface work that involves design, redesign, critique, audit, polish, UX hierarchy, accessibility, responsive behavior, product UI, dashboards, app shells, components, forms, empty/error/loading states, or anti-AI-slop hardening.
- Own frontend UI, Next.js conventions, accessibility, UX polish, integration with backend/internal APIs, and frontend tests.
- Avoid generic/sloppy UI; use impeccable together with design-taste-frontend/frontend-design/ui-ux-pro-max when building or reviewing interfaces.
- Run requesting-code-review before declaring frontend code ready; include SonarQube only during explicit review/tester verification.
- **Do not block completed implementation as `review-required` when a tester/reviewer child depends on this task.** If implementation is complete and local verification has passed, finish/complete the frontend task with a structured handoff summary for tester. Use `blocked` only for real blockers: incomplete work, failing checks, missing input/credentials, or unsafe scope. If human approval is required before shipping, state that in the handoff and let tester/final-approval tasks run separately.

## Kanban Assignment Checklist

- [ ] Explain why `frontend` is the right assignee.
- [ ] List the exact skills from this manifest that will be attached to the card.
- [ ] Confirm dependencies and acceptance criteria before dispatch.
- [ ] Ask the user for confirmation before creating or dispatching kanban tasks.
- [ ] If a required skill is missing, update this manifest and synchronize profile skills before dispatch.
- [ ] For tasks with tester/reviewer children, acceptance criteria say: completed implementation must return `done`/handoff, not `blocked review-required`.

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
--skill impeccable --skill repomix-explorer --skill plan --skill next-best-practices --skill frontend-design --skill design-taste-frontend --skill ui-ux-pro-max --skill frontend-marketing-sites --skill management-module-frontend-integration --skill operational-dashboard-implementation --skill guestos-frontend-i18n --skill node-inspect-debugger --skill test-driven-development --skill systematic-debugging --skill requesting-code-review --skill simplify-code --skill local-code-quality-gates
```

Do not blindly attach every skill if a narrower task only needs a subset.


Fast selection index for this specialist is generated at:

```text
C:\Users\Admin\.hermes\profiles\frontend\skills\SKILL_DESCRIPTIONS.md
```
