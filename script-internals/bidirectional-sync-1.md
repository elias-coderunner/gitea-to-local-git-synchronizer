# `sync_repo()` — two-way sync for one repo

Two-way sync for one repo, including branch creations AND deletions.

Uses a tiny state file inside `.git/info/` to remember the last-known branch set on each side. This lets us tell "branch missing because the other side deleted it" apart from "branch missing because this side just created it."

## Per-branch decision matrix

|                      | gitea has it: yes          | gitea has it: no                                      |
|----------------------|----------------------------|-------------------------------------------------------|
| **local has it: yes** | commit sync               | was-in-gitea-prev? → delete local; else → push to gitea |
| **local has it: no**  | was-in-local-prev? → delete on gitea; else → create local branch | — |

## Read/write paths

- Reads from Gitea via the bare repo path (fast, local filesystem).
- Writes to Gitea via HTTP (so Gitea's receive hooks fire → DB counters stay correct → the UI shows the right numbers).

## Output

Echoes `<commits_delta> <conflicts>` on stdout.
