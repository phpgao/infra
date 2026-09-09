# AGENTS.md - infra 项目规范

> **项目名称**: infra (基础设施镜像仓库)
> **仓库地址**: `github.com/phpgao/infra`
> **镜像仓库**: `ghcr.io/phpgao/<image>`

## 项目概述

本项目维护一组基于 Alpine Linux 的 Docker 镜像，用于 AI Agent 场景和通用基础设施部署。

## 目录结构

```
infra/
├── AGENTS.md                    # 本文件
├── README.md                    # 使用说明
├── .github/
│   └── workflows/               # CI/CD 工作流
├── images/                      # 各镜像定义
│   ├── pgvector/                # PostgreSQL + pgvector
│   ├── mariadb/                 # MariaDB
│   ├── caddy-dns/               # Caddy + 多 DNS 服务商
│   └── shadowsocks/             # Shadowsocks 多版本
│       ├── rust/
│       ├── go/
│       └── libev/
└── scripts/                     # 工具脚本
```

## 镜像清单

| 镜像 | 用途 | Tag 策略 |
|------|------|----------|
| `phpgao/pgvector` | AI Agent 向量数据库 | `<version>` + `latest` |
| `phpgao/mariadb` | 关系型数据库 | `<version>` + `latest` |
| `phpgao/caddy-dns` | 反向代理 + 多 DNS 服务商 | `<version>` + `latest` |
| `phpgao/shadowsocks-rust` | 代理 (Rust) | `<version>` + `latest` |
| `phpgao/shadowsocks-go2` | 代理 (Go, 纯 AEAD，兼容标准客户端) | `<version>` + `latest` |
| `phpgao/shadowsocks-libev` | 代理 (libev) | `<version>` + `latest` |

## 构建规范

### Dockerfile 约定

- 基础镜像统一使用 `alpine:3`
- 每次构建拉取最新版本 (`apk add --no-cache <package>`)
- 镜像标签格式: `<软件版本>` + `latest`
- 支持 `docker-entrypoint-initdb.d` 标准目录

### CI/CD 触发条件

- **push**: main 分支变更时触发对应镜像构建
- **schedule**: 每周一 02:00 UTC 定时构建
- **workflow_dispatch**: 支持手动触发

## 新增镜像流程

1. 在 `images/` 下创建子目录
2. 编写 `Dockerfile` 和必要的配置文件
3. 在 `.github/workflows/` 添加对应 workflow
4. 更新本文档的镜像清单

## 发布规范

- 打 tag 发布时**必须创建 GitHub Release 并写入详细发布信息**，禁止发布空 release 或仅填版本号。
- Release notes 至少包含：镜像清单、本次变更/修复记录、快速使用说明、关键构建要点、已知问题。
- README 顶部应放置各镜像对应的 GitHub Actions build badge。
- 维护已存在的 release 时优先用 `gh release edit` / `gh release publish`；**不要**直接 `git push :refs/tags/<tag>` 删除远程 tag（会把关联的 Release 变成草稿/孤儿，发布信息丢失）。
- 必须在 tag 最终稳定（不再 force push 移动）之后再创建 Release，否则 tag 变动会连带删除/降级已有的 Release。

## 版本号获取

使用 GitHub Actions 自动获取最新版本:

```bash
# 示例: 获取 PostgreSQL 最新版本
curl -s "https://api.github.com/repos/postgres/postgres/releases/latest" | jq -r '.tag_name'
```

## 安全要求

- 不在镜像中硬编码密钥
- 敏感配置通过环境变量或挂载卷传入
- CI 中使用 GitHub Secrets 存储凭证
