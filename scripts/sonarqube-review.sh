#!/usr/bin/env bash
set -euo pipefail

# SonarQube local review helper for Hermes.
# Runs only when explicitly invoked during code review/testing.

usage() {
  cat <<'USAGE'
Usage: sonarqube-review.sh [project_dir] [project_key]

Runs sonar-scanner in Docker against a local SonarQube server.
Defaults:
  project_dir = current directory
  project_key = basename(project_dir)

Requires:
  - Docker running
  - SonarQube container reachable at http://localhost:9000
  - C:\Users\Admin\AppData\Local\hermes\sonarqube\sonar.env with SONAR_TOKEN
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

PROJECT_DIR="${1:-$(pwd)}"
PROJECT_KEY="${2:-$(basename "$PROJECT_DIR" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9_.:-' '-')}"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
ENV_FILE="$HOME/AppData/Local/hermes/sonarqube/sonar.env"
NETWORK="sonarqube-review-net"
SONAR_CONTAINER="sonarqube-local"

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "ERROR: project_dir does not exist: $PROJECT_DIR" >&2
  exit 2
fi
if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: missing env file: $ENV_FILE" >&2
  exit 2
fi
# shellcheck disable=SC1090
source "$ENV_FILE"
: "${SONAR_TOKEN:?SONAR_TOKEN missing in $ENV_FILE}"
SONAR_HOST_URL="${SONAR_HOST_URL:-http://localhost:9000}"
SONAR_DOCKER_HOST_URL="${SONAR_DOCKER_HOST_URL:-http://sonarqube-local:9000}"

if ! docker ps --filter "name=^/${SONAR_CONTAINER}$" --format '{{.Names}} {{.Status}}' | grep -q "^${SONAR_CONTAINER} .*Up"; then
  echo "Starting $SONAR_CONTAINER..." >&2
  docker start "$SONAR_CONTAINER" >/dev/null
fi

# Ensure a shared network so scanner container can reach SonarQube by container name.
docker network inspect "$NETWORK" >/dev/null 2>&1 || docker network create "$NETWORK" >/dev/null
if ! docker inspect "$SONAR_CONTAINER" --format '{{json .NetworkSettings.Networks}}' | grep -q "\"$NETWORK\""; then
  docker network connect "$NETWORK" "$SONAR_CONTAINER" >/dev/null 2>&1 || true
fi

# Wait for server UP.
for i in $(seq 1 60); do
  status="$(curl -fsS "$SONAR_HOST_URL/api/system/status" 2>/dev/null || true)"
  if echo "$status" | grep -q '"status":"UP"'; then
    break
  fi
  if [[ "$i" == "60" ]]; then
    echo "ERROR: SonarQube not UP after waiting. Last status: ${status:-empty}" >&2
    exit 3
  fi
  sleep 2
done

# Exclude common generated/vendor directories by default.
EXCLUSIONS="**/node_modules/**,**/dist/**,**/build/**,**/.next/**,**/coverage/**,**/.git/**,**/vendor/**,**/.venv/**,**/venv/**,**/target/**,**/.turbo/**"

echo "Running SonarQube scan"
echo "  project_dir=$PROJECT_DIR"
echo "  project_key=$PROJECT_KEY"
echo "  sonar_host=$SONAR_HOST_URL"

# Docker scanner avoids requiring Java/sonar-scanner installed on Windows host.
docker run --rm \
  --network "$NETWORK" \
  -e SONAR_HOST_URL="$SONAR_DOCKER_HOST_URL" \
  -e SONAR_TOKEN="$SONAR_TOKEN" \
  -v "$PROJECT_DIR:/usr/src" \
  sonarsource/sonar-scanner-cli:latest \
  -Dsonar.projectKey="$PROJECT_KEY" \
  -Dsonar.projectName="$PROJECT_NAME" \
  -Dsonar.sources=. \
  -Dsonar.exclusions="$EXCLUSIONS"

# Query quality gate and top issues from host API.
echo
printf 'Quality Gate: '
curl -fsS -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/qualitygates/project_status?projectKey=$(python - <<PY
from urllib.parse import quote
print(quote('''$PROJECT_KEY'''))
PY
)" | tee "$PROJECT_DIR/.sonarqube-quality-gate.json"

echo
echo "Top issues saved to $PROJECT_DIR/.sonarqube-issues.json"
curl -fsS -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/issues/search?componentKeys=$(python - <<PY
from urllib.parse import quote
print(quote('''$PROJECT_KEY'''))
PY
)&resolved=false&ps=100&facets=severities,types" > "$PROJECT_DIR/.sonarqube-issues.json"

PROJECT_DIR_FOR_PY="$(cygpath -w "$PROJECT_DIR" 2>/dev/null || printf '%s' "$PROJECT_DIR")"
PROJECT_DIR_FOR_PY="$PROJECT_DIR_FOR_PY" python - <<'PY'
import json, os
from pathlib import Path
project_dir = Path(os.environ['PROJECT_DIR_FOR_PY'])
q = project_dir / '.sonarqube-quality-gate.json'
i = project_dir / '.sonarqube-issues.json'
try:
    qdata = json.loads(q.read_text(encoding='utf-8'))
    status = qdata.get('projectStatus', {}).get('status')
except Exception as e:
    status = f'UNKNOWN ({e})'
try:
    idata = json.loads(i.read_text(encoding='utf-8'))
    issues = idata.get('total', 0)
    sample = idata.get('issues', [])[:10]
except Exception as e:
    issues = f'UNKNOWN ({e})'
    sample = []
print(f'SONAR_SUMMARY quality_gate={status} unresolved_issues={issues}')
for item in sample:
    print(f"- {item.get('severity')} {item.get('type')} {item.get('component')}:{item.get('line','?')} {item.get('message')}")
PY
