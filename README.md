# Tramplin Infra

Shared infrastructure for staging and production.

## Services

- Caddy — TLS and reverse proxy;
- RabbitMQ — queues for algorithm jobs, embeddings, and email;
- Piston — runs user code in isolation;
- Prometheus, Loki, Grafana, Alloy — metrics, logs, dashboards;
- Docker socket proxy — gives Alloy read-only access to Docker.

Queues are defined in [`rabbitmq/definitions.json`](rabbitmq/definitions.json),
and nowhere else. Apps only check that a queue exists (`passive=true`) and fail
loudly if it doesn't. So a new queue goes here first, then into the code.

Everything connects through the `tramplin-edge` network:

```text
internet → Caddy → frontend
                 → backend API → RabbitMQ → algorithm worker → Piston
                 → MCP → backend authoring API

Alloy → Prometheus / Loki → Grafana
```

Piston only exposes an HTTP API at `tramplin-piston:2000` and can't see the
database or storage. It needs `privileged` mode to sandbox code.

## Running

You need a Linux host with Docker and the Compose plugin.

```bash
cp .env.example .env
make validate
make up
```

`make up` creates the network on first run and starts everything. Point your
domains at the server first, or TLS certificates won't be issued.

Piston starts with no languages. Install them once with:

```bash
docker compose run --rm piston-init
```

`deploy-remote.sh` does this on every deploy.

```bash
make ps          # service status
make logs        # logs
make restart     # restart Caddy
make validate    # check Compose, Caddyfile, Alloy config
make build       # build Caddy
make tunnel      # Grafana :3000 and Prometheus :9090 over SSH
make down        # stop, keeping volumes
```

## Data and security

Volumes hold RabbitMQ, Piston packages, Caddy certificates, Prometheus, Loki, and
Grafana data. `make down` keeps them; `docker compose down -v` deletes them for good.

Back up RabbitMQ and monitoring data regularly. Don't expose management ports.
Piston has no authentication, so port 2000 must stay inside `tramplin-edge`.
