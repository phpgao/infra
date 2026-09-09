# mariadb Dockerfile
# MariaDB 数据库

FROM alpine:3

ARG MARIADB_VERSION=11.8

# 安装 MariaDB (mariadb 包包含服务端) + 客户端工具 + su-exec 用于降权
# 使用通配符匹配小版本 (如 11.8 -> 11.8.*)
RUN apk add --no-cache \
    "mariadb>=${MARIADB_VERSION}" \
    mariadb-client \
    su-exec

# 创建数据/运行目录并归属 mysql 用户
RUN mkdir -p /var/lib/mysql /run/mysqld /var/log/mysql && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld /var/log/mysql

# 入口脚本：首次启动初始化数据目录、处理 root 密码/默认库、以 mysql 用户运行
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 复制初始化脚本目录
COPY init/ /docker-entrypoint-initdb.d/

EXPOSE 3306

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mariadbd"]
