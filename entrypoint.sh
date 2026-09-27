#!/bin/sh

# Maximize file descriptor limits for concurrent high connection loads
ulimit -n 1048576 2>/dev/null || true

# Apply kernel network optimizations (fails gracefully if unprivileged)
sysctl -w net.core.somaxconn=65535 2>/dev/null || true
sysctl -w net.ipv4.tcp_fastopen=3 2>/dev/null || true
sysctl -w net.ipv4.tcp_max_syn_backlog=65536 2>/dev/null || true
sysctl -w net.ipv4.tcp_rmem="4096 87380 33554432" 2>/dev/null || true
sysctl -w net.ipv4.tcp_wmem="4096 65536 33554432" 2>/dev/null || true
sysctl -w net.ipv4.tcp_congestion_control=bbr 2>/dev/null || true

# Hand over execution to supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
