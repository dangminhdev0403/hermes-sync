#!/usr/bin/env bash
set -euo pipefail

# SonarQube local review helper for Hermes.
# Runs only when explicitly invoked during code review/testing.

usage() {
  cat <<'USAGE'
Usage: sonarqube-review.sh [options] [project_dir] [project_key]

Runs sonar-scanner in Docker against a local SonarQube server.
Defaults:
  project_dir = current directory
  project_key = basename(project_dir)

Options:
  --bootstrap              Create/start the local SonarQube Docker container
                           and wait for http://localhost:9000 to report UP.
                           No scanner token or project scan is required.
  --keep-running           Do not stop sonarqube-local after a scan. Bootstrap
                           mode also leaves SonarQube running.
  --no-auto-start-docker   If Docker daemon is down, fail instead of trying to
                           start Docker Desktop on Windows.
  -h, --help               Show this help.

Default scan behavior:
  - Auto-start Docker Desktop when docker info is unreachable on Windows.
  - Create/start sonarqube-local as needed.
  - Run scanner, write result JSON files, print SONAR_SUMMARY.
  - Stop sonarqube-local after the scan result has been returned.

Requires for scans:
  - Docker Desktop / Docker daemon available
  - SonarQube reachable at http://localhost:9000 after startup
  - $HOME/AppData/Local/hermes/sonarqube/sonar.env with SONAR_TOKEN

First bootstrap flow:
  1. sonarqube-review.sh --bootstrap
  2. Open http://localhost:9000
  3. Complete initial admin login/password setup
  4. Create a scanner token and save it to sonar.env
  5. Run sonarqube-review.sh [project_dir] [project_key]
USAGE
}

BOOTSTRAP_ONLY=0
AUTO_STOP=1
AUTO_START_DOCKER=1

while [[ $# -gt 0 ]]; do
  case "${1:-}" in
    -h|--help)
      usage
      exit 0
      ;;
    --bootstrap)
      BOOTSTRAP_ONLY=1
      shift
      ;;
    --keep-running)
      AUTO_STOP=0
      shift
      ;;
    --no-auto-start-docker)
      AUTO_START_DOCKER=0
      shift
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "ERROR: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      break
      ;;
  esac
done

# Bootstrap is an explicit setup/readiness action; leave the UI available so the
# user can finish first-login/token setup.
if [[ "$BOOTSTRAP_ONLY" == "1" ]]; then
  AUTO_STOP=0
fi

PROJECT_DIR="${1:-$(pwd)}"
PROJECT_KEY="${2:-$(basename "$PROJECT_DIR" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9_.:-' '-')}"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
ENV_FILE="$HOME/AppData/Local/hermes/sonarqube/sonar.env"
NETWORK="sonarqube-review-net"
SONAR_CONTAINER="sonarqube-local"
SONAR_IMAGE="sonarqube:community"
SONAR_HOST_URL="${SONAR_HOST_URL:-http://localhost:9000}"
SONAR_DOCKER_HOST_URL="${SONAR_DOCKER_HOST_URL:-http://sonarqube-local:9000}"
DOCKER_START_TIMEOUT_SECONDS="${SONAR_DOCKER_START_TIMEOUT_SECONDS:-300}"
STOP_ON_EXIT_ARMED=0

# Load optional local settings before bootstrap/wait. A missing env file is OK
# for --bootstrap, but a scan still requires SONAR_TOKEN below.
if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  SONAR_HOST_URL="${SONAR_HOST_URL:-http://localhost:9000}"
  SONAR_DOCKER_HOST_URL="${SONAR_DOCKER_HOST_URL:-http://sonarqube-local:9000}"
fi

start_docker_desktop() {
  python - <<'PY'
from pathlib import Path
import subprocess
import sys

candidates = [
    Path(r"C:\Program Files\Docker\Docker\Docker Desktop.exe"),
    Path(r"C:\Program Files\Docker\Docker\frontend\Docker Desktop.exe"),
]
creationflags = 0
for name in ("DETACHED_PROCESS", "CREATE_NEW_PROCESS_GROUP"):
    creationflags |= getattr(subprocess, name, 0)
for path in candidates:
    if path.exists():
        subprocess.Popen(
            [str(path)],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            creationflags=creationflags,
            close_fds=True,
        )
        print(path)
        sys.exit(0)
print("Docker Desktop.exe not found in standard install paths", file=sys.stderr)
sys.exit(1)
PY
}

ensure_docker() {
  if docker info >/dev/null 2>&1; then
    return 0
  fi

  if [[ "$AUTO_START_DOCKER" != "1" ]]; then
    echo "ERROR: Docker daemon is not reachable. Start Docker Desktop / Docker daemon, then retry." >&2
    exit 2
  fi

  echo "Docker daemon is not reachable; attempting to start Docker Desktop..." >&2
  if ! docker_desktop_path="$(start_docker_desktop)"; then
    echo "ERROR: Docker daemon is not reachable and Docker Desktop could not be started automatically." >&2
    exit 2
  fi
  echo "Started Docker Desktop: $docker_desktop_path" >&2

  local waited=0
  while (( waited < DOCKER_START_TIMEOUT_SECONDS )); do
    if docker info >/dev/null 2>&1; then
      echo "Docker daemon is ready." >&2
      return 0
    fi
    sleep 5
    waited=$((waited + 5))
  done

  echo "ERROR: Docker daemon was not ready after ${DOCKER_START_TIMEOUT_SECONDS}s." >&2
  exit 2
}

stop_sonarqube_if_needed() {
  local exit_code=$?
  if [[ "${AUTO_STOP:-0}" == "1" && "${STOP_ON_EXIT_ARMED:-0}" == "1" ]]; then
    if docker info >/dev/null 2>&1 && docker ps --filter "name=^/${SONAR_CONTAINER}$" --format '{{.Names}} {{.Status}}' | grep -q "^${SONAR_CONTAINER} .*Up"; then
      echo "Stopping $SONAR_CONTAINER after scan..." >&2
      docker stop "$SONAR_CONTAINER" >/dev/null 2>&1 || true
    fi
  fi
  exit "$exit_code"
}
trap stop_sonarqube_if_needed EXIT

ensure_sonarqube_container() {
  if ! docker ps -a --filter "name=^/${SONAR_CONTAINER}$" --format '{{.Names}}' | grep -qx "$SONAR_CONTAINER"; then
    echo "Creating $SONAR_CONTAINER from $SONAR_IMAGE..." >&2
    docker pull "$SONAR_IMAGE" >/dev/null
    docker run -d --name "$SONAR_CONTAINER" \
      -p 9000:9000 \
      -v sonarqube-local-data:/opt/sonarqube/data \
      -v sonarqube-local-extensions:/opt/sonarqube/extensions \
      -v sonarqube-local-logs:/opt/sonarqube/logs \
      --restart unless-stopped \
      "$SONAR_IMAGE" >/dev/null
  elif ! docker ps --filter "name=^/${SONAR_CONTAINER}$" --format '{{.Names}} {{.Status}}' | grep -q "^${SONAR_CONTAINER} .*Up"; then
    echo "Starting $SONAR_CONTAINER..." >&2
    docker start "$SONAR_CONTAINER" >/dev/null
  fi

  STOP_ON_EXIT_ARMED=1

  # Shared network lets the scanner container reach SonarQube by container name.
  docker network inspect "$NETWORK" >/dev/null 2>&1 || docker network create "$NETWORK" >/dev/null
  if ! docker inspect "$SONAR_CONTAINER" --format '{{json .NetworkSettings.Networks}}' | grep -q "\"$NETWORK\""; then
    docker network connect "$NETWORK" "$SONAR_CONTAINER" >/dev/null 2>&1 || true
  fi
}

wait_for_sonarqube() {
  for i in $(seq 1 90); do
    status="$(curl -fsS "$SONAR_HOST_URL/api/system/status" 2>/dev/null || true)"
    if echo "$status" | grep -q '"status":"UP"'; then
      return 0
    fi
    if [[ "$i" == "90" ]]; then
      echo "ERROR: SonarQube not UP after waiting. Last status: ${status:-empty}" >&2
      exit 3
    fi
    sleep 5
  done
}

if [[ "$BOOTSTRAP_ONLY" != "1" && ! -d "$PROJECT_DIR" ]]; then
  echo "ERROR: project_dir does not exist: $PROJECT_DIR" >&2
  exit 2
fi

ensure_docker
ensure_sonarqube_container
wait_for_sonarqube

if [[ "$BOOTSTRAP_ONLY" == "1" ]]; then
  echo "SONAR_BOOTSTRAP status=UP url=$SONAR_HOST_URL container=$SONAR_CONTAINER auto_stop=false"
  exit 0
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: missing env file: $ENV_FILE" >&2
  echo "Run: sonarqube-review.sh --bootstrap, create a scanner token in SonarQube, then save SONAR_TOKEN in sonar.env." >&2
  exit 2
fi
: "${SONAR_TOKEN:?SONAR_TOKEN missing in $ENV_FILE}"

# Exclude common generated/vendor directories by default.
EXCLUSIONS="**/node_modules/**,**/dist/**,**/build/**,**/.next/**,**/coverage/**,**/.git/**,**/vendor/**,**/.venv/**,**/venv/**,**/target/**,**/.turbo/**"

echo "Running SonarQube scan"
echo "  project_dir=$PROJECT_DIR"
echo "  project_key=$PROJECT_KEY"
echo "  sonar_host=$SONAR_HOST_URL"
echo "  auto_stop_sonarqube=$AUTO_STOP"

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

# Query quality gate and top issues from host API. Immediately after scanner
# upload, Compute Engine may still be processing and project_status can be
# NONE. Retry briefly so the saved gate reflects the processed analysis.
PROJECT_KEY_ENCODED="$(python - <<PY
from urllib.parse import quote
print(quote('''$PROJECT_KEY'''))
PY
)"
QUALITY_GATE_URL="$SONAR_HOST_URL/api/qualitygates/project_status?projectKey=$PROJECT_KEY_ENCODED"
ISSUES_URL="$SONAR_HOST_URL/api/issues/search?componentKeys=$PROJECT_KEY_ENCODED&resolved=false&ps=100&facets=severities,types"

quality_payload=""
for i in $(seq 1 24); do
  quality_payload="$(curl -fsS -u "$SONAR_TOKEN:" "$QUALITY_GATE_URL")"
  gate_status="$(QUALITY_PAYLOAD="$quality_payload" python - <<'PY'
import json, os
try:
    print(json.loads(os.environ['QUALITY_PAYLOAD']).get('projectStatus', {}).get('status') or '')
except Exception:
    print('')
PY
)"
  if [[ -n "$gate_status" && "$gate_status" != "NONE" ]]; then
    break
  fi
  sleep 3
done

echo
printf 'Quality Gate: '
printf '%s' "$quality_payload" | tee "$PROJECT_DIR/.sonarqube-quality-gate.json"

echo
echo "Top issues saved to $PROJECT_DIR/.sonarqube-issues.json"
curl -fsS -u "$SONAR_TOKEN:" "$ISSUES_URL" > "$PROJECT_DIR/.sonarqube-issues.json"

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
