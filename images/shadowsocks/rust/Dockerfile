# shadowsocks-rust Dockerfile
# Rust 实现的 Shadowsocks，性能最佳

FROM alpine:3 AS downloader

ARG SS_RUST_VERSION=1.25.0

RUN apk add --no-cache curl tar xz && \
    cd /tmp && \
    curl -sL "https://github.com/shadowsocks/shadowsocks-rust/releases/download/v${SS_RUST_VERSION}/shadowsocks-v${SS_RUST_VERSION}.x86_64-unknown-linux-musl.tar.xz" -o shadowsocks.tar.xz && \
    tar xf shadowsocks.tar.xz && \
    find . -name "ss*" -type f -exec mv {} /usr/local/bin/ \; && \
    rm -rf /tmp/*

FROM alpine:3

COPY --from=downloader /usr/local/bin/ss* /usr/local/bin/

EXPOSE 8388

# 通过环境变量配置：
#   SS_ADDR    监听地址 (默认 0.0.0.0)
#   SS_PORT    监听端口 (默认 8388)
#   SS_METHOD  加密方法 (默认 aes-256-gcm)
#   SS_PASSWORD 密码 (默认 changeme，生产务必修改)
ENV SS_ADDR=0.0.0.0 \
    SS_PORT=8388 \
    SS_METHOD=aes-256-gcm \
    SS_PASSWORD=changeme

# v1.25.0 起 -s 为服务端监听地址(-b 已变为出站绑定地址)，故这里用 -s
CMD ["sh", "-c", "ssserver -s ${SS_ADDR}:${SS_PORT} -m ${SS_METHOD} -k ${SS_PASSWORD}"]
