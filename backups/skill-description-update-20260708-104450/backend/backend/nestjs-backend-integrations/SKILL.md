---
name: nestjs-backend-integrations
description: Implement external service integrations in NestJS/Prisma backends as asynchronous side effects without breaking core business writes.
category: software-development
---

# NestJS Backend Integrations

Use this skill when adding integrations such as messaging/webhook/notification providers to a NestJS service backed by Prisma.

## Principles

1. Keep the domain write first and authoritative.
   - Persist the business record normally.
   - Dispatch integration work only after the DB transaction commits.
   - Never make user-facing request creation depend on a third-party API call.

2. Model integration state explicitly.
   - Add route/config tables for destination selection.
   - Add delivery tracking tables with provider, destination, external IDs, status, errors, timestamps, and duplicate-prevention constraints.
   - Prefer idempotent upsert for notification records before sending.

3. Do provider calls asynchronously.
   - If a queue exists, use it.
   - If no queue exists, use fire-and-forget with `.catch()` structured logging.
   - Do not log secrets/tokens.

4. Keep callbacks/webhooks narrow and defensive.
   - Verify a secret/signature before doing work.
   - Parse compact callback IDs.
   - Validate legal state transitions before updates.
   - Update state atomically, e.g. `updateMany({ where: { id, status: currentStatus }, data: { status: targetStatus } })`.
   - Treat `count === 0` as already handled by someone else.

5. Preserve existing API/UI scope.
   - Do not refactor unrelated modules while adding the integration.
   - Do not touch frontend flows unless the task asks for it.
   - Keep existing contracts stable unless the domain state enum itself must change.

## Verification

- Run `npx prisma generate` after schema changes.
- Run the backend build.
- Add an ad-hoc focused verification script when the harness asks for one or when no canonical test is detected.
- For callback/button systems, verify the transition matrix and rendered callback payloads directly.
- Clearly label ad-hoc verification as such; do not call it full suite coverage.

## User-Specific Lessons

- This user expects high-energy, direct coding execution: fix failures immediately, rerun verification, and report concrete results.
- If a verification run fails, do not summarize success; repair the failing code and run verification again.
- For temporary verification scripts on Windows, use `tempfile.mkstemp(prefix="hermes-verify-", suffix=".ps1")`, close the file descriptor before running PowerShell, and clean up afterward.

## References

- `references/vietsage-telegram-guestos.md`: session-specific details for the VietSage GuestOS Telegram notification implementation, including the permanent ban on `GuestRequestType` and category-only routing.
