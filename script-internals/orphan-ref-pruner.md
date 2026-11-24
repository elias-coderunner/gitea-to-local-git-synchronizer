# orphan-ref-pruner — technical details

Garbage-collects unreachable git objects (dangling commits, trees, blobs) from every local repo under `SCAN_ROOTS` and every Gitea bare repo under `$GITEA_REPOS_DIR/$GITEA_USER`. Any commit no branch or tag still points at gets pruned, so the commit graph stops showing ghost history after deletes.

## What it does per repo

- Expires the reflog immediately (`reflog expire --expire=now --all`).
- Runs `git gc --auto --prune=now`, which is fast when there's nothing to clean and only kicks in heavier work when git's own object-count threshold is passed.

## Extra step for Gitea bare repos

Each pull request has a hidden ref (`refs/pull/N/head`, optionally `refs/pull/N/merge`). If a PR row has been removed from Gitea's DB but the ref wasn't cleaned up, `git gc` can't prune the PR's commits because the ref still points at them. Before calling `gc`, the script:

- Reads the current repo's id from Gitea's SQLite DB.
- Lists the PR indexes that still exist for that repo.
- Walks `refs/pull/*` in the bare and deletes any whose number isn't in that list.

## Usage

- Invoked every 5 minutes from cron as a safety-net background pass.
- Also triggered immediately by `bidirectional-sync` when any branch or tag was deleted during a sync run (via a sentinel file at `/tmp/.g2l-deletions-sentinel`). This deletion-triggered path is gated by `AUTO_PRUNE=true` in `user-settings.conf` (the default); set `AUTO_PRUNE=false` to disable both the cron entry and the deletion-triggered run.
- Supports `--dry-run` to print what it would delete without touching anything.

## Config

Shares `/etc/gitea-sync.env` and `support-artifacts/user-settings.conf` with the sync and watcher scripts. See `shared-helpers.md` for the full variable list; this script also consumes `GITEA_DB` (default `/var/lib/gitea/data/gitea.db`).
