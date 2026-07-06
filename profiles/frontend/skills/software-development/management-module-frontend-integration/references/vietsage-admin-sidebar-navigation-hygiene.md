# VietSage admin sidebar navigation hygiene

Session pattern: SUPER_ADMIN login rendered the dashboard sidebar from backend/RBAC menu entries. Some entries were route templates or inactive menu slugs, which produced noisy navigation and one runtime crash.

## Concrete issue

- Next.js App Router rejects dynamic route templates passed directly to `<Link>`, e.g. `/owner/hotels/[hotelId]/billing`.
- Generic menu slug fallback produced extra admin links such as `/admin/dashboard?tab=<slug>` for backend menu entries that were not real admin pages.
- The active admin pages were the actual page routes: `/admin/dashboard`, `/admin/hotels`, `/admin/users`, and `/admin/roles`.

## Fix pattern

- Normalize menu hrefs before rendering sidebars.
- Reject route templates/placeholders (`[param]`, `{param}`, `:param`) from navigation data unless there is a concrete entity id to substitute.
- Canonicalize legacy aliases such as `/hotel-users` -> `/admin/users`, `/hotels` -> `/admin/hotels`, and admin role/permission tabs -> `/admin/roles`.
- For admin sidebars, allowlist only known active admin page routes instead of converting every unknown backend menu slug into a dashboard tab.
- Provide a compact fallback admin nav with the active routes if the menu API returns no usable entries.

## Verification used

- `pnpm run lint` passed with existing unrelated unused-symbol warnings.
- `pnpm run build` passed, including TypeScript and static page generation.
