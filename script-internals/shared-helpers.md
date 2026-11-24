# shared-helpers.sh — technical details

Shared prelude for `bidirectional-sync`, `ref-change-watcher`, `orphan-ref-pruner`.

Sourced by each script after it sets `set -uo pipefail`. Loads two config files, fills in defaults, and defines the two helpers every script uses.

## Exposes

- `err_log <msg>` — timestamped ERROR line appended to `$LOG` (grep ERROR catches every caller in every script); entries are followed by a blank line (`\n\n`) so the log stays one-blank-line-separated.
- `find_repos` — print every local `.git` dir under `$SCAN_ROOTS`, with the shared `EXCLUDE_REGEX` filter applied.

## Config sources

Loaded in this order:

1. `/etc/gitea-sync.env` — the credentials and deployment-specific paths. The path can be overridden via the `CONF` environment variable. Owned by root, readable by the service user (typical mode `640`, group-owned by that user).
2. `<install-dir>/support-artifacts/user-settings.conf` — tunable knobs (debounce, intervals, log cap, page size, `AUTO_PRUNE`). Sourced from the script's own location on disk; does not need to be in `/etc/`.

## Required variables (script aborts if any is unset)

- `GITEA_URL` — the Gitea base URL, including scheme (e.g. `http://host:3000` or `https://git.example.com`). The scheme is preserved in all generated push and clone URLs.
- `GITEA_USER` — the Gitea account whose repositories are synced.
- `GITEA_TOKEN` — API token for `GITEA_USER` with `repo` write permission.
- `SCAN_ROOTS` — space-separated list of root directories to search for `.git` folders.

## Optional variables (defaults shown)

- `GITEA_REPOS_DIR` = `/var/lib/gitea/data/gitea-repositories` — filesystem path to Gitea's bare repositories.
- `EXCLUDE_REGEX` = `/(node_modules|\.nvm|\.cache|\.local/share|vendor|\.venv|venv)/` — paths skipped during the recursive scan.
- `LOG` — defaults to `<install-dir>/activity-log/activity.log`, derived at runtime from the script's own on-disk location. Override only if a different log destination is needed.

## Tunable knobs (set in `user-settings.conf`; defaults shown)

- `DEBOUNCE_MS` = `150`
- `RESCAN_SECONDS` = `60`
- `HEARTBEAT_SECONDS` = `43200`
- `LOG_MAX_LINES` = `1000`
- `GITEA_API_PAGE_SIZE` = `50`
- `AUTO_PRUNE` = `true`

See `user-settings.conf` itself for a plain-language explanation of each.
