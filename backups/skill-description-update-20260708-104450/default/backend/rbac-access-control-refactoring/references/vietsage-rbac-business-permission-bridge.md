# VietSage RBAC Business Permission Bridge

Session learning from refactoring `services/auth-service` RBAC without a Prisma migration.

## Problem

The app used route-level permissions generated from controller routes (`method + path`) and exposed those low-level API permissions in admin UI. This made permission management complex and created fail-open risk when route sync/descriptions were missing and strict mode was disabled.

## Bridge Implementation

- Added a business permission registry at `src/common/config/business-permissions.registry.ts` with stable keys such as `platform.roles.manage`, `platform.permissions.manage`, `hotel.rooms.qr.manage`, labels, descriptions, domain/module grouping, risk level, and optional menu paths.
- Added `@RequirePermission(...)` metadata via `src/shared/decorators/require-permission.decorator.ts`.
- Updated `AuthorizationGuard` to check explicit business permission metadata first, then fall back to legacy route permission keys.
- Added `AuthorizationService.checkUserBusinessPermission` and repository lookup through active user roles where `Permission.path === permissionKey`.
- Seeded registry permissions during route permission sync using existing `Permission` rows with sentinel method `OPTIONS`; this avoids an immediate DB migration while making keys grantable via existing role-permission tables.
- Updated role-to-menu derivation to prefer registry `menuPath` when a permission path is actually a business key.
- Decorated high-risk RBAC endpoints with `platform.roles.view`, `platform.roles.manage`, and `platform.permissions.manage` first.

## Verification Pattern

When canonical test detection is unavailable, create a temporary script under `C:\Users\ADMIN\AppData\Local\Temp` using Python `tempfile.mkstemp(prefix='hermes-verify-', suffix='.py')`. The script can run focused commands such as:

```text
npm run build
npm test -- authorization.guard.spec.ts rbac.service.spec.ts --runInBand
```

Clean up the script after running and report the result as ad-hoc verification rather than full suite green.

## Follow-up Refactor Targets

- Add explicit `@RequirePermission` coverage to all protected controllers.
- Add tests for explicit business permission allow/deny paths.
- Replace the sentinel `OPTIONS + path=permissionKey` bridge with a first-class `Permission.key` schema migration.
- Collapse low-level grant/revoke/module APIs behind a simpler access-model endpoint for the frontend.
- Convert built-in roles into protected templates and only allow cloning/custom roles for normal admins.
