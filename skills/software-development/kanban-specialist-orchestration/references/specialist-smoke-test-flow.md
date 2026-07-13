# Specialist Kanban Smoke-Test Flow

Use this reference when validating that backend/frontend/dev-ops/tester profiles can receive and complete Kanban tasks after profile, Telegram, or skill-sync changes.

## Flow

1. **Audit before side effects**
   - Check profiles exist and Kanban board is safe to use.
   - Inspect specialist manifests and compare required skills against each profile's `skills/` tree.
   - Do not create/dispatch tasks until the user confirms the plan.

2. **Backup before synchronization**
   - Back up each specialist profile's `skills/` directory before copying missing skills.
   - Use the active Hermes home/profile path, not hard-coded examples from old manifests.

3. **Sync missing skills**
   - Copy missing class-level skills from the default profile skill tree into the specialist profile's skill tree.
   - Keep `skill-<specialist>` manifests present in the matching specialist profile so workers can self-reference their canonical role and checklist.
   - Patch any stale path examples in manifests after moving to a different Windows user/home directory.

4. **Smoke-test skill loading before Kanban dispatch**
   - Run one-shot profile checks before creating tasks:
     ```bash
     hermes -p backend --skills skill-backend,local-code-quality-gates chat -q "Skill load smoke test. Reply OK backend" -Q
     hermes -p frontend --skills skill-frontend,local-code-quality-gates chat -q "Skill load smoke test. Reply OK frontend" -Q
     hermes -p dev-ops --skills skill-dev-ops,docker-development-workflows,local-code-quality-gates chat -q "Skill load smoke test. Reply OK dev-ops" -Q
     hermes -p tester --skills skill-tester,local-code-quality-gates,sonarqube-scanner-skill chat -q "Skill load smoke test. Reply OK tester" -Q
     ```
   - If a skill alias fails, fix the profile skill tree or use the accepted alias before dispatching.

5. **Use an isolated smoke board**
   - Create a dedicated board such as `kanban-smoke-YYYYMMDD` instead of testing on `default`.
   - Use `scratch` workspaces and task bodies that explicitly forbid file edits, destructive commands, and `package.json` changes.

6. **Dispatch and monitor to completion**
   - Run `hermes kanban dispatch --json` and then poll `hermes kanban stats`, `list --json`, `runs <task>`, and `show <task>` until each task is `done` or `blocked`.
   - Classify blockers by evidence: missing skill, model/API problem, workspace issue, worker crash, or dependency wait.

7. **Restore board context**
   - Switch active board back to `default` after smoke testing so future user commands do not accidentally operate on the smoke board.

## Acceptance criteria for a successful specialist smoke test

- Each specialist task is spawned for the intended profile.
- Each worker confirms its assigned profile and requested/preloaded skills.
- Each task completes with a summary beginning `OK <profile>`.
- No project files are modified.
- No SonarQube scan or other heavyweight review gate runs unless the task explicitly asks for it.
- Final report includes task IDs, statuses, and how to inspect the smoke board later.
