#!/bin/sh
set -e

DATADIR="${DATADIR:-/var/lib/mysql}"
SOCKET="${SOCKET:-/run/mysqld/mysqld.sock}"
INITDB_DIR="/docker-entrypoint-initdb.d"
LOGDIR="/var/log/mysql"

# 以 root 启动时，先把目录权限交给 mysql 用户，再降权运行
if [ "$(id -u)" = "0" ]; then
  mkdir -p "$(dirname "$SOCKET")" "$LOGDIR"
  chown -R mysql:mysql "$DATADIR" "$(dirname "$SOCKET")" "$LOGDIR" 2>/dev/null || true

  # 首次启动：初始化系统库
  if [ ! -d "$DATADIR/mysql" ]; then
    echo "初始化 MariaDB 数据目录 ($DATADIR) ..."
    mariadb-install-db --user=mysql --datadir="$DATADIR" --auth-root-authentication-method=normal >/dev/null
  fi

  # 构造启动期初始化 SQL（root 密码 / 默认库 / 普通用户 / 删除匿名用户）
  INIT_SQL=""
  NEED_INIT=0
  [ -n "$MARIADB_ROOT_PASSWORD" ] && NEED_INIT=1
  [ -n "$MARIADB_DATABASE" ] && NEED_INIT=1
  [ -n "$MARIADB_USER" ] && NEED_INIT=1
  [ "$FIRST_INIT" = "1" ] && NEED_INIT=1
  if [ "$NEED_INIT" = "1" ]; then
    INIT_SQL=$(mktemp)
    [ -n "$MARIADB_ROOT_PASSWORD" ] && printf "ALTER USER 'root'@'localhost' IDENTIFIED BY '%s';\n" "$MARIADB_ROOT_PASSWORD" >> "$INIT_SQL"
    [ -n "$MARIADB_DATABASE" ] && printf "CREATE DATABASE IF NOT EXISTS \`%s\`;\n" "$MARIADB_DATABASE" >> "$INIT_SQL"
    if [ -n "$MARIADB_USER" ]; then
      printf "CREATE USER IF NOT EXISTS '%s'@'%%' IDENTIFIED BY '%s';\n" "$MARIADB_USER" "${MARIADB_PASSWORD:-}" >> "$INIT_SQL"
      [ -n "$MARIADB_DATABASE" ] && printf "GRANT ALL PRIVILEGES ON \`%s\`.* TO '%s'@'%%';\n" "$MARIADB_DATABASE" "$MARIADB_USER" >> "$INIT_SQL"
    fi
    chmod 644 "$INIT_SQL"
  fi

  ARGS=""
  [ -n "$INIT_SQL" ] && ARGS="--init-file=$INIT_SQL"

  # root 认证选项（设置了密码时，连接需带密码）
  MARIADB_OPTS=""
  [ -n "$MARIADB_ROOT_PASSWORD" ] && MARIADB_OPTS="-p$MARIADB_ROOT_PASSWORD"

  # 后台以 mysql 用户启动
  su-exec mysql mariadbd --datadir="$DATADIR" --socket="$SOCKET" $ARGS &
  pid=$!

  # 等待服务就绪
  for _ in $(seq 1 60); do
    if mysqladmin --socket="$SOCKET" $MARIADB_OPTS ping >/dev/null 2>&1; then break; fi
    sleep 1
  done

  # 删除匿名用户（避免 ''@'localhost' 抢占连接导致普通用户登录被拒）
  HN=$(hostname)
  mariadb --socket="$SOCKET" $MARIADB_OPTS -e "DROP USER IF EXISTS ''@'localhost'; DROP USER IF EXISTS ''@'127.0.0.1'; DROP USER IF EXISTS ''@'::1'; DROP USER IF EXISTS ''@'$HN';" 2>/dev/null || true

  # 首次启动：执行 init 目录下的脚本（sql / sh）
  if [ -d "$INITDB_DIR" ] && ls "$INITDB_DIR"/* >/dev/null 2>&1; then
    for f in "$INITDB_DIR"/*; do
      case "$f" in
        *.sql) echo "导入 $f"; mariadb --socket="$SOCKET" $MARIADB_OPTS < "$f" ;;
        *.sh)  echo "执行 $f"; sh "$f" ;;
      esac
    done
  fi

  # 转前台，跟随子进程
  wait "$pid"
else
  # 已是 mysql 用户：自行初始化并启动
  if [ ! -d "$DATADIR/mysql" ]; then
    mariadb-install-db --user=mysql --datadir="$DATADIR" --auth-root-authentication-method=normal >/dev/null
  fi
  exec mariadbd --datadir="$DATADIR" --socket="$SOCKET"
fi
