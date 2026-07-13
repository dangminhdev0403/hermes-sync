---
name: "SonarQube Scanner Skill"
slug: "sonarqube-scanner-skill"
description: "Use when running explicit code-review/tester verification with a local Docker SonarQube quality gate. Ensures SonarQube Community runs in Docker, runs sonar-scanner via Docker, reads quality gate/issues from the Web API, and maps findings to source lines for review notes."
github_stars: 10433
verification: "security_reviewed"
source: "https://github.com/SonarSource/sonarqube"
category: "Code Quality & Review"
framework: "Claude Code"
tool_ecosystem:
  github_repo: "sonarsource/sonarqube"
  github_stars: 10433
---

# SonarQube Scanner Skill

## Overview

Use this skill only for **explicit code review / tester verification** that needs a local SonarQube quality gate. It is not part of ordinary implementation unless the user specifically asks for a review gate.

The local stack is Docker-first: run SonarQube Community in a container and run `sonarsource/sonar-scanner-cli` in a second container. Do **not** install Java or the scanner on the Windows host just to run this workflow.

## When to Use

- The user asks for SonarQube review, quality gate, static analysis, or tester verification.
- A code-review workflow explicitly requires SonarQube issue/quality-gate evidence.
- A specialist/tester profile must verify frontend/backend cleanliness with the local review gate.

Do **not** use this skill for normal feature implementation, formatting, or routine tests unless requested.

## Local Hermes Setup

| Item | Value |
|---|---|
| SonarQube container | `sonarqube-local` |
| SonarQube image | `sonarqube:community` |
| UI/API | `http://localhost:9000` |
| Scanner image | `sonarsource/sonar-scanner-cli:latest` |
| Review helper | `~/AppData/Local/hermes/scripts/sonarqube-review.sh` |
| Env file | `~/AppData/Local/hermes/sonarqube/sonar.env` |
| Shared Docker network | `sonarqube-review-net` |

## Prerequisites

1. Docker Desktop / Docker daemon is available; on Windows the helper attempts to auto-start Docker Desktop if `docker info` is unreachable.
2. `sonarqube-local` exists or can be created from `sonarqube:community`; the helper creates/starts it automatically when Docker is reachable.
3. `~/AppData/Local/hermes/sonarqube/sonar.env` exists with:
   ```bash
   SONAR_HOST_URL=http://localhost:9000
   SONAR_DOCKER_HOST_URL=http://sonarqube-local:9000
   SONAR_TOKEN=<scanner token>
   # Optional admin bootstrap fields, do not print secrets:
   SONAR_ADMIN_USER=admin
   SONAR_ADMIN_PASSWORD=<local strong password>
   ```

## Install / Bootstrap SonarQube with Docker

For a first-time local setup, let the helper create/start SonarQube and wait for readiness:

```bash
~/AppData/Local/hermes/scripts/sonarqube-review.sh --bootstrap
```

Equivalent manual Docker bootstrap, if needed:

```bash
docker pull sonarqube:community
docker run -d --name sonarqube-local \
  -p 9000:9000 \
  -v sonarqube-local-data:/opt/sonarqube/data \
  -v sonarqube-local-extensions:/opt/sonarqube/extensions \
  -v sonarqube-local-logs:/opt/sonarqube/logs \
  --restart unless-stopped \
  sonarqube:community
```

If this is a fresh SonarQube install, open `http://localhost:9000`, log in with the initial admin account, set a strong local password, and create a user token for scanner use. Save only the token in `sonar.env`; never print the full token in summaries.

## Run a Review Scan

From a repository root:

```bash
~/AppData/Local/hermes/scripts/sonarqube-review.sh "$(pwd)" "$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')"
```

Default scan behavior auto-starts Docker Desktop when needed and stops `sonarqube-local` after results are printed. Use `--keep-running` only when you intentionally want the SonarQube UI/container to remain up after the scan.

The helper:

1. Verifies `sonar.env` and `SONAR_TOKEN`.
2. Creates `sonarqube-local` from `sonarqube:community` if missing, or starts it if it exists but is stopped.
3. Ensures scanner and SonarQube share `sonarqube-review-net`.
4. Waits for `http://localhost:9000/api/system/status` to return `UP`.
5. Runs scanner via Docker with `SONAR_DOCKER_HOST_URL=http://sonarqube-local:9000`.
6. Retries quality-gate API reads briefly until Compute Engine finishes processing instead of saving an early `NONE` status.
7. Writes `.sonarqube-quality-gate.json` and `.sonarqube-issues.json` in the project root.
8. Prints `SONAR_SUMMARY quality_gate=<status> unresolved_issues=<count>` plus sample issues.
9. Stops `sonarqube-local` after the result is returned, unless `--keep-running` is passed or `--bootstrap` mode is used.

Expected successful markers:

```text
ANALYSIS SUCCESSFUL
EXECUTION SUCCESS
SONAR_SUMMARY quality_gate=OK unresolved_issues=0
```

## Common Pitfalls

1. **Docker Desktop not running.** `docker --version` can succeed while `docker info` fails with `dockerDesktopLinuxEngine` missing. The helper attempts to start Docker Desktop on Windows; if it times out, start Docker Desktop manually and rerun.
2. **Container auto-shutdown.** Scan mode stops `sonarqube-local` after results are returned to avoid leaving the service running. Use `--keep-running` when you need to inspect the UI after a scan.
3. **Container missing / first bootstrap.** The helper creates `sonarqube-local` automatically when Docker is reachable, but a fresh SonarQube still needs initial admin login and scanner-token creation.
4. **Wrong URL from scanner container.** Host uses `http://localhost:9000`; scanner container uses `http://sonarqube-local:9000` on the shared Docker network.
5. **Weak admin password.** New SonarQube versions reject weak passwords. Use a strong local password, then create a scanner token.
6. **Secret leakage.** Do not paste or summarize full `SONAR_TOKEN` / admin password.
7. **Windows Git Bash paths.** Pass repository paths from Git Bash as `$(pwd)`; the helper handles Windows path conversion for the Python summary.

## Verification Checklist

- [ ] `docker info` succeeds, or the helper auto-starts Docker Desktop and then `docker info` succeeds.
- [ ] `docker ps -a --filter name=sonarqube-local` shows the container exists.
- [ ] `curl -fsS http://localhost:9000/api/system/status` eventually returns `{"status":"UP"...}` while the scan is running.
- [ ] `sonar.env` exists and contains `SONAR_TOKEN` without printing it.
- [ ] The review helper finishes with `ANALYSIS SUCCESSFUL` / `EXECUTION SUCCESS`.
- [ ] `.sonarqube-quality-gate.json` and `.sonarqube-issues.json` are created in the scanned repo.
- [ ] Final review reports quality-gate status and issue counts with file/line evidence where available.
- [ ] After scan mode completes, `sonarqube-local` is stopped unless `--keep-running` was used.

## Source

- [SonarQube Community Build](https://github.com/SonarSource/sonarqube)
- [Agent Skill Exchange entry](https://agentskillexchange.com/skills/sonarqube-scanner-skill/)
