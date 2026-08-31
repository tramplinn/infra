FROM caddy:builder-alpine AS builder

RUN xcaddy build \
    --with github.com/mholt/caddy-ratelimit@v0.1.0

FROM caddy:alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Базовый образ отстаёт от репозитория alpine на несколько исправлений
# безопасности, поэтому пакеты обновляем на этапе сборки.
RUN apk upgrade --no-cache \
    && apk add --no-cache --virtual .setcap libcap \
    && setcap cap_net_bind_service=+ep /usr/bin/caddy \
    && apk del .setcap \
    && adduser -D -u 10001 caddy-run \
    && mkdir -p /data /config \
    && chown -R caddy-run:caddy-run /data /config

USER caddy-run

HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=5 \
    CMD ["wget", "--quiet", "--spider", "http://127.0.0.1:2019/metrics"]
