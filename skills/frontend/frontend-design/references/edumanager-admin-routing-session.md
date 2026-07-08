# EduManager Stitch Admin Routing Follow-up

## Context

A rejected admin UI was replaced from a local Google Stitch template. The first implementation ported only the dashboard and rendered it at home `/`. The user corrected the scope: the dashboard belonged under `/admin`, the related template tabs/pages needed real routes, and `/login` needed to exist.

## Durable lesson

When replacing an app/admin UI from a multi-screen template, the deliverable is not just visual parity for the first screen. The replacement must also preserve the route model and screen inventory implied by the template and user request.

## Workflow to apply next time

1. Inventory the template directory before coding:
   - design notes such as `DESIGN.md`
   - every `code.html`
   - every screenshot
   - likely route/page names
2. Map screens to app routes in the plan before implementation.
3. Fix route ownership explicitly:
   - home `/` should not accidentally become an admin dashboard unless the user asked for that
   - admin dashboards should live under `/admin` or the requested admin route
   - login screens from the template should become `/login` when requested
4. For temporary/demo login requested before backend auth exists:
   - implement a small client-side form handler that navigates to the target route
   - allow arbitrary/empty input if the user requests permissive demo behavior
   - do not store passwords/tokens
   - do not create fake backend API/auth services
   - document the bypass as frontend-only temporary behavior
5. Convert template navigation/sidebar items into real links to the created routes, or mark placeholders clearly.
6. Verify with browser smoke tests for:
   - `/`
   - `/login`
   - login submit behavior
   - `/admin`
   - at least two admin subroutes
7. Run typecheck/lint/build and update `docs/PROJECT_PLANS.md` before completion.

## Route mapping used in the EduManager case

- `/` -> redirect/entry to `/login`
- `/login` -> `ng_nh_p_edumanager`
- `/admin` -> `dashboard_t_ng_quan_edumanager`
- `/admin/students` -> `danh_s_ch_h_c_sinh_edumanager`
- `/admin/students/vu-danh-tung` or dynamic equivalent -> `chi_ti_t_h_c_sinh_v_danh_t_ng_edumanager`
- `/admin/attendance` -> `qu_n_l_chuy_n_c_n_edumanager`
- `/admin/grades` -> `s_i_m_i_n_t_edumanager`
- `/admin/tuition` -> `h_c_ph_thanh_to_n_edumanager`

## Pitfall

A visual screenshot/browser check of `/` can look successful while still failing the user's requested routing model. Always verify route placement separately from visual quality.
