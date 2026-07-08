---
name: operational-dashboard-implementation
description: Build operational dashboards that help staff decide what to do next, with domain-oriented aggregate APIs and actionable frontend sections.
---

# Operational Dashboard Implementation

Use this skill when redesigning or implementing a dashboard for operations teams (hotel, support, fulfillment, field ops) where the goal is rapid situational awareness and next actions, not CRUD or BI exploration.

## Core Principles

1. Treat the dashboard as an operational command view, not a CRUD surface.
2. Design the backend response around business domains, not UI widgets.
3. Frontend maps domain data into KPI cards and sections.
4. Do not fake data. Return `null`, `available: false`, empty arrays, or warnings when data is missing.
5. Keep the frontend to one dashboard API call.
6. Keep urgent/actionable data real-time or very short-cache only.

## Backend Response Shape

Prefer a reusable domain response:

```ts
{
  hotelId?: string;
  generatedAt: string;
  rooms?: object;
  stays?: object;
  requests?: object;
  revenue?: object;
  health?: object;
  attention: AttentionItem[];
  insights: Insight[];
  sla?: object;
  activities: Activity[];
  warnings: string[];
}
```

Do not return `kpiCards`, `dashboardSections`, or widget-specific objects unless the project already has a strong convention for that.

## Aggregation Rules

- Use existing models/tables only; inspect schema before designing.
- Use `COUNT`, `SUM`, `GROUP BY`, date filters, `ORDER BY`, and `LIMIT`.
- Do not load full lists and count/sum in memory.
- Run independent queries with `Promise.all`.
- Recent activities: at most 20, newest first.
- Read-only service only; no writes, no status mutation, no event creation.
- Add indexes only when missing and supported by the project migration flow.

## Recent Activities

Avoid merging multiple event sources unless the product explicitly requires a unified timeline.

Priority order:

1. Event table for the main workflow, e.g. `GuestRequestEvent`.
2. Main workflow records, e.g. `GuestRequest`.
3. Only fall back to secondary sources such as stays or payments when no event source exists.

This prevents duplicate or inconsistent timeline items.

## Attention Section

Every attention item must tell staff what to do next.

```ts
type AttentionItem = {
  id: string;
  type: string;
  priority: "urgent" | "high" | "normal";
  title: string;
  description: string;
  createdAt: string;
  source: { type: string; id: string };
  action: { label: string; route: string };
};
```

Rules:

- Limit to the highest-priority operational items.
- Sort by urgency first, then newest.
- Actions navigate to existing pages/routes only. If an action points at a detail URL, verify that the route/page actually exists for that user surface (owner/staff/admin paths may differ).
- Do not add CRUD actions or forms to the dashboard.
- Apply lifecycle scoping before counting or displaying items: operational request queues should exclude requests from completed/checked-out stays unless the product explicitly asks for history.

Examples:

- Urgent request -> `Xử lý ngay`, route to existing request detail.
- Pending checkout -> `Xem lưu trú`, route to existing stay page.
- Room processing issue -> `Xem phòng`, route to existing room page.

## Health Domain

Use deterministic scoring, never AI/LLM scoring.

```ts
health: {
  score: number | null;
  status: "excellent" | "good" | "warning" | "critical" | "unknown";
  title: string;
  factors: Array<{
    type: string;
    label: string;
    impact: "positive" | "negative" | "neutral";
    message: string;
  }>;
}
```

If not enough data exists, return `score: null` and `status: "unknown"`.

Typical negative factors:

- urgent unprocessed requests
- total unprocessed requests
- rooms in processing/maintenance
- pending check-outs
- failed payment/billing issues if billing exists
- QR/session issues only if real data supports them

## Insights Domain

Generate insights with aggregate queries only.

```ts
type Insight = {
  id: string;
  type: string;
  severity: "info" | "warning" | "critical";
  title: string;
  description: string;
  metric?: { current: number; previous?: number; changePercent?: number };
};
```

- Compare today with yesterday/recent periods only if data exists.
- Do not fake trends.
- Return an empty array if there is not enough data.

## SLA Domain

Only calculate SLA if reliable timestamps exist.

```ts
sla: {
  available: boolean;
  averageResponseMinutes: number | null;
  averageCompletionMinutes: number | null;
  completedWithinSlaPercent: number | null;
  thresholdMinutes: number;
}
```

Do not infer SLA from unreliable fields.

## Frontend Layout

Prefer this operational priority order:

1. KPI cards
2. Operational health
3. Attention / requires action
4. Operational insights
5. Status summaries
6. Workflow overview
7. SLA, only if available
8. Revenue, only if available
9. Recent activities

Use skeleton/loading, error, and empty states. Do not hardcode fake numbers when API returns `null` or unavailable data.

## References

- `references/vietsage-dashboard-session.md` captures a concrete VietSage hotel dashboard implementation and the user's architecture corrections.
- `references/vietsage-owner-dashboard-request-lifecycle.md` captures the checked-out-stay filtering and missing owner detail route pitfall.
- `references/full-width-admin-dashboard-refactor.md` captures the pattern for refactoring cramped/chaotic admin dashboards into full-width operational command centers.

## Layout Pitfall: Cramped Admin Dashboards

When a user complains that an admin/dashboard frontend is chaotic, incoherent, or visually "co lại / không giãn đúng màn hình", do not merely recolor cards or tweak copy. First inspect the app shell for centered marketing-page constraints such as `mx-auto max-w-*`. Authenticated operational dashboards usually need a full-viewport shell: persistent grouped sidebar, elastic main workspace (`minmax(0,1fr)`), sticky filters/search/actions, critical signals, central work queue/table, and supporting right rail. Preserve intentional density, but standardize radius, button vocabulary, semantic colors, and table overflow handling.

## Verification Pattern

For full-stack dashboard changes, verify both sides:

- Backend build.
- Frontend build.
- Targeted lint for changed files when full-repo lint is blocked by unrelated legacy errors.
- State any blocker precisely instead of claiming full verification.

When browser UI testing is blocked by auth, capture a screenshot of the redirect/login state and say dashboard access was blocked by authentication rather than claiming visual verification.
