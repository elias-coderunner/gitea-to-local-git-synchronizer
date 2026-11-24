# `reconcile_gitea_db()` — fix phantom branch rows

Reconcile Gitea's DB with the actual refs in its bare repos.

Normal user actions (UI delete, a `push --delete` from the synchronizer) keep the two in sync via Gitea's receive hooks. But if anything ever bypasses those hooks (direct bare-repo manipulation, bugs, out-of-band changes), the DB can carry phantom branch rows that the UI still shows but can't delete. This function marks those rows as deleted so the UI matches reality.
