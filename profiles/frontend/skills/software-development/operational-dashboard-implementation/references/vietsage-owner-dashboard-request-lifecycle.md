# VietSage owner dashboard request lifecycle pitfall

A session found two coupled defects in the owner operational dashboard:

1. Urgent and normal guest requests still appeared in dashboard counts/attention after the guest stay had checked out.
2. `Xử lý ngay` / `Xem chi tiết` dashboard actions linked to `/owner/hotels/:hotelId/requests/:requestId`, but that owner detail page did not exist, causing a 404.

Reusable fix pattern:

- Add a reusable Prisma request filter for operational queues, e.g. `stay: { is: { status: { in: [CHECKED_IN, ACTIVE] }, checkedOutAt: null } }`.
- Apply it consistently to dashboard request group/count queries, urgent/unprocessed counts, attention request lists, request queue lists, and request summaries.
- Be deliberate about historical/reporting sections; only exclude checked-out stays from operational views unless product wants historical analytics.
- For each attention item `action.route`, check the user-surface route exists. Owner, staff, and admin paths may share backend APIs but not frontend pages.
- If a detail route is missing, either point to an existing queue route or add a thin surface-specific page that reuses the common detail client inside the correct shell/navigation.

Focused verification pattern used:

- Backend build and frontend build where available.
- When the harness asks for behavior-specific evidence, create a temporary script with a safe `tempfile.mkstemp(prefix="hermes-verify-", dir=<OS temp dir>)`, assert the source contains the active lifecycle filter and route page, run it, then clean it up. Report it as ad-hoc verification, not full suite green.
