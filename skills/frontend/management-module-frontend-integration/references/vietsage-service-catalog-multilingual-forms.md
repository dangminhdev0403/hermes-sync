# VietSage Service Catalog Multilingual Management Forms

Session context: owner service catalog UI in `frontends/font-end-vietsage` and backend `services/auth-service`. The user expected the five language options to appear inside the existing Services create/edit modals, not only in request detail popups or backend models.

## Implementation Pattern

- Frontend owner Services UI: `src/app/(vietsage)/owner/hotels/[hotelId]/services/owner-service-catalog-client.tsx`.
- Add a `TranslationFormState` keyed by supported content locales: `en`, `zh`, `ko`, `ru`, `hi`.
- Track an `activeLocale` in each category/item form. Use `vi` for the base Vietnamese fields and the five supported locale keys for translations.
- Prefill edit forms from `category.translations` / `item.translations` with a helper like `translationsToForm`.
- Make `translationsToForm` defensive: backend data may arrive as either an array (`[{ locale, name, description }]`) or an object (`{ en: { name, description } }`). Normalize before iterating to avoid `(translations ?? []) is not iterable` browser crashes.
- Convert non-empty translation names back to the backend payload shape with `translationsFromForm`; include optional `description` as `null` when empty.
- Render a visible `Tùy chọn đa ngôn ngữ` section in both category and service item modals.
- Prefer compact language chips/tabs (`Tiếng Việt`, `English`, `中文`, `한국어`, `Русский`, `हिन्दी`) that switch the visible inputs. Do not render all five languages' large name/description fields at once in an already-large modal.
- Vietnamese (`vi`) uses the existing top-level Name/Description fields. Other locale chips show one translated name input and one translated description textarea.
- Make large modals scrollable (`max-h-[90vh] overflow-y-auto`) after adding language controls.

## Internal API Validators

The Next.js internal owner CRUD routes use strict Zod schemas. When adding multilingual fields to the UI, update all relevant strict schemas or saves will fail:

- `src/app/api/owner/hotels/[hotelId]/service-categories/route.ts`
- `src/app/api/owner/hotels/[hotelId]/service-categories/[categoryId]/route.ts`
- `src/app/api/owner/hotels/[hotelId]/service-items/route.ts`
- `src/app/api/owner/hotels/[hotelId]/service-items/[itemId]/route.ts`

Use a `translationsSchema` with optional locale keys and `{ name, description }` values.

## User Expectation

For this user, multilingual support is not considered complete unless the management UI visibly exposes the five language options in the form/modal where users edit the service category or item. They prefer compact language switch controls at the top of the translation section so pressing a language changes the text being edited, instead of displaying a large amount of text for every language at once.
