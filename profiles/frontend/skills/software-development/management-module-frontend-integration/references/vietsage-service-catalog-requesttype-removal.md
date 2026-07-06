# VietSage Service Catalog requestType removal

Session pattern: Service Catalog categories became the only business classification for service requests. `GuestRequestType` remained as a legacy guest-request concept, but it was removed from the Service Catalog pipeline.

## Durable lessons

- Do not add new enum values like `SPA`, `GYM`, or `TOUR` to satisfy catalog categories. Category names/classification come from `HotelServiceCategory`.
- Google Sheets sync must not require or read `request_type`. Remove aliases such as `Loại yêu cầu` / `loai_yeu_cau` from header normalization when the catalog classification is category-based.
- In NestJS/Prisma catalog imports, remove `requestType` from parser payload, validation schema, current-state select, diff fields, and category upsert create/update data together. Leaving any one behind breaks Prisma generate/build after the schema migration.
- If `HotelServiceCategory.requestType` exists only for catalog routing, remove it from `schema.prisma` and add a migration that drops the index and column. Regenerate Prisma Client before building.
- Keep `GuestRequest.serviceItemId -> HotelServiceItem -> HotelServiceCategory` as the classification path. Do not duplicate category/type information into `GuestRequest` when it can be derived through the relation.
- Frontend cleanup must include strict internal API validators, shared contract types, create/edit form state, payload construction, filters, table columns, detail/export snippets, and any stale generated OpenAPI/types if the repo uses checked-in clients.
- Build both backend and frontend. Removing a field from shared types often surfaces hidden request-type displays in staff/request pages, not only the owner catalog form.

## Verification commands used

```bash
cd services/auth-service
npm run prisma:generate
npm run build

cd frontends/font-end-vietsage
npm run build
```
