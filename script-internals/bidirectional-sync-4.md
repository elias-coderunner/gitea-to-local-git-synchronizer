# "Gitea doesn't have this repo" — import vs. do-not-resurrect

Two possibilities when a local repo has no match in Gitea:

1. First contact — it has never been imported. Import it.
2. Gitea deleted it — the user removed the repo in Gitea's UI. Do NOT resurrect it.

The state file in `.git/info/g2l-sync-gitea-prev.tsv` is the fingerprint of prior sync: if it exists, this repo was synced before, so its absence on Gitea means a deliberate deletion. If the state file is missing, this is a brand-new repo that needs importing.
