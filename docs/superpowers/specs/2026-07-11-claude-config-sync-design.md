# Claude config sync — design spec

**Date:** 2026-07-11 · **Status:** Approved (user pre-authorized recommended approach)
**Repo:** Twoody/mac-config (`~/install-scripts`, PUBLIC — synced content must stay secret-free)

## Problem

Claude Code config that is machine-agnostic (global `~/.claude/CLAUDE.md`, global commands, reusable hook scripts, plugin bootstrap) currently lives only on one machine. This repo is the per-machine environment installer; it should carry that config between environments.

## Mechanism: symlink live-source

Matches the repo's existing idiom (rc files are sourced live from `~/install-scripts`; `git pull` updates the environment). The repo becomes the canonical home for Claude config; `~/.claude` gets symlinks into it. Editing config on any machine writes through the symlink into the repo → commit/push; other machines `git pull`. No copy drift.

## Layout

```
claude/
  CLAUDE.md                      # canonical global instructions
  commands/
    sdd.md                       # subagent-orchestration contract
    hydrate-context.md           # project-orientation command
  hooks/                         # reference library — NOT auto-installed
    test-safety-guard.sh         # PreToolUse(Bash) bounded-test-runner guard
    lint-changed.sh              # PostToolUse(Edit|Write) scoped check-only lint
templates/
  claude-settings.json           # first-run bootstrap (enabledPlugins, ponytail marketplace, defaults)
src/install_scripts/claude-setup.sh   # setup_claude()
```

Initial content of `claude/` = verbatim copies of the current `~/.claude` files (built 2026-07-11 from the usage-insights optimization).

## setup_claude() behavior (idempotent, repo style: check-then-act + printf status)

1. `mkdir -p ~/.claude/commands` (the commands *directory* stays a real dir so machine-local commands coexist).
2. For each managed pair (`~/.claude/CLAUDE.md` → `$WORKING_DIR/claude/CLAUDE.md`; each file in `claude/commands/` → `~/.claude/commands/<name>`):
   - already the correct symlink → print "exists", skip
   - exists as real file/wrong link → move to `$ATTIC/claude-backup-<name>.<timestamp>`, then `ln -s`
   - absent → `ln -s`
3. `~/.claude/settings.json`: if absent, `cp templates/claude-settings.json` there; if present, leave untouched (print skip message). Never overwrite — settings accumulate machine-local state.
4. New files added later to `claude/commands/` are picked up on the next `setup_claude` run (loop globs the directory).
5. Wire-up: `CLAUDE_SETUP=$INSTALL_DIR/claude-setup.sh` in `src/constants.sh`; `source $CLAUDE_SETUP` + `setup_claude` call in `first-day-install.sh` (after `setup_zsh`, before app installs). Also runnable standalone: `sh -c '. src/constants.sh; . $CLAUDE_SETUP; setup_claude'` from the repo root.

## settings template content

`enabledPlugins` (superpowers, ponytail, commit-commands, frontend-design, stripe, slack), `extraKnownMarketplaces` (ponytail → github DietrichGebert/ponytail), `permissions.defaultMode: dontAsk`. No statusLine (plugin cache path is machine/version-specific; ponytail sets it up), no model (machine choice), no hooks (global hooks are deliberately empty). No secrets exist in any synced file.

## Out of scope (rejected)

- Per-repo CLAUDE.md mirroring — those live in their own repos; mirroring creates drift.
- Auto-installing the hook library into project repos — provided as reference copies only.
- chezmoi/stow — new dependency + idiom for four files.
- Copy-on-install — edits wouldn't propagate back; contradicts the live-source idiom.

## Error handling

Never clobber: real files are backed up to `$ATTIC` (repo's existing backup location) before symlinking; `setup_claude` runs `mkdir -p $ATTIC` itself so standalone runs don't depend on `make_dirs` having run first. Template copy is only-if-absent. Script is `sh`-compatible like its siblings.

## Testing

Run `setup_claude` on this machine: verifies backup-then-symlink of the real files created this morning (repo copies are identical, so behavior is unchanged), then run it a second time to verify idempotency (all "exists/skip" messages, no changes). `claude` CLI must still resolve the global CLAUDE.md and list `/sdd` + `/hydrate-context`.

## Acceptance

- `readlink ~/.claude/CLAUDE.md` → `~/install-scripts/claude/CLAUDE.md`; same for both commands.
- Second `setup_claude` run is a no-op.
- Existing `~/.claude/settings.json` untouched; on a machine without one, template lands.
- PR opened against Twoody/mac-config master from a feature branch.
