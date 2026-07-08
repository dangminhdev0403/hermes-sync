---
name: guestos-frontend-i18n
description: Add frontend-only multilingual support to GuestOS/guest-facing flows without touching admin/owner/staff pages or backend translation APIs.
---

# GuestOS Frontend i18n

Use this skill when adding or refining multilingual support for guest-facing GuestOS screens in an existing hospitality web app.

## Scope Rules

1. Translate GuestOS guest-facing hardcoded UI text only.
2. Do not convert admin, owner, staff, RBAC, billing operations, or internal dashboard pages unless explicitly requested.
3. Do not wait for a backend translation API when the request is frontend-only.
4. Do not build translation CRUD UI.
5. Leave dynamic/business content from the backend unchanged unless the backend already provides translated fields.

Dynamic content to leave unchanged:

- hotel names
- room numbers
- service names/descriptions from backend
- guest-entered request notes/descriptions
- IDs/codes
- backend enum values in API payloads

## Language Set

For the VietSage GuestOS class of tasks, support:

- Vietnamese: `vi`
- English: `en`
- Chinese: `zh`
- Korean: `ko`
- Russian: `ru`
- Hindi for Indian: `hi`

Normalize regional/browser values to these app-level locales, e.g. `zh-CN` -> `zh`, `hi-IN` -> `hi`.

## Architecture Pattern

Prefer a feature-scoped i18n layer under GuestOS rather than global app i18n:

```txt
src/features/guest-os/i18n/
  config.ts
  dictionary.ts
  use-guest-i18n.ts
```

Use existing guest session/store language state when available. Avoid adding new global providers unless the app already has one for GuestOS.

A compact hook should provide:

- `locale`
- `intlLocale`
- `setLocale(locale)`
- `t(key, replacements?)`

## Translation Key Rules

Use semantic keys, not literal sentences:

```txt
nav.home
common.scanQrTitle
home.heroTitle
language.confirmMessage
qr.switchTitle
services.send
requests.urgent
```

Fallback behavior for VietSage GuestOS must be:

1. selected locale dictionary
2. Vietnamese dictionary (`vi`)
3. key string

Do not silently fall back to English unless the user explicitly asks for English as the fallback language.

## Pages And Components To Check

Typical GuestOS targets:

```txt
src/app/(vietsage)/g/[qrCode]/page.tsx
src/app/(vietsage)/g/home/page.tsx
src/app/(vietsage)/g/language/page.tsx
src/app/(vietsage)/g/services/page.tsx
src/app/(vietsage)/g/requests/page.tsx
src/app/(vietsage)/_components/vs-bottom-nav.tsx
src/features/guest-os/components/*
src/features/guest-os/utils/*
```

If a shared component is used outside GuestOS, either make it safely client-side with GuestOS-specific labels or pass labels from GuestOS callers; do not accidentally translate owner/admin/staff UI.

## Implementation Steps

1. Inspect GuestOS pages/components for hardcoded guest-facing text.
2. Add feature-scoped locale config and dictionaries.
3. Wire the language page to the supported options only.
4. Translate bottom navigation and QR/session states first.
5. Translate core GuestOS pages: home, services, requests.
6. Keep backend-provided service names/descriptions as-is.
7. Use selected locale for date/number formatting where practical.
8. Run build and targeted lint for changed GuestOS files.

## Pitfalls

- When forwarding GuestOS locale to backend endpoints, keep it out of strict JSON bodies unless the API contract explicitly allows it. Prefer headers such as `Accept-Language`/`x-lang`; a backend `Unrecognized key: "locale"` response means the frontend service/client layer must strip locale from the body before sending.
- For guest-facing `/g/**` pages, do not surface raw `401`, `403`, or `410` errors to customers. These usually mean the stay/session has ended, the guest checked out, or spam/expired requests are blocked; map them to localized "session ended / contact reception" copy while preserving the QR scan flow for direct `/g/...` links.
- Do not make `/g/**` the default login/logout redirect for staff/owner/admin auth flows. GuestOS is customer QR-scanning territory; default auth redirects should use role dashboards or `/`, and `/g/**` should be reached intentionally from QR/customer navigation.
- When debugging GuestOS on a phone, treat browser/network hostnames as part of the bug: `localhost` and `127.0.0.1` point to the phone, and `169.254.x.x` is not a reliable QR host. Use the PC LAN IP, bind the dev server to `0.0.0.0`, and make Socket.IO/backend URLs browser-reachable from the phone.
- GuestOS API calls that use guest session tokens should not trigger NextAuth client refresh/logout behavior. Add/verify an escape hatch such as `skipAuthRefresh: true` for guest service methods; expired guest sessions should become localized customer-facing copy, not `/api/auth/refresh` noise.
- Do not claim GuestOS i18n is complete after only build/lint. Run a static completeness check for dictionary key parity and hardcoded guest-facing strings.
- When user asks for complete i18n, every supported language should explicitly resolve the canonical key set. Avoid partial language dictionaries that merely spread/copy English and override a few keys; that hides missing translations.
- Do not add admin/owner/staff multilingual scope after the user narrows the request to GuestOS only.
- Do not translate service catalog data in frontend if backend/Excel-driven translations will handle dynamic/business content later.
- Do not use `in` as a language code for Indian; use Hindi `hi` unless the user specifies another Indian language.
- If `t` is used inside hooks/effects, include it in dependencies or refactor to avoid `react-hooks/exhaustive-deps` warnings.
- If helper functions outside React components need translation, pass `t`/locale in or keep them pure; do not reference hook-scoped `t` at module scope.

## Verification Pattern

Use targeted lint and build:

```bash
npm run build
npx eslint "src/app/(vietsage)/g/[qrCode]/page.tsx" \
  "src/app/(vietsage)/g/home/page.tsx" \
  "src/app/(vietsage)/g/language/page.tsx" \
  "src/app/(vietsage)/g/services/page.tsx" \
  "src/app/(vietsage)/g/requests/page.tsx" \
  "src/app/(vietsage)/_components/vs-bottom-nav.tsx" \
  src/features/guest-os/i18n/config.ts \
  src/features/guest-os/i18n/dictionary.ts \
  src/features/guest-os/i18n/use-guest-i18n.ts
```

Treat lint warnings as repairable when they are in changed files; fix them before final summary when possible.

## References

- `references/vietsage-guestos-i18n-session.md` records the initial VietSage GuestOS frontend-only i18n rollout and user scope corrections.
- `references/guestos-locale-api-boundary.md` records the QR scan validation failure caused by sending locale in the body instead of headers.
- `references/guestos-session-expiry-and-auth-redirects.md` records the guest-session 401/checkout handling pattern and the rule that `/g/**` is not a default auth redirect target.
- `references/guestos-phone-network-and-realtime.md` records phone/LAN QR debugging, Socket.IO backend host normalization, and avoiding NextAuth refresh for guest-token APIs.
