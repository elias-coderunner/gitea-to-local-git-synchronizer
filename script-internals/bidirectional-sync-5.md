# Verification pass — did the sync actually catch up?

For each scanned repo, compare every branch's HEAD in the source working tree against Gitea's bare copy. Any mismatch means the sync didn't actually catch up and the repo is flagged as out of sync.

This is a belt-and-suspenders check: the sync logic above should have handled everything, but if a push failed quietly or a fetch returned stale data, this pass catches it so the log records the inconsistency.
