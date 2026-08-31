#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

: "${CADDY_IMAGE:?}" "${CI_REGISTRY:?}"

docker network inspect tramplin-edge >/dev/null 2>&1 || docker network create tramplin-edge

compose() {
  docker compose --env-file .env "$@"
}

compose config --quiet
compose pull --quiet
compose up -d --no-build --remove-orphans --wait --wait-timeout 180

docker image prune -f
docker logout "$CI_REGISTRY"
