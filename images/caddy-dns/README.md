# phpgao/caddy-dns

Caddy 反向代理 + 多 DNS 服务商自动 HTTPS 镜像。

## 背景

Caddy 是现代化的 Web 服务器，以自动 HTTPS 著称。结合 DNS 插件，可实现：

- **全自动证书**: 无需手动配置 Let's Encrypt
- **通配符证书**: 支持 `*.example.com` 泛域名
- **零停机续期**: 证书自动更新，不影响服务
- **简洁配置**: Caddyfile 语法直观易读

相比 Nginx + Certbot 方案，Caddy 大幅简化了 HTTPS 部署复杂度。

## 支持的 DNS 服务商

| 服务商 | 模块 | 环境变量前缀 |
|--------|------|-------------|
| Cloudflare | `caddy-dns/cloudflare` | `CF_` |
| AWS Route53 | `caddy-dns/route53` | `AWS_` |
| Google Cloud DNS | `caddy-dns/googleclouddns` | `GOOGLECLOUD_` |
| Azure DNS | `caddy-dns/azure` | `AZURE_` |
| AliDNS (阿里云) | `caddy-dns/alidns` | `ALIDNS_` |
| Namecheap | `caddy-dns/namecheap` | `NAMECHEAP_` |
| Gandi | `caddy-dns/gandi` | `GANDI_` |
| OVH | `caddy-dns/ovh` | `OVH_` |

## 镜像信息

| 属性 | 值 |
|------|-----|
| 基础镜像 | alpine:3 |
| Caddy 版本 | 2.x |
| 端口 | 80, 443 |

## 快速开始

### Docker Run

```bash
docker run -d \
  --name caddy \
  -p 80:80 -p 443:443 \
  -e CF_API_EMAIL=your@email.com \
  -e CF_API_KEY=your-global-api-key \
  -v ./Caddyfile:/etc/caddy/Caddyfile \
  ghcr.io/phpgao/caddy-dns:latest
```

### Docker Compose

```yaml
services:
  caddy:
    image: ghcr.io/phpgao/caddy-dns:latest
    environment:
      CF_API_EMAIL: your@email.com
      CF_API_KEY: ${CF_API_KEY}
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
    ports:
      - "80:80"
      - "443:443"
```

## DNS 配置示例

### Cloudflare

```caddy
example.com {
    reverse_proxy localhost:8080

    tls {
        dns cloudflare {env.CF_API_EMAIL} {env.CF_API_KEY}
    }
}
```

### AWS Route53

```caddy
example.com {
    reverse_proxy localhost:8080

    tls {
        dns route53 {env.AWS_ACCESS_KEY_ID} {env.AWS_SECRET_ACCESS_KEY}
    }
}
```

### Google Cloud DNS

```caddy
example.com {
    reverse_proxy localhost:8080

    tls {
        dns googleclouddns {env.GOOGLECLOUD_PROJECT} {env.GOOGLECLOUD_CREDENTIALS}
    }
}
```

### Azure DNS

```caddy
example.com {
    reverse_proxy localhost:8080

    tls {
        dns azure {env.AZURE_TENANT_ID} {env.AZURE_CLIENT_ID} {env.AZURE_CLIENT_SECRET} {env.AZURE_SUBSCRIPTION_ID}
    }
}
```

### AliDNS (阿里云)

```caddy
example.com {
    reverse_proxy localhost:8080

    tls {
        dns alidns {env.ALIDNS_ACCESS_KEY} {env.ALIDNS_SECRET_KEY}
    }
}
```

## 常用配置

### 重定向 HTTP 到 HTTPS

```caddy
example.com {
    redir https://{http.request.host}{http.request.uri} permanent
}
```

### 启用 HSTS

```caddy
example.com {
    header Strict-Transport-Security "max-age=31536000; includeSubDomains"
    reverse_proxy localhost:8080
}
```

### CORS 配置

```caddy
api.example.com {
    @options method OPTIONS
    header Access-Control-Allow-Origin "*"
    header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    header Access-Control-Allow-Headers "Authorization, Content-Type"
    reverse_proxy localhost:8080
}
```

## 注意事项

- 确保域名 DNS 已托管在对应服务商
- 服务器防火墙需开放 80 和 443 端口
- 首次启动会自动申请证书，可能需要几秒到几分钟
- 生产环境建议使用 Docker Compose 配合后端服务
