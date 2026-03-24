#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_COMPOSE="${ROOT_DIR}/docker-compose.base.yml"
ACTIVE_COLOR_FILE="${ACTIVE_COLOR_FILE:-${ROOT_DIR}/proxy/state/active_color}"
ACTIVE_UPSTREAM_FILE="${ACTIVE_UPSTREAM_FILE:-${ROOT_DIR}/proxy/upstreams/active-upstream.conf}"

target_color="${ROLLBACK_TO:-${1:-}}"

if [[ "${target_color}" != "blue" && "${target_color}" != "green" ]]; then
  echo "Usage: ROLLBACK_TO=blue|green ./scripts/rollback.sh" >&2
  echo "   or: ./scripts/rollback.sh blue|green" >&2
  exit 1
fi

cat <<EOF > "${ACTIVE_UPSTREAM_FILE}"
set \$frontend_upstream http://frontend-${target_color}:80;
set \$backend_upstream http://backend-${target_color}:3000;
EOF

echo "${target_color}" > "${ACTIVE_COLOR_FILE}"

docker compose -f "${BASE_COMPOSE}" exec -T reverse-proxy nginx -s reload

echo "Rollback complete. Active color: ${target_color}"
