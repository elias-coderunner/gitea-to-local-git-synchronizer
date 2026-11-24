# bidirectional-sync — technical details

Keeps a Gitea instance and every local Git repository found under `SCAN_ROOTS` in two-way lock-step.

## What it does

- New local repos are imported into Gitea (private, owner `$GITEA_USER`).
- Branches ahead locally get pushed up to Gitea.
- Branches ahead on Gitea get fast-forwarded down to local (so merges and edits done in Gitea's UI land on disk).
- Diverged branches (both sides advanced independently) are left alone and logged as conflicts — manual resolution required.
- The same create/delete logic is applied to tags.
- Repos created in Gitea's web UI but absent on disk are cloned into the first path in `SCAN_ROOTS`.
- Gitea's SQLite database is reconciled against the actual bare-repo refs, so phantom branch rows the UI cannot delete get swept.
- If any branch or tag was deleted during the run, `orphan-ref-pruner` is kicked off immediately so the graph does not keep showing dangling history.

## How the branch decision is made

Uses a small state file inside each repository's `.git/info/` directory (`g2l-sync-local-prev.tsv`, `g2l-sync-gitea-prev.tsv`, and the tag counterparts) to remember the last-known branch and tag set on each side. This lets the script tell "branch missing because the other side deleted it" apart from "branch missing because this side just created it."

Per branch:

|                             | gitea has it: yes          | gitea has it: no                                                |
|-----------------------------|----------------------------|-----------------------------------------------------------------|
| **local has it: yes**       | commit sync                | was-in-gitea-prev? → delete local; else → push to gitea         |
| **local has it: no**        | was-in-local-prev? → delete on gitea; else → create local branch | —                                                               |

Reads from Gitea via the bare repository path on disk (fast, local filesystem). Writes to Gitea via HTTP so that Gitea's receive hooks fire and its DB counters stay correct.

## Logging policy

- On any run where anything was imported, fetched, pushed, or diverged: one summary line.
- Otherwise, a heartbeat line is emitted at most once every `HEARTBEAT_SECONDS` (default 12 h) — written by the watcher, not by this script.
- The log file is trimmed to the most recent `LOG_MAX_LINES` lines (default 1000) at the end of each run.

## Config

All deployment-specific values come from `/etc/gitea-sync.env` (owned by root, readable by the service user; typical mode `640`). The variables consumed by this script are:

Required:
- `GITEA_URL` — Gitea base URL, including scheme.
- `GITEA_USER` — the Gitea account whose repositories are synced.
- `GITEA_TOKEN` — API token for `GITEA_USER` with `repo` write permission.
- `SCAN_ROOTS` — space-separated list of directories to scan for `.git` folders.

Optional (defaults in `shared-helpers.sh`):
- `GITEA_REPOS_DIR`, `GITEA_DB`, `EXCLUDE_REGEX`, `LOG`.

Tunables are loaded from `support-artifacts/user-settings.conf`; see `shared-helpers.md` for the full list.
