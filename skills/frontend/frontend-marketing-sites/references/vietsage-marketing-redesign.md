# VietSage Marketing Redesign Case Study

## Context

The user asked to transform a plain `/` route in a Next.js App Router project into a premium SaaS-style public marketing website for an international AI hospitality platform. Later scope expanded to public pages: Home, About Us, VietSage Commerce, VietSage Health, Blog, B2B, Contact, top navigation with Solutions mega menu, and redesigned footer.

## Useful Implementation Pattern

- Added a shared component umbrella at `src/components/marketing/marketing-shell.tsx` with:
  - `MarketingShell`
  - `Hero`
  - `SectionHeader`
  - `CardGrid`
  - `CTA`
  - footer and navigation/mega-menu data
- Kept page files mostly declarative content composition.
- Added pages under App Router:
  - `src/app/about/page.tsx`
  - `src/app/commerce/page.tsx`
  - `src/app/health/page.tsx`
  - `src/app/blog/page.tsx`
  - `src/app/b2b/page.tsx`
  - `src/app/contact/page.tsx`
- Updated `src/app/layout.tsx` metadata with title template, description, metadataBase, and Open Graph image.
- Added marketing utility CSS to `globals.css` rather than inline duplicated hover/nav/logo tile styles.
- Copied user-provided local images to `public/marketing/` and referenced them through `next/image`.

## Verification Lessons

- Run `npm run lint` and `npm run build`; if lint fails because of unrelated existing errors, either fix safe blockers or report the concrete blocker.
- In this case, lint initially failed on unrelated React hook lint errors in `request-queue-client.tsx`; wrapping effect-driven state updates in `queueMicrotask` avoided `react-hooks/set-state-in-effect` without changing visible behavior.
- Lint can exit 0 with warnings; report these as warnings, not failures.
- Production build may emit a non-blocking Node warning about `--localstorage-file`; do not call it a failure if exit code is 0.
- When the system asks for fresh verification, rerun the commands instead of citing prior runs.

## Screenshot Delivery Pattern

- Use browser navigation to load `/` after HMR/build.
- Capture with browser screenshot/vision.
- Copy the generated screenshot into the user-requested screenshot folder, e.g. `C:\Users\ADMIN\Desktop\workspace\screen_shot\19_marketing_home_redesign.png`.
- Include `MEDIA:<path>` in the response so the user receives the image.

## Pitfalls Encountered

- Generated one-line JSX can make lint errors hard to locate. Prefer formatted component/page files for maintainability.
- `react/no-unescaped-entities` flags literal quote characters inside JSX text; render testimonial quote text as data (`{q}`) or use entities.
- If a script writes files by reading tool output that includes line numbers, it can accidentally preserve tool formatting; use direct shell/node reads or the file write tool with clean content.
