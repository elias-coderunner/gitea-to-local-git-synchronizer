# Deletion-triggered prune — why run it immediately

If any branches or tags were deleted this run, kick off `orphan-ref-pruner` right away (via the sentinel file `/tmp/.g2l-deletions-sentinel`) so the commit graph does not keep showing dangling history until the cron pruner runs on its schedule.

Without this, a branch you just deleted in Gitea would still show its orphaned commits for up to five minutes (until the next cron tick, which runs the pruner every 5 min). The in-line trigger makes deletes look instantaneous.

The deletion-triggered path is gated by `AUTO_PRUNE=true` in `support-artifacts/user-settings.conf` (the default). When `AUTO_PRUNE=false`, both this in-line trigger and the cron entry are expected to be absent — the operator has opted to manage repository garbage collection themselves.
