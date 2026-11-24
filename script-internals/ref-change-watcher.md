# ref-change-watcher — technical details

Event-driven two-way sync watcher: wakes on any ref change in local repos or in Gitea's bare repos and triggers a sync within ~100 ms. Falls back to a periodic rescan so brand-new repos get picked up and nothing stalls.

## How it wakes

- Uses `inotifywait` to watch, recursively:
  - Each local repo's `.git/refs`, `.git/logs`, `.git/HEAD`, `.git/packed-refs`.
  - Each Gitea bare repo's `refs/` and `packed-refs`.
  - The Gitea user directory itself (for repos created/deleted in the UI).
  - Each root in `SCAN_ROOTS` (for `git init` of brand-new local repos).
- On any event, waits 150 ms (debounce) then runs `bidirectional-sync` once.
- On a 60-second timeout with no events, runs `bidirectional-sync` anyway as a safety net and to pick up repos created in that window.
- Rebuilds its watch list every loop iteration, so newly created repos join the watch on the next cycle.

## Log policy

- Errors write immediately via the sync script's own `err_log`.
- One heartbeat line every `HEARTBEAT_SECONDS` (default 12h) proves the watcher is alive.
- Normal event-triggered runs are silent.

## Config

Shares `/etc/gitea-sync.env` with `bidirectional-sync`.
