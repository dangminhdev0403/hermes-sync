# Production NestJS + Next.js Compose Pattern

Session-derived pattern for converting a Dockerized NestJS backend + Next.js frontend from dev containers to production containers.

## Required shape

- Each service Dockerfile is multi-stage:
  - `builder`: copy package metadata/lockfile first, run `npm ci`, copy source, run build, prune dev dependencies with `npm prune --omit=dev`.
  - `runtime`: copy only production `node_modules`, compiled output, package metadata, and required static/config assets.
- Compose should build images and provide env/ports/dependencies only. Do not mount source code or `node_modules`, and do not override `command` to install/build at startup.

## NestJS specifics

- Runtime command: `node dist/main.js`.
- Build command: `npm run build`.
- If Nest emits `dist/src/main.js`, update `tsconfig.build.json` with:

```json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "rootDir": "./src",
    "outDir": "./dist"
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules", "test", "dist", "**/*spec.ts"]
}
```

- Add the `include` guard when non-`src` TypeScript files exist at the service root (for example `prisma.config.ts`); otherwise Nest/tsc can match them by the default `**/*` pattern and fail because they are outside `rootDir`.
- If `incremental` builds appear to succeed without emitting `dist/main.js`, remove stale `tsconfig.build.tsbuildinfo` and rebuild before concluding the config is valid.
- Copy Prisma schema/migrations into the image when Prisma generation or runtime metadata requires them.

## Next.js specifics

- Build command: `npm run build` / `next build`.
- Runtime command: `npm run start -- --hostname 0.0.0.0` / `next start`.
- Runtime image generally needs `.next`, `public`, `node_modules`, `package.json`, and `next.config.*`.
- Ensure `package-lock.json` exists if the user mandates `npm ci`; pnpm-only projects need a generated npm lockfile before Docker build.

## Ad-hoc verification

When Docker Desktop/daemon is unavailable, do not claim a full build. Run `docker compose config` plus a focused script that checks the production invariants:

- no dev runtime commands (`next dev`, `start:dev`, `nest start --watch`, `npm run dev`, `pnpm dev`, `ts-node`)
- Dockerfiles contain builder/runtime stages and `npm ci`
- backend runtime command is `node dist/main.js`
- frontend runtime command uses `next start`
- compose has no source/code volumes, no `node_modules` overrides, no startup install/build command, and no watcher env vars

If the harness asks for fresh verification, create the focused script under the OS temp directory with a `hermes-verify-` filename prefix, run it, and delete it in a `finally`/cleanup step. Label this as ad-hoc verification, not suite green.
