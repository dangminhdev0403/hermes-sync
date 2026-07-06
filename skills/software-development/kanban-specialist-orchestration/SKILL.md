---
name: kanban-specialist-orchestration
description: Use when planning, auditing, or dispatching multi-profile kanban work across specialist agents. Enforces plan-first confirmation, specialist-to-skill mapping, manifest synchronization, and safe dispatch sequencing.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [kanban, multi-agent, orchestration, specialist-sync, planning]
    related_skills: [skill-backend, skill-frontend, skill-dev-ops, skill-tester, requesting-code-review]
---

# Kanban Specialist Orchestration

## Overview

Use this skill to coordinate `/kanban` work across specialist profiles such as `backend`, `frontend`, `dev-ops`, and `tester`. The operating rule is **plan and confirm before dispatch**: never create, assign, or dispatch kanban work until the user has seen the proposed task graph, specialist mapping, selected skills, dependencies, and acceptance criteria.

This skill governs the orchestrator workflow, not the specialist implementation details. Specialist skill manifests (`skill-backend`, `skill-frontend`, `skill-dev-ops`, `skill-tester`) define each worker's canonical skill set and must be consulted before assignment.

## When to Use

- The user asks to use `/kanban`, "đệ", specialist agents, or multi-agent work.
- A task should be split across backend/frontend/dev-ops/tester profiles.
- You need to decide which specialist gets which task and which skills to attach.
- A previous kanban run failed because a specialist lacked a skill or the task was dispatched too early.
- The user asks to synchronize or update specialist skill libraries.

Do **not** use this for a single direct task that does not need kanban delegation.

## Hard Rule: Confirmation Gate

Before any kanban side effect, present a plan and ask for confirmation. Side effects include:

- `hermes kanban create`
- `hermes kanban assign` / `reassign`
- `hermes kanban dispatch`
- creating task graphs / dependencies
- spawning specialist workers

The pre-dispatch plan must include:

1. **Goal summary** — what business/technical outcome the kanban run should produce.
2. **Specialist assignment table** — each `đệ`/profile, responsibility, and why it fits.
3. **Selected skills table** — exact skills to attach per specialist, based on the specialist manifest.
4. **Task graph** — parallel tasks, dependencies, and final integration/review step.
5. **Acceptance criteria** — what each task must return before it is considered complete.
6. **Risk/assumption list** — credentials, repo path, destructive operations, unavailable services, or unclear scope.
7. **Explicit confirmation question** — e.g. "Xác nhận cho tạo và dispatch kanban theo plan này không?"

Only proceed after the user explicitly confirms.

## Specialist Manifest Workflow

Before assigning a specialist:

1. Load or inspect the relevant manifest skill:
   - `skill-backend`
   - `skill-frontend`
   - `skill-dev-ops`
   - `skill-tester`
2. Select only the skills relevant to the specific card. Do not blindly attach every manifest skill.
3. If a required skill is missing, update the manifest and synchronize the specialist profile before dispatch.
4. If the update is broad or risky, explain the proposed skill change and ask for confirmation first.
5. After updating, verify the manifest exists in both:
   - default profile skills: `C:/Users/Admin/AppData/Local/hermes/skills/specialist-sync/skill-<name>/SKILL.md`
   - specialist profile skills: `C:/Users/Admin/.hermes/profiles/<name>/skills/specialist-sync/skill-<name>/SKILL.md`

## Default Specialist Responsibilities

| Specialist | Primary ownership | Typical manifest |
|---|---|---|
| `backend` | APIs, services, data validation, integrations, RBAC, backend tests | `skill-backend` |
| `frontend` | UI, Next.js conventions, UX polish, frontend integration, accessibility | `skill-frontend` |
| `dev-ops` | Docker, local services, infra config, deployment/runtime reproducibility | `skill-dev-ops` |
| `tester` | QA, regression, independent verification, SonarQube/code-quality review | `skill-tester` |

## Planning Template

Use this shape before creating kanban tasks:

```markdown
## Kanban Plan: <title>

### Goal
<one paragraph>

### Specialist + Skill Mapping
| Đệ | Responsibility | Skills to attach | Why |
|---|---|---|---|
| backend | ... | `skill-a`, `skill-b` | ... |
| frontend | ... | `skill-a`, `skill-b` | ... |
| dev-ops | ... | `skill-a`, `skill-b` | ... |
| tester | ... | `skill-a`, `skill-b` | ... |

### Task Graph
| Task | Assignee | Depends on | Deliverable |
|---|---|---|---|
| T1 | backend | none | ... |
| T2 | frontend | T1 | ... |
| T3 | tester | T1,T2 | QA report + blockers |

### Acceptance Criteria
- [ ] ...

### Risks / Questions
- ...

Xác nhận cho tạo và dispatch kanban theo plan này không?
```

## Tester Quality Gate Policy

For explicit code review or tester verification of frontend/backend code, assign `tester` with the relevant QA/code-review skills and include the local SonarQube review gate when appropriate:

```bash
~/AppData/Local/hermes/scripts/sonarqube-review.sh "$(pwd)" "$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')"
```

Treat SonarQube as a review gate, not an implementation-time background process. It should run during tester/code-review verification or when the user explicitly asks for it.

## Synchronization Policy

The orchestrator may add, patch, or synchronize specialist skills when the change materially improves project reliability, quality, or delegation correctness. Before changing skills:

1. Check whether the learning belongs in an existing class-level skill or manifest.
2. Prefer updating a currently used/loaded skill over creating a narrow one-off skill.
3. Keep specialist manifests synchronized with profile skills.
4. Avoid duplicating large instructions across many manifests; put class-level rules here and keep manifests focused on each specialist's canonical set.
5. Verify after synchronization by checking files and, where possible, loading the manifest skill.

## Common Pitfalls

1. **Dispatching too early.** Creating or dispatching kanban tasks before the user confirms violates the workflow. Always show the plan first.
2. **Attaching irrelevant skills.** Large skill sets add noise. Attach a focused subset from the specialist manifest.
3. **Skipping manifest checks.** If the specialist lacks a skill, the worker may crash or miss important procedure. Check before dispatch.
4. **Making tester an implementer.** Tester should verify and report unless explicitly assigned a fix task.
5. **Treating SonarQube as always-on.** SonarQube is for review/tester verification unless explicitly requested during implementation.
6. **Letting manifests drift.** When adding a new reusable workflow for a specialist, update both the class-level skill and the relevant `skill-<specialist>` manifest.

## Verification Checklist

- [ ] User saw and confirmed the kanban plan before side effects.
- [ ] Each specialist has a clear responsibility and deliverable.
- [ ] Skills were selected from the appropriate `skill-<specialist>` manifest.
- [ ] Dependencies prevent tester/reviewer tasks from running before implementation tasks complete.
- [ ] Any skill changes were synchronized to default and specialist profile skill trees.
- [ ] Final response reports task IDs, assignees, and how to monitor progress.
