# VietSage Owner Room QR Lifecycle

Session lesson from owner hotel room/stay work.

## Durable Pattern

- Do not create or rotate room QR codes as a side effect of check-in. Check-in should consume/reuse an existing room QR and activate it for the stay if needed.
- Room QR lifecycle belongs on the owner room management page: per-room activate/deactivate/rotate actions plus bulk activate/export/rotate actions.
- Activation can safely happen before check-in if guest scan/access logic still verifies an active stay before creating a guest session.
- Backend activation should be idempotent: find latest non-revoked room QR, create one if missing, deactivate any other active room QR for that room, then mark the chosen QR active. If an active stay exists, set expiry from planned checkout; otherwise leave expiry open/null or use the product-defined room QR expiry.
- Rotation remains a separate destructive operation because old printed QR codes stop working.

## UI Notes

- Remove copy that says check-in is required to create/enable QR when QR pre-provisioning is supported. Use hints like `Chưa tạo mã QR` for rooms with no QR value.
- If a QR action route returns QR data while the table displays room rows with nested `qr`, refresh/refetch the room list after the action rather than trusting optimistic replacement by id.

## Verification Used

- Backend: `npm run build` in `services/auth-service`.
- Frontend: `npm run lint && npm run build` in `frontends/font-end-vietsage`.
