#!/usr/bin/env bash
# sleep-manager.sh — manage macOS sleep behavior
# Usage: sleep-manager.sh {status|disable|enable}

set -euo pipefail

CAFFEINATE_PIDFILE="/tmp/sleep-manager-caffeinate.pid"

status() {
    echo "=== Current Sleep Settings ==="
    pmset -g | grep -E '^\s*(sleep|displaysleep|disksleep)\b' || true

    echo
    echo "=== Active Sleep Assertions ==="
    # Assertions are processes actively blocking sleep right now
    pmset -g assertions | grep -E 'PreventUserIdleSystemSleep|PreventUserIdleDisplaySleep' | grep -v '0$' || echo "(none)"

    echo
    if [[ -f "$CAFFEINATE_PIDFILE" ]] && kill -0 "$(cat "$CAFFEINATE_PIDFILE")" 2>/dev/null; then
        echo "=== Script-managed caffeinate: RUNNING (pid $(cat "$CAFFEINATE_PIDFILE")) ==="
    else
        echo "=== Script-managed caffeinate: not running ==="
    fi
}

enable_sleep() {
    # Restore default sleep behavior.
    # Kill our caffeinate process if running.
    if [[ -f "$CAFFEINATE_PIDFILE" ]]; then
        if kill -0 "$(cat "$CAFFEINATE_PIDFILE")" 2>/dev/null; then
            kill "$(cat "$CAFFEINATE_PIDFILE")"
            echo "Stopped caffeinate process."
        fi
        rm -f "$CAFFEINATE_PIDFILE"
    fi

    # Restore pmset defaults (sensible values; user can tune later).
    echo "Restoring pmset defaults (requires sudo)..."
    sudo pmset -a sleep 10 displaysleep 10 disksleep 10
    echo "Sleep re-enabled."
}

disable_sleep() {
    # TODO: implement — see prompt below.
    echo "disable_sleep not yet implemented" >&2
    exit 1
}

case "${1:-}" in
    status)  status ;;
    disable) disable_sleep ;;
    enable)  enable_sleep ;;
    *)
        echo "Usage: $0 {status|disable|enable}" >&2
        exit 1
        ;;
esac
