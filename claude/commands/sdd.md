Orchestrate parallel subagent development (SDD) safely. This is the standing contract for any
session that fans out implementer agents across worktrees. Every rule exists because its absence
broke something.

## Preflight (before any fan-out)

1. **Hooks**: read the project's `.claude/settings.json`. If any PostToolUse hook spawns test or
   lint runs on Edit|Write, temporarily remove it and restore it after the run. Hook config is
   cached at session spawn and inherited by subagents — editing settings.json mid-session does
   NOT stop already-running sessions or their children.
2. **Worktrees**: one per parallel task. In an npm-workspaces monorepo, run `npm ci` inside each
   fresh worktree before dispatching — upward node_modules resolution misses un-hoisted
   per-package deps, and workspace symlinks otherwise point at the MAIN checkout (shared-lib
   edits would test against stale code).
3. **Partition**: assign each agent a strictly disjoint file set, stated explicitly in its
   dispatch prompt. A shared file forces sequencing, not parallelism.
4. The main checkout and its checked-out branch are **shared, live state** (the user commits to
   them mid-session; a branch checked out there is ref-locked). All SDD work happens on dedicated
   branches in worktrees.

## Dispatch contract (include in every agent prompt)

- FIRST, before any edit: `cd <your-worktree> && git rev-parse --abbrev-ref HEAD && pwd` — abort
  unless both match your assignment. (Subagents start in the main checkout's cwd.)
- Edit and commit ONLY your owned files (list them). Out-of-scope edits are forbidden.
- Run only tests scoped to your files, via the repo's bounded runner with worker caps
  (e.g. `--maxWorkers=2`). Never the full suite; never another task's tests.
- Never pipe test output through grep/head — SIGPIPE kills the npm wrapper and orphans the
  runner, which silently keeps running the whole suite. Redirect to a file, grep the file.
- Specs must be hermetic: mock every network/service boundary. A spec that needs the local
  docker stack running is a bug in the spec.

## Monitor (while agents run)

- Runner processes: `pgrep -fl 'vit[e]st|jest'` — ≥4 concurrent runners, or any runner older
  than ~2 min, means the contract broke; `pkill -9` strays (they ignore SIGTERM).
- Background builds (gradle/xcodebuild/docker): poll the log file every ~60s; a log silent for
  5+ minutes is a stall to report and nudge, not to wait out.
- A failure that appears only under concurrent load is a contention flake — re-run standalone
  before debugging it.

## Integrate

- Before merging any agent branch: `git merge-base <target> <branch>` must equal
  `git rev-parse <target>`. If it doesn't (worktree branches have silently based off HEAD~1),
  cherry-pick the agent's commits onto an integration branch instead of merging.
- Never accept an agent's self-report: re-run its scoped tests yourself and inspect
  `git log` / `git diff --stat` on its branch. Counts and green claims are re-derived, not trusted.
- Sweep before push: `git status` / `git diff` — revert or exclude anything outside the plan's
  scope (version bumps, formatter churn). An unrelated diff mid-run likely belongs to a
  concurrent session: leave it alone.
- If the integration target is checked out elsewhere (ref-locked): fast-forward push, or
  `git merge-tree` to verify zero conflicts then `git commit-tree` + push. Never force-switch
  the main checkout.
- Local docker DB/containers are shared across sessions: only additive, backward-compatible
  migrations from unmerged branches; record every applied migration or container rebuild in the
  plan/notes file so other sessions and the eventual merge know the environment is ahead.

## Final gate (mandatory)

1. Full test sweep on the MERGED/integrated result — serialized, run once, by the controller.
   Cross-task and merge-fallout bugs exist only there.
2. Adversarial whole-branch review by a strong model. For DB-touching work the reviewer checks
   against the real schema and existing migrations — mocked tests cannot catch cross-migration
   constraint conflicts.
3. Restore any hooks removed in preflight.
