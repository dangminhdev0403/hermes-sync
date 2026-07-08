---
name: backend-i18n
description: Design and implement backend multilingual support for API messages and database-backed content, especially NestJS/Prisma service catalog domains.
---

# Backend I18n

Use this skill when adding or planning multilingual backend behavior: localized API success/error/validation messages, locale resolution, Prisma-backed content translations, or fallback behavior for guest-facing/public API payloads.

## Core Workflow

1. Identify whether the requirement is API-message i18n, content i18n, or both.
   - API-message i18n covers success messages, exception details, validation messages, and response envelopes.
   - Content i18n covers database text like product/category/service names and descriptions.
2. Inspect existing locale resolver before adding a package or new convention.
   - Check accepted inputs: `?lang`, `x-lang`, `Accept-Language`.
   - Check canonical locale values and aliases, e.g. `vi` and `vi-VN` may need to resolve to one internal value.
3. Preserve response contracts unless the user explicitly asks to change them.
   - Prefer changing only localized text fields, not status codes or envelope shape.
4. For database-backed content, prefer `base fields + translation table` over JSON blobs when records must be searched, edited, indexed, or constrained.
5. Add tests for locale resolution, fallback order, validation rejection of unsupported locales, and at least one end-to-end localized response path.

## Content Translation Pattern

For Prisma-backed content such as service categories/items:

- Keep existing `name` and `description` as the default/base language when that is already how the product stores content.
- Add translation tables for non-base locales, with `@@unique([parentId, locale])`.
- Do not backfill the base locale into translation tables unless the user explicitly wants duplicate base records.
- Use transaction-safe nested create and upsert for translations.
- Return admin responses with translations visible for editing; return guest/public responses localized to the requested locale.

Fallback must be a project-level decision, not a per-module improvisation. For this user's GuestOS/service catalog work, use the global content fallback:

```txt
requested locale -> Vietnamese base fields -> key/name
```

If the user chooses Korean:

```txt
ko exists   -> return Korean
ko missing  -> return Vietnamese base fields
base missing -> return stable key/name fallback
```

Do not add an English fallback unless the user explicitly chooses that global strategy; English is used only when English is the requested locale.

## NestJS Implementation Notes

- Thread locale from controllers to services for content localization when service methods build response DTOs.
- For API-message i18n, resolve locale in interceptors/filters where the request is available.
- Keep thrown legacy strings working during migration by mapping known strings to stable i18n keys.
- Change decorators like `@SuccessMessage("literal text")` to stable keys when possible.
- For Zod schemas, `.strict()` on a translation object is useful to reject unsupported locale keys such as a base locale that should not be stored.
- Do not add lightweight helper services to constructors unless they are registered providers in the module. Either add/import an actual module provider or instantiate stateless helpers as private fields; otherwise Nest fails at startup with `UnknownDependenciesException`.
- Do not suppress all Nest startup logging while debugging (`logger: false`), because DI/bootstrap errors can disappear behind a generic exit. Keep enough logger output to expose startup failures.

## Prisma Repository Notes

- Include translations anywhere content names/descriptions are returned to clients.
- For relation includes, remember both parent and nested category/item may need translations.
- On update flows, if translations are upserted after updating the parent, refetch or update before returning if the response must include fresh translation data.
- Add a migration file with FK cascade and unique `(entityId, locale)` constraints.

## Plan-Mode Discipline

When the user says `plan mode` or explicitly says `chưa code`, do not edit files. Inspect enough code to produce an actionable plan with exact paths and decisions to confirm. Only switch to implementation after the user authorizes coding.

## Verification

Run the narrowest useful checks first:

```bash
npm run prisma:generate
npm test -- i18n.service.spec.ts
npm test -- hotels.schema.spec.ts
npm run build
```

If Prisma schema changed, generate the client before TypeScript build so new relation/model types exist.

When the harness asks for fresh verification evidence after edits, create a temporary script under `C:\Users\ADMIN\AppData\Local\Temp` with a `hermes-verify-` prefix and run the relevant generate/build/start checks from it. Report it as ad-hoc verification, not full suite green, and remove the script afterward.

## Reference Material

- `references/service-catalog-content-i18n.md` captures the HotelServiceCategory/HotelServiceItem design pattern and fallback rule from a real service catalog implementation.
- `references/import-framework-service-catalog.md` captures the reusable Import Framework architecture, Service Catalog Excel adapter rules, translation merge behavior, and GuestOS runtime localization pitfalls.
