# Tramplin Infra

Общая инфраструктура Tramplin для staging и production.

## Сервисы

- Caddy — TLS, reverse proxy, security headers;
- RabbitMQ — очереди алгоритмических заданий, эмбеддингов и почты;
- Judge0 — изолированное выполнение кода;
- Prometheus, Loki, Grafana и Alloy — метрики, логи и dashboards;
- Docker socket proxy — read-only доступ Alloy к Docker API.

Топология RabbitMQ (какие очереди существуют, durable/quorum) описана
декларативно в [`rabbitmq/definitions.json`](rabbitmq/definitions.json) и
грузится брокером при старте — это единственный источник истины. Backend,
воркеры и email-service объявляют те же очереди с `passive=true`: если
определение здесь не задеплоено, приложение падает с понятной ошибкой вместо
того, чтобы молча создать очередь с непредсказуемыми параметрами. Новую
очередь сначала добавляют сюда, потом — в код, который её использует.

Все приложения соединяются через внешнюю сеть `tramplin-edge`:

```text
internet → Caddy → frontend
                 → backend API → RabbitMQ → algorithm worker → Judge0
                 → MCP → backend authoring API

Alloy → Prometheus / Loki → Grafana
```

Judge0 использует отдельную внутреннюю сеть и не видит базы или хранилища
приложения. Его server и worker требуют Docker `privileged`.

## Запуск

Нужны Docker, Compose plugin и Linux host.

```bash
cp .env.example .env
make validate
make up
```

`make up` создаёт общую сеть при первом запуске и поднимает полный стек, включая
Judge0. Домены должны указывать на сервер до получения TLS-сертификатов.

Полезные команды:

```bash
make ps          # состояние сервисов
make logs        # общие логи
make restart     # перезапустить Caddy
make validate    # Compose, Caddyfile и Alloy config
make build       # собрать Caddy
make tunnel      # Grafana :3000 и Prometheus :9090 через SSH
make down        # остановить стек без удаления volumes
```

## Конфигурация

Шаблон находится в [`.env.example`](.env.example).

- `FRONTEND_DOMAIN`, `PROD_DOMAIN` — production web и API;
- `FRONTEND_STAGE_DOMAIN`, `STAGE_DOMAIN` — staging web и API;
- `MCP_DOMAIN`, `MCP_STAGE_DOMAIN` — production и staging MCP;
- `ACME_EMAIL` — выпуск TLS-сертификатов;
- `RABBITMQ_*`, `JUDGE0_*`, `GRAFANA_ADMIN_PASSWORD` — секреты сервисов;
- `WEB_*_UPSTREAM`, `API_*_UPSTREAM`, `MCP_*_UPSTREAM` — aliases приложений в `tramplin-edge`.

Backend и frontend должны публиковать aliases, совпадающие с upstream-значениями.
По умолчанию это:

```text
tramplin-prod-web       tramplin-prod-api
tramplin-stage-web      tramplin-stage-api
tramplin-mcp-prod-mcp   tramplin-mcp-stage-mcp
tramplin-rabbitmq       tramplin-judge0
```

Grafana и Prometheus слушают только `127.0.0.1`; открывайте их через
`make tunnel`. RabbitMQ management UI доступен аналогично на порту `15672`.

## CI/CD

Pipeline проверяет Compose, формат Alloy, секреты и конфигурационные уязвимости,
затем собирает, валидирует и сканирует immutable Caddy image.

Deploy копирует Compose, `judge0.conf`, Caddy и observability configs, создаёт
`tramplin-edge`, обновляет весь стек и ждёт healthchecks. При ошибке job печатает
состояние и последние логи.

Нужные protected CI/CD variables:

- `SERVER_IP`, `SSH_PRIVATE_KEY`;
- `INFRA_ENV` типа File;
- `PROD_DOMAIN` для GitLab environment URL.

## Данные и безопасность

Именованные volumes содержат RabbitMQ, Judge0 PostgreSQL, Caddy certificates,
Prometheus, Loki и Grafana. `make down` их сохраняет; `docker compose down -v`
удалит безвозвратно.

Регулярно сохраняйте PostgreSQL Judge0, RabbitMQ и данные observability во внешнее
хранилище. Не публикуйте management-порты наружу и не добавляйте приложения в
закрытую сеть Judge0.
