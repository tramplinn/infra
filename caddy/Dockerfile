# Официальный образ идёт без rate_limit — модуль сторонний, поэтому собираем свой.
# Версия модуля закреплена: xcaddy без неё берёт master и сборка перестаёт быть
# воспроизводимой.
FROM caddy:2.11-builder-alpine AS builder

RUN xcaddy build \
    --with github.com/mholt/caddy-ratelimit@v0.1.0

FROM caddy:2.11-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Проверка живости идёт по admin API, он же отдаёт метрики Prometheus.
HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=5 \
    CMD ["wget", "--quiet", "--spider", "http://127.0.0.1:2019/metrics"]
