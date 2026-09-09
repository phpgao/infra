# caddy-dns Dockerfile
# Caddy + 多 DNS 服务商插件

FROM caddy:2-builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/caddy-dns/route53 \
    --with github.com/caddy-dns/googleclouddns \
    --with github.com/caddy-dns/azure \
    --with github.com/caddy-dns/alidns \
    --with github.com/caddy-dns/namecheap \
    --with github.com/caddy-dns/gandi \
    --with github.com/caddy-dns/ovh

FROM caddy:2

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# 复制默认配置
COPY Caddyfile /etc/caddy/Caddyfile

# 暴露端口
EXPOSE 80 443 443/udp

# 启动 Caddy
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile"]
