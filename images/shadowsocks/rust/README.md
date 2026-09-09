# phpgao/shadowsocks-rust

Rust 实现的 Shadowsocks 服务器，性能最佳，推荐使用。

## 背景

shadowsocks-rust 是 Shadowsocks 的 Rust 语言重写版本，具有以下优势：

- **极致性能**: 零成本抽象 + SIMD 加速，吞吐量领先
- **内存安全**: 编译期保证无数据竞争和缓冲区溢出
- **现代协议**: 支持 AEAD 加密、TLS 代理等最新特性
- **活跃维护**: 社区活跃，持续更新

相比 C 语言原版，Rust 版本在同等硬件下吞吐量提升 30%-50%。

## 镜像信息

| 属性 | 值 |
|------|-----|
| 基础镜像 | alpine:3 |
| 版本 | 1.x |
| 端口 | 8388 |

## 快速开始

### 通过环境变量（推荐，无需覆盖命令）

镜像会根据以下环境变量自动生成启动参数，密码等敏感项请务必覆盖：

```bash
docker run -d \
  --name ss-rust \
  -p 8388:8388 \
  -e SS_PASSWORD="your-strong-password-here" \
  -e SS_METHOD="aes-256-gcm" \
  ghcr.io/phpgao/shadowsocks-rust:latest
```

| 环境变量 | 说明 | 默认值 |
|----------|------|--------|
| `SS_ADDR` | 监听地址 | `0.0.0.0` |
| `SS_PORT` | 监听端口 | `8388` |
| `SS_METHOD` | 加密方式 | `aes-256-gcm` |
| `SS_PASSWORD` | 密码（生产务必修改） | `changeme` |

### 覆盖命令（注意 v1.25.0 起 `-s` 才是服务端监听地址，`-b` 已变为出站绑定地址）

```bash
docker run -d \
  --name ss-rust \
  -p 8388:8388 \
  ghcr.io/phpgao/shadowsocks-rust:latest \
  ssserver -s "0.0.0.0:8388" -m "aes-256-gcm" -k "your-strong-password-here"
```

### Docker Compose

```yaml
services:
  shadowsocks:
    image: ghcr.io/phpgao/shadowsocks-rust:latest
    environment:
      - SS_PASSWORD=${SS_PASSWORD}
      - SS_METHOD=aes-256-gcm
    ports:
      - "8388:8388"
```

## 命令行参数

### ssserver (服务端)

| 参数 | 说明 | 示例 |
|------|------|------|
| `-s` | 服务端监听地址 | `0.0.0.0:8388` |
| `-b` | 出站绑定地址（v1.25.0 起，非监听地址） | `0.0.0.0` |
| `-m` | 加密方式 | `aes-256-gcm` |
| `-k` | 密码 | `your-password` |
| `-c` | 配置文件路径 | `/etc/shadowsocks/config.json` |

### sslocal (客户端)

```bash
docker run -d \
  --name ss-local \
  -p 1080:1080 \
  ghcr.io/phpgao/shadowsocks-rust:latest \
  sslocal -b "127.0.0.1:1080" -s "server-ip:8388" -m "aes-256-gcm" -k "your-password"
```

## 推荐加密方式

| 加密方式 | 安全性 | 性能 | 推荐场景 |
|----------|--------|------|----------|
| `aes-256-gcm` | 高 | 快 | 通用推荐 |
| `chacha20-ietf-poly1305` | 高 | 中 | 无 AES 指令集时 |
| `2022-blake3-aes-128-gcm` | 极高 | 快 | 最新协议 |

## 配置文件示例

```json
{
  "server": "0.0.0.0",
  "server_port": 8388,
  "password": "your-password",
  "method": "aes-256-gcm",
  "fast_open": true,
  "mode": "tcp_and_udp"
}
```

使用配置文件启动：

```bash
docker run -d \
  -v ./config.json:/etc/shadowsocks/config.json \
  ghcr.io/phpgao/shadowsocks-rust:latest \
  ssserver -c "/etc/shadowsocks/config.json"
```

## 性能优化

### 启用 TCP Fast Open

```bash
ssserver -b "0.0.0.0:8388" ... --fast-open 128
```

### 多核绑定

```bash
ssserver -b "0.0.0.0:8388" ... --cpu-affinity
```

## 注意事项

- 密码长度建议 >= 16 字符
- 生产环境建议使用 TLS 代理或 CDN 前置
- 定期更换密码和加密方式
