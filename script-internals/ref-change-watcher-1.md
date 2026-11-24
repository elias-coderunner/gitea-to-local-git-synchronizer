# Gitea bare repos — what to watch and why

Gitea's bare repos are where UI merges and edits land. The watcher needs to notice ref changes there too, not just in local working trees.

The script also watches the user-level directory (`$GITEA_REPOS_DIR/$GITEA_USER`) itself so repos created or deleted in the UI are noticed within one event cycle — otherwise a brand-new Gitea repo wouldn't trigger a sync until the 60-second fallback rescan picked it up.
