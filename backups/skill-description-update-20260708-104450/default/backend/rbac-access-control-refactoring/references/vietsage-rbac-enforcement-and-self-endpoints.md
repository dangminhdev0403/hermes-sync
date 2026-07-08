# VietSage RBAC enforcement and authenticated self endpoints

Session learning from debugging inconsistent RBAC behavior in a NestJS/Prisma auth service.

## Symptom

RBAC appeared to block permissions sometimes and allow them other times. Tenant-owner account behavior was inconsistent across endpoints such as `/roles`, `/hotels`, `/roles/menus`, and `/auth/me`.

## Root causes

- `AUTHZ_ENFORCEMENT_ENABLED=false` and `AUTHZ_STRICT_MODE=false` made missing permissions fail open.
- Authenticated self-service endpoints were protected by ordinary RBAC checks:
  - `GET /auth/me`
  - `GET /roles/menus`
- Tenant-owner role data had drifted to zero permissions, so once fail-closed RBAC was enabled it was correctly blocked from hotel operations until the role grants were restored.

## Fix pattern

1. Make RBAC fail closed by default in config code and local env for the environment under test:
   - `AUTHZ_ENFORCEMENT_ENABLED=true`
   - `AUTHZ_STRICT_MODE=true`
2. Add a dedicated `@SkipAuthorization()` metadata decorator that bypasses only the authorization guard, not JWT authentication.
3. In `AuthorizationGuard`, check `SKIP_AUTHORIZATION_KEY` after public-route bypass and before route/business permission checks.
4. Apply `@SkipAuthorization()` to authenticated self-service endpoints that any logged-in user needs for session bootstrap/navigation:
   - `GET /auth/me`
   - `GET /roles/menus`
5. Restore role data separately from code changes. For test accounts, verify the role actually has the permissions expected by the test scenario.

## Verification matrix

Use both high-privilege and lower-privilege accounts. Example expected results after the fix:

| Account | `/auth/me` | `/roles/menus` | `/roles` | `/hotels` | `/tenant-owners` |
| --- | ---: | ---: | ---: | ---: | ---: |
| `admin@vietsage.vn` | 200 | 200 | 200 | 200 | 200 |
| `tenant@vietsage.vn` | 200 | 200 | 403 | 200 | 403 |

This matrix catches both false positives (tenant can access admin endpoints) and false negatives (tenant cannot bootstrap session menus or access allowed hotel operations).

## Pitfalls

- Do not make self-service endpoints public unless they should work without JWT. `@SkipAuthorization()` should still require authentication via the JWT guard.
- Do not diagnose RBAC only from frontend symptoms. Check backend config, guard order, route permission resolution, and actual role-permission rows.
- Do not confuse a code fix with data repair: if a role has zero permissions, strict RBAC will correctly block it.
- Report ad-hoc runtime verification separately from full test-suite success.
