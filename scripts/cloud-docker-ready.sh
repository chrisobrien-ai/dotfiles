#!/usr/bin/env bash
# Start dockerd on Cloud Agent VMs where systemd is unavailable.
# Idempotent — safe to run from .cursor/environment.json "start" each session.
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "cloud-docker-ready: docker not installed (see .cursor/Dockerfile or AGENTS.md)" >&2
  exit 0
fi

if docker info >/dev/null 2>&1 || sudo docker info >/dev/null 2>&1; then
  exit 0
fi

if ! sudo -n true 2>/dev/null; then
  echo "cloud-docker-ready: dockerd not running and passwordless sudo unavailable" >&2
  exit 1
fi

sudo sh -c 'dockerd >/tmp/dockerd.log 2>&1 &'
for _ in $(seq 1 20); do
  if docker info >/dev/null 2>&1 || sudo docker info >/dev/null 2>&1; then
    exit 0
  fi
  sleep 1
done

echo "cloud-docker-ready: dockerd failed to start (see /tmp/dockerd.log)" >&2
tail -20 /tmp/dockerd.log >&2 || true
exit 1
