---
name: management-module-frontend-integration
description: Implement management/admin module frontend integrations for CRUD lists, synchronization actions, and file imports against existing backend/internal API layers.
---

# Management Module Frontend Integration

Use this skill when adding or wiring a management module in an existing web app: owner/admin/staff CRUD pages, service catalogs, room/user management, synchronization actions, bulk imports, or internal API proxy routes.

## Workflow

1. Inspect the existing module route, client component, service layer, and internal API route patterns before adding new code.
2. Identify whether the backend already exposes a domain endpoint. If it does not, prefer a narrow internal frontend API route that composes existing backend service methods rather than inventing a mismatched backend contract.
3. Preserve existing UI language, modal/alert patterns, table components, pagination, and error mapping.
4. For synchronization actions, make the action explicit in the UI: selected file/source, confirmation dialog, loading state, success counts, and refresh behavior.
5. Validate both the internal route payload and the UI path with TypeScript and lint/build checks.

## File Import / External Sync Pattern

- Use `FormData` + `fetch` from client components for file uploads. Do not route multipart upload through generic JSON HTTP helpers that always set `Content-Type: application/json`.
- Put parsing and orchestration in a Next.js internal API route only when the backend has no domain import/sync endpoint and only exposes granular CRUD APIs.
- When replacing uploads with an external source of truth such as Google Sheets, move orchestration to the backend domain module. Keep the Next.js internal route as a thin authenticated proxy, and remove the upload UI, upload endpoint, parser dependency, and orphaned parser files together.
- Reuse existing import adapter/service abstractions when available by converting the external source into the same parsed workbook/payload shape. This preserves required-column validation, normalization, diffing, upsert behavior, single Prisma transaction, and rollback semantics.
- When a catalog already has first-class categories, do not preserve or expand redundant request-type enums for import/sync. Remove enum fields from the sheet template, parser, validators, DTOs, Prisma selects/upserts, OpenAPI/contracts, frontend forms, filters, and display snippets as one refactor; derive classification from `GuestRequest -> serviceItem -> category` instead.
- Validate workbook/source structure early and return user-facing validation messages.
- Match incoming rows to existing records by a stable key when available; if the public API does not expose import keys, fall back to a documented domain match such as normalized name + parent id.
- Return summary counts such as created/updated/skipped or inserted/updated/skipped plus duration/errors so the UI can show a trustworthy result.
- Refresh server data after success; do not assume optimistic state is complete after a bulk import/sync.
- If a client component copied server props into local `useState` (for sorting, pagination, editing, etc.), `router.refresh()` alone may not update the visible table. After a successful import/sync, explicitly refetch the relevant internal list endpoints and replace local state, then call `router.refresh()` to keep server-rendered data/cache aligned. If the import/sync API can cheaply return fresh rows, prefer returning them in the success payload and updating local state directly before showing the success modal.

## Scheduled External Sync Pattern

- For NestJS cron jobs, register `ScheduleModule.forRoot()` once before adding `@Cron` handlers.
- Prevent concurrent syncs with an in-process guard for single-instance apps; note when a distributed lock is needed for multi-replica deployments.
- Manual sync should authorize the requesting user. Automatic sync should use an explicit system-sync context path in shared import adapters rather than pretending to be a real user id.
- Log structured lifecycle events: started, validation, upsert, summary, errors, and duration.

## Excel Catalog Convention

For service catalog imports, support a two-sheet workbook when present:

- `categories`: `category_key`, `name_vi`, `description_vi`, `default_price`, `currency`, `sort_order`, `status`. Do not include `request_type` when the category itself is the business classification.
- `items`: `item_key`, `category_key`, `name_vi`, `description_vi`, `price_override`, `quantity_enabled`, `min_quantity`, `max_quantity`, `sort_order`, `status`.
- Multilingual service catalogs may also include translation columns per supported locale, e.g. `name_en`/`description_en`, `name_zh`/`description_zh`, `name_ko`/`description_ko`, `name_ru`/`description_ru`, `name_hi`/`description_hi`. Treat `name_vi`/`description_vi` as the base Vietnamese fields and pass other locales through the domain `translations` payload so translation tables are populated.

Keep header normalization tolerant of spaces/case. Treat `ACTIVE` and `DISABLED` as the management status values unless the project has a different enum.

## QR / Token Lifecycle Controls

- Treat QR/token creation, activation, deactivation, rotation, and check-in/usage as separate domain operations unless the product explicitly defines them as one transaction. If a user flags that creating a QR during check-in feels wrong, move QR generation to the room/token management surface and make check-in require or reuse an existing QR.
- Management UIs for QR/token inventory should include per-row activate/deactivate controls plus clearly labeled bulk actions such as activate all, export all, and rotate all. Bulk activation may need to create missing inactive tokens first; rotation should remain a separate destructive action because old printed codes stop working.
- Backend activation should be idempotent where possible: find the latest non-revoked token, create one if missing, deactivate other active tokens for the same entity, then mark the chosen token active. Keep guest/runtime access checks separate so a pre-created active QR can still be denied until there is an eligible active stay/session.
- When a client action endpoint returns a token object but the table stores room rows, do not rely only on optimistic replacement by `updated.id`; refetch the room list after QR actions so local state reflects nested QR fields.

## Realtime Request Queues

- If a management queue has both a normal table and a special alert/urgent panel, keep the table as the durable operational/history surface and treat the alert panel as a transient triage surface.
- Wire existing realtime hooks into the queue client when available; do not leave state overlays unused. Merge realtime changes over server-provided rows by id so status changes are visible immediately, then use `router.refresh()` for server/cache alignment.
- Use one predicate for alert-panel membership, e.g. `priority === "URGENT" && !isFinalRequestStatus(status)`. Resolved/final requests should disappear from urgent panels but remain in the normal table/history when they match filters.
- If domain lifecycle metadata changes triage semantics (for example a guest stay has `checkedOutAt` or `stayStatus === "CHECKED_OUT"`), include that metadata in backend list responses and extend the alert predicate to exclude those records from transient urgent panels while keeping them visible/badged in the durable table.
- Reuse the same realtime merge helper after local status/assignment mutations so local actions and socket events produce the same UI state.

## Navigation Hygiene

- For admin/management sidebars driven by backend RBAC/menu entries, normalize and canonicalize hrefs before rendering. Backend menus can include legacy aliases, inactive capabilities, or route templates that should not become visible links.
- Never pass route templates like `/owner/hotels/[hotelId]/billing`, `{id}` placeholders, or `:id` placeholders directly to Next.js App Router `<Link>`; filter them out or substitute concrete ids first.
- Prefer an explicit allowlist of active management page routes when the user asks to remove unnecessary navigation. Unknown menu slugs should not be converted into generic dashboard tabs unless those tabs actually exist.
- Keep a compact fallback sidebar for the active routes so a failed/empty menu API does not leave management pages without navigation.

## Optional Notification Routing Fields

- When a backend adds an optional per-category notification-routing field (for example `id_group` for a Telegram group), wire it through every management layer as optional: domain contract type, create/update input types, backend DTO/schema validation, strict internal API validators, form state, edit prefill, table display, and save payload.
- Preserve optional semantics in the UI: label it clearly as optional, send `null` when the field is blank, and explain that it is only needed when that service group should notify a dedicated external group/channel.
- Do not assume the new field is a physical column on the category table. If the backend stores routing separately (for example `NotificationRoute.telegramChatId` keyed by `serviceCategoryId`), either make the backend category endpoint translate `id_group` to that routing table or have the frontend call a dedicated routing endpoint; then return `id_group` in list/update responses for edit prefill.
- After adding a strict-field payload, check live backend logs for `Unrecognized key`/400 validation errors and PATCH the backend schema/service, not only the frontend proxy schema. Verify with an authenticated API request using both a filled value and `null` when the field is optional.
- If older/admin and newer/owner service catalog clients coexist, update both or verify which one is active; otherwise one management surface silently drops the new field.
- When the user provides test credentials and asks for screenshots, attempt a real login after local build/lint. Start/verify every local dependency needed for that login, especially the backend Nest API health endpoint, before deciding credentials failed. If auth fails because the backend/API is not reachable, capture the failed-login screenshot and name the concrete blocker instead of fabricating logged-in UI evidence.

## Pitfalls

- Do not add upload support only in the UI; verify the internal route can receive multipart data.
- Do not use a JSON-only API client for `FormData` unless it explicitly preserves multipart headers.
- When adding a Details click in an existing management modal, confirm the backend detail endpoint returns the nested fields the UI will display. Existing endpoints often include only minimal names/ids; extend the domain include/select before wiring the click.
- For multilingual management support, do not stop at backend `translations` payload/model wiring. Add visible inputs or controls for each supported locale directly in the current create/edit form or modal, prefill them from existing translations, include them in save payloads, and update any strict internal API validators to accept them.
- Prefer compact locale switcher controls (language chips/tabs) over rendering every language's full name/description fields at once in already-large modals; users should be able to click a language and edit that locale's text in-place.
- Be defensive about translation payload shape. Backends may return translations as an array (`[{ locale, name, description }]`) or as an object (`{ en: { name, description } }`); normalize both before iterating to avoid `(translations ?? []) is not iterable` runtime crashes.
- Escape DB-provided values before interpolating them into modal `html` strings (for example SweetAlert `html`).
- Do not claim full-repo cleanliness when lint reports unrelated pre-existing warnings; state changed-file status separately.
- When endpoint or `.env` issues are discovered, leave a short, practical inline/config comment near the related code or example env value with the suggested fix (for example LAN IP instead of `localhost` for phone QR/socket testing) rather than only explaining it in chat.
- Be careful with existing dirty worktrees. Summarize only files you touched and note unrelated modifications if visible.

## Verification

- Run `pnpm exec tsc --noEmit` or the project equivalent for TypeScript projects.
- Run lint. If unrelated warnings remain, report them with file paths.
- For import routes, test at least static type coverage and schema validation paths; add runtime fixtures only if the project already has a test harness for that module.

## References

- `references/vietsage-admin-sidebar-navigation-hygiene.md` records filtering/canonicalization rules for RBAC-driven admin sidebars and Next.js dynamic route template crashes.
- `references/vietsage-service-catalog-excel-import.md` records a concrete Next.js owner service-catalog Excel upload implementation.
- `references/vietsage-service-catalog-google-sheets-sync.md` records the backend-owned Google Sheets replacement pattern, Nest scheduler guard, UI summary, and stale `.next` route-validator pitfall.
- `references/vietsage-service-catalog-requesttype-removal.md` records the category-as-classification refactor: remove redundant request-type enum handling from sheet sync, import adapters, DTOs, Prisma, contracts, and frontend displays.
- `references/vietsage-service-catalog-multilingual-forms.md` records how to expose five service catalog language options in owner create/edit modals and strict internal API validators.
- `references/vietsage-service-category-telegram-group.md` records the optional `id_group`/Telegram group field pattern for owner service category forms, tables, contracts, and strict internal API validators.
- `references/vietsage-owner-service-catalog-refresh-after-import.md` records the local-state refresh pattern needed after owner Excel imports when `router.refresh()` alone leaves stale tables.
- `references/vietsage-owner-request-realtime-and-urgent-panel.md` records the realtime merge pattern for owner request queues with urgent panels.
- `references/vietsage-owner-request-service-details.md` records a concrete owner request Details-box implementation for nested service item/category data.
- `references/vietsage-owner-room-qr-lifecycle.md` records the owner room QR lifecycle split: pre-provision/activate/export/rotate in room management, while check-in reuses existing QR.
