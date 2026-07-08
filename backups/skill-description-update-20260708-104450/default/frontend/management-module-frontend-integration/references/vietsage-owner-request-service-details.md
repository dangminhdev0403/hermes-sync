# VietSage owner request service details

Session learning from `owner/hotels/[hotelId]/requests` Services module.

When a request detail modal needs a clickable Details box for service catalog data, check both layers:

- Backend: `GET /hotels/:hotelId/requests/:requestId` may exist but only include minimal `serviceItem` / `category` fields. Extend the Prisma include/select for request detail/list rows to include the nested service item and category fields the UI needs (`description`, pricing, quantity rules, status, timestamps, category default price/currency/requestType, etc.).
- Multilingual catalog detail is a separate requirement from base Vietnamese fields. Include `serviceItem.translations` and `serviceItem.category.translations` from Prisma, add matching frontend contract fields (for example `translations?: ServiceCatalogTranslation[]`), and render an explicit multilingual section in the Details popup. Do not assume `name_vi`/`description_vi` proves other locales are available.
- Frontend: wire the existing request detail card rather than creating a separate route if the UX asks for a click event in the current model. In VietSage this was a clickable Service box inside `request-queue-client.tsx` that opens a SweetAlert details modal.
- Escape any DB-provided values interpolated into SweetAlert `html` strings.
- Verification: after code edits, run the repository's canonical checks when possible (`pnpm run lint`, `pnpm run build`, backend `npm run build`). If a harness still requests focused verification, create a temp script under the OS temp dir with a `hermes-verify-` prefix, check for backend include fields plus frontend click/helper/translation wiring, then delete it and report it as ad-hoc verification (not suite green).
