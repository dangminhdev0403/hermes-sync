# VietSage Service Catalog Google Sheets Sync

Session learning from replacing owner Service Catalog Excel import with Google Sheets synchronization.

## Durable Implementation Pattern

- Prefer backend-owned synchronization for Google Sheets sources of truth. Do not keep parsing/orchestration in a Next.js internal route when the source is no longer an uploaded browser file.
- Use `googleapis` with `GoogleAuth` and the readonly Sheets scope. Read credentials and spreadsheet id from `GOOGLE_APPLICATION_CREDENTIALS` and `GOOGLE_SHEET_ID`; validate presence at sync time, not by hardcoding defaults.
- Convert Sheets value ranges into the existing import workbook abstraction when one exists, then reuse the existing import adapter/service so validation, normalization, diff, upsert, transaction, and rollback behavior stay identical.
- Add a narrow backend endpoint such as `POST /hotels/:hotelId/service-catalog/sync` plus a Next.js internal proxy route. The UI should call the proxy, not Google directly.
- Preserve business keys (`category_key`, `item_key`) and never delete missing rows automatically; report unchanged rows as skipped.

## Scheduler Pattern

- Register `ScheduleModule.forRoot()` once in the Nest app module before using `@Cron`.
- For automatic sync every 5 minutes, guard with an in-memory `isSyncing` flag or stronger distributed lock if multiple app replicas are possible.
- If the same import adapter enforces user hotel access, add an explicit system-sync context path rather than faking a real user id. Manual sync should still authorize the requesting user.

## Frontend Replacement Pattern

- Replace file picker state, `FormData`, and upload button with a single explicit action button such as `Đồng bộ Google Sheets`.
- Show a confirmation dialog, loading state, and summary counts: categories processed, items processed, inserted, updated, skipped, duration, and errors.
- After success, refetch local list state and then call `router.refresh()`; do not rely on `router.refresh()` alone for client-state tables.

## Validation Pitfalls

- Removing a Next.js app route can leave stale `.next` generated route validator references. If `next build` fails with a missing deleted route under `.next/.../validator.ts`, remove `.next` and rerun the build before treating it as a code issue.
- When deleting an upload/import workflow, remove the internal API route, upload UI, parser dependency (for example `xlsx`), and any orphaned parser files together; then search for `Excel`, `xlsx`, and the old route path.
