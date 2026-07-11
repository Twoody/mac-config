- don't make extensive md files for everything

## Debugging discipline
- Before editing any fix: gather evidence and state a root-cause hypothesis. No code changes
  until the cause is established — wrong-hypothesis first fixes cost more than the investigation.
- Bug fixes include a regression test that fails against the buggy code and passes after; run both to confirm.
- Green tests ≠ fixed: reproduce the original symptom in the running app/container (or prod signal)
  and confirm it's gone before declaring a bug resolved.

## Keep diffs task-scoped
- Run eslint --fix (or any formatter) only on files you edited. If a fixer reformats unrelated
  files, revert that churn before committing.

## Output hygiene
- Large outputs (digests, audits, plans, reports): write to the target file incrementally as
  sections complete; keep chat replies to a few short paragraphs. Giant single replies have
  aborted whole sessions on output-token limits.
- MEMORY.md index entries stay one short line (~120 chars); details belong in the memory file body.

## Preflight
- Before PR/review/GitHub work, verify `gh auth status`.
- Prefer absolute paths — cwd can reset between Bash calls; verify location before greps/builds.
- Remote/prod shell commands must be POSIX-sh-safe (no bash-only `source`; use `. ./file`).

## Long-running jobs
- Any local job expected to exceed ~45 minutes (builds, prerenders, full sweeps): detach with
  `nohup … & disown` from a quick foreground command — background Bash tasks are killed at ~1h
  regardless of health — or split into shorter runs.

## Parallel subagents
- Follow the /sdd contract (~/.claude/commands/sdd.md): strictly disjoint file scopes per agent,
  scoped tests only (never each other's suites), hermetic mocks, controller-verified integration.
