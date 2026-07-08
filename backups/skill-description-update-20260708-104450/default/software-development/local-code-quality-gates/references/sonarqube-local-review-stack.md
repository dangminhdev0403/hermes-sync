# SonarQube Local Review Stack Reference

## Purpose

Session-derived reference for setting up a local SonarQube quality gate that QA/tester agents invoke only during explicit code review or pre-commit verification.

## Working Setup

| Item | Value |
|---|---|
| SonarQube container | `sonarqube-local` |
| SonarQube image | `sonarqube:community` |
| UI/API | `http://localhost:9000` |
| Scanner image | `sonarsource/sonar-scanner-cli:latest` |
| Helper script | `~/AppData/Local/hermes/scripts/sonarqube-review.sh` |
| Env file | `~/AppData/Local/hermes/sonarqube/sonar.env` |
| Token name | `hermes-review-token` |
| Shared Docker network | `sonarqube-review-net` |

## Key Commands

Start SonarQube with persistent volumes:

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

Wait for readiness:

```bash
for i in $(seq 1 90); do
  status=$(curl -fsS http://localhost:9000/api/system/status 2>/dev/null || true)
  echo "[$i] ${status:-not-ready}"
  echo "$status" | grep -q '"status":"UP"' && exit 0
  sleep 5
done
exit 1
```

Run a review scan from repo root:

```bash
~/AppData/Local/hermes/scripts/sonarqube-review.sh "$(pwd)" "$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')"
```

Expected successful scan markers:

```text
ANALYSIS SUCCESSFUL
EXECUTION SUCCESS
SONAR_SUMMARY quality_gate=OK unresolved_issues=0
```

## Important Implementation Notes

- `localhost:9000` is correct from the host, but not from the scanner container.
- The scanner container should reach SonarQube through `http://sonarqube-local:9000` on a shared Docker network.
- The helper can maintain two URLs:
  - `SONAR_HOST_URL=http://localhost:9000`
  - `SONAR_DOCKER_HOST_URL=http://sonarqube-local:9000`
- Store scanner token in `~/AppData/Local/hermes/sonarqube/sonar.env`; do not print full token.
- On Windows Git Bash, convert project paths for Python summary parsing with `cygpath -w` before using `pathlib.Path` in Windows-native Python.

## SonarQube Password Caveat

Newer SonarQube versions may reject weak admin passwords such as `root` with validation errors like:

```text
Password must be at least 12 characters long
Password must contain at least one uppercase character
```

Use a strong local admin password and store it in the env file. The scanner uses a token, not the admin password.

## Kanban Tester Check

To verify the tester profile can use the review gate, create a Kanban task assigned to `tester` with forced skills:

```bash
hermes kanban create "Tester: verify SonarQube review skill availability" \
  --assignee tester \
  --skill sonarqube-scanner-skill \
  --skill requesting-code-review \
  --max-runtime 10m \
  --body "Check that tester can see SonarQube review skills, helper script, and API; return AVAILABLE/PARTIAL/MISSING with evidence." \
  --json

hermes kanban dispatch
```

Expected tester answer shape:

```text
STATUS: AVAILABLE | PARTIAL | MISSING
Skills: sonarqube-scanner-skill=<yes/no>, requesting-code-review=<yes/no>
Helper: exists=<yes/no>
API: UP=<yes/no>
Gaps: ...
```
