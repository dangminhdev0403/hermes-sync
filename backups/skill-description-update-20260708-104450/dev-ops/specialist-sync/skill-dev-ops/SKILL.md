---
name: skill-dev-ops
description: Use when synchronizing or assigning the dev-ops specialist profile/deệ. Lists the canonical skills, responsibilities, and quality gates that must be considered before kanban delegation.
version: 1.0.1
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [kanban, specialist-sync, dev-ops, skills]
    related_skills: [hermes-agent, requesting-code-review]
---

# DevOps Specialist Skill Sync

## Overview

This manifest keeps the `dev-ops` specialist profile synchronized with the skills it needs for kanban work. Use it before creating `/kanban` tasks for `dev-ops`, when auditing specialist readiness, or when updating specialist skills after a workflow improvement.

**Specialist role:** DevOps Engineer

## When to Use

- Before assigning a kanban card to `dev-ops`.
- When selecting skills for `dev-ops` in a multi-agent plan.
- When checking whether `dev-ops` has the required capabilities for a task.
- When adding or removing skills that should stay synchronized for this specialist.

## Canonical Skill Set

| Skill path | Skill name |
|---|---|
| `dev-ops/repomix-explorer` | repomix-explorer |
| `dev-ops/autonomous-ai-agents/codex` | codex |
| `dev-ops/docker-expert` | docker-expert |
| `dev-ops/local-docker-databases` | local-docker-databases |
| `dev-ops/azure-kubernetes` | azure-kubernetes |
| `dev-ops/azure-kubernetes/azure-kubernetes-automatic-readiness` | azure-kubernetes-automatic-readiness |
| `backend/docker-development-workflows` | docker-development-workflows |
| `software-development/local-code-quality-gates` | local-code-quality-gates |

## Operating Policy

- Own Docker, local development services, infrastructure readiness, deployment/runtime configuration, and reproducibility.
- Verify real service readiness with commands and health checks; never report infra success without tool output.
- For local databases, provide connection details and verified versions.
- Use Codex/autonomous-agent skill only when a DevOps task explicitly benefits from a separate coding-agent workflow.

## Kanban Assignment Checklist

- [ ] Explain why `dev-ops` is the right assignee.
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
C:/Users/Admin/.hermes/profiles/dev-ops/skills
```

## Example Skill Flags

When creating a kanban task, attach only the skills relevant to the specific card. Example full set:

```bash
--skill repomix-explorer --skill codex --skill docker-expert --skill local-docker-databases --skill azure-kubernetes --skill azure-kubernetes-automatic-readiness --skill docker-development-workflows --skill local-code-quality-gates
```

Do not blindly attach every skill if a narrower task only needs a subset.
