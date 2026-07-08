# VietSage Operational Dashboard Session Notes

## Context

The user wanted `/dashboard` redesigned for VietSage hotel operations so Owner/Staff can understand hotel status in 5-10 seconds. The user explicitly corrected the plan before implementation to avoid widget-coupled APIs and to make the dashboard actionable.

## Durable Lessons

- Plan updates may be treated as approved when the user says so; continue implementation without asking for another confirmation.
- Use domain-oriented API response shapes for dashboards: `rooms`, `stays`, `requests`, `revenue`, `health`, `attention`, `insights`, `sla`, `activities`, `generatedAt`, `warnings`.
- `generatedAt` or `snapshotAt` is important because it communicates freshness of all metrics.
- Recent activities should usually come from one primary event source, not a merged timeline, to avoid duplicates.
- Operational dashboards need an Attention section with actions, not just statistics.
- Every attention item should contain a route/action that navigates to an existing detail/list page.
- Health scores should be deterministic from existing data, never AI-generated.
- Insights should be aggregate-query driven and omitted when trends cannot be supported by data.
- SLA is optional and should only appear when reliable timestamps exist.
- For protected/authenticated pages, UI test attempts may legitimately stop at login; capture screenshot evidence and explain that auth blocked dashboard visual verification.
- If full-repo lint is blocked by unrelated legacy errors, run targeted lint on changed files plus build for the changed apps/services and report the blocker precisely.

## Example Endpoint

`GET /hotels/:hotelId/dashboard`

## Example Frontend Order

1. KPI Cards
2. Sức khỏe vận hành
3. Cần xử lý
4. Insight vận hành
5. Tình trạng phòng
6. Yêu cầu của khách
7. SLA xử lý yêu cầu, only if available
8. Doanh thu, only if available
9. Hoạt động gần đây
