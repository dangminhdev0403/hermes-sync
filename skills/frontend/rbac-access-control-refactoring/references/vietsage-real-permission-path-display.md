# VietSage Permission Editor: Display Real Permission Paths

Session learning: the admin permission editor displayed synthetic paths such as `/permissions/hotels/<permissionId>` for module permission rows. Users reasonably interpreted these as real backend/API permission paths, then could not find them in the permissions table.

## Root Cause

The backend module-permission endpoint returned only:

```json
{
  "permissionId": "cmpx3bqxz0005p4ui4vxq0uxp",
  "method": "GET",
  "description": "Liệt kê các khách sạn mà nhân sự được phép truy cập",
  "enabled": true
}
```

The frontend filled the missing path with a synthetic display value:

```ts
path: `/permissions/${moduleKey}/${permissionId}`
```

That looked like a real API path but was not stored in the `Permission.path` column.

## Fix Pattern

Prefer making the backend response carry the real permission path:

```json
{
  "permissionId": "cmpx3bqxz0005p4ui4vxq0uxp",
  "method": "GET",
  "path": "/hotels",
  "description": "Liệt kê các khách sạn mà nhân sự được phép truy cập",
  "enabled": true
}
```

Implementation checklist:

1. Add `path: true` to the repository select for module permissions.
2. Add `path: row.path` to the service DTO mapper and include `path: string` in the DTO type.
3. Update OpenAPI/schema contracts to require `path` for module permission items.
4. Update the frontend mapper to use `item.path`; only fall back to `permissionId` for old responses.
5. Verify with the live endpoint, e.g. `GET /roles/:roleId/permission-modules/hotels/permissions?page=1&limit=100`, and assert returned paths start with real route paths such as `/hotels`, not `/permissions/`.

## UX Rule

Never show synthetic identifiers in a field styled like an API route/path. If the value is only an id, label it as an id; if the UI says/shows path, it must be the real backend `Permission.path` value.
