# Windows NestJS + Next.js + Prisma Docker Dev Stack Notes

Session-derived patterns for a Windows + Docker Desktop + pnpm stack with NestJS, Next.js/Auth.js, Prisma, and Postgres.

## Durable patterns

- If a Nest app's env loader checks for a physical `.env`, Compose `env_file` alone is not enough; mount the Docker env file as `/app/.env:ro`.
- Use service DNS names in containers:
  - backend to Postgres: `postgres:5432`
  - frontend server-side to backend: `http://auth-service:8080`
  - browser to backend: `http://localhost:8080`
- Keep source bind-mounted, but put `node_modules` and `.next` in named volumes for Windows performance.
- Guard startup installs: `if [ ! -d node_modules/.pnpm ]; then pnpm install ...; fi`.
- pnpm in noninteractive Docker may need `CI=true` and `PNPM_CONFIG_CONFIRM_MODULES_PURGE=false`; native modules may need an explicit build-script approval/config depending on the pnpm version.
- For Auth.js/NextAuth version transitions, set both `NEXTAUTH_SECRET` and `AUTH_SECRET` consistently to avoid JWT session decrypt errors.

## Prisma migration safety

- `prisma migrate deploy` is safe compared to reset/push, but it can still block app startup when the database has a failed migration record or drift.
- Do not fix drift by running `prisma reset`, `prisma migrate reset`, or `prisma db push` unless the user explicitly approves destructive schema/data work.
- For dev stacks with known drift, make migration-on-start opt-in, e.g. `PRISMA_MIGRATE_ON_START=false`, then run only `prisma generate` before `start:dev` so the app can boot against the existing database.
- Document that migrations remain a separate repair task.

## Verification recipe

```bash
docker compose config
docker compose build
docker compose up -d --build
curl -fsS http://localhost:8080/health
curl -I -fsS http://localhost:3000
docker compose exec -T frontend node -e "fetch('http://auth-service:8080/health').then(async r=>{console.log(r.status); console.log(await r.text())})"
docker compose logs --tail=120 frontend | grep -i 'NEXT_AUTH_ERROR\|JWTSessionError\|no matching decryption secret' || true
```

## Package-manager note

When adding pnpm support to a backend that already has `package-lock.json`, keep the npm lockfile unless the user explicitly requests removal. If dependencies change, update both `package-lock.json` and `pnpm-lock.yaml` or clearly report any lockfile that could not be updated.
