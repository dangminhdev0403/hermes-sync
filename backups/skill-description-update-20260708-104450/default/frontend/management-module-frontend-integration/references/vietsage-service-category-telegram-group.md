# VietSage Service Category Telegram Group Field

Session pattern: backend added optional `id_group` on service categories for Telegram integration. Frontend must not treat Telegram routing as required; it is only filled when an owner wants requests for that service group to notify a dedicated group/channel.

## Implementation checklist

- Add `id_group?: string | null` to `HotelServiceCategory`, `CreateServiceCategoryInput`, and `UpdateServiceCategoryInput`.
- Update strict Next.js internal owner API route schemas for service category create/update to allow `id_group: string | null`.
- Add `id_group` to category form state and edit prefill.
- Add a form field labelled as optional, e.g. `ID group Telegram (tùy chọn)`, with helper copy explaining it is only needed for a dedicated Telegram group.
- Save `id_group: categoryForm.id_group.trim() || null` so blank values clear/omit routing.
- Display a compact Telegram column/badge in the category table so owners can see whether routing is configured.
- If both legacy admin catalog and owner catalog clients exist, update both or confirm the inactive one can be ignored.

## Backend-routing lesson

Do not stop at the frontend proxy/schema. In this project the live backend rejected the payload with:

```text
PATCH /hotels/.../service-categories/...
Status: 400
Message: input: Unrecognized key: "id_group"
```

Fix pattern:

- Add `id_group: z.string().trim().min(1).max(128).nullable().optional()` to backend create/update service category schemas.
- If `id_group` is not a physical `HotelServiceCategory` column, translate it to the existing routing model. For VietSage this means syncing `NotificationRoute.telegramChatId` for `{ hotelId, serviceCategoryId, isActive: true }`.
- On blank/null `id_group`, disable active routes for that service category instead of treating it as invalid.
- On nonblank `id_group`, update the active route if one exists; otherwise create a new active route.
- When listing service categories, return `id_group` by reading the active notification route so edit forms can prefill the optional value.

## Verification pattern

- Run frontend lint/build after UI/proxy changes.
- Run backend build after backend schema/service/repository changes.
- Use live credentials when available to verify the actual API path, not just static code tokens.
- Test both optional cases:
  - `PATCH .../service-categories/:id` with `{ "id_group": null }` returns `200 OK` and `data.id_group === null`.
  - If safe to mutate, test a nonblank value such as `-1001234567890` and confirm the response/list endpoint returns the same `id_group`.
- Check backend logs after the UI save; no `Unrecognized key` validation error should remain.
