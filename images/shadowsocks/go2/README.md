# phpgao/shadowsocks-go2

Go 语言实现的 Shadowsocks（[shadowsocks/go-shadowsocks2](https://github.com/shadowsocks/go-shadowsocks2)），**纯 AEAD 实现**，与 rust / libev 等标准客户端完全互通。

## 背景

go-shadowsocks2 与历史上另一个 Go 实现 `shadowsocks-go`（shadowsocks/shadowsocks-go，cfb 流密码）是**两个不同的项目**：

| 镜像 | 实现 | 加密 | 与标准客户端互通 |
|------|------|------|------------------|
| `shadowsocks-go` | shadowsocks/shadowsocks-go | cfb 流密码 | ❌ 实测握手失败 |
| `shadowsocks-go2` | shadowsocks/go-shadowsocks2 | AES-GCM / ChaCha20 AEAD | ✅ 完全互通 |

> 新项目 / 需要标准客户端兼容时，**优先用 `shadowsocks-go2`**。

支持的方法（方法名大写）：`AES-128-GCM`、`AES-256-GCM`、`CHACHA20-IETF-POLY1305`、`XCHACHA20-IETF-POLY1305`。默认 `AES-256-GCM`。TCP + UDP relay 默认开启。

## 镜像信息

| 属性 | 值 |
|------|-----|
| 基础镜像 | alpine:3 |
| 版本 | 0.1.5 |
| 端口 | 8388 |
| 二进制 | `go-shadowsocks2` |

## 快速开始

### 单端口（环境变量，推荐）

```bash
docker run -d \
  --name ss-go2 \
  -p 8388:8388 \
  -e SS_PASSWORD="your-password" \
  -e SS_METHOD="AES-256-GCM" \
  ghcr.io/phpgao/shadowsocks-go2:latest
```

| 环境变量 | 说明 | 默认值 |
|----------|------|--------|
| `SS_ADDR` | 监听地址 | `0.0.0.0` |
| `SS_PORT` | 监听端口 | `8388` |
| `SS_METHOD` | 加密方法（仅 AEAD，方法名大写） | `AES-256-GCM` |
| `SS_PASSWORD` | 密码（生产务必修改） | `changeme` |
| `SS_PORT_PASSWORD` | 多端口 JSON，如 `{"8388":"pw1","8389":"pw2"}` | 空（单端口） |
| `SS_URI` | 直接给定完整 SIP002 URI，优先级最高 | 空 |

### 多端口 / 多密码

```bash
docker run -d \
  --name ss-go2-multi \
  -p 8388:8388 -p 8389:8389 \
  -e SS_PORT_PASSWORD='{"8388":"password1","8389":"password2"}' \
  -e SS_METHOD="AES-256-GCM" \
  ghcr.io/phpgao/shadowsocks-go2:latest
```

每个端口会生成独立的 `-s 'ss://METHOD:PASSWORD@ADDR:PORT'`。

### 直接给定 SIP002 URI

```bash
docker run -d \
  --name ss-go2-uri \
  -p 8388:8388 \
  -e SS_URI='ss://AES-256-GCM:your-password@0.0.0.0:8388' \
  ghcr.io/phpgao/shadowsocks-go2:latest
```

### Docker Compose

```yaml
services:
  shadowsocks:
    image: ghcr.io/phpgao/shadowsocks-go2:latest
    environment:
      - SS_PASSWORD=${SS_PASSWORD}
      - SS_METHOD=AES-256-GCM
    ports:
      - "8388:8388"
```

## SIP002 链接

客户端使用的链接格式（`#` 后为备注名，URL 编码）：

```
ss://base64(AES-256-GCM:your-password)@host:8388/#tag
```

例如密码 `your-password`、方法 `AES-256-GCM`：

```
ss://QVNUUC1JRUYtU1hNX3hjaGFjaGEyMC1pZXRmLXBvbHk5NzUzOnlvdXItcGFzc3dvcmQ=@example.com:8388/?#MyServer
```

## 注意事项

- **仅支持 AEAD 方法**，不支持 cfb / rc4 等流密码
- 方法名使用大写（如 `AES-256-GCM`），与 shadowsocks-go 的小写 `aes-256-cfb` 不同
- 与 rust / libev 客户端互通良好；需配合客户端使用对应方法（默认 AES-256-GCM）
- 生产环境建议修改默认密码，并配合防火墙 / TLS 使用
