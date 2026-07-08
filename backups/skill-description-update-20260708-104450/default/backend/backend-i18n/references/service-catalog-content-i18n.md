# Service Catalog Content I18n Reference

## Context

A NestJS/Prisma auth-service needed multilingual content support for service catalog tables:

- `HotelServiceCategory`
- `HotelServiceItem`

Existing tables already had Vietnamese/default content in:

- `name`
- `description`

The product needed locales:

- `vi-VN` as base/default
- `en`
- `zh`
- `ko`
- `ru`
- `hi`

## User Decisions

- Do not store `vi-VN` in translation tables.
- Treat base `name` and `description` fields as Vietnamese (`vi-VN`).
- Store only non-base translations: `en`, `zh`, `ko`, `ru`, `hi`.
- Fallback order for guest-facing content:

```txt
requested locale -> en -> base vi-VN
```

Example for Korean:

```txt
ko translation exists      -> return Korean
ko missing, en exists      -> return English
ko missing, en missing     -> return Vietnamese base fields
```

## Prisma Shape

Use two translation tables:

```prisma
model HotelServiceCategoryTranslation {
  id          String @id @default(cuid())
  categoryId  String
  locale      String @db.VarChar(10)
  name        String @db.VarChar(120)
  description String? @db.VarChar(500)
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  category HotelServiceCategory @relation(fields: [categoryId], references: [id], onDelete: Cascade)

  @@unique([categoryId, locale])
  @@index([locale])
}
```

```prisma
model HotelServiceItemTranslation {
  id          String @id @default(cuid())
  itemId      String
  locale      String @db.VarChar(10)
  name        String @db.VarChar(160)
  description String? @db.VarChar(1000)
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  item HotelServiceItem @relation(fields: [itemId], references: [id], onDelete: Cascade)

  @@unique([itemId, locale])
  @@index([locale])
}
```

Add relations:

```prisma
HotelServiceCategory.translations HotelServiceCategoryTranslation[]
HotelServiceItem.translations HotelServiceItemTranslation[]
```

## Zod Input Pattern

Reject base locale in translations by allowing only non-base keys and using `.strict()`:

```ts
const serviceCategoryTranslationsSchema = z
  .object({
    en: serviceCategoryTranslationSchema.optional(),
    zh: serviceCategoryTranslationSchema.optional(),
    ko: serviceCategoryTranslationSchema.optional(),
    ru: serviceCategoryTranslationSchema.optional(),
    hi: serviceCategoryTranslationSchema.optional(),
  })
  .strict()
  .optional();
```

Use separate category/item translation schemas because max lengths differ.

## Response Pattern

Admin/staff APIs should expose base fields plus editable translations:

```json
{
  "name": "Dịch vụ phòng",
  "description": "Các dịch vụ hỗ trợ tại phòng",
  "translations": {
    "en": { "name": "Room services", "description": "In-room support services" },
    "ko": { "name": "룸 서비스", "description": "객실 내 지원 서비스" }
  }
}
```

Guest/public APIs should return localized `name`/`description` only, using the fallback order.

## Pitfalls

- If update flow performs parent update first and translation upserts second, the parent result may contain stale translation data. Refetch before returning when the response includes translations.
- Run `prisma generate` before TypeScript build after adding models/relations.
- Locale resolver may normalize `vi-VN` incorrectly if it simply splits on `-`; add aliases so `vi`, `vi-VN`, and `vi-vn` all resolve to the canonical base locale.
