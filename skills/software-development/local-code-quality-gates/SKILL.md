---
name: local-code-quality-gates
description: Use when setting up or running local static-analysis quality gates for code review, especially SonarQube-in-Docker review gates for frontend/backend cleanliness checks.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [code-review, sonarqube, static-analysis, quality-gate, docker, qa]
    related_skills: [requesting-code-review, sonarqube-scanner-skill, local-docker-databases]
---

# Local Code Quality Gates

## Overview

Use this skill to install, verify, and operate local quality-gate services that support code review. The main pattern is a local SonarQube server in Docker plus a scanner helper that is invoked only during explicit review/tester verification, not during ordinary implementation.

The goal is to make QA/reviewer agents catch frontend/backend maintainability, security, and cleanliness issues with a repeatable gate instead of relying only on manual inspection.

## When to Use

- User asks to set up SonarQube, sonar-scanner, or a local code-quality gate.
- User asks that tester/QA reviewers enforce cleaner frontend/backend code.
- User asks whether a tester profile has access to SonarQube review skills.
- During explicit code review, tester review, pre-commit verification, or “review code bằng SonarQube”.

Do **not** use this for ordinary implementation turns unless the user explicitly asks to review/verify code quality.

## Local SonarQube Review Stack Pattern

Recommended local setup:

| Component | Default |
|---|---|
| SonarQube container | `sonarqube-local` |
| SonarQube image | `sonarqube:community` |
| UI/API | `http://localhost:9000` |
| Scanner | `sonarsource/sonar-scanner-cli:latest` in Docker |
| Helper script | `~/AppData/Local/hermes/scripts/sonarqube-review.sh` |
| Env/token file | `~/AppData/Local/hermes/sonarqube/sonar.env` |

Use Docker scanner instead of requiring host Java/sonar-scanner on Windows. Attach the scanner container and SonarQube container to a shared Docker network so the scanner can reach `http://sonarqube-local:9000` while host-side API checks use `http://localhost:9000`.

## Setup Workflow

1. **Check prerequisites**
   - Docker CLI and daemon are available.
   - Port `9000` is not already occupied.
   - Existing `sonarqube-local` container is inspected before replacing.

2. **Bootstrap SonarQube**
   - Prefer the local helper bootstrap path when available: `~/AppData/Local/hermes/scripts/sonarqube-review.sh --bootstrap`.
   - Bootstrap should pull `sonarqube:community`, create/start `sonarqube-local` with persistent data/extensions/logs volumes, attach `sonarqube-review-net`, and wait for `http://localhost:9000/api/system/status` to report `UP`.
   - Use manual `docker run` only when the helper is unavailable or being repaired.

3. **Wait for readiness**
   - Poll `http://localhost:9000/api/system/status` until `status` is `UP`.
   - Do not report success while status is `STARTING` or while only the TCP port is open.

4. **Initialize credentials/token**
   - First login is usually `admin/admin`.
   - Newer SonarQube versions enforce strong admin passwords; if `root` is too weak, use a strong local password and store it in the local env file.
   - Generate a dedicated scanner token such as `hermes-review-token`.
   - Store token in `~/AppData/Local/hermes/sonarqube/sonar.env`; do not print the full token in chat.

5. **Create/reuse review helper**
   - The helper should support a bootstrap-only mode for creating/starting SonarQube before a scanner token exists.
   - For scans, it should auto-start Docker Desktop on Windows if `docker info` is unreachable, start SonarQube if needed, wait for readiness, run scanner in Docker, then query quality gate and unresolved issues.
   - After scanner upload, retry quality-gate API reads briefly because Compute Engine may still be processing and can return an early `NONE` status.
   - It should write `.sonarqube-quality-gate.json` and `.sonarqube-issues.json` in the reviewed repo.
   - It should print a compact line: `SONAR_SUMMARY quality_gate=<status> unresolved_issues=<count>`.
   - It should stop `sonarqube-local` after scan results are returned, unless `--keep-running` was passed or `--bootstrap` mode is used.

6. **Verify with a real scan**
   - Create or use a small sample project.
   - Run the helper.
   - Confirm scanner logs include `ANALYSIS SUCCESSFUL` and `EXECUTION SUCCESS`.
   - Confirm the summary line is parsed correctly.

## Review-Time Usage

From a repository root:

```bash
~/AppData/Local/hermes/scripts/sonarqube-review.sh "$(pwd)" "$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')"
```

Treat these as blockers unless the user explicitly downgrades severity:

- Quality gate failure.
- BLOCKER/CRITICAL issues.
- Vulnerabilities or security hotspots.
- Clear frontend/backend maintainability bugs likely to cause production defects.

Style-only code smells should be fixed when cheap, otherwise reported as non-blocking recommendations with file/line evidence.

## Tester / Kanban Verification

When the user asks to “ask tester” or “bật mode /kanban hỏi tester”, use Kanban rather than just asserting the tester knows.

Create a task assigned to `tester` that asks the tester profile to verify:

- `sonarqube-scanner-skill` is available or loadable.
- `requesting-code-review` includes the SonarQube review gate.
- The helper script exists.
- SonarQube API responds at `http://localhost:9000`.
- Tester can run the gate during review tasks.

A good tester result shape is:

```text
STATUS: AVAILABLE | PARTIAL | MISSING
Skills: ...
Helper: ...
API: ...
Gaps: ...
```

## Common Pitfalls

1. **Confusing skill installation with working SonarQube.** A skill only teaches the workflow; SonarQube server, scanner, token, and project scan still need setup and verification.

2. **Running SonarQube during implementation.** Keep it review-only unless asked. This avoids slowing normal dev loops.

3. **Using host URL inside scanner container.** `localhost:9000` inside the scanner container points to the scanner container, not SonarQube. Use `http://sonarqube-local:9000` via a shared Docker network for scanner execution.

4. **Reporting startup before API is UP.** SonarQube may accept TCP while still `STARTING`. Poll `/api/system/status`.

5. **Leaking tokens.** Store scanner tokens locally and redact them in chat. Report token file path, not token value.

6. **Windows path confusion in Bash/Python.** When a Bash script passes MSYS paths to Python, convert with `cygpath -w` before `Path(...)` if Python is Windows-native.

## Reference Files

- `references/sonarqube-local-review-stack.md` — concrete session-derived details for the local SonarQube Docker + scanner helper setup, verification output shape, and Kanban tester check.
- `references/sonarqube-docker-bootstrap-and-gate-retry.md` — bootstrap-only helper pattern, token setup, container networking, and bounded quality-gate retry to avoid early `NONE` statuses.

## Verification Checklist

- [ ] Docker daemon is reachable, or the helper auto-starts Docker Desktop and then Docker becomes reachable.
- [ ] SonarQube container exists and is `Up` during scan/bootstrap.
- [ ] `curl http://localhost:9000/api/system/status` returns `status: UP` during scan/bootstrap.
- [ ] Scanner token exists in the local env file.
- [ ] Docker scanner image is available or pullable.
- [ ] Review helper is executable.
- [ ] A real scan returns `ANALYSIS SUCCESSFUL` and `EXECUTION SUCCESS`.
- [ ] `.sonarqube-quality-gate.json` and `.sonarqube-issues.json` are written.
- [ ] Scan mode stops `sonarqube-local` after returning results unless `--keep-running` was used.
- [ ] Review workflow/QA tester uses the gate only for explicit review tasks.
