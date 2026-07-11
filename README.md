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
