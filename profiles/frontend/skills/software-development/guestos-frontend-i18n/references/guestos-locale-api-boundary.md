# GuestOS Locale API Boundary Note

Session learning from VietSage GuestOS QR scan debugging.

## Symptom

A QR scan request failed with backend validation:

```text
POST /guest/qr/scan -> 400 VALIDATION_ERROR
input: Unrecognized key: "locale"
```

## Cause

The app route gathered the guest locale and passed it to the GuestOS service. The service then sent the whole `GuestScanQrRequest` object as the JSON body while also using the locale to build headers. Backend schema accepted QR/session fields only and rejected `locale` in the body.

## Durable Fix Pattern

At the final HTTP boundary, split locale from body payload:

```ts
async scanQr(input: GuestScanQrRequest): Promise<GuestScanQrResult> {
  const { locale, ...body } = input;

  return this.httpClient.request({
    method: "POST",
    path: this.path("/guest/qr/scan"),
    body,
    headers: localeHeaders(locale),
    isPublic: true,
  });
}
```

Use headers such as `Accept-Language` and `x-lang` for locale metadata unless the endpoint contract explicitly includes locale in the body.

## Debugging Checklist

- Read backend validation detail; `Unrecognized key` is usually exact.
- Trace both Next.js route sanitization and service/client request construction.
- Verify TypeScript/lint after changing request shapes.
