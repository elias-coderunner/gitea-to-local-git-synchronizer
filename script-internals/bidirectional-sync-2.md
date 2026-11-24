# `reconcile_gitea_db()` — fix phantom branch rows

Reconcile Gitea's DB with the actual refs in its bare repos.

Normal user actions (UI delete, our `push --delete`) keep the two in sync via Gitea's receive hooks. But if anything ever bypasses those hooks (bare manipulation, bugs, our own earlier mistakes), the DB can carry phantom branch rows that the UI still shows but can't delete. This function marks those rows as deleted so the UI matches reality.
