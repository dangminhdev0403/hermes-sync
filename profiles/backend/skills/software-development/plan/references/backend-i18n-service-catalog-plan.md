# Backend I18n Service Catalog Planning Notes

Use when planning multilingual backend work for a NestJS/Prisma service catalog where database content, not only API messages, must be localized.

## What to inspect first

- Prisma models for catalog content fields and relations, especially `HotelServiceCategory` and `HotelServiceItem`.
- Admin/staff controller and service wrappers that manage CRUD endpoints.
- Business service methods that build query filters and response DTOs.
- Repository include/select shapes used by staff and guest endpoints.
- Guest/public endpoints that read catalog content and create downstream records/realtime payloads.
- OpenAPI contract schemas and Zod validation schemas.

## Durable design pattern

Separate two classes of i18n:

- API message i18n: success, error, validation messages through the app i18n catalog.
- Content i18n: tenant/hotel-authored database content such as category/item `name` and `description`.

For content i18n, prefer `base fields + translation tables`:

- Keep existing base fields (`name`, `description`) as canonical fallback and backward-compatible response data.
- Add per-entity translation tables with `@@unique([entityId, locale])`.
- Use canonical locale codes consistently, e.g. `vi-VN`, `en`, `zh`, `ko`, `ru`, `hi`.
- For admin/staff responses, return base fields plus `translations`; optionally support `?lang=` preview.
- For guest/public responses, return localized `name` and `description` only, resolved from request locale.

## Fallback rules to decide explicitly

Before coding, ask or state assumptions for:

- Whether base fields represent `vi-VN`, and whether a `vi-VN` translation row should be stored or derived.
- Whether missing guest translations fall back to `en` first or directly to base fields.
- Whether admin endpoints should localize output by default or expose full translation maps.
- Whether search should remain base-field-only in phase 1 or include translation relations.

## Implementation phases

1. Add Prisma translation models and relations; run/generate migration.
2. Extend DTO/Zod schemas for `translations` without breaking existing create/update bodies.
3. Update repositories to include translations and create/update them transactionally with category/item rows.
4. Add localization helpers for response mapping; do not put this logic inline in every service method.
5. Localize guest service catalog responses first because they are user-facing.
6. Add admin/staff translation management and OpenAPI response schemas.
7. Add translation-aware search only after base behavior is stable.

## Tests to include

- Create/update category translations.
- Create/update item translations.
- Guest list services resolves requested locale.
- Missing translation falls back according to chosen policy.
- Existing create/update without translations remains valid.
- Search remains compatible, then translation-aware search if implemented.
