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

1. Choose candidate skills from **names and frontmatter descriptions only**: specialist manifests, `SKILL_DESCRIPTIONS.md`, `skills_list`, or the frontmatter returned by the loader. Do not read entire `SKILL.md` bodies merely to decide which skills a `đệ` should get; full skill bodies are loaded only after a skill has been selected for the work.
2. Load or inspect the relevant manifest skill when needed for assignment policy:
   - `skill-backend`
   - `skill-frontend`
   - `skill-dev-ops`
   - `skill-tester`
3. Select only the skills relevant to the specific card. Do not blindly attach every manifest skill.
4. If a required skill is missing, update the manifest and synchronize the specialist profile before dispatch.
5. If the update is broad or risky, explain the proposed skill change and ask for confirmation first.
6. After updating, verify the manifest exists in both profile-aware locations:
   - default profile skills: `$HERMES_HOME/skills/specialist-sync/skill-<name>/SKILL.md`
   - specialist profile skills: `$HERMES_HOME/profiles/<name>/skills/specialist-sync/skill-<name>/SKILL.md`

   On Windows/git-bash, `$HERMES_HOME` may resolve to `C:/Users/<user>/AppData/Local/hermes`; do not hardcode stale usernames such as `C:/Users/Admin` in plans, manifests, or task instructions.

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


## Security Verification / Fix Orchestration

When Kanban or specialist agents are used for security checks, security fixes, scanner review, or pentest-adjacent workflows, the pre-dispatch plan must add a security gate section before any task creation or dispatch:

- **Scope contract:** explicit repo/path/target allowlist, denylist, authorization owner, rate limits, and kill switch. If scope is missing, create/propose a `scope.yaml` template and stop for confirmation.
- **Operation class:** classify each task as plan-only, read-only review, static/code-quality review, localhost smoke test, active scan/fuzz, auth/credential test, or destructive/production action. Active/auth/destructive classes require separate human approval and should normally be denied until scoped.
- **Tool readiness and skip/install matrix:** list what is already installed and smoke-tested, what is partially ready, what is missing, and which items will be skipped instead of reinstalled.
- **Tester role:** assign `tester` as independent verifier for security/code-quality evidence; tester should not implement fixes unless explicitly assigned a fix card.
- **Evidence taxonomy:** require workers to label outputs as `signal`, `candidate`, `confirmed`, or `invalid`; scanner output alone is not `confirmed` without reproduction evidence.
- **Artifact contract:** require timestamp, tool version/tag/commit, command, target, redaction status, and output path under an approved artifacts/report folder.

See `references/security-agent-toolchain-orchestration.md` for the session-derived SOP pattern covering PentesterFlow/tester/SonarQube-style security agent readiness.

## Review-Required Handoff Protocol

`review-required` is a **handoff signal**, not a dependency-blocking failure. When an implementation worker has completed the requested change and only wants downstream QA/code review, the orchestrator must not leave that implementation parent in `blocked` if tester/reviewer children depend on it.

Use this decision table whenever an implementation task returns `blocked` or a summary beginning with `review-required`:

| Situation | Orchestrator action | Why |
|---|---|---|
| Implementation reports work complete, local checks passed, and asks for tester/code review | `hermes kanban complete <implementation-task> --summary <handoff>` then `hermes kanban dispatch --json` | Opens the dependency gate so tester/reviewer children run. |
| Implementation reports uncertainty, failing checks, missing credentials, or incomplete work | Keep it `blocked`, inspect `hermes kanban runs/log`, and send explicit feedback or create a fix task | This is a real blocker, not a review handoff. |
| Human approval is required before *shipping* but QA is still required | Complete the implementation parent with a clear "not shipped; QA required" summary and model approval as a separate final gate task | Prevents tester from waiting forever behind the same parent. |

Required recovery loop for parent/child deadlocks:

```bash
hermes kanban show <parent_task>
hermes kanban show <child_task>
hermes kanban runs <parent_task>
# If parent is only review-required after completed work:
hermes kanban complete <parent_task> --result "Implementation handoff accepted for downstream QA" --summary "<changed files, checks, QA instructions>"
hermes kanban dispatch --json
hermes kanban show <child_task>
```

Do not rely on memory or assumptions: always inspect the parent summary/runs before completing it. The completion summary must preserve changed files, checks run, known risks, and exact QA instructions so tester has enough context.

## Synchronization Policy

The orchestrator may add, patch, or synchronize specialist skills when the change materially improves project reliability, quality, or delegation correctness. Before changing skills:

1. Check whether the learning belongs in an existing class-level skill or manifest.
2. Prefer updating a currently used/loaded skill over creating a narrow one-off skill.
3. Keep specialist manifests synchronized with profile skills.
4. Avoid duplicating large instructions across many manifests; put class-level rules here and keep manifests focused on each specialist's canonical set.
5. Verify after synchronization by checking files and, where possible, loading the manifest skill.

## Common Pitfalls

1. **Dispatching too early.** Creating or dispatching kanban tasks before the user confirms violates the workflow. Always show the plan first.
2. **Attaching irrelevant or unverified skill names.** Large skill sets add noise, and kanban workers can fail before doing any work if the exact `--skill` names do not resolve in the target profile. Attach a focused subset from the specialist manifest, then smoke-test exact names with the target profile before dispatch when the task depends on explicit skills:
   ```bash
   hermes -p <profile> chat -q "Skill load smoke test. Reply OK." --skills skill-a,skill-b -Q
   ```
   If a skill has both display name and slug/frontmatter aliases, prefer the name that the target profile's CLI accepts. When in doubt, put the procedure in the task body instead of forcing a fragile skill flag.
3. **Skipping manifest checks.** If the specialist lacks a skill, the worker may crash or miss important procedure. Check before dispatch.
4. **Confusing dependency gating with worker failure.** A child tester task stays `todo` until its parent is `done`; a tester task that becomes `blocked` after dispatch needs `hermes kanban runs <id>` and `hermes kanban log <id>` before assuming the implementation is the problem.
5. **Leaving review-required blocks unresolved.** Implementation workers may block with `review-required` after successful verification. Treat this as a handoff signal: inspect the run, complete the implementation parent with the handoff summary, and dispatch tester/reviewer children. Keep it blocked only when work is incomplete, checks failed, or the worker needs real input.
6. **Making tester an implementer.** Tester should verify and report unless explicitly assigned a fix task.
7. **Treating SonarQube as always-on.** SonarQube is for review/tester verification unless explicitly requested during implementation. If SonarQube is available but the skill flag is fragile, include the helper command and service facts in the tester task body rather than blocking dispatch on a scanner skill alias.
8. **Letting manifests drift.** When adding a new reusable workflow for a specialist, update both the class-level skill and the relevant `skill-<specialist>` manifest.
9. **Starting Kanban smoke tests before profile readiness checks.** When the user asks to test connected specialist/Telegram flows, first do a read-only audit: `hermes profile list`, `hermes gateway status`, `hermes kanban boards/list/stats/assignees`, inspect each profile's config/toolsets, and compare each profile's installed skills against the specialist manifest. Then present a repair + smoke-test plan and ask for confirmation before creating boards/tasks or dispatching.
10. **Confusing worker replies with profile gateways.** Kanban dispatcher-spawned CLI workers do not require each specialist gateway to be running. If the user wants each specialist to answer through its own Telegram bot/chat, explicitly audit multi-profile gateway and bot-token/channel configuration; avoid assuming a stopped profile gateway blocks ordinary Kanban worker execution.
11. **Using the default board for smoke tests.** Create a dedicated temporary board (for example `kanban-smoke-<date>`) for connectivity/readiness tests so real work on `default` is not polluted.
12. **Making the user manually run `notify-subscribe` per task.** After creating, decomposing, promoting, reassigning, or dispatching Kanban tasks, the orchestrator/script should auto-subscribe active tasks instead of asking the user to know task IDs. Use `C:/Users/Dangminhdev0403/AppData/Local/hermes/scripts/kanban-subscribe-active.py` (or the current `$HERMES_HOME/scripts/kanban-subscribe-active.py`) to scan `hermes kanban list --json`, skip done/archived tasks, check `notify-list --json`, and subscribe missing active tasks. Default mapping is `backend->backend`, `frontend->frontend`, `dev-ops->dev-ops`, `tester->tester`; use `--notifier-mode default` when all task events should be delivered by the default profile.
13. **Making the user manually start/stop specialist gateways.** When Kanban tasks are assigned to `backend`, `frontend`, `tester`, or `dev-ops`, lifecycle automation should start the required specialist gateway(s) and stop script-managed specialist gateways once their active task count returns to zero. Prefer the wrapper `C:/Users/Dangminhdev0403/AppData/Local/hermes/scripts/kanban-auto-maintain.py --all-boards --quiet-noop`, backed by a no-agent cron watchdog, instead of asking the user to run `hermes -p <profile> gateway run` by hand. Never stop the default gateway; do not stop manually-started specialist gateways unless explicitly configured to manage existing gateways; detect duplicate Telegram bot-token conflicts before starting multiple polling gateways. On Windows, background lifecycle scripts must hide short-lived subprocess consoles with `CREATE_NO_WINDOW` and start specialist gateways via base `pythonw.exe -m hermes_cli.main -p <profile> gateway run --accept-hooks` plus `VIRTUAL_ENV`/`PYTHONPATH`, not via `hermes.exe` or venv `python.exe`, because console launchers can leave persistent cmd/conhost windows.
14. **Mistaking Kanban completion for Telegram delivery.** A task can be `done` with the expected `runs` summary while Telegram still shows no specialist reply. For short smoke tasks, subscribe active tasks *before* dispatch/gateway lifecycle can complete them, subscribe per board under `--all-boards`, and keep script-managed specialist gateways alive long enough for the notifier tick to advance `notify-list.last_event_id`. Verify both Kanban DB (`show`/`runs`) and delivery state (`notify-list`, gateway logs, Telegram chat) before reporting success.
15. **Confusing flow-state visibility with event/log spam.** For this user's Kanban/đệ workflows, Telegram should receive every user-meaningful task state transition — `created`/`todo`/`ready`, `processing`/`running`, `blocked`/`needs_input`, `unblocked`, `done`, `failed`, `archived`, assigned/reassigned — including confirmation tasks. Do **not** spam low-level events like `heartbeat`, `spawned`, scratch workspace tips, comments, or logs. If a child task is created by one specialist for another, notify the child task's `TODO/READY` state and, when human approval is expected, block it with `needs_input` and wait for confirmation before downstream dispatch.
16. **Using the default/orchestrator bot instead of the specialist bot.** When the user has configured separate bots for `backend`, `frontend`, `tester`, and `dev-ops`, task flow-state messages must be sent by the corresponding specialist profile (`hermes -p <profile> send ...`), not by the default bot echoing summaries to the origin chat. Smoke-test direct sends through each profile, route watcher delivery by task assignee, keep successful cron output quiet so the origin chat is not mirrored, and only report success when delivery evidence shows `profile=<specialist>` and `sent=true` for each state transition.
17. **Dispatching after a failed profile/model smoke test.** If `hermes -p <profile> chat ... --skills ...` fails with provider/auth/model errors, do not create/dispatch the real Kanban card anyway. Stop at the readiness blocker, report the failed profile and safe repair options, then dispatch only after the exact profile+skill smoke test passes. If a task already crashed before doing work, inspect `runs`/`log`, classify it as profile-readiness, and keep it blocked until the profile is repaired or the user approves another execution path.

See `references/kanban-profile-readiness-gate.md` for the pre-dispatch specialist profile readiness probe, safe credential diagnostics, and recovery loop for tasks that auto-block after provider/auth crashes.
See `references/kanban-worker-skill-loader-pitfalls.md` for a concrete session example involving tester tasks, SonarQube, and `Unknown skill(s)` crashes.
See `references/specialist-smoke-test-flow.md` for the safe end-to-end profile smoke-test flow: backup/sync missing skills, patch stale manifest paths, one-shot skill-load probes, isolated smoke board, dispatch, monitor, and restore the active board.
See `references/kanban-gateway-lifecycle-automation.md` for the auto-start/auto-stop gateway lifecycle pattern paired with Kanban notification subscription.
See `references/kanban-telegram-notification-timing.md` for the timing pitfall where short tasks finish before subscriptions/notifier delivery, plus the subscribe-before-dispatch and gateway grace-period verification pattern.
See `references/kanban-telegram-flow-state-notifications.md` for the user's preferred non-spam Telegram model: notify task flow state transitions (`TODO/READY`, `PROCESSING/RUNNING`, `BLOCKED/NEEDS CONFIRMATION`, `DONE`, etc.) while suppressing low-level heartbeat/spawn/log noise.
See `references/kanban-specialist-bot-routing.md` for the specialist-bot routing rule: backend/frontend/tester/dev-ops task notifications must be sent by the corresponding profile bot rather than the default/orchestrator bot.
See `references/codex-app-server-specialist-runtime.md` for the Windows/API-key Codex app-server pattern: resolve npm `codex.cmd` shims before spawning, make `openai-api` eligible for `openai_runtime: codex_app_server`, configure each specialist profile explicitly, and verify with runtime/log smoke tests.
See `references/specialist-model-and-codex-routing.md` when assigning models per đệ: distinguish the specialist brain from the Codex execution/review model, inspect Hermes config + Codex config + app-server request propagation, and verify the effective runtime model before dispatch.

## Verification Checklist

- [ ] User saw and confirmed the kanban plan before side effects.
- [ ] Each specialist has a clear responsibility and deliverable.
- [ ] Skills were selected from the appropriate `skill-<specialist>` manifest.
- [ ] Exact explicit skill names were smoke-tested in the target profile, or the procedure was embedded in the task body instead of passed as fragile `--skill` flags.
- [ ] Dependencies prevent tester/reviewer tasks from running before implementation tasks complete.
- [ ] `review-required` implementation parents with tester/reviewer children were completed with a handoff summary and followed by `hermes kanban dispatch --json`.
- [ ] Blocked tasks were classified correctly: dependency wait, review-required handoff, incomplete work, missing input, or worker crash.
- [ ] Any skill changes were synchronized to default and specialist profile skill trees.
- [ ] Final response reports task IDs, assignees, and how to monitor progress.
