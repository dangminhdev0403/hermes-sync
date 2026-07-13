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

| Skill path | Skill name | Description |
|---|---|---|
| `software-development/confirmation-gated-execution` | confirmation-gated-execution | Use when a normal chat request may execute commands, edit code/files, configure local services, improve work products, fix bugs, or assign specialists/đệ. Enforces a pro-max proposal and explicit user confirmation before side effects. |
| `dogfood` | dogfood | Exploratory QA of web apps: find bugs, evidence, reports. |
| `software-development/local-code-quality-gates` | local-code-quality-gates | Use when setting up or running local static-analysis quality gates for code review, especially SonarQube-in-Docker review gates for frontend/backend cleanliness checks. |
| `software-development/multi-language-code-review` | multi-language-code-review | Use when the user asks Hermes or tester to check security, review code, audit a repo/module, or design a security flow across languages/stacks. Detects stack, selects safe quality/security gates, uses SecurityLab artifacts, and decides when recon-skills, DockerScan, or Ghidra/GhidraGPT are appropriate. |
| `sonarqube-scanner-skill` | SonarQube Scanner Skill | Use when running explicit code-review/tester verification with a local Docker SonarQube quality gate. Ensures SonarQube Community runs in Docker, runs sonar-scanner via Docker, reads quality gate/issues from the Web API, and maps findings to source lines for review notes. |
| `backend/requesting-code-review` | requesting-code-review | Pre-commit review: security scan, quality gates, auto-fix. |
| `backend/test-driven-development` | test-driven-development | TDD: enforce RED-GREEN-REFACTOR, tests before code. |
| `backend/systematic-debugging` | systematic-debugging | 4-phase root cause debugging: understand bugs before fixing. |
| `github/github-code-review` | github-code-review | Review PRs: diffs, inline comments via gh or REST. |
| `github/codebase-inspection` | codebase-inspection | Inspect codebases w/ pygount: LOC, languages, ratios. |
| `frontend/next-best-practices` | next-best-practices | Next.js best practices - file conventions, RSC boundaries, data patterns, async APIs, metadata, error handling, route handlers, image/font optimization, bundling |
| `frontend/design-taste-frontend` | design-taste-frontend | Use when building, redesigning, or reviewing frontend experiences that need stronger taste, anti-template design direction, hierarchy, and interface polish. |

## Operating Policy

- The confirmation gate applies to direct user chats as well as Kanban: inspect read-only, present a pro-max plan, and wait for explicit approval before any side effect.
- Own QA, regression checks, exploratory web testing, code cleanliness review, security review, and independent verification.
- Prefer Lightpanda MCP for text/DOM browser automation, crawling, extraction, and non-visual web checks; use Chrome/Chromium only when screenshot, visual QA, or complex rendering is required. See `references/lightpanda-browser-policy.md`.
- When Lightpanda is available through Docker/MCP but not as a native PATH binary, use the Docker-backed PATH shim and auth smoke pattern in `references/lightpanda-docker-path-and-auth-smoke.md` instead of treating it as missing. For auth checks, combine DOM proof with session/API evidence and redact credentials/tokens/cookies from logs.
- When explicitly assigned security review, security-flow review, audit, or multi-language repo/module review, use `multi-language-code-review` to classify the lane, select gates, and separate confirmed findings from tool-only candidates.
- When explicitly assigned code review/tester verification for frontend/backend code, run the local SonarQube review gate via ~/AppData/Local/hermes/scripts/sonarqube-review.sh.
- Do not modify implementation code unless explicitly assigned a fix task; report blockers with evidence.
- If a tester task stays `todo`, first check whether its implementation parent is stuck in `blocked review-required`. Tester cannot run until the parent is `done`; ask the orchestrator to complete the parent handoff or promote the tester only after the dependency is intentionally resolved.

## Kanban Assignment Checklist

- [ ] Explain why `tester` is the right assignee.
- [ ] List the exact skills from this manifest that will be attached to the card.
- [ ] Confirm dependencies and acceptance criteria before dispatch.
- [ ] Ask the user for confirmation before creating or dispatching kanban tasks.
- [ ] If a required skill is missing, update this manifest and synchronize profile skills before dispatch.
- [ ] If tester is not spawned, verify parent tasks are `done`; flag `review-required` parent deadlocks immediately.

## Sync Notes

The current synchronization source is the default profile skill tree:

```text
C:/Users/Dangminhdev0403/AppData/Local/hermes/skills
```

The synchronized specialist profile target is:

```text
C:/Users/Dangminhdev0403/AppData/Local/hermes/profiles/tester/skills
```

## Example Skill Flags

When creating a kanban task, attach only the skills relevant to the specific card. Example full set:

```bash
--skill dogfood --skill multi-language-code-review --skill local-code-quality-gates --skill sonarqube-scanner-skill --skill requesting-code-review --skill test-driven-development --skill systematic-debugging --skill github-code-review --skill codebase-inspection --skill next-best-practices --skill design-taste-frontend
```

Do not blindly attach every skill if a narrower task only needs a subset.


Fast selection index for this specialist is generated at:

```text
C:\Users\Dangminhdev0403\AppData\Local\hermes\profiles\tester\skills\SKILL_DESCRIPTIONS.md
```
