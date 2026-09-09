# mariadb

MariaDB 数据库镜像，基于 Alpine Linux。

## 背景

MariaDB 由 MySQL 原作者领导开发，性能优化更多，存储引擎更丰富。与 MySQL 高度兼容，但部分新特性仅 MariaDB 支持。

## 镜像信息

| 属性 | 值 |
|------|-----|
| 基础镜像 | alpine:3 |
| MariaDB 版本 | 11.x |
| 端口 | 3306 |

## 快速开始

### Docker Run

```bash
docker run -d \
  --name mariadb \
  -e MARIADB_ROOT_PASSWORD=secret \
  -e MARIADB_DATABASE=myapp \
  -v mariadbdata:/var/lib/mysql \
  ghcr.io/phpgao/mariadb:latest
```

### Docker Compose

```yaml
services:
  mariadb:
    image: ghcr.io/phpgao/mariadb:latest
    environment:
      MARIADB_ROOT_PASSWORD: secret
      MARIADB_DATABASE: myapp
    volumes:
      - mariadbdata:/var/lib/mysql
    ports:
      - "3306:3306"

volumes:
  mariadbdata:
```

## 初始化脚本

将 `.sql` 或 `.sh` 文件放入 `init/` 目录，容器首次启动时自动执行：

```bash
docker run -d \
  -v ./my-init.sql:/docker-entrypoint-initdb.d/my-init.sql \
  -e MARIADB_ROOT_PASSWORD=secret \
  ghcr.io/phpgao/mariadb:latest
```

## 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `MARIADB_ROOT_PASSWORD` | root 用户密码 | 必填 |
| `MARIADB_USER` | 创建普通用户 | - |
| `MARIADB_PASSWORD` | 普通用户密码 | - |
| `MARIADB_DATABASE` | 默认数据库 | - |

## 连接数据库

```bash
# 进入容器
docker exec -it mariadb mariadb -u root -p

# 远程连接
mariadb -h <host> -P 3306 -u root -p
```

## MySQL vs MariaDB

| 特性 | MySQL | MariaDB |
|------|-------|---------|
| 维护方 | Oracle | 社区 |
| 存储引擎 | InnoDB | InnoDB + Aria |
| JSON 支持 | 原生 | 原生 |
| 窗口函数 | 8.0+ | 10.2+ |
