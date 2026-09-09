# pgvector Dockerfile
# PostgreSQL + pgvector 向量数据库，用于 AI Agent 场景

FROM postgres:18-alpine

ARG VECTOR_VERSION=0.8.6

# 安装编译依赖 → 编译并安装 pgvector → 清理编译依赖，全部在单层完成。
# 这样 clang21/llvm21 等构建依赖不会残留在最终镜像层，减小体积。
RUN apk add --no-cache \
        curl make gcc musl-dev libpq-dev clang21 llvm21 \
    && cd /tmp \
    && curl -sL "https://github.com/pgvector/pgvector/archive/refs/tags/v${VECTOR_VERSION}.tar.gz" -o pgvector.tar.gz \
    && tar xzf pgvector.tar.gz \
    && cd "pgvector-${VECTOR_VERSION}" \
    && make CLANG=clang-21 \
    && make install \
    && cd / \
    && rm -rf /tmp/* \
    && apk del curl make gcc musl-dev clang21 llvm21

# 复制初始化脚本目录
COPY init/ /docker-entrypoint-initdb.d/

# 暴露端口
EXPOSE 5432

# 启动 PostgreSQL (官方镜像默认命令)
CMD ["postgres"]
