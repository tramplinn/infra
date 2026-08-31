COMPOSE = docker compose --env-file .env
SSH = ssh -p 15945 user1@$(SERVER_IP)

.PHONY: up down restart ps logs validate build tunnel

up:
	$(COMPOSE) up -d --build --wait --wait-timeout 180

down:
	$(COMPOSE) down

restart:
	$(COMPOSE) restart caddy

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f --tail=100

build:
	$(COMPOSE) build caddy

# Полная проверка конфигов без запуска стенда.
validate:
	$(COMPOSE) config --quiet
	$(COMPOSE) run --rm --no-deps --entrypoint caddy caddy validate --adapter caddyfile --config /etc/caddy/Caddyfile
	$(COMPOSE) run --rm --no-deps --entrypoint alloy alloy fmt /etc/alloy/config.alloy > /dev/null

# Grafana и Prometheus наружу не смотрят: SERVER_IP=1.2.3.4 make tunnel
tunnel:
	$(SSH) -N -L 3000:127.0.0.1:3000 -L 9090:127.0.0.1:9090
