# Kanban Specialist Confirmation Reply Bridge

## Lesson

For this user's Kanban/đệ workflows, Telegram flow-state notifications are not enough by themselves. When a specialist bot sends a `BLOCKED / NEEDS CONFIRMATION` message, a human reply such as `A` or `B: ...` in that specialist bot chat must be interpreted as a Kanban decision for the referenced `Board:` and `Task:` — not as a normal free-form chat message.

Failure mode observed: the user replied `A` in the `Đệ Backend` Telegram chat after a Kanban handoff message. The backend profile gateway treated `A` as ordinary chat and answered with a clarification request. The missing piece was a bridge from specialist-bot replies back into blocked Kanban tasks.

## Accepted flow

1. Parent specialist task runs and completes a handoff.
2. Child specialist task is created for the next profile.
3. Child task is immediately blocked with `--kind needs_input`.
4. Flow-state watcher sends `TODO/READY` and `BLOCKED / NEEDS CONFIRMATION` via the **child specialist's own bot/profile**.
5. User replies in that bot chat:
   - `A` / `A: detail` = accept and continue.
   - `B` / `B: detail` = choose another direction; keep blocked and record the alternative.
6. Confirmation reply bridge maps the user reply to the latest blocked message in the same specialist profile session that contains `Board:` and `Task:`.
7. For `A`, bridge comments the decision, unblocks the task, and triggers flow-state notification; auto-maintain/dispatch can then continue.
8. For `B`, bridge comments the alternative and leaves the task blocked for the orchestrator/user to revise.

## Implementation pattern

A small script can poll specialist profile `state.db` files:

- Profiles: `backend`, `frontend`, `tester`, `dev-ops`.
- Read recent `messages` rows for each profile.
- Track the latest assistant message in a session containing both:
  - `BLOCKED / NEEDS CONFIRMATION` or `blocked/needs_confirmation`
  - `Board: <board>`
  - `Task: <task_id>`
- If a later user message in the same session matches `A`, `A: ...`, `B`, or `B: ...`, apply it once using a `(profile, message_id)` cursor state.

For `A`:

```bash
hermes kanban --board "$BOARD" comment "$TASK" "USER_DECISION_FROM_<PROFILE>: A — <detail>"
hermes kanban --board "$BOARD" unblock "$TASK" --reason "User replied A in <profile> bot: <detail>"
python "$HERMES_HOME/scripts/kanban-telegram-state-watch.py"
```

For `B`:

```bash
hermes kanban --board "$BOARD" comment "$TASK" "USER_DECISION_FROM_<PROFILE>: B — <detail>. Task remains blocked until updated."
```

Run this as a quiet no-agent cron watchdog. Empty stdout means no-op/success; output should be reserved for errors or explicit manual `--json`/`--verbose` inspection so the default bot does not mirror specialist decisions.

## Message format requirement

Blocked confirmation messages sent by specialist bots must include parseable `Board:` and `Task:` lines. Avoid asking the user to reply to a vague handoff message that lacks task identity.

Recommended footer:

```text
Reply in this bot chat:
A = continue / unblock this Kanban task
B: <direction> = keep blocked and record another direction
```

## Verification checklist

- [ ] Direct `hermes -p <profile> send --to telegram:<target> ...` succeeds for each specialist bot.
- [ ] `TODO/READY` and `BLOCKED / NEEDS CONFIRMATION` messages are sent by the task assignee's own profile bot, not the default bot.
- [ ] User reply `A` in the same specialist chat creates a `USER_DECISION_FROM_<PROFILE>` comment and unblocks the referenced task.
- [ ] User reply `B: ...` creates a decision comment and leaves the task blocked.
- [ ] The specialist worker sees the decision in Kanban comments when dispatched.
- [ ] No low-level heartbeat/spawn/log/comment spam is sent to Telegram.
