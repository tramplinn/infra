FROM caddy:2.11.4-builder-alpine AS builder

RUN xcaddy build \
    --with github.com/mholt/caddy-ratelimit@v0.1.0 \
    --replace golang.org/x/crypto=golang.org/x/crypto@v0.56.0 \
    --replace golang.org/x/net=golang.org/x/net@v0.58.0 \
    --replace golang.org/x/text=golang.org/x/text@v0.41.0 \
    --replace google.golang.org/grpc=google.golang.org/grpc@v1.83.2

FROM caddy:2.11.4-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

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
