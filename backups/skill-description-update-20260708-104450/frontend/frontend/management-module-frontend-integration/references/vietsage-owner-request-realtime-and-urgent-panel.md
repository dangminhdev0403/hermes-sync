# VietSage Owner Request Realtime + Urgent Panel Notes

Session learning from fixing `/owner/hotels/[hotelId]/requests` / shared `RequestQueueClient` behavior.

## Problem Pattern

A request queue had two surfaces backed by the same records:

- The normal request / "Needs Handling" table.
- A special red urgent/emergency panel for `priority === "URGENT"`.

Bugs appeared because the urgent panel kept its own local notification state and the owner realtime hook existed but was not wired into the queue client:

- Status changes did not update the table immediately.
- Acknowledged or completed urgent items could stay in the urgent panel.
- Removing an item from the urgent panel risked hiding it from the operator's main handling table.
- Requests tied to already checked-out stays needed a different triage rule: keep them visible in the durable table, but do not keep interrupting staff via the red urgent panel.

## Durable Fix Pattern

1. Wire the owner realtime hook into the queue client when an owner access token is available.
2. Keep a small `liveRequestChanges` overlay keyed by request id and merge it over the server-provided `requests` prop for the normal table.
3. Keep the urgent panel derived from request state, not from acknowledgement state alone.
4. Include stay lifecycle metadata in list responses when it affects triage. For VietSage this meant adding `stay.status` and `stay.checkedOutAt` to the backend list include, returning `stayStatus` and `checkedOutAt`, and adding optional frontend contract fields.
5. Use a single predicate for urgent panel membership:

```ts
function isCheckedOutRequest(
  request: Partial<Pick<StaffRequestListItem, "checkedOutAt" | "stayStatus">>,
): boolean {
  return Boolean(request.checkedOutAt) || request.stayStatus === "CHECKED_OUT";
}

function shouldShowInUrgentPanel(
  request: Partial<Pick<StaffRequestListItem, "priority" | "status" | "checkedOutAt" | "stayStatus">>,
): boolean {
  return Boolean(request.status)
    && request.priority === "URGENT"
    && !isFinalRequestStatus(request.status)
    && !isCheckedOutRequest(request);
}
```

6. On realtime `created`, `updated`, and `answered` events:
   - merge the change into `liveRequestChanges` so the normal table updates immediately;
   - add/update the urgent panel only if the predicate is true;
   - remove it from the urgent panel if the request is final, no longer urgent, or belongs to a checked-out stay.
7. On local mutations (status/assignment), call the same live-change application helper before `router.refresh()` so the UI is correct immediately.
8. In the normal table, badge checked-out records (for example `Đã checkout`) so operators know why the request is not in the urgent interrupt panel.

## UX Rule

Do not conflate "hide from urgent panel" with "remove from handling table".

- The urgent panel is only an interrupt/triage surface for active urgent requests from active stays.
- A resolved/final urgent request should disappear from the urgent panel.
- A checked-out-stay urgent request should also disappear from the urgent panel to avoid noisy emergency triage after checkout.
- The same request should still appear in the normal request table/history when it matches the current filters/page data, ideally with a checkout badge.

## Verification

- Run lint after wiring the hook; React hooks dependencies are easy to get wrong here.
- If the harness does not detect canonical verification, create a temporary ad-hoc script under the OS temp directory with a `hermes-verify-` prefix, check for the key behavior markers, run it, and clean it up. Report this as ad-hoc verification, not suite green.
- Manually verify these transitions:
  - new urgent from active stay -> appears in urgent panel and table;
  - acknowledged urgent from active stay -> remains visible if not final;
  - completed/cancelled/failed urgent -> removed from urgent panel but table status updates;
  - urgent tied to checked-out stay -> not in urgent panel, still visible/badged in table;
  - socket reconnect -> triggers a server refresh.
