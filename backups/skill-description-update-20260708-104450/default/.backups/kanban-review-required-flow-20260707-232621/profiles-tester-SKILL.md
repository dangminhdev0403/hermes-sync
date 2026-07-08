---
name: skill-tester
description: Use when synchronizing or assigning the tester specialist profile/deệ. Lists the canonical skills, responsibilities, and quality gates that must be considered before kanban delegation.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [kanban, specialist-sync, tester, skills]
    related_skills: [hermes-agent, requesting-code-review]
---

# Tester Specialist Skill Sync

## Overview

This manifest keeps the `tester` specialist profile synchronized with the skills it needs for kanban work. Use it before creating `/kanban` tasks for `tester`, when auditing specialist readiness, or when updating specialist skills after a workflow improvement.

**Specialist role:** QA Engineer / Code Reviewer

## When to Use

- Before assigning a kanban card to `tester`.
- When selecting skills for `tester` in a multi-agent plan.
- When checking whether `tester` has the required capabilities for a task.
- When adding or removing skills that should stay synchronized for this specialist.

## Canonical Skill Set

| Skill path | Skill name |
|---|---|
| `dogfood` | dogfood |
| `software-development/local-code-quality-gates` | local-code-quality-gates |
| `sonarqube-scanner-skill` | SonarQube Scanner Skill |
| `backend/requesting-code-review` | requesting-code-review |
| `backend/test-driven-development` | test-driven-development |
| `backend/systematic-debugging` | systematic-debugging |
| `github/github-code-review` | github-code-review |
| `github/codebase-inspection` | codebase-inspection |
| `frontend/next-best-practices` | next-best-practices |
| `frontend/design-taste-frontend` | design-taste-frontend |

## Operating Policy

- Own QA, regression checks, exploratory web testing, code cleanliness review, and independent verification.
- When explicitly assigned code review/tester verification for frontend/backend code, run the local SonarQube review gate via ~/AppData/Local/hermes/scripts/sonarqube-review.sh.
- Do not modify implementation code unless explicitly assigned a fix task; report blockers with evidence.

## Kanban Assignment Checklist

- [ ] Explain why `tester` is the right assignee.
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
C:/Users/Admin/.hermes/profiles/tester/skills
```

## Example Skill Flags

When creating a kanban task, attach only the skills relevant to the specific card. Example full set:

```bash
--skill dogfood --skill local-code-quality-gates --skill sonarqube-scanner-skill --skill requesting-code-review --skill test-driven-development --skill systematic-debugging --skill github-code-review --skill codebase-inspection --skill next-best-practices --skill design-taste-frontend
```

Do not blindly attach every skill if a narrower task only needs a subset.
