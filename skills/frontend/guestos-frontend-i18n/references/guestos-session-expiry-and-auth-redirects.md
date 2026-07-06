# GuestOS session expiry and auth redirect lessons

Session context: VietSage GuestOS customer QR pages (`/g/**`) share a frontend app with admin/owner/staff auth routes.

## Durable lessons

- Treat `/g/**` as customer QR-scanning territory, not a general authenticated-user landing area.
- Default login/logout redirects should not fall back to `/g/services` for generic guest/unknown roles; use `/` or an explicit role dashboard unless the user deliberately opened a QR/customer URL.
- A backend `401`/`403`/`410` on `/g/**` can be a normal hospitality lifecycle state: the customer checked out, the stay session expired, or duplicate/spam requests are blocked.
- Do not show raw HTTP text such as `Request failed with status 401` to hotel guests. Map it to localized copy like: "Your stay session has ended or is no longer available. Please contact reception if you need more help."
- Keep this message multilingual in the GuestOS feature dictionary for all supported locales (`vi`, `en`, `zh`, `ko`, `ru`, `hi`).

## Implementation pattern

- Add a small GuestOS-specific error helper, e.g. `features/guest-os/utils/guest-os-errors.ts`, that detects `HttpError` statuses `401`, `403`, and `410`.
- Use that helper in `/g/services` and `/g/requests` catches for loading, creating, cancelling, and similar guest actions.
- Preserve direct QR navigation behavior: `/g/[qrCode]` should still scan/open GuestOS; only default auth redirects should avoid `/g/**`.
