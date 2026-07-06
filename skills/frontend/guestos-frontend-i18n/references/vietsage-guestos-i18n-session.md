# VietSage GuestOS i18n Session Notes

## User Scope Corrections

- The user first asked for a multilingual frontend plan, then narrowed scope: admin pages do not need multilingual support; only GuestOS guest pages do.
- The implementation request explicitly said:
  - frontend i18n only for hardcoded GuestOS UI text
  - do not wait for backend translation API
  - do not build translation CRUD UI
  - do not convert admin/owner/staff pages
  - later backend Excel-driven translations will handle dynamic/business content

## Implementation Pattern Used

- Add feature-scoped i18n under `src/features/guest-os/i18n/`.
- Supported locales: `vi`, `en`, `zh`, `ko`, `ru`, `hi`.
- Use the existing GuestOS store `language` field for persistence instead of global app i18n.
- Translate GuestOS hardcoded UI in:
  - bottom nav
  - `/g/language`
  - `/g/[qrCode]`
  - `/g/home`
  - `/g/services`
  - `/g/requests`
  - GuestOS display helpers such as `guest-os-display.ts`

## Lessons / Pitfalls

- Keep dynamic backend service names/descriptions untranslated on the frontend when backend Excel translations are planned.
- Avoid referencing `t` at module scope; helper functions outside React components need `t` passed in or must remain static/pure.
- If `t` is used inside `useEffect`, include it in dependencies to avoid changed-file lint warnings.
- For complete i18n requests, build/lint are not enough. Run a static check for:
  - equal key counts across all supported locale dictionaries
  - missing keys per language
  - user-visible hardcoded strings in all `/g/*` pages and GuestOS components/utils
  - fallback order in `use-guest-i18n.ts`
- VietSage fallback requirement from this session: selected language -> `vi` -> key. Do not use selected language -> `en` -> key for GuestOS unless explicitly requested.
- `guest-os-display.ts` should not contain Vietnamese enum labels. Return translation keys or accept `t`/locale as dependency.

## Verification Commands

Use targeted lint and full frontend build:

```bash
npm run build
npx eslint "src/app/(vietsage)/_components/vs-bottom-nav.tsx" \
  "src/app/(vietsage)/g/[qrCode]/page.tsx" \
  "src/app/(vietsage)/g/home/page.tsx" \
  "src/app/(vietsage)/g/language/page.tsx" \
  "src/app/(vietsage)/g/services/page.tsx" \
  "src/app/(vietsage)/g/requests/page.tsx" \
  src/features/guest-os/i18n/config.ts \
  src/features/guest-os/i18n/dictionary.ts \
  src/features/guest-os/i18n/use-guest-i18n.ts \
  src/features/guest-os/utils/guest-os-display.ts
```

## Static Check Shape

A future static check should inspect these paths at minimum:

```txt
src/app/(vietsage)/g/home/page.tsx
src/app/(vietsage)/g/[qrCode]/page.tsx
src/app/(vietsage)/g/language/page.tsx
src/app/(vietsage)/g/services/page.tsx
src/app/(vietsage)/g/requests/page.tsx
src/app/(vietsage)/_components/vs-bottom-nav.tsx
src/features/guest-os/components/*
src/features/guest-os/utils/*
src/features/guest-os/i18n/*
```
