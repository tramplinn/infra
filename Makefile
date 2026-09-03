COMPOSE = docker compose --env-file .env
SSH = ssh -p 15945 user1@$(SERVER_IP)

.PHONY: network up down restart ps logs validate build tunnel

network:
	@docker network inspect tramplin-edge >/dev/null 2>&1 || docker network create tramplin-edge

up: network
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

validate: network
	$(COMPOSE) config --quiet
	$(COMPOSE) run --rm --no-deps --entrypoint caddy caddy validate --adapter caddyfile --config /etc/caddy/Caddyfile
	$(COMPOSE) run --rm --no-deps --entrypoint alloy alloy fmt /etc/alloy/config.alloy > /dev/null

tunnel:
	$(SSH) -N -L 3000:127.0.0.1:3000 -L 9090:127.0.0.1:9090 \
		-L 15672:127.0.0.1:15672
