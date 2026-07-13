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

| Skill path | Skill name | Description |
|---|---|---|
| `software-development/confirmation-gated-execution` | confirmation-gated-execution | Use when a normal chat request may execute commands, edit code/files, configure local services, improve work products, fix bugs, or assign specialists/đệ. Enforces a pro-max proposal and explicit user confirmation before side effects. |
| `dev-ops/repomix-explorer` | repomix-explorer | Use when exploring an unfamiliar or large local/remote codebase for structure, patterns, metrics, or broad discovery before planning; not for targeted edits or known-file lookups. |
| `dev-ops/autonomous-ai-agents/codex` | codex | Delegate coding to OpenAI Codex CLI (features, PRs). |
| `dev-ops/docker-expert` | docker-expert | You are an advanced Docker containerization expert with comprehensive, practical knowledge of container optimization, security hardening, multi-stage builds, orchestration patterns, and production deployment strategies based on current industry best practices. |
| `dev-ops/local-docker-databases` | local-docker-databases | Set up, replace, and verify local development databases in Docker, especially PostgreSQL/MySQL/Redis-style services with durable volumes and connection details. |
| `dev-ops/azure-kubernetes` | azure-kubernetes | Use when planning, creating, securing, operating, or cost-optimizing production Azure Kubernetes Service clusters, including SKU, networking, autoscaling, upgrades, and observability choices. |
| `dev-ops/azure-kubernetes/azure-kubernetes-automatic-readiness` | azure-kubernetes-automatic-readiness | Use when assessing AKS Standard workloads and manifests for AKS Automatic compatibility, migration blockers, required fixes, and readiness reporting. |
| `backend/docker-development-workflows` | docker-development-workflows | Design and implement Docker Compose development workflows for Node/NestJS/Next.js apps with databases, especially Windows + Docker Desktop + pnpm setups. |
| `software-development/local-code-quality-gates` | local-code-quality-gates | Use when setting up or running local static-analysis quality gates for code review, especially SonarQube-in-Docker review gates for frontend/backend cleanliness checks. |

## Operating Policy

- The confirmation gate applies to direct user chats as well as Kanban: inspect read-only, present a pro-max plan, and wait for explicit approval before any side effect.
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
C:/Users/Dangminhdev0403/AppData/Local/hermes/skills
```

The synchronized specialist profile target is:

```text
C:/Users/Dangminhdev0403/AppData/Local/hermes/profiles/dev-ops/skills
```

## Example Skill Flags

When creating a kanban task, attach only the skills relevant to the specific card. Example full set:

```bash
--skill repomix-explorer --skill codex --skill docker-expert --skill local-docker-databases --skill azure-kubernetes --skill azure-kubernetes-automatic-readiness --skill docker-development-workflows --skill local-code-quality-gates
```

Do not blindly attach every skill if a narrower task only needs a subset.


Fast selection index for this specialist is generated at:

```text
C:\Users\Dangminhdev0403\AppData\Local\hermes\profiles\dev-ops\skills\SKILL_DESCRIPTIONS.md
```
## Inline Plan Artifact Policy

The approved inline chat plan is the execution contract. Do not create, update, attach, list, or resend `PLAN.md`, `PLANS.md`, or `.hermes/plans/*` unless the user explicitly requested a saved plan artifact. A clear approval such as `phê duyệt triển khai` must authorize the existing plan immediately without a second confirmation loop.
