# VietSage GuestOS Telegram Notification Session Notes

Context: `services/auth-service` NestJS backend. GuestOS service request creation should save `GuestRequest` first, then dispatch Telegram notifications asynchronously.

## Non-Negotiable Domain Rule

- Do **not** use or reintroduce `GuestRequestType` anywhere in active schema/source for VietSage.
- Service classification is derived from relations only:
  - `GuestRequest -> serviceItemId -> HotelServiceItem -> HotelServiceCategory`
- Telegram notification routing is category-only:
  1. exact route: `hotelId + serviceCategoryId + isActive=true`
  2. fallback route: `hotelId + serviceCategoryId=null + isActive=true`
- No `requestType` column, DTO field, fallback, enum, OpenAPI enum, test fixture, or callback logic should be added for notifications or service catalog.
- Old historical migrations may mention `GuestRequestType`; active `prisma/schema.prisma` and `src/` must not.

## Telegram Confirmation Workflow Pattern

Latest requested behavior is a single confirmation workflow, not a multi-step status action keyboard:

- New service requests start in `GuestRequestStatus.NEW`.
- Telegram `sendMessage` keeps the existing message text unchanged and adds one inline button:
  - text: `✅ Confirm`
  - `callback_data`: `guest_request:confirm:{guestRequestId}`
- Webhook handles `callback_query` only after validating `TELEGRAM_WEBHOOK_SECRET` from `/integrations/telegram/webhook/:secret`.
- Callback flow:
  1. parse `guestRequestId` from `guest_request:confirm:{guestRequestId}`
  2. atomically update `GuestRequest` with `where: { id: guestRequestId, status: NEW }`
  3. set `status=CONFIRMED`, `confirmedBy`, `confirmedAt`
  4. if update count is 0, answer callback: `This request has already been confirmed.` and do not write again
  5. answer successful callback: `Request confirmed.`
  6. emit realtime update to owner/staff room and guest session room
  7. edit Telegram message to append `🟢 Confirmed`, staff name, timestamp, and remove keyboard

## Implementation Pattern Used

- Prisma schema additions:
  - `NotificationRoute`: `hotelId`, nullable `serviceCategoryId`, `telegramChatId`, `isActive`, timestamps.
  - `GuestRequestNotification`: unique `(guestRequestId, provider)`, Telegram chat/message IDs, status `PENDING|SENT|FAILED`, error fields.
  - `NotificationProvider.TELEGRAM`.
- `GuestOsService.createRequest` returns the normal response immediately and triggers:
  - `void telegramNotificationService.sendServiceRequestNotification(request.id).catch(...)`
- Do not send Telegram inside the DB transaction.
- Keep Telegram failures isolated from GuestOS request creation.

## Pitfalls Found

- The user strongly objected to lingering `GuestRequestType`; search active schema/source after changes with:
  - `rg -n "GuestRequestType|guestRequestTypeEnum|requestType" prisma/schema.prisma src -S`
- Temporary verification scripts on Windows must close the `mkstemp` file descriptor before invoking PowerShell; otherwise PowerShell cannot read the script and cleanup fails with WinError 32.
- If adding Swagger/decorator annotations, use project-local decorators (`ApiDescript`) and imports exactly; stale decorators like `Api` / `ApiDescription` broke the build.
- When extending Prisma enums, update all exhaustive TypeScript `Record<GuestRequestStatus, ...>` and `switch` statements, not just the schema.
- Emoji equality can be brittle in shell/PowerShell ad-hoc checks; assert callback payload exactly and button text with a contains check if the terminal mangles emoji representation.

## Focused Ad-Hoc Verification Used

A temporary PowerShell script under `%TEMP%` should run:

```powershell
rg -n "GuestRequestType|guestRequestTypeEnum|requestType" prisma/schema.prisma src -S
npx prisma generate
npm run build
npx ts-node -e "...confirm button callback_data assertions..."
npx ts-node -e "...atomic NEW -> CONFIRMED update payload and duplicate confirmation assertions..."
```

Report this as ad-hoc verification, not full test suite coverage.
