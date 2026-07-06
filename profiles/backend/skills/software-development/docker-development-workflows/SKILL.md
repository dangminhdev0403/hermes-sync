---
name: docker-development-workflows
description: Design and implement Docker Compose development workflows for Node/NestJS/Next.js apps with databases, especially Windows + Docker Desktop + pnpm setups.
---

# Docker Development Workflows

Use this skill when a user asks to containerize a local development or production stack, add Docker Compose, or review/design Docker architecture for Node, NestJS, Next.js, Prisma, or similar web apps.

## Communication Preferences

- When the user explicitly asks for production Docker fixes and says not to explain at length, make the edits first and keep the final response short: changed files, verification status, and any concrete blocker only.
- Do not over-explain standard Docker concepts unless the user asks for rationale.

## Workflow

1. **Plan before edits when requested**
   - If the user asks for review/design first, produce the requested architecture report and stop.
   - Do not create Dockerfiles, Compose files, env files, or scripts until explicit approval.
   - Mirror the user's deliverable structure exactly when they provide one.

2. **Map the existing stack first**
   - Identify app roots, package managers, lockfiles, ports, env examples, database config, and startup scripts.
   - Confirm the target path when multiple projects exist.
   - Note mismatches such as actual `.env` ports differing from `.env.example`.

3. **Keep the core stack narrow**
   - Include only services the user requested: typically database, backend, frontend.
   - Exclude side services unless explicitly requested.
   - Do not include unrelated agents, bots, cron jobs, workers, gateways, or observability extras in a minimal dev workflow.

4. **Protect application behavior**
   - Do not change UI, API contracts, business logic, auth, RBAC, or database schema unless the user explicitly approves.
   - Keep Docker changes minimal: Compose, Dockerfile.dev, .dockerignore, Docker env examples, and package metadata only when required for build correctness.

5. **Handle env files deliberately**
   - Some apps require a physical `.env` file, not just process env vars. If the loader checks for `.env`, ensure the container has a genuine `/app/.env` by mounting/copying a Docker env file or make a narrowly scoped loader change only with approval.
   - Separate host/browser URLs from container service URLs:
     - browser to backend: `http://localhost:<backend-port>`
     - frontend container server-side to backend: `http://<backend-service>:<backend-port>`
     - backend container to database: database service name, not `localhost`.

6. **Use safe database startup**
   - Add database healthchecks and make backend startup wait for database readiness.
   - For Prisma, use `prisma migrate deploy` and `prisma generate` for startup verification when the database state is healthy.
   - Never run `prisma reset`, `prisma migrate reset`, `prisma db push`, or project aliases for those commands unless the user explicitly asks for destructive database work.
   - If `migrate deploy` fails due migration drift, stop and report the exact blocker instead of bypassing with reset/push.
   - For development stacks with known migration drift, make migration-on-start opt-in (for example `PRISMA_MIGRATE_ON_START=false`) so the app can boot against the existing dev database; document that migrations must be repaired/reviewed separately and keep the destructive commands banned.

7. **Optimize for Windows + Docker Desktop + pnpm**
   - Bind-mount source code only.
   - Keep `node_modules` in Docker named volumes.
   - Keep Next.js `.next` cache in a named volume.
   - Bind dev servers to `0.0.0.0`.
   - Use polling env vars only as needed for file watching.
   - Avoid running `pnpm install` on every container start: guard with `if [ ! -d node_modules/.pnpm ]; then pnpm install ...; fi`.
   - Set noninteractive pnpm env/config when needed (`CI=true`, `PNPM_CONFIG_CONFIRM_MODULES_PURGE=false`, or approved build-script config) to avoid TTY prompts.

8. **Respect lockfiles**
   - Do not delete existing lockfiles.
   - If introducing pnpm to a package that already has `package-lock.json`, retain `package-lock.json` and clearly state whether a new `pnpm-lock.yaml` was generated/needed.
   - If a production Dockerfile is required to use `npm ci`, ensure a valid `package-lock.json` exists for each Node app. For projects previously using pnpm only, generate the lockfile in a clean temporary directory from `package.json` when local pnpm `node_modules` confuses npm/arborist, then copy only the generated lockfile into the app.
   - If package dependencies are changed, update the relevant lockfiles consistently.

9. **Production Node/NestJS/Next.js Docker flow**
   - Use multi-stage Dockerfiles: builder installs with `npm ci`, builds the app, prunes dev dependencies; runtime copies only compiled output, production `node_modules`, package metadata, and required static/config assets.
   - Never run dev-mode commands in production containers: no `next dev`, `npm run dev`, `nest start --watch`, hot reload, or `ts-node` in runtime.
   - NestJS runtime should run compiled output directly, e.g. `CMD ["node", "dist/main.js"]`; if the existing Nest build emits `dist/src/main.js`, fix `tsconfig.build.json` (`rootDir: ./src`, `outDir: ./dist`) rather than changing runtime to a nested dev-oriented path.
   - Next.js runtime should run `next start`, commonly through `npm run start -- --hostname 0.0.0.0`; build with `next build`/`npm run build` in the builder stage.
   - Production Compose should not bind-mount source code, should not mount/override `node_modules`, should not run install/build commands at startup, and should not set watcher/polling env vars.

10. **Verify only the requested scope unless asked for more**
   - Minimum Docker checks: `docker compose config`, `docker compose build` or `docker compose up --build`, frontend port, backend health endpoint, and frontend-to-backend connectivity if backend is healthy.
   - For NextAuth/Auth.js containers, check logs for `NEXT_AUTH_ERROR`, `JWTSessionError`, and `no matching decryption secret`; set both legacy `NEXTAUTH_SECRET` and modern `AUTH_SECRET` consistently when the app/version expects them.
   - If code/package changes were made, run relevant `pnpm run build`/lint checks when practical.
   - If verification is blocked, name the concrete blocker and do not claim full verification.

## References

- `references/windows-nest-next-prisma-dev-stack.md` captures a concrete Windows + Docker Desktop + pnpm + NestJS + Next.js/Auth.js + Prisma/Postgres dev-stack recipe, including migration-drift handling and verification commands.
- `references/production-nest-next-compose.md` captures a production multi-stage Docker pattern for NestJS + Next.js Compose stacks, including npm lockfile handling and ad-hoc verification when Docker daemon is unavailable.

## Pitfalls

- `localhost` inside a container points to that container, not the host or another service.
- A Compose `env_file` may not satisfy an application that explicitly checks for an on-disk `.env` file.
- `depends_on` without a healthcheck does not guarantee readiness.
- Prisma migration failures are often real schema/migration-state problems; do not repair them with reset or db push without explicit approval.
- Windows bind mounts are slow for dependency and build-cache directories; do not bind-mount host `node_modules` into Linux containers.
- When editing Windows workspaces via Hermes file tools, use Windows absolute paths such as `C:\Users\...`, not Git Bash/WSL-style `/c/Users/...`; the latter can be interpreted as `C:\c\...` and create stray files outside the repo.
- Docker build success does not prove runtime readiness; always check the service endpoints requested by the user.
