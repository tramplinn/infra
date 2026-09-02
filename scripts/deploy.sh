#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ "$#" -ne 2 ]; then
  echo "usage: $0 IMAGE REGISTRY" >&2
  exit 2
fi

caddy_image=$1
registry=$2

if ! docker network inspect tramplin-edge >/dev/null 2>&1; then
  docker network create tramplin-edge
fi

docker compose --env-file .env config --quiet
docker pull "$caddy_image"
docker tag "$caddy_image" tramplin-caddy:local
docker compose --env-file .env pull --quiet --ignore-buildable
docker compose --env-file .env up -d --no-build --remove-orphans --wait --wait-timeout 180

docker image prune -f
docker logout "$registry"
