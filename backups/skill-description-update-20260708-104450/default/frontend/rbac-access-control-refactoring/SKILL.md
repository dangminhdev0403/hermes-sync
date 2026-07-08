---
name: rbac-access-control-refactoring
description: Refactor role/permission systems from route-level RBAC toward business capability permissions with safer backend guards and simpler admin UIs.
---

# RBAC Access Control Refactoring

Use this skill when reviewing, simplifying, or upgrading authorization systems for admin/owner/staff apps: RBAC modules, permission catalogs, route guards, role management APIs, and permission editor UIs.

## Goals

- Prefer business capability permissions over raw HTTP method/path permissions.
- Keep authorization fail-closed in production.
- Make the admin UI understandable to operators, not only developers.
- Separate route authorization from tenant/resource ownership checks.
- Preserve compatibility during migration when replacing route-level permission tables is too risky for one pass.

## Workflow

1. Map the current authorization flow end to end: token payload, guards, permission lookup query, role-permission tables, route sync, resource-scope services, frontend internal proxy routes, and admin role UI.
2. Before editing more code, respect operator-mode requests such as “stop editing + no code”; switch to explanation/diagnosis only until the user explicitly asks for implementation again.
3. Identify whether permissions are route-level (`GET /x/:id`) or business-level (`hotel.rooms.manage`). If route-level permissions exist, treat them as a compatibility layer or developer audit tool, not the long-term admin-facing model.
4. Introduce a canonical permission registry with stable keys, labels, descriptions, domain/module grouping, risk level, and optional `menuPath` mapping.
5. Add explicit route metadata such as `@RequirePermission("hotel.rooms.manage")` and update guards to prefer explicit business permissions before falling back to legacy route permissions.
6. Seed business permissions during bootstrap/sync so existing role-permission tables can grant them without an immediate database migration.
7. Apply explicit permission decorators first to high-risk RBAC/admin endpoints (`roles.manage`, `permissions.manage`, user management, billing, QR/token management), then expand to the rest of the API.
8. Keep resource-scope checks separate: RBAC says the actor may perform the action class; tenant/hotel access services must still prove the actor may touch the specific resource.
9. Simplify frontend permission management around grouped capabilities and templates. Hide raw HTTP method/path rows in an advanced/developer audit view.

## Bridge Pattern Without a Migration

When the schema only has route-style `Permission(method, path, description, moduleKey)` rows and a migration is too risky:

- Store business permission keys in `Permission.path` and use a sentinel method such as `OPTIONS`.
- Add repository methods like `countUserWithBusinessPermission(userId, permissionKey)` that check `permission.path === permissionKey` through active roles.
- Seed registry entries with `upsertBusinessPermission({ key, description, moduleKey, moduleId })`.
- Update menu derivation to prefer registry `menuPath` for business permission keys and fall back to legacy route-to-menu mapping.
- Document this as a compatibility bridge; plan a later migration to a first-class `Permission.key` column.

## Security Pitfalls

- Do not let missing permission rows allow access in production. Strict/fail-closed mode should deny unresolved or missing permissions.
- Do not rely on route sync alone. Routes without descriptions/decorators can be skipped and become accidental allow/deny depending on strict mode.
- Do not expose full role-permission replacement to non-super-admins unless it checks that the actor can grant every requested permission and revoke every removed permission.
- Treat built-in roles as protected templates. Prefer cloning templates over editing `SUPER_ADMIN`, owner, or tenant roles directly.
- Bootstrap super-admin accounts must be repairable, not create-only: if configured admin email already exists, update password hash, status, user type, and active role assignment so stale credentials do not lock out the highest-privilege account.
- After seeding a business-permission bridge, ensure `SUPER_ADMIN` receives newly seeded business permissions as well as legacy route permissions; otherwise explicit `@RequirePermission(...)` guards can lock out the admin UI.
- Avoid deleting roles that may have audit/history significance; prefer disable/soft-delete unless the domain explicitly supports hard delete.
- Audit permission mutations with actor id, role id, before/after diff, timestamp, and reason when possible.

## Frontend Guidance

- Show capability groups such as Platform, Users, Hotel Operations, Rooms/QR, Stays, Requests, Billing, Services, GuestOS, and System.
- Use labels like “Manage room QR” or “Finalize checkout,” not `POST /hotels/:id/rooms/:roomId/qr/rotate`.
- When bridging from route permissions, treat sentinel business permissions (for example `method === "OPTIONS"` and `path === businessKey`) as first-class feature toggles; hide method/path detail for those rows and only show it for legacy route permissions in a smaller developer/audit line.
- Never show synthetic identifiers in a field styled as an API path. For module permission rows, have the backend return the real `Permission.path` and display that; do not invent `/permissions/{moduleKey}/{permissionId}` because users will look for it in the permissions table.
- Add stable frontend module metadata (label, icon, visual tone) keyed by business `moduleKey`, and show per-module enabled counts like `2/5 quyền đang bật`.
- Remove temporary debug output (`console.debug`, ad-hoc trace labels) before final verification.
- Provide role templates: Super Admin, Platform Operator, Tenant Owner, Hotel Owner, Front Desk, Housekeeping, Service Staff, Billing Staff.
- Use a single access-model endpoint when possible: roles, templates, permission catalog, current grants, and menu metadata.
- For cross-role permission editors, load module summaries/items for the selected role, not `me`; initialize toggles from the module item `enabled` flag so counts and active state share one source of truth.
- Keep endpoint/method matrices only as an advanced audit panel.

## Verification And Cleanup

- Build the backend after changing guards, decorators, repositories, or bootstrap sync.
- Run focused authorization/RBAC tests covering: public bypass, enforcement disabled, insufficient permission denial, missing permission behavior, explicit business permission allow/deny, and protected role mutation.
- Run frontend lint/build after permission-editor UI changes; warnings in unrelated files should be reported as unrelated, not silently fixed unless requested.
- In dirty worktrees, inspect status first and only remove code/files clearly created by the RBAC work (debug logs, temp verification scripts, one-off traces). Do not delete unrelated migrations, docs, `.vscode`, or broad untracked feature folders without explicit confirmation.
- If canonical commands are not detected in the environment, create an ad-hoc temp verification script under the OS temp directory with a `hermes-verify-` prefix, run focused build/tests, and remove it afterward. Report it explicitly as ad-hoc verification, not full suite green.

## References

- `references/vietsage-rbac-business-permission-bridge.md` records a concrete NestJS/Prisma bridge from route permissions to business capability permissions without a DB migration.
- `references/vietsage-selected-role-permission-editor.md` records the selected-role permission editor pitfall: do not use `/roles/me` catalogs for editing another role; derive active state from selected-role module item `enabled` flags.
- `references/vietsage-real-permission-path-display.md` records the UI pitfall of synthetic `/permissions/{module}/{id}` display paths and the backend/API fix to return real `Permission.path` values.
- `references/vietsage-rbac-enforcement-and-self-endpoints.md` records the fail-open strict-mode pitfall, authenticated self-endpoint bypass pattern, and two-account RBAC verification matrix.
