# shadowsocks-libev Dockerfile
# C 语言原版 Shadowsocks (shadowsocks-libev)

FROM alpine:3.16 AS builder

ARG SS_LIBEV_VERSION=3.3.6

# 安装编译依赖
RUN apk add --no-cache \
    build-base \
    curl \
    tar \
    git \
    cmake \
    c-ares-dev \
    libcap \
    libev-dev \
    libsodium-dev \
    linux-headers \
    mbedtls-dev \
    pcre2-dev

# 克隆完整仓库（包括 git submodule）并编译
RUN cd /tmp && \
    git clone --depth 1 --branch "v${SS_LIBEV_VERSION}" --recurse-submodules \
        https://github.com/shadowsocks/shadowsocks-libev.git && \
    cd "shadowsocks-libev" && \
    mkdir -p build && cd build && \
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DBUILD_TESTING=OFF \
        -DWITH_STATIC=OFF \
        -DCMAKE_BUILD_TYPE=Release && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    make install

# 清理
RUN apk del build-base curl tar git cmake c-ares-dev libcap libev-dev libsodium-dev linux-headers mbedtls-dev pcre2-dev

FROM alpine:3.16

# 复制编译产物
COPY --from=builder /usr/local/bin/ss-* /usr/local/bin/
COPY --from=builder /usr/local/lib/libshadowsocks* /usr/local/lib/

# 安装运行时依赖（pcre2 为 ss-server 运行必需的动态库，缺失会导致二进制无法加载）
RUN apk add --no-cache \
    ca-certificates \
    libsodium \
    libev \
    mbedtls \
    c-ares \
    pcre2

# 创建配置目录
RUN mkdir -p /etc/shadowsocks

# 暴露端口
EXPOSE 8388

# 通过环境变量配置：
#   SS_ADDR    监听地址 (默认 0.0.0.0)
#   SS_PORT    监听端口 (默认 8388)
#   SS_METHOD  加密方法 (默认 aes-256-gcm)
#   SS_PASSWORD 密码 (默认 changeme，生产务必修改)
# 注意 libev 的 -s 仅为主机地址，端口用 -p 指定
ENV SS_ADDR=0.0.0.0 \
    SS_PORT=8388 \
    SS_METHOD=aes-256-gcm \
    SS_PASSWORD=changeme

CMD ["sh", "-c", "ss-server -s ${SS_ADDR} -p ${SS_PORT} -m ${SS_METHOD} -k ${SS_PASSWORD}"]
