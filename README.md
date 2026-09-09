# infra - 基础设施镜像仓库

![Build pgvector](https://github.com/phpgao/infra/actions/workflows/pgvector.yml/badge.svg)
![Build mariadb](https://github.com/phpgao/infra/actions/workflows/mariadb.yml/badge.svg)
![Build caddy-dns](https://github.com/phpgao/infra/actions/workflows/caddy-dns.yml/badge.svg)
![Build shadowsocks](https://github.com/phpgao/infra/actions/workflows/shadowsocks.yml/badge.svg)

基于 Alpine Linux 的 Docker 镜像集合，专为 AI Agent 场景和通用基础设施设计。

## 镜像列表

| 镜像 | 描述 | 拉取命令 |
|------|------|----------|
| `phpgao/pgvector` | PostgreSQL + pgvector 向量数据库 | `docker pull ghcr.io/phpgao/pgvector:latest` |
| `phpgao/mariadb` | MariaDB 数据库 | `docker pull ghcr.io/phpgao/mariadb:latest` |
| `phpgao/caddy-dns` | Caddy + 多 DNS 服务商 | `docker pull ghcr.io/phpgao/caddy-dns:latest` |
| `phpgao/shadowsocks-rust` | Shadowsocks (Rust) | `docker pull ghcr.io/phpgao/shadowsocks-rust:latest` |
| `phpgao/shadowsocks-go2` | Shadowsocks (Go, 纯 AEAD) | `docker pull ghcr.io/phpgao/shadowsocks-go2:latest` |
| `phpgao/shadowsocks-libev` | Shadowsocks (libev) | `docker pull ghcr.io/phpgao/shadowsocks-libev:latest` |

## 快速开始

各镜像的详细使用说明和 Docker Compose 示例，请查看对应目录下的 README：

- [pgvector](images/pgvector/README.md) - AI Agent 向量数据库
- [mariadb](images/mariadb/README.md) - MariaDB 数据库
- [caddy-dns](images/caddy-dns/README.md) - 反向代理 + 多 DNS 服务商自动 HTTPS
- [shadowsocks-rust](images/shadowsocks/rust/README.md) - 代理 (Rust)
- [shadowsocks-go2](images/shadowsocks/go2/README.md) - 代理 (Go, 纯 AEAD)
- [shadowsocks-libev](images/shadowsocks/libev/README.md) - 代理 (libev)

## 标签策略

- `<version>`: 特定版本标签 (如 `17-0.8.6`, `1.25.0`)
- `latest`: 最新版本

## CI/CD

- **触发**: push 到 main 或每周一 02:00 UTC
- **构建**: GitHub Actions 自动构建并推送到 GHCR
- **手动触发**: 在 GitHub Actions 页面使用 `workflow_dispatch`

## 许可证

MIT
