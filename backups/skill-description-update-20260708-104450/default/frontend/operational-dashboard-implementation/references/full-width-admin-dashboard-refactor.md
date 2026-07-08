# Full-width admin dashboard refactor pattern

Session-derived pattern for fixing admin dashboards that feel chaotic, cramped, or visually centered instead of using the available screen.

## Symptoms

- User says the frontend is "too chaotic", "not coherent", or "co lại / không giãn đúng màn hình".
- Dashboard content is wrapped in a centered `mx-auto max-w-*` shell even though it is an authenticated operational app.
- UI changes only recolor cards or copy, but the product still lacks a command-center structure.

## Durable fix pattern

1. Treat the page as an app shell, not a marketing page.
2. Remove centered page caps such as `mx-auto max-w-[1600px]` when they make the workspace feel boxed-in.
3. Use a full-viewport structural grid, e.g. sidebar + elastic workspace:

```tsx
<div className="grid min-h-[100dvh] w-full lg:grid-cols-[280px_minmax(0,1fr)]">
  <Sidebar />
  <main className="min-w-0">...</main>
</div>
```

4. Give the IA a clear operational order:
   - persistent grouped sidebar with active state and counts;
   - sticky topbar with filters/search/primary action;
   - critical signals first;
   - actionable work queue/table as the main center of gravity;
   - supporting capacity/watchlist panels;
   - right rail for today/deadlines/system states.
5. Reduce visual noise by standardizing component vocabulary: one radius scale, one button shape, restrained semantic colors, fewer shadows, no nested card grids.
6. Keep dense operational data, but make density intentional with tables, dividers, clear headings, and tabular numerals.
7. If bulk actions are mentioned, ensure row selection controls exist or remove/adjust the copy.

## Verification

Run available project checks (`tsc`, lint, build). If a dev server is already running, inspect that live URL rather than starting a duplicate server. Verify layout with both screenshot and DOM probes:

```js
({
  innerWidth: window.innerWidth,
  docScrollWidth: document.documentElement.scrollWidth,
  bodyScrollWidth: document.body.scrollWidth,
  overflowing: [...document.querySelectorAll('*')]
    .filter(el => el.scrollWidth > el.clientWidth + 2)
    .slice(0, 20)
    .map(el => ({ tag: el.tagName, id: el.id, cls: el.className, sw: el.scrollWidth, cw: el.clientWidth }))
})
```

`docScrollWidth` should match `innerWidth` unless a deliberate horizontally scrollable table region is contained inside an `overflow-x-auto` wrapper.
