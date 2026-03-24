#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_COMPOSE="${ROOT_DIR}/docker-compose.base.yml"
BLUE_COMPOSE="${ROOT_DIR}/docker-compose.blue.yml"
GREEN_COMPOSE="${ROOT_DIR}/docker-compose.green.yml"
ACTIVE_COLOR_FILE="${ACTIVE_COLOR_FILE:-${ROOT_DIR}/proxy/state/active_color}"
ACTIVE_UPSTREAM_FILE="${ACTIVE_UPSTREAM_FILE:-${ROOT_DIR}/proxy/upstreams/active-upstream.conf}"
PROXY_CONTAINER="${PROXY_CONTAINER:-reverse-proxy}"
HEALTHCHECK_RETRIES="${HEALTHCHECK_RETRIES:-30}"
HEALTHCHECK_SLEEP_SECONDS="${HEALTHCHECK_SLEEP_SECONDS:-2}"
NETWORK_NAME="${NETWORK_NAME:-gym-bluegreen-network}"
VOLUME_NAME="${VOLUME_NAME:-gym-postgres-data}"
LEGACY_PROXY_CONTAINER="${LEGACY_PROXY_CONTAINER:-reverse-proxy}"

: "${GITHUB_SHA:?GITHUB_SHA must be set}"
: "${GHCR_OWNER:?GHCR_OWNER must be set}"

GHCR_OWNER="$(echo "${GHCR_OWNER}" | tr '[:upper:]' '[:lower:]')"

compose() {
  docker compose "$@"
}

compose_color() {
  local color="$1"
  shift

  case "${color}" in
    blue)
      BLUE_IMAGE_TAG="${BLUE_IMAGE_TAG:-$GITHUB_SHA}" \
      GHCR_OWNER="${GHCR_OWNER}" \
      compose -f "${BASE_COMPOSE}" -f "${BLUE_COMPOSE}" "$@"
      ;;
    green)
      GREEN_IMAGE_TAG="${GREEN_IMAGE_TAG:-$GITHUB_SHA}" \
      GHCR_OWNER="${GHCR_OWNER}" \
      compose -f "${BASE_COMPOSE}" -f "${GREEN_COMPOSE}" "$@"
      ;;
    *)
      echo "Unsupported color: ${color}" >&2
      exit 1
      ;;
  esac
}

service_names() {
  local color="$1"
  if [[ "${color}" == "blue" ]]; then
    echo "backend-blue frontend-blue"
  else
    echo "backend-green frontend-green"
  fi
}

base_compose() {
  compose -f "${BASE_COMPOSE}" "$@"
}

service_container_id() {
  local compose_file="$1"
  local service_name="$2"
  compose -f "${BASE_COMPOSE}" -f "${compose_file}" ps -q "${service_name}"
}

write_active_upstream() {
  local color="$1"
  cat <<EOF > "${ACTIVE_UPSTREAM_FILE}"
set \$frontend_upstream http://frontend-${color}:80;
set \$backend_upstream http://backend-${color}:3000;
EOF
}

wait_for_service_health() {
  local service_name="$1"
  local compose_file="$2"
  local attempt=1

  while (( attempt <= HEALTHCHECK_RETRIES )); do
    local status
    local container_id
    container_id="$(service_container_id "${compose_file}" "${service_name}")"
    status="$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "${container_id}" 2>/dev/null || true)"
    if [[ "${status}" == "healthy" || "${status}" == "running" ]]; then
      echo "Service ${service_name} is ${status}"
      return 0
    fi

    echo "Waiting for ${service_name} to become healthy (attempt ${attempt}/${HEALTHCHECK_RETRIES})"
    sleep "${HEALTHCHECK_SLEEP_SECONDS}"
    ((attempt++))
  done

  echo "Service ${service_name} did not become healthy in time" >&2
  local container_id
  container_id="$(service_container_id "${compose_file}" "${service_name}")"
  docker logs "${container_id}" || true
  return 1
}

verify_proxy() {
  local expected_color="$1"
  local health_url="${PROXY_HEALTH_URL:-http://127.0.0.1/health}"

  echo "Verifying proxy routing against ${expected_color} using ${health_url}"
  curl --fail --silent --show-error "${health_url}" >/dev/null
  echo "Proxy is serving ${expected_color}"
}

ensure_base_stack() {
  mkdir -p "$(dirname "${ACTIVE_COLOR_FILE}")" "$(dirname "${ACTIVE_UPSTREAM_FILE}")"
  if [[ ! -f "${ACTIVE_COLOR_FILE}" ]]; then
    echo "blue" > "${ACTIVE_COLOR_FILE}"
  fi

  if [[ ! -f "${ACTIVE_UPSTREAM_FILE}" ]]; then
    write_active_upstream "blue"
  fi

  if docker inspect "${LEGACY_PROXY_CONTAINER}" >/dev/null 2>&1; then
    echo "Removing legacy proxy container ${LEGACY_PROXY_CONTAINER} to free port 80"
    docker rm -f "${LEGACY_PROXY_CONTAINER}" >/dev/null
  fi

  docker network inspect "${NETWORK_NAME}" >/dev/null 2>&1 || docker network create "${NETWORK_NAME}" >/dev/null
  docker volume inspect "${VOLUME_NAME}" >/dev/null 2>&1 || docker volume create "${VOLUME_NAME}" >/dev/null

  base_compose up -d
}

color_is_running() {
  local color="$1"
  local compose_file service_id

  if [[ "${color}" == "blue" ]]; then
    compose_file="${BLUE_COMPOSE}"
  else
    compose_file="${GREEN_COMPOSE}"
  fi

  service_id="$(service_container_id "${compose_file}" "backend-${color}")"
  [[ -n "${service_id}" ]] || return 1
  service_id="$(service_container_id "${compose_file}" "frontend-${color}")"
  [[ -n "${service_id}" ]]
}

active_color="$(tr -d '[:space:]' < "${ACTIVE_COLOR_FILE}" 2>/dev/null || true)"
if [[ "${active_color}" != "blue" && "${active_color}" != "green" ]]; then
  active_color="blue"
fi

target_color="${DEPLOY_COLOR:-}"
if [[ -z "${target_color}" ]]; then
  if ! color_is_running "${active_color}"; then
    target_color="${active_color}"
  elif [[ "${active_color}" == "blue" ]]; then
    target_color="green"
  else
    target_color="blue"
  fi
fi

if [[ "${target_color}" != "blue" && "${target_color}" != "green" ]]; then
  echo "DEPLOY_COLOR must be blue or green" >&2
  exit 1
fi

echo "Active color detected: ${active_color}"
echo "Target color selected: ${target_color}"
echo "Deploying GHCR owner: ${GHCR_OWNER}"
echo "Deploying image tag: ${GITHUB_SHA}"

BACKEND_IMAGE="ghcr.io/${GHCR_OWNER}/cloudnative-backend:${GITHUB_SHA}"
FRONTEND_IMAGE="ghcr.io/${GHCR_OWNER}/cloudnative-frontend:${GITHUB_SHA}"

echo "Pulling images:"
echo " - ${BACKEND_IMAGE}"
echo " - ${FRONTEND_IMAGE}"
docker pull "${BACKEND_IMAGE}"
docker pull "${FRONTEND_IMAGE}"

cd "${ROOT_DIR}"

ensure_base_stack
compose_color "${target_color}" up -d

if [[ "${target_color}" == "blue" ]]; then
  target_compose_file="${BLUE_COMPOSE}"
else
  target_compose_file="${GREEN_COMPOSE}"
fi

for service in $(service_names "${target_color}"); do
  wait_for_service_health "${service}" "${target_compose_file}"
done

write_active_upstream "${target_color}"
echo "${target_color}" > "${ACTIVE_COLOR_FILE}"

echo "Reloading Nginx in ${PROXY_CONTAINER}"
base_compose exec -T reverse-proxy nginx -s reload

verify_proxy "${target_color}"

echo "Blue/green deployment completed."
echo "Active color is now: ${target_color}"
echo "Rollback remains available by switching proxy back to: ${active_color}"
