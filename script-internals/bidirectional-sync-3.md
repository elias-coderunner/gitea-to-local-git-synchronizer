# `deletion_sentinel` — why a fixed-path sentinel file

Set by `sync_repo` via a sentinel file when any branch/tag was deleted this run; triggers an immediate prune at the end of `main()`.

A fixed path is used so subshells spawned by `read < <(sync_repo ...)` can touch it — a variable set inside the subshell would be lost on the way out.
