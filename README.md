# first-day-install

First day install for mac users to have a complete working environment on day zero

## TODO

Update `sh` and initial command both here and in the wiki. Basically an `sh ${curl this-repop-url}` I think

## Claude config sync

Machine-agnostic Claude Code config lives in `claude/` and is symlinked into `~/.claude`
by `setup_claude` (runs in `first-day-install.sh`, or standalone:
`sh -c '. src/constants.sh; . src/install_scripts/claude-setup.sh; setup_claude'`).

- Edit `~/.claude/CLAUDE.md` or a synced command on any machine → the symlink writes into
  this repo → commit + push; `git pull` on other machines to sync.
- `templates/claude-settings.json` seeds `~/.claude/settings.json` on first run only.
- `claude/hooks/` is a reference library (test-safety guard, scoped lint) to copy into
  project repos' `.claude/hooks/` — not auto-installed.

## Disk guard

`bin/disk-guard.sh` runs hourly via launchd and **only notifies — it never deletes**. It warns
when free space drops below 25G or a watched log dir exceeds 2048MB.

Installed by `setup_diskguard` (runs in `first-day-install.sh`, or standalone:
`sh -c '. src/constants.sh; . src/install_scripts/diskguard-setup.sh; setup_diskguard'`).

- `launchd/com.twoody.diskguard.plist` is symlinked into `~/Library/LaunchAgents`, so a
  `git pull` updates the guard on every machine. The plist has no hardcoded `/Users/<name>`:
  launchd won't expand `~` or `$VAR` in `ProgramArguments`, so it runs `sh -c` and lets the
  shell expand `$HOME`.
- Add directories to watch via `WATCH_DIRS` in the script. Missing dirs are skipped silently,
  so the list is safe on a machine that doesn't have those apps.
- Why it exists: a runaway third-party log writer (Reolink, ~23G in two hours) filled the disk
  to 99% and took Docker Desktop down with it — the engine crash-loops when its VM can't write,
  which looks nothing like a disk problem. Prune commands are in the script's header.

`bin/disk-cleanup.sh` runs weekly (Monday 10:00, or on wake if the Mac was asleep) and
**does delete**: Chrome `code_sign_clone` dirs older than a day (chrome-devtools-mcp leaves one
per launch) and Docker images, stopped containers, networks and build cache older than 7 days.
It never prunes Docker volumes. `setup_diskguard` installs it too. Log: `/tmp/disk-cleanup.log`.
