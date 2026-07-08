# Porting a local Stitch/admin template into an existing frontend

Use this when the user rejects an existing dashboard/admin UI and provides a local template directory as the source of truth.

## Source-of-truth workflow

1. Inspect the local template directory before designing anything new.
   - Read `DESIGN.md` or equivalent design-system notes first.
   - Read the template `code.html` files to capture exact copy, layout, color tokens, spacing, and component inventory.
   - Inspect `screen.png` screenshots with vision when available; use the screenshot as the visual acceptance target.
2. Replace the disliked UI, do not merely decorate it.
   - Identify the active route entry (`app/page.tsx`, route page, shell component).
   - Port the template into the active component/module.
   - Delete or decommission stale components that are no longer part of the active UI, especially in TypeScript projects where all `*.tsx` files are typechecked even when not imported.
3. Preserve project constraints.
   - Do not edit `package.json` or add dependencies unless the user explicitly permits it.
   - Keep pages thin and put feature UI under `features/<feature>/components`.
   - Keep static/demo data under `features/<feature>/data/*.mock.ts`.
4. Match the template literally first.
   - Use the template's names, visible Vietnamese copy, card order, sidebar/topbar structure, charts, and control labels.
   - Prefer exact palette/spacing/radius from the template over a new creative direction when the user says the template is the new UI.
5. Verify with real gates and browser.
   - Run typecheck, lint, build.
   - Audit UTF-8/mojibake markers (`Ã`, `Â`, `�`, `á»`, `áº`, etc.).
   - Restart any stale dev server before browser verification; an old Next dev process can show an error overlay from previous source even after production build passes.
   - Browser-check for visual match, missing icon fonts, Next error overlays, and horizontal overflow.

## Pitfalls from the EduManager Stitch replacement

- `tsconfig` may include all `**/*.tsx`; stale unused components with old imports can break `tsc` even after the route no longer imports them. Delete the old files or keep their imports/data typed.
- CSS `@import` for external icon fonts after Tailwind can trigger PostCSS ordering warnings/errors in dev. Prefer `next/font` for text fonts and a head/link escape only when replicating a provided template asset stack.
- If the browser shows an old Next overlay but `next build` passes, kill/restart the existing `next dev` process and reload before diagnosing the current code.
