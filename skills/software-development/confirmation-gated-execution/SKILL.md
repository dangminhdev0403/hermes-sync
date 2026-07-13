---
name: confirmation-gated-execution
description: Use when a normal chat request may execute commands, edit code/files, configure local services, improve work products, fix bugs, or assign specialists/đệ. Enforces a pro-max proposal and explicit user confirmation before side effects.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [workflow, confirmation-gate, planning, execution, coding, specialists]
    related_skills: [plan, kanban-specialist-orchestration, systematic-debugging]
---

# Confirmation-Gated Execution

## Overview

Use this skill for ordinary chat requests that are related to execution: code edits, bug fixes, local setup, configuration changes, workflow improvements, file moves, tool runs with side effects, or assigning specialist/đệ work.

For this user, the default behavior is **proposal before execution**. Do not jump straight into edits or dispatch. First produce an optimized/pro-max plan, list the intended side effects and verification steps, and ask for explicit confirmation. If the user asks follow-up questions, update the proposal instead of executing.

## When to Use

- User asks to fix, improve, refactor, configure, install, run, verify, or change code/work.
- User asks to assign work to đệ/specialists or use Kanban.
- A requested action would create/edit/delete files, start/stop services, install packages, run migrations, dispatch agents, or make external side effects.
- The task is technically clear, but the user has not yet explicitly approved execution.

Do **not** use this skill to delay purely informational answers with no side effects. For simple questions, answer directly.

## Confirmation Gate Workflow

1. **Inspect only what is needed for a good proposal.** Read-only inspection is allowed when it materially improves the plan. Avoid broad scans that feel like execution unless needed.
2. **State the root problem / goal.** Summarize what will be fixed or improved in one paragraph.
3. **Propose the pro-max approach visibly.** Include the recommended path, alternatives if meaningful, and why the recommendation is best. Do not hide the plan behind only a saved file path; show enough of the plan inline for the user to review without asking “plan đâu?”.
4. **List side effects.** Be explicit about files to edit, services to start/stop, commands to run, data that may be touched, and any package/dependency changes. If `package.json` changes are needed for this user’s projects, ask separately before editing it.
5. **List verification.** Include exact tests, smoke checks, or filesystem checks that prove success.
6. **Ask for confirmation.** End with a clear question such as: “Xác nhận cho tôi thực thi plan này không?”
7. **Wait.** If the user asks a question or changes constraints, update the proposal. Execute only after explicit approval such as “ok”, “chấp nhận”, “làm đi”, or equivalent.

## External CLI / Local Agent Installation Proposals

When the user asks to install a third-party CLI, local agent, or binary distribution, inspect enough read-only context to make the proposal concrete before requesting confirmation:

- Read the official README/install instructions, platform-specific installer script, and latest release metadata/assets when available.
- Prefer the host-native installer with built-in checksum/signature verification; on Windows this usually means PowerShell (`install.ps1`) rather than piping a POSIX installer through Git Bash.
- List exact side effects: downloaded asset names, install directory, PATH mutation, config/data directories, shipped playbook/skill directories, and any prerequisites.
- Verification must run real post-install checks such as `--version`, `--help`, and listing shipped assets; avoid launching an interactive session unless the user explicitly wants it.
- For `curl | sh` or `irm | iex` installers, explicitly call out checksum verification behavior and ask for confirmation before execution.
- If an official installer fails because checksum metadata was decoded/parsing incorrectly, do **not** bypass integrity with a skip-checksum flag. Prefer an audited fallback that downloads the same release asset and checksum file, decodes checksum text correctly, matches the exact asset line, verifies the hash, stages the binary, then runs the same post-install smoke checks.

See `references/third-party-cli-agent-installation.md` for a compact checklist and the PentesterFlow installation example.
See `references/pentesterflow-windows-checksum-fallback.md` for the Windows PowerShell `Invoke-WebRequest` byte-array checksum parsing pitfall and safe fallback pattern.

## Document-Driven Repo Updates

When the request is to update repository docs or code from an uploaded Word/PDF/brief:

- Extract/read the source document first; do not ask the user to paste binary document contents.
- Inspect the target repo docs and `git status` read-only before proposing, so the plan accounts for existing terminology and unrelated dirty worktree state.
- If the worktree already has unrelated changes, explicitly scope side effects to the requested paths and say what will **not** be touched.
- Present a file-by-file update plan plus verification checklist before editing unless the user already gave explicit execution approval.
- Keep document-derived terminology aligned across companion docs; avoid updating one architecture doc while leaving contradictory wording in another.

See `references/document-driven-repo-doc-updates.md` for a compact checklist.

## Security Artifact Workspace Proposals

When planning a local security lab/toolchain around existing projects, make the storage model explicit before creating folders:

- Project source code stays in the user's existing repo/workspace path.
- A `SecurityLab` folder, if needed, is an **artifact workspace** for `scope.yaml`, logs, scanner outputs, reports, and findings.
- Prefer workspace-local placement such as `<workspace>/SecurityLab` over a detached root like `C:/SecurityLab` when the user already has a projects workspace.
- Each engagement records `repo_path` or `repo-path.txt` pointing to the real project; do not copy/move source into the lab unless the user explicitly approves an isolated sandbox clone.
- For readiness pilots, use a small local fixture under `SecurityLab/projects/<engagement>/fixtures/` rather than touching a real repo.

See `references/security-artifact-workspace-pattern.md` for the session-derived directory contract and scope template.
See `references/securitylab-wsl-raccoon-ubuntu24.md` for the Windows WSL2 + Ubuntu-24.04 + Raccoon install recipe, including the Docker Desktop `docker-desktop` distro pitfall and Python 3.12 dependency compatibility fixes.
See `references/securitylab-recon-dockerscan-ghidra-stack.md` for the follow-on optional SecurityLab components: recon-skills/PentesterFlow skill-pack loading, DockerScan checksum fallback, local JDK/Maven/Ghidra/GhidraGPT install, no-target smoke checks, and doc/report/SOP updates.
See `references/securitylab-ghidra-gpt-smoke.md` for the Ghidra/GhidraGPT pre-project smoke workflow: distinguish launcher vs plugin folders, avoid Shared Project/Ghidra Server mistakes, create a harmless Java `.class` fixture, run `analyzeHeadless.bat` through a `.cmd` wrapper, and configure OpenAI-compatible proxies such as OmniRoute without exposing secrets.

## After Approval

### Local Dev Server / Port Discipline

When the approved task requires running a frontend/backend/dev server, use the project's configured/default port and command first. Do **not** silently choose an alternate port just to avoid a conflict or timeout. If the default/configured port is busy, unreachable, or fails to start, stop and report the concrete blocker, then ask whether to kill/free the port, use an alternate port, or follow another proposal. This applies especially to screenshot and browser-smoke tasks where the URL/port is part of the evidence.

See `references/local-dev-server-port-policy.md` for the session lesson that introduced this rule.

- Execute only the approved scope.
- Keep changes focused; do not add opportunistic refactors.
- Verify with real tool output.
- Report files changed, commands run, real results, and remaining blockers.
- If execution reveals a materially different risk or scope, pause and ask again.

## Skill Loading Scope Discipline

For normal chat work, load the minimum canonical skill set that covers the task. Do not load duplicate copies of the same class skill from multiple category paths (for example `repomix-explorer`, `repomix-explorer/repomix-explorer`, and `backend/repomix-explorer`) just because several aliases exist. Pick the canonical/global skill unless the task explicitly targets a specialist profile or repository sub-scope that requires the profile-specific copy. If a duplicate or wrong-scope skill is accidentally loaded, acknowledge it and avoid repeating that pattern in the same session.

## Specialist / Đệ Selection Rule

When choosing skills for a specialist/đệ, select from skill names and frontmatter descriptions / selection summaries first. Do not read entire `SKILL.md` bodies merely for selection. Load full skill bodies only after the skill is selected and needed for execution. Do not read specialist/profile skills such as `backend/*`, `frontend/*`, `tester/*`, or `dev-ops/*` during ordinary user tasks unless the user explicitly assigned that specialist/profile or the task is about maintaining that profile's skills.

## Delegated Codex Approval Propagation

When the user has already approved execution and Hermes/đệ delegates the approved scoped task to Codex, do not let Codex re-run the user-facing confirmation gate. The delegated prompt should begin with the required approval context (for repositories that require a literal command, put that literal such as `CHO PHÉP SỬA` on the first line), then state that user/Hermes already approved the scoped task and Codex must not ask again for PLAN MODE / EXECUTE MODE / approval. If Codex is already blocked at the guard, restart it with approval context at the top of the prompt instead of trying to submit approval into a possibly closed PTY.

When project docs contain strict exact-command-only plan-mode rules, make them delegation-aware rather than removing safety entirely: direct user-facing sessions stay guarded; delegated specialist/Kanban/Codex workers may execute only inside a prompt-stated approved scope; destructive DB/deploy/credential/git-history actions still require explicit approval in the delegated prompt.

See `references/delegated-codex-approval-propagation.md` for the concrete pattern and verification search terms.

## Codex App-Server Enforcement

When a specialist profile hands the whole turn to `codex_app_server`, profile `SOUL.md`, memory, and skill text alone may not reliably stop Codex from attempting tools before approval. For profiles that require this hard gate:

- Enable a profile-scoped runtime flag such as `agent.confirmation_gate: true`; do not change the default profile unless requested.
- Prepend a `PLAN_ONLY` directive to unapproved Codex turns: informational requests may be answered directly, but side-effecting requests must not call tools and must end with the exact marker `NEEDS_CONFIRMATION`.
- Recognize approval only when the user replies explicitly after an assistant plan containing `NEEDS_CONFIRMATION`, or when a delegated prompt starts with the established literal `CHO PHÉP SỬA`.
- On resume, replay the original request and approved plan into the Codex input; a fresh native Codex thread may not otherwise know what “ok triển khai” authorizes.
- For the approved turn only, bridge that approval to Codex exec/apply-patch routing so the user is not asked twice. Restore the previous fail-closed routing in `finally` so approval never leaks into later turns.
- Behavioral verification must test both halves: before approval, no tool/file side effect; after approval in the same Hermes session, the exact scoped artifact is created and read back. Do not trust model self-report alone.

## Common Pitfalls

1. **Treating “I can fix it” as approval.** A plan is not authorization. Wait for explicit permission.
2. **Executing while answering follow-up questions.** If the user asks for clarification, update the proposal only.
3. **Hiding side effects.** Say exactly which files, services, or commands will be touched.
4. **Dispatching đệ too early.** Specialist assignment must include task mapping, selected skills, dependencies, acceptance criteria, and confirmation before dispatch.
5. **Over-planning simple information requests.** If there is no side effect, answer directly and concisely.

## Verification Checklist

- [ ] Request involves side effects or execution-related work.
- [ ] Proposal includes optimized approach, side effects, and verification.
- [ ] User explicitly confirmed before execution.
- [ ] Any changed scope triggered a second confirmation.
- [ ] Final report includes real verification output, not just intent.
