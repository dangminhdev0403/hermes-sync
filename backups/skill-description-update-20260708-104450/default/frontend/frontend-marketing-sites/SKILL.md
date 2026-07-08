---
name: frontend-marketing-sites
description: Build or redesign public marketing websites and landing pages inside an existing web app without breaking product/auth routes.
---

# Frontend Marketing Sites

Use this skill when the user asks to redesign a homepage, marketing website, SaaS landing page, public solution pages, blog shell, B2B/contact pages, or conversion-focused public routes in an existing frontend codebase.

## Workflow

0. **Use references as input, not a blueprint**
   - When the user provides a competitor/reference page, inspect it for useful UI mechanics (hierarchy, CTA placement, spacing, visual rhythm), but restate the user's positioning before editing.
   - Do not clone the reference's concept, copy, information architecture, palette, or business narrative when the user says their product direction differs.
   - For hospitality pages, distinguish CRM/customer-management messaging from guest-facing in-stay service messaging when relevant.

1. **Audit the route surface first**
   - Identify the existing app framework and public route structure.
   - Preserve authenticated/product routes and backend/API routes.
   - Inspect root layout metadata, global CSS/design tokens, and existing brand assets.

2. **Create a reusable marketing shell**
   - Prefer a shared component layer for header, responsive nav, mega menu, footer, hero, CTA, card grids, and section headers.
   - Keep page files mostly content/data composition rather than duplicating large JSX blocks.
   - Use existing design tokens, fonts, brand colors, and utility classes unless a deliberate UX improvement is needed.

3. **Build conversion-first structure**
   - Every primary CTA should lead to a demo/contact/sales path.
   - Include trust signals, outcome metrics, platform overview, solution cards, social proof, FAQ, and final CTA.
   - For solution pages, structure around audience pain points, AI solution, workflows, dashboard preview, integrations/security, and CTA.
   - For blog pages, include categories/search/tags/article cards/reading time/author/date/newsletter placeholders.

4. **Use user-provided images carefully**
   - Copy user-provided local images into the app public assets directory when appropriate.
   - Use `next/image` (or the framework equivalent) for optimized rendering.
   - Avoid text baked into images; keep marketing copy in semantic HTML for SEO and accessibility.

5. **SEO and accessibility**
   - Update root/page metadata: title, description, Open Graph image, and metadata base if appropriate.
   - Use semantic landmarks (`header`, `nav`, `main`, `section`, `footer`) and heading hierarchy.
   - Maintain contrast, keyboard-accessible links/buttons, and mobile-first layouts.

6. **Verification and screenshots**
   - Run both lint and production build after edits.
   - Treat lint warnings separately from errors; report warnings honestly if the command exits 0.
   - When the user asks to inspect locally, start the local dev server, open the edited route in a browser, and use a visual screenshot check for hero/layout breakage before finalizing.
   - If the screenshot flags visual issues, make a focused polish pass and re-check the route.
   - Capture and save a screenshot of the redesigned public page when the user requests visual proof.
   - If an automated system asks for fresh verification, rerun the relevant command even if it was already run earlier; if it asks for an ad-hoc temp verifier, create it under the OS temp directory with a `hermes-verify-` prefix and delete it after running.

## Pitfalls

- Do not break or rename existing auth/admin/owner/guest/product routes while adding marketing routes.
- Do not claim full verification from a build alone if lint still fails; fix lint errors or explain blockers.
- Avoid one-off giant page-only implementations when the user requested an entire marketing site; make shared components first.
- Avoid lorem ipsum. Use meaningful placeholder copy tailored to the user’s domain.
- Avoid desktop-only mega menus; provide a mobile-friendly fallback or ensure critical nav/CTAs remain accessible on small screens.

## Verification Checklist

- `npm run lint` or project lint command exits 0.
- `npm run build` or project build command exits 0.
- New public routes appear in build output.
- Homepage loads in browser without visible error overlays.
- Screenshot saved to the requested location when asked.

## References

- `references/vietsage-marketing-redesign.md` captures a concrete Next.js App Router case study: premium SaaS marketing redesign, shared shell, route additions, image handling, lint/build verification, and screenshot delivery.
- `references/reference-page-to-distinct-positioning.md` captures how to use a competitor/reference page for UI mechanics while preserving a different product positioning and avoiding concept/copy cloning.
