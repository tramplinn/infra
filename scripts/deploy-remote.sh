#!/usr/bin/env bash
set -euo pipefail

deploy_path=$1
export CADDY_IMAGE=$2
registry=$3

cd "$deploy_path"
compose=(docker compose --env-file .env)

trap '"${compose[@]}" ps; "${compose[@]}" logs --tail 100' ERR
trap 'docker logout "$registry" >/dev/null 2>&1 || true' EXIT

set -a
source .env
set +a

rmq_user="${RABBITMQ_USER:-tramplin}"
pass_hash="$(python3 "$(dirname "$0")/rabbitmq-password-hash.py")"
jq --arg user "$rmq_user" --arg hash "$pass_hash" '
  .users = [{name: $user, password_hash: $hash, hashing_algorithm: "rabbit_password_hashing_sha256", tags: ["administrator"]}] |
  .permissions = [{user: $user, vhost: "/", configure: ".*", write: ".*", read: ".*"}]
' rabbitmq/definitions.json > rabbitmq/definitions.json.tmp
mv rabbitmq/definitions.json.tmp rabbitmq/definitions.json
export RABBITMQ_CONFIG_HASH="$(sha256sum rabbitmq/rabbitmq.conf rabbitmq/definitions.json | sha256sum | cut -d' ' -f1)"

docker network inspect tramplin-edge >/dev/null 2>&1 || docker network create tramplin-edge
"${compose[@]}" config --quiet

docker image prune -af
df -h /
"${compose[@]}" pull
"${compose[@]}" up -d --no-build --remove-orphans --wait --wait-timeout 180
# Одноразовая установка пакетов Piston: profiles: ["init"] держит её вне `up`/`--wait`.
"${compose[@]}" run --rm piston-init
docker image prune -af
