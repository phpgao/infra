# shadowsocks-go2 Dockerfile
# go-shadowsocks2: 纯 AEAD 的 Shadowsocks Go 实现（AES-GCM / ChaCha20-Poly1305）
# 与 rust / libev 等标准客户端完全互通；区别于仓库内另一个 cfb 版的 shadowsocks-go

FROM golang:1.23-alpine AS builder

ARG GO_SHADOWSOCKS2_VERSION=v0.1.5

# 通过 Go module proxy 直接安装指定版本的二进制（无需 clone 仓库）
RUN go install "github.com/shadowsocks/go-shadowsocks2@${GO_SHADOWSOCKS2_VERSION}"

FROM alpine:3

COPY --from=builder /go/bin/go-shadowsocks2 /usr/local/bin/

# jq 仅用于 entrypoint 里对密码做 percent-encode，避免特殊字符破坏 SIP002 URI
RUN apk add --no-cache jq && mkdir -p /etc/shadowsocks

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8388

# 通过环境变量配置：
#   SS_ADDR       监听地址 (默认 0.0.0.0)
#   SS_PORT       监听端口 (默认 8388)
#   SS_METHOD     加密方法 (默认 AES-256-GCM，仅 AEAD，无 cfb)
#   SS_PASSWORD   密码 (默认 changeme，生产务必修改)
#   SS_PORT_PASSWORD  多端口 JSON，例如 '{"8388":"pw1","8389":"pw2"}'
#   SS_URI        直接给定完整 SIP002 URI，优先级最高
ENV SS_ADDR=0.0.0.0 \
    SS_PORT=8388 \
    SS_METHOD=AES-256-GCM \
    SS_PASSWORD=changeme

ENTRYPOINT ["entrypoint.sh"]
