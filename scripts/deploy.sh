#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

: "${GITHUB_SHA:?GITHUB_SHA must be set}"
: "${GHCR_OWNER:?GHCR_OWNER must be set}"

GHCR_OWNER="$(echo "${GHCR_OWNER}" | tr '[:upper:]' '[:lower:]')"
export IMAGE_TAG="${IMAGE_TAG:-$GITHUB_SHA}"

BACKEND_IMAGE="ghcr.io/${GHCR_OWNER}/cloudnative-backend:${IMAGE_TAG}"
FRONTEND_IMAGE="ghcr.io/${GHCR_OWNER}/cloudnative-frontend:${IMAGE_TAG}"

echo "Deploying images:"
echo " - ${BACKEND_IMAGE}"
echo " - ${FRONTEND_IMAGE}"

cd "${ROOT_DIR}"

# Stop the current application stack without touching persistent volumes.
docker compose down

docker pull "${BACKEND_IMAGE}"
docker pull "${FRONTEND_IMAGE}"

docker compose up -d
