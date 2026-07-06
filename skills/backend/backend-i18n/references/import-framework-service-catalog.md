# Reusable Import Framework + GuestOS Service Catalog I18n

Session-derived design notes for backend multilingual service catalog imports.

## Architecture Rule

Do not build a one-off Excel importer for Service Catalog. Build a reusable Import Framework that handles common workflow:

```txt
Upload -> Parse -> Validate -> Preview -> Diff -> Commit -> Audit -> Domain Events -> Error Report
```

The framework owns:

- Excel parsing and sheet/column normalization
- validation orchestration and common issue shape
- preview session storage
- diff response contract
- transaction boundary for commit
- generic audit log and domain events
- template generation and error report generation

Business adapters own only:

- workbook schema
- business validation rules
- mapping from rows to DTOs
- current-state loading
- business diff rules
- commit logic
- business-specific domain event payloads

Use this for Service Catalog first, then future Translation, Airport, FAQ, Hotel Policy, and other import modules.

## Service Catalog Adapter

Service Catalog import is one adapter of the framework.

Excel has exactly two sheets:

- `categories`
- `items`

Do not use a single merged sheet.

Stable keys are mandatory:

- `category_key -> HotelServiceCategory.importKey`
- `item_key -> HotelServiceItem.importKey`

Do not upsert by Vietnamese name. Names may change; keys should not. Add unique constraints on `(hotelId, importKey)`.

## Import Modes

Phase 1 supports only:

```txt
upsert
```

Future `replace` mode must never hard-delete records. Missing rows should become `DISABLED` to preserve GuestRequest, Folio, Invoice, analytics, and audit history.

## Translation Storage

Base fields are Vietnamese (`vi-VN`):

- `HotelServiceCategory.name` / `description`
- `HotelServiceItem.name` / `description`

Translation tables store only:

- `en`
- `zh`
- `ko`
- `ru`
- `hi`

Do not store `vi` or `vi-VN` translation rows.

## Translation Merge Rule

For Excel import phase 1:

```txt
cell has value -> upsert translation
cell empty     -> keep existing translation
```

Do not add `translation_mode`, `clear_translation_xx`, or blank-means-delete behavior in phase 1. Avoid accidental data loss.

## Global Fallback Rule

Unify fallback across modules:

```txt
requested language -> Vietnamese base fields -> key/name
```

Do not make Service Catalog use a different order such as requested -> English -> base. Only use English when English is the requested language.

Runtime GuestOS APIs localize only guest-facing dynamic content:

- category name/description
- item name/description
- request display name if derived from service item name

Do not localize API enum/status values, ids, prices, currency, quantity config, or timestamps.

## Runtime Pitfall

If a helper like `I18nService` is not registered as a Nest provider in the module, do not add it as a constructor parameter. Either register/export/import a proper module or instantiate it as a private field for lightweight stateless helpers. Otherwise Nest startup fails with `UnknownDependenciesException`.

When debugging startup failures, avoid suppressing Nest startup logs entirely (`logger: false`) because dependency injection errors can be hidden. Keep enough logger output to reveal bootstrap failures.

If `nest build` emits to `dist/src/main.js`, ensure `start:prod` points to `node dist/src/main`, not `node dist/main`. A stale start script can look like an application runtime failure even when the build is successful.

For Import Framework adapters, keep the framework business-agnostic. Adapters may register themselves with a shared registry on module init, but the framework should only orchestrate parse/validate/preview/diff/commit/transaction/audit/reporting and should not contain service-catalog-specific rules.
