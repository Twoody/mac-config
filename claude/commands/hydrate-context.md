Familiarize yourself with the current project by mapping its structure and working state. Works in any repo — lean on the project's own docs for specifics.

Your context auto-loads each project's `CLAUDE.md` and (if present) its memory index `MEMORY.md` at session start — **don't re-read them**, you already have them. This skill fills the gaps: the live directory layout, current git state, and any detailed docs/memory the task needs.

## Steps

0. **Confirm location**: `pwd` and `git rev-parse --show-toplevel`; run everything below from
   that root using absolute paths — cwd can reset between Bash calls.

1. **Map the structure** (stdout only — do not write a file). Directories-only gives a clean skeleton without dumping every source file:

   ```bash
   tree -d -L 4 -I 'node_modules|.git|.turbo|dist|build|out|target|vendor|.venv|__pycache__|.next|coverage|.attic|.claude|playwright-report|test-results' 2>/dev/null || find . -maxdepth 4 -type d -not -path '*/node_modules/*' -not -path '*/.git/*' | sort
   ```

   Identify the top-level layout, the main source dirs, and where tests/migrations/config live. If `CLAUDE.md` already documents the structure, use the tree to confirm and extend it rather than re-deriving from scratch.

2. **Read top-level docs only if not already in context.** A `CLAUDE.md` is auto-loaded — skip it. If the repo has no `CLAUDE.md` but does have a `README` / `readme.md`, read that for orientation.

3. **Check current git state** (the snapshot in your session context can be stale):

   ```bash
   git branch --show-current && git status --short && git log --oneline -10
   ```

4. **Pull detailed memory/docs only as needed.** If a `MEMORY.md` index is in context, it points to detailed memory files in the same directory — read a specific one only when its description is relevant to the task. Likewise skim `docs/` only for the area the task touches; don't bulk-read.

5. **Summarize briefly**: project type/stack, current branch + uncommitted work, and which area(s) the task likely touches. Then ask what we're working on.
