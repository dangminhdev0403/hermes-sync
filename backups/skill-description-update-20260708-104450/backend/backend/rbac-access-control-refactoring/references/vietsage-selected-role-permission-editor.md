# VietSage selected-role permission editor pitfall

When building an admin permission editor that lets a SUPER_ADMIN inspect or edit another role, do not load the permission module catalog from a `me` endpoint and then infer active grants from a separate role-permissions endpoint.

## Failure mode

- Page displayed the selected role (`TENANT_OWNER`) but module data came from `/roles/me/permission-modules` or was otherwise not guaranteed to be for the selected role.
- The grid showed misleading active counts/toggles: some modules appeared `0/N` even though the selected role should have active business permissions, or only legacy route permissions matched the catalog.
- The frontend fetched a module catalog and initial grants from separate sources, then matched only by permission id. If the catalog was for the actor role or the grant list was shaped differently, active state was wrong.

## Durable fix pattern

1. Backend exposes selected-role module endpoints:
   - `GET /roles/:id/permission-modules`
   - `GET /roles/:id/permission-modules/:moduleKey/permissions`
2. Each module permission item includes `permissionId`, `method`, `description`, and `enabled` for that selected role.
3. Frontend loads these selected-role endpoints whenever a `roleId` is present.
4. Frontend initializes draft/active permission IDs from `item.enabled === true`, not from a second endpoint that may not align with the module catalog.
5. Keep `/roles/me/permission-modules` only for current-user/self permission views, not cross-role admin editing.

## Verification pattern

Use a focused ad-hoc verifier when canonical evidence is not detected: create `hermes-verify-*` under the OS temp directory, assert selected-role endpoint strings and frontend `enabled` initialization exist, run frontend lint/build and backend build, then delete the temp script. Report this as ad-hoc verification, not full suite green.
