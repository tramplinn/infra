# Официальный образ идёт без rate_limit — модуль сторонний, поэтому собираем свой.
# Версия модуля закреплена: xcaddy без неё берёт master и сборка перестаёт быть
# воспроизводимой.
FROM caddy:2.11-builder-alpine AS builder

RUN xcaddy build \
    --with github.com/mholt/caddy-ratelimit@v0.1.0

FROM caddy:2.11-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Официальный образ работает от root, потому что 80 и 443 — привилегированные
# порты. Вместо root выдаём бинарнику одну способность их занимать: процесс
# теряет все остальные права, а слушать наружу по-прежнему может.
RUN apk add --no-cache --virtual .setcap libcap \
    && setcap cap_net_bind_service=+ep /usr/bin/caddy \
    && apk del .setcap \
    && adduser -D -u 10001 caddy-run \
    && mkdir -p /data /config \
    && chown -R caddy-run:caddy-run /data /config

USER caddy-run

# Проверка живости идёт по admin API, он же отдаёт метрики Prometheus.
HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=5 \
    CMD ["wget", "--quiet", "--spider", "http://127.0.0.1:2019/metrics"]
