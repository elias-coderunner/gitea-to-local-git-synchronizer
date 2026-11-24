# `prune_orphan_pull_refs()` — why it exists

For a Gitea bare repo, this function removes any `refs/pull/<N>/head` or `refs/pull/<N>/merge` whose `<N>` has no matching row in Gitea's `pull_request` table.

Such refs get left behind when the DB row was removed out-of-band — for example, by a direct SQL cleanup or any other DB manipulation that bypassed Gitea's hooks. The refs then keep stale commits reachable, so `git gc` won't prune them. Removing the refs first lets the subsequent `gc` pass actually reclaim those commits.
