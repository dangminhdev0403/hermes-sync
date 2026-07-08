# GuestOS phone network and realtime session notes

When `/g/**` works on the developer machine but fails on a guest phone, check two different host contexts:

- `localhost` in a phone browser means the phone, not the developer PC.
- `169.254.x.x` is a link-local fallback and is unreliable for QR/customer flows.
- Use the PC LAN IP (`192.168.x.x`) in QR/front-end URLs and start the Next dev server on `0.0.0.0`.

Realtime sockets need the same browser-reachable backend host. If the frontend is opened as `http://192.168.1.15:3000` but `NEXT_PUBLIC_AUTH_API_BASE_URL` is `http://localhost:3001`, the phone tries to connect its own localhost and Socket.IO fails. A durable client-side mitigation is to normalize local backend hosts at browser runtime:

```ts
if ((host === "localhost" || host === "127.0.0.1") && window.location.hostname is not local) {
  backendUrl.hostname = window.location.hostname;
}
```

For GuestOS APIs, guest session tokens are not NextAuth admin/staff access tokens. Do not let `/g/**` guest API calls trigger NextAuth client refresh (`/api/auth/refresh`) or logout-required behavior. Add a per-request escape hatch such as `skipAuthRefresh: true` for guest service methods, then surface expired/checked-out guest sessions as localized customer-friendly copy.

Verification for this class of fix:

- `pnpm run lint`
- From a phone on the same Wi-Fi, open `http://<pc-lan-ip>:3000/g/<qrCode>`.
- In browser/dev logs, confirm Socket.IO connects to `http://<pc-lan-ip>:<backend-port>/request-realtime`, not `localhost`.
- Trigger a guest request update and confirm `guest:join_session_requests` joins without `request_realtime.error`.
