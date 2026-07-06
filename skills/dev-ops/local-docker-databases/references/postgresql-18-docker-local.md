# PostgreSQL 18+ in Docker for local development

Session-derived reference for local PostgreSQL installation/replacement in Docker.

## Verified image behavior

`postgres:latest` resolved to PostgreSQL 18.4 in the observed session:

```text
postgres (PostgreSQL) 18.4 (Debian 18.4-1.pgdg13+1)
```

Do not rely on that exact patch version staying current. Pull and verify at runtime:

```bash
docker pull postgres:latest
docker run --rm postgres:latest postgres --version
```

## PostgreSQL 18+ volume mount layout

For PostgreSQL Docker images 18+, mount the persistent named volume at:

```bash
-v postgres-local-data:/var/lib/postgresql
```

A container using the older PostgreSQL mount pattern:

```bash
-v postgres-local-data:/var/lib/postgresql/data
```

can restart repeatedly on 18+ with logs like:

```text
Error: in 18+, these Docker images are configured to store database data in a
       format which is compatible with "pg_ctlcluster" ...

Counter to that, there appears to be PostgreSQL data in:
  /var/lib/postgresql/data (unused mount/volume)
```

For a disposable local dev DB, fix by removing the bad container/volume and recreating with the `/var/lib/postgresql` mount.

## Known-good fresh local command

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

## Verification commands

```bash
for i in $(seq 1 30); do
  if docker exec postgres-local pg_isready -U postgres; then break; fi
  sleep 2
done

docker exec postgres-local psql -U postgres -d postgres -c "SELECT version();"
docker ps --filter name=^/postgres-local$ --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}'
```

Expected connection defaults from the session:

| Field | Value |
|---|---|
| Host | `localhost` |
| Port | `5432` |
| Database | `postgres` |
| Username | `postgres` |
| Password | `root` |
| Container | `postgres-local` |
| Image | `postgres:latest` |
| Volume | `postgres-local-data` |
