#!/bin/sh
# Хост — cgroup v2 (unified), а judge0/judge0:1.13.1 несёт isolate 1.8.1, который
# умеет только cgroup v1 и хардкодит путь /sys/fs/cgroup/<controller>/box-N —
# такого пути на cgroup v2 просто нет, поэтому песочница не создавалась вообще
# (см. систему тикетов isolate/judge0 про "No such file or directory @
# rb_sysopen - /box/script.py": isolate падает на первом шаге, box так и не
# создаётся). Здесь мы: 1) собрали isolate 2.0 (см. Dockerfile) — он поддерживает
# только cgroup v2; 2) готовим ему делегированный поддерево cgroup, раз в
# контейнере нет systemd, который бы сделал это через isolate.service.
set -e

sudo sh -c '
  set -e
  mkdir -p /run/isolate/locks
  cg=/sys/fs/cgroup

  # cgroup v2 запрещает контроллеры на поддереве, если в самой группе есть
  # процессы — переносим всё текущее (сам этот шелл) в отдельный лист.
  mkdir -p "$cg/init"
  for pid in $(cat "$cg/cgroup.procs"); do
    echo "$pid" > "$cg/init/cgroup.procs" 2>/dev/null || true
  done

  for c in cpuset cpu io memory pids; do
    echo "+$c" > "$cg/cgroup.subtree_control" 2>/dev/null || true
  done

  mkdir -p "$cg/isolate"
  for c in cpu memory pids; do
    echo "+$c" > "$cg/isolate/cgroup.subtree_control" 2>/dev/null || true
  done

  cat > /usr/local/etc/isolate <<CONF
lock_root = /run/isolate/locks
box_root = /var/local/lib/isolate
cg_root = $cg/isolate
first_uid = 60000
first_gid = 60000
num_boxes = 1000
CONF
'

exec /api/docker-entrypoint.sh "$@"
