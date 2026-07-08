---
name: local-docker-databases
description: Set up, replace, and verify local development databases in Docker, especially PostgreSQL/MySQL/Redis-style services with durable volumes and connection details.
---

# Local Docker Databases

Use this skill when the user asks to install, run, replace, or troubleshoot a local database service in Docker for development.

## Core workflow

1. **Clarify only when necessary**
   - If the user gives an obvious target such as “local PostgreSQL in Docker”, act immediately.
   - Use safe local defaults unless the user specifies otherwise.
   - If the user requests “latest”, “current”, or a specific major version, do not assume from memory: pull/inspect/run the image to verify the actual version.

2. **Check prerequisites**
   - Verify Docker CLI and daemon are available:
     ```bash
     docker --version
     docker info --format '{{json .ServerVersion}}'
     ```
   - Check for an existing container with the planned name before creating a new one:
     ```bash
     docker ps -a --filter name=^/<container-name>$ --format '{{.Names}} {{.Status}} {{.Ports}}'
     ```

3. **Create an intentional container layout**
   - Use a stable, predictable container name such as `postgres-local`.
   - Use a named Docker volume for data persistence.
   - Set an explicit restart policy for local services, usually `--restart unless-stopped`.
   - Map the default service port unless the user asks otherwise.

4. **Verify the exact running version**
   - For PostgreSQL:
     ```bash
     docker pull postgres:latest
     docker run --rm postgres:latest postgres --version
     ```
   - After the real container starts, verify readiness and query the server:
     ```bash
     docker exec postgres-local pg_isready -U postgres
     docker exec postgres-local psql -U postgres -d postgres -c "SELECT version();"
     docker ps --filter name=^/postgres-local$ --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}'
     ```

5. **Deliver connection info, not just success text**
   Always return the fields the user needs to connect:
   - host
   - port
   - database
   - username
   - password, if the user explicitly provided or requested it
   - container name
   - image/tag
   - version verified from the running server
   - volume name
   - connection string
   - basic start/stop/logs/psql commands

## PostgreSQL local defaults

When the user asks for local PostgreSQL and provides password `root`, a good default is:

| Field | Value |
|---|---|
| Container | `postgres-local` |
| Image | `postgres:latest` if the user asks latest, otherwise a pinned supported major version |
| Host | `localhost` |
| Port | `5432` |
| Database | `postgres` |
| Username | `postgres` |
| Password | user-provided value |
| Restart | `unless-stopped` |

Example PostgreSQL 18+ command:

```bash
docker volume create postgres-local-data
docker run -d --name postgres-local \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=root \
  -e POSTGRES_DB=postgres \
  -p 5432:5432 \
  -v postgres-local-data:/var/lib/postgresql \
  --restart unless-stopped \
  postgres:latest
```

## PostgreSQL 18+ Docker image pitfall

PostgreSQL Docker images from **18+** changed the data directory layout to use major-version-specific directories compatible with `pg_ctlcluster`.

For PostgreSQL 18+:

- Prefer mounting the named volume at:
  ```bash
  -v postgres-local-data:/var/lib/postgresql
  ```
- Avoid the old habit for fresh PostgreSQL 18+ containers:
  ```bash
  -v postgres-local-data:/var/lib/postgresql/data
  ```

If a PostgreSQL 18+ container keeps restarting and logs mention existing data in `/var/lib/postgresql/data (unused mount/volume)`, recreate the container with the volume mounted at `/var/lib/postgresql`. For a fresh local dev database, removing and recreating the named volume is acceptable only if the user does not need the data preserved.

## Replacement workflow

When replacing a mistaken local dev database version:

1. Pull and verify the requested image/tag.
2. Stop and remove the old container.
3. Remove the old named volume only if the data is disposable or the user has approved losing it.
4. Recreate the volume and container with the correct mount layout.
5. Wait for readiness, then run a real query.
6. Report verified output.

## Safety notes

- Do not fabricate successful startup. Confirm with `pg_isready`, a SQL query, and `docker ps`.
- For destructive operations (`docker rm -f`, `docker volume rm`), ensure the context is local/dev and data is disposable, or ask before deleting.
- If port `5432` is already occupied, either identify the occupying container/process or map to another host port and clearly report the changed connection details.

## References

- `references/postgresql-18-docker-local.md` — session-derived notes on PostgreSQL 18+ Docker `latest`, mount layout, restart-loop symptom, and verified commands.
