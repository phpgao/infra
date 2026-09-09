#!/bin/sh
# shadowsocks-go2 入口脚本
# go-shadowsocks2 通过 -s 'ss://METHOD:PASSWORD@:PORT' (SIP002) 启动服务端
set -e

# 多端口会起多个子进程，收到停止信号时一并结束
trap 'kill -TERM -1 2>/dev/null; exit 0' TERM INT

ADDR="${SS_ADDR:-0.0.0.0}"
PORT="${SS_PORT:-8388}"
METHOD="${SS_METHOD:-AES-256-GCM}"
PASSWORD="${SS_PASSWORD:-changeme}"
PORT_PASSWORD="${SS_PORT_PASSWORD:-}"
URI="${SS_URI:-}"

# 对密码做 percent-encode，避免 @ : / 等特殊字符破坏 SIP002 URI
enc() { printf '%s' "$1" | jq -sRr @uri; }

# 直接给定完整 SIP002 URI 则原样使用（最高优先级）
# -udp: go-shadowsocks2 服务端默认只监听 TCP，必须显式开启 UDP
if [ -n "$URI" ]; then
  echo "使用给定的 SS_URI"
  exec go-shadowsocks2 -s "$URI" -udp
fi

# 多端口 / 多密码: SS_PORT_PASSWORD 为 JSON 对象 {"端口":"密码", ...}
# 注意: go-shadowsocks2 单进程只认最后一个 -s，多端口需每个端口各起一个进程
if [ -n "$PORT_PASSWORD" ]; then
  echo "$PORT_PASSWORD" | jq -r 'to_entries[] | "\(.key)\t\(.value)"' > /tmp/pp
  echo "生成多端口配置 (port_password)，每个端口独立进程"
  while IFS=$(printf '\t') read -r p pw; do
    go-shadowsocks2 -s "ss://${METHOD}:$(enc "$pw")@${ADDR}:${p}" -udp &
  done < /tmp/pp
  wait
  exit $?
fi

# 单端口（默认）
PW=$(enc "$PASSWORD")
echo "生成单端口配置 port=$PORT method=$METHOD"
exec go-shadowsocks2 -s "ss://${METHOD}:${PW}@${ADDR}:${PORT}" -udp
