# Agents

Orientation for AI agents working in this repository. The project itself is already documented in depth elsewhere; this file's only job is to route you to the right place based on what you are trying to do.

## What this repo is

A systemd + cron synchronizer that keeps a Gitea instance and a set of local Git working trees in two-way sync. Three shell scripts (`bidirectional-sync`, `ref-change-watcher`, `orphan-ref-pruner`) share one helpers library and one config file.

## Where to read next

| If you need to…                                  | Read                                                   |
| ------------------------------------------------ | ------------------------------------------------------ |
| Understand the problem this solves and the solution approach | `README`                                               |
| Find any file in the repo                        | `Index`                                                |
| Install the synchronizer on a machine            | `installation-instructions`                            |
| Edit post-install deployment config (rotate the Gitea token, add a scan root, change the Gitea URL) | `/etc/gitea-sync.env` on the target machine; schema documented in `installation-instructions` Step 2 |
| Change the systemd unit (how the watcher is launched, restart policy, user, environment) | `installation-instructions` Step 4 (holds the canonical unit content)                                |
| Diagnose a failure (service won't start, syncs fail, pushes rejected, repos not picked up, inotify limits) | `installation-instructions` → "When something goes wrong" section                                    |
| Understand how a specific script works internally | `script-internals/<script-name>.md` (plus numbered follow-ups) |
| Understand the shared config loader and helpers  | `script-internals/shared-helpers.md`                   |
| Change a user-tunable knob (debounce, intervals, log cap, page size, auto-prune) | `support-artifacts/user-settings.conf` |
| Change defaults or shared helper functions       | `support-artifacts/shared-helpers.sh`                  |
| See the running system's log                     | `activity-log/activity.log` (runtime, gitignored)      |

## House rules

Non-obvious invariants that are easy to break. Check these before editing anything.

- **Required env vars** in `/etc/gitea-sync.env` are `GITEA_URL`, `GITEA_USER`, `GITEA_TOKEN`, `SCAN_ROOTS`. The scripts abort at startup if any is unset. Do not reintroduce silent defaults for these — the previous version of the scripts did, and it leaked the author's values into fresh installs.
- **State-file prefix is `g2l-`** (as in `g2l-sync-local-prev.tsv`, `/tmp/.g2l-deletions-sentinel`). Read and write sites must match. If you rename the prefix, rename every matching read site and migrate existing state files on disk, or the next sync will treat every repo as brand-new.
- **Systemd unit name is `gitea-to-local-git-synchronizer-watcher.service`.** Canonical source: `installation-instructions` Step 4. Do not rename it in documentation without renaming the unit file itself and every reference.
- **`activity-log/activity.log` is runtime state**, gitignored. Do not commit log content, and do not write new log lines from documentation examples.
- **Scheme-preserving URLs.** The push and clone URLs in `bidirectional-sync` derive their scheme from `GITEA_URL`. Do not hardcode `http://` or `https://`.
- **Filesystem access to Gitea is a hard requirement** (not optional). `sync_repo` fetches from `$GITEA_REPOS_DIR/<user>/<repo>.git` on disk. The synchronizer only works same-box with Gitea or with Gitea's data directory mounted on the sync host.

## Verifying a change works

Three commands, same as `installation-instructions` Step 6:

```
<install-dir>/scripts/bidirectional-sync          # should exit 0
systemctl status gitea-to-local-git-synchronizer-watcher.service   # should be active (running)
tail -20 <install-dir>/activity-log/activity.log  # should have no new ERROR lines
```
