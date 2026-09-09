# phpgao/shadowsocks-libev

C 语言原版 Shadowsocks (shadowsocks-libev)，最成熟的实现。

## 背景

shadowsocks-libev 是 Shadowsocks 的 C 语言实现，也是最早的参考实现：

- **成熟稳定**: 经过十年以上生产环境验证
- **资源占用低**: C 语言实现，内存占用极小
- **兼容性最广**: 支持最多平台和设备
- **生态完善**: 大量第三方客户端基于此实现

适合对稳定性要求极高、资源受限的场景。

## 镜像信息

| 属性 | 值 |
|------|-----|
| 基础镜像 | alpine:3.16 |
| 版本 | 3.3.6 |
| 端口 | 8388 |

## 快速开始

### 通过环境变量（推荐，无需覆盖命令）

镜像根据环境变量自动生成启动参数：

```bash
docker run -d \
  --name ss-libev \
  -p 8388:8388 \
  -e SS_PASSWORD="your-password" \
  -e SS_METHOD="aes-256-gcm" \
  ghcr.io/phpgao/shadowsocks-libev:latest
```

| 环境变量 | 说明 | 默认值 |
|----------|------|--------|
| `SS_ADDR` | 监听地址 | `0.0.0.0` |
| `SS_PORT` | 监听端口 | `8388` |
| `SS_METHOD` | 加密方式 | `aes-256-gcm` |
| `SS_PASSWORD` | 密码（生产务必修改） | `changeme` |

### 覆盖命令（注意 libev 的 `-s` 仅为主机地址，端口用 `-p`）

```bash
docker run -d \
  --name ss-libev \
  -p 8388:8388 \
  ghcr.io/phpgao/shadowsocks-libev:latest \
  ss-server -s "0.0.0.0" -p 8388 -k "your-password" -m "aes-256-gcm"
```

### Docker Compose

```yaml
services:
  shadowsocks:
    image: ghcr.io/phpgao/shadowsocks-libev:latest
    environment:
      - SS_PASSWORD=${SS_PASSWORD}
      - SS_METHOD=aes-256-gcm
    ports:
      - "8388:8388"
```

## 命令行参数

### ss-server (服务端)

| 参数 | 说明 | 示例 |
|------|------|------|
| `-s` | 监听主机地址（**仅主机，不含端口**） | `0.0.0.0` |
| `-p` | 监听端口 | `8388` |
| `-k` | 密码 | `your-password` |
| `-m` | 加密方式 | `aes-256-gcm` |
| `-c` | 配置文件路径 | `/etc/shadowsocks/config.json` |

### ss-local (客户端)

```bash
docker run -d \
  --name ss-local \
  -p 1080:1080 \
  ghcr.io/phpgao/shadowsocks-libev:latest \
  ss-local -s "server-ip" -p 8388 -l "0.0.0.0:1080" -k "your-password" -m "aes-256-gcm"
```

## 配置文件示例

```json
{
  "server": "0.0.0.0",
  "server_port": 8388,
  "password": "your-password",
  "method": "aes-256-gcm",
  "timeout": 300,
  "fast_open": true
}
```

使用配置文件启动：

```bash
docker run -d \
  -v ./config.json:/etc/shadowsocks/config.json \
  ghcr.io/phpgao/shadowsocks-libev:latest \
  ss-server -c "/etc/shadowsocks/config.json"
```

## 多用户 / 多端口

libev 的多用户通过配置文件实现（注意 `-s` 仅为主机地址，端口用 `server_port`）：

```json
{
  "server": "0.0.0.0",
  "server_port": 8388,
  "password": "your-password",
  "method": "aes-256-gcm",
  "timeout": 300,
  "fast_open": true
}
```

> 说明：libev 的 `-U` 表示「启用 UDP 转发并禁用 TCP 转发」，并非多用户模式；多用户请使用 `ss-manager` 或配置文件。

## 推荐加密方式

| 加密方式 | 安全性 | 性能 |
|----------|--------|------|
| `aes-256-gcm` | 高 | 快 |
| `chacha20-ietf-poly1305` | 高 | 中 |
| `bf-cfb` | 中 | 慢 |

**注意**: 建议使用 AEAD 加密（如 aes-256-gcm），避免使用过时的加密方式。

## 注意事项

- 本项目已停止新功能开发，建议使用 shadowsocks-rust
- 部分旧加密方式存在安全问题，请使用 AEAD 加密
- 生产环境建议配合 TLS 或 CDN 前置
