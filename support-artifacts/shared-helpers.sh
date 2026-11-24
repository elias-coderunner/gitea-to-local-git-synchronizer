#!/usr/bin/env bash
# Technical details: script-internals/shared-helpers.md

CONF=${CONF:-/etc/gitea-sync.env}
[ -r "$CONF" ] && . "$CONF"

# User-tunable settings (debounce, rescan interval, heartbeat, log size).
# Lives in the project folder so it can be edited without sudo.
USER_SETTINGS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/user-settings.conf"
[ -r "$USER_SETTINGS" ] && . "$USER_SETTINGS"

: "${GITEA_URL:?GITEA_URL not set in $CONF}"
: "${GITEA_USER:?GITEA_USER not set in $CONF}"
: "${GITEA_TOKEN:?GITEA_TOKEN not set in $CONF}"
: "${GITEA_REPOS_DIR:=/var/lib/gitea/data/gitea-repositories}"
: "${SCAN_ROOTS:?SCAN_ROOTS not set in $CONF}"
: "${EXCLUDE_REGEX:=/(node_modules|\.nvm|\.cache|\.local/share|vendor|\.venv|venv)/}"
: "${LOG:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/activity-log/activity.log}"

# Tunable defaults (overridable via user-settings.conf). See that file for
# what each one means.
: "${DEBOUNCE_MS:=150}"
: "${RESCAN_SECONDS:=60}"
: "${HEARTBEAT_SECONDS:=43200}"
: "${LOG_MAX_LINES:=1000}"
: "${GITEA_API_PAGE_SIZE:=50}"
: "${AUTO_PRUNE:=true}"

err_log() {
    printf '%s  ERROR %s\n\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG"
}

find_repos() {
    for root in $SCAN_ROOTS; do
        find "$root" -type d -name .git 2>/dev/null \
            | grep -Ev "$EXCLUDE_REGEX" || true
    done
}
