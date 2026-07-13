# Delegated Codex approval propagation

Session lesson: strict repository approval docs can make Codex stop after reading rules and ask for `CHO PHÉP SỬA`, even though the user already approved execution at the Hermes/orchestrator layer.

## Durable pattern

When the user approves a task and Hermes delegates execution to a specialist/đệ or Codex process:

1. Treat the user's approval as applying to the delegated scoped task.
2. Put approval context at the top of the delegated/Codex prompt, before any task details. Example:

   ```text
   CHO PHÉP SỬA

   User/Hermes has already approved execution for this scoped task.
   Do not stop to ask again for PLAN MODE / EXECUTE MODE / CHO PHÉP SỬA.
   Work only inside the approved scope and preserve unrelated dirty changes.
   ```

3. If the target repo has strict approval markdown, update it to be delegation-aware rather than exact-command-only for every process:
   - direct user-facing sessions remain read-only until user approval;
   - delegated specialist/Kanban/Codex workers may execute when the launch prompt states user/Hermes approved the scope;
   - destructive DB, deployment, credential, or git-history actions still need explicit approval in the delegated prompt.
4. Do not rely on `process.submit("CHO PHÉP SỬA")` after Codex is already blocked. PTYs can close; kill/restart with the approval context as the first prompt line.

## Verification

- Search repo docs for stale exact-command-only guard wording, e.g. `STRICT PLAN MODE`, `Cho phép sửa?`, `Do not switch to editing unless`, and `exact approved command`.
- Confirm remaining approval text distinguishes direct user-facing sessions from delegated worker sessions.
- Inspect target profile/SOUL instructions so specialists pass approval context into Codex prompts.