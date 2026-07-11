# Claude Config Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `~/install-scripts` the canonical, git-synced home for machine-agnostic Claude config (global CLAUDE.md, commands, hook library, settings bootstrap) via symlinks.

**Architecture:** New `claude/` dir holds canonical files; idempotent `setup_claude()` in `src/install_scripts/claude-setup.sh` symlinks them into `~/.claude` (backing up real files to `$ATTIC`), copies a settings template only-if-absent, and is wired into `first-day-install.sh`. Transfer between machines = normal `git push`/`git pull`.

**Tech Stack:** POSIX-ish sh in the repo's existing idiom (`source $CONSTANTS_FILE`, check-then-act, printf status).

## Global Constraints

- Repo is PUBLIC — no secrets in any added file (spec: "synced content must stay secret-free").
- Never clobber: real files back up to `$ATTIC/claude-backup-<name>.<timestamp>` before symlinking; `mkdir -p $ATTIC` inside the helper.
- `~/.claude/settings.json` is copied from template ONLY if absent; never overwritten.
- `~/.claude/commands/` stays a real directory (machine-local commands must coexist).
- Work on branch `claude-config-sync`; PR targets `master` on Twoody/mac-config.
- All commits end with: `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`

---

### Task 1: Canonical Claude assets in `claude/`

**Files:**
- Create: `claude/CLAUDE.md`, `claude/commands/sdd.md`, `claude/commands/hydrate-context.md`, `claude/hooks/test-safety-guard.sh`, `claude/hooks/lint-changed.sh`

**Interfaces:** Produces `$WORKING_DIR/claude/` layout consumed by Task 3's `setup_claude()`.

- [ ] **Step 1: Copy the live files (they are the canonical source, created 2026-07-11):**

```bash
cd ~/install-scripts
mkdir -p claude/commands claude/hooks
cp ~/.claude/CLAUDE.md claude/CLAUDE.md
cp ~/.claude/commands/sdd.md claude/commands/sdd.md
cp ~/.claude/commands/hydrate-context.md claude/commands/hydrate-context.md
cp ~/workspace/personal/tymbr/.claude/hooks/test-safety-guard.sh claude/hooks/test-safety-guard.sh
cp ~/workspace/personal/tymbr/.claude/hooks/lint-changed.sh claude/hooks/lint-changed.sh
chmod +x claude/hooks/*.sh
```

- [ ] **Step 2: Verify:** `wc -l claude/CLAUDE.md claude/commands/*.md` → 32, 66, 30 (±1); `diff ~/.claude/CLAUDE.md claude/CLAUDE.md` → empty; `grep -c 'test:ai' claude/hooks/test-safety-guard.sh` → ≥5.

- [ ] **Step 3: Commit:**

```bash
git add claude/ && git commit -m "feat(claude): canonical global CLAUDE.md, commands, and hook library

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

### Task 2: Settings bootstrap template

**Files:**
- Create: `templates/claude-settings.json`

**Interfaces:** Consumed by Task 3 (`cp $WORKING_DIR/templates/claude-settings.json ~/.claude/settings.json`).

- [ ] **Step 1: Write exactly:**

```json
{
  "permissions": {
    "defaultMode": "dontAsk"
  },
  "enabledPlugins": {
    "commit-commands@claude-plugins-official": true,
    "frontend-design@claude-plugins-official": true,
    "ponytail@ponytail": true,
    "superpowers@claude-plugins-official": true,
    "stripe@claude-plugins-official": true,
    "slack@claude-plugins-official": true
  },
  "extraKnownMarketplaces": {
    "ponytail": {
      "source": {
        "source": "github",
        "repo": "DietrichGebert/ponytail"
      }
    }
  }
}
```

(No `statusLine` — plugin cache path is machine/version-specific; no `model` — per-machine choice; no `hooks` — global hooks deliberately empty.)

- [ ] **Step 2: Verify:** `python3 -m json.tool templates/claude-settings.json` parses.

- [ ] **Step 3: Commit:**

```bash
git add templates/claude-settings.json && git commit -m "feat(claude): settings.json first-run template

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

### Task 3: `setup_claude()` + wiring

**Files:**
- Create: `src/install_scripts/claude-setup.sh`
- Modify: `src/constants.sh` (add two constants after the `SETUP=` / installer block)
- Modify: `first-day-install.sh` (source + call)

**Interfaces:**
- Consumes: `$ATTIC`, `$WORKING_DIR` from constants.sh; `claude/` from Task 1; template from Task 2.
- Produces: `setup_claude()` and `link_claude_file(src, target)`.

- [ ] **Step 1: Create `src/install_scripts/claude-setup.sh` with exactly:**

```sh
WORKING_DIR=~/install-scripts
CONSTANTS_FILE=$WORKING_DIR/src/constants.sh

# Symlink one repo file into ~/.claude, backing up any real file first
# @param {path} $1 - Source file inside the repo (absolute)
# @param {path} $2 - Target path under ~/.claude
link_claude_file ()
{
  source $CONSTANTS_FILE
  NAME=$(basename $2)

  if [ -L $2 ] && [ "$(readlink $2)" = "$1" ];
    then
      printf "\t$NAME already linked\n"
      return 0
  fi

  mkdir -p $ATTIC
  if [ -e $2 ] || [ -L $2 ];
    then
      BACKUP=$ATTIC/claude-backup-$NAME.$(date +%Y%m%d%H%M%S)
      printf "\tBacking up existing $NAME to $BACKUP\n"
      mv $2 $BACKUP
  fi

  printf "\tLinking $2 -> $1\n"
  ln -s $1 $2
  return 0
}

# Idempotent: symlink canonical Claude config from the repo into ~/.claude.
# Editing ~/.claude/CLAUDE.md (etc.) edits the repo through the symlink;
# commit + push here, `git pull` on other machines to sync.
setup_claude ()
{
  source $CONSTANTS_FILE
  printf "SETTING UP claude CONFIG\n"

  # commands dir stays a REAL dir so machine-local commands coexist
  mkdir -p ~/.claude/commands

  link_claude_file $CLAUDE_DIR/CLAUDE.md ~/.claude/CLAUDE.md

  for f in $CLAUDE_DIR/commands/*.md;
  do
    link_claude_file $f ~/.claude/commands/$(basename $f)
  done

  # First-run bootstrap only; settings accumulate machine-local state
  if [ ! -e ~/.claude/settings.json ];
    then
      printf "\tInstalling settings.json from template\n"
      cp $WORKING_DIR/templates/claude-settings.json ~/.claude/settings.json
    else
      printf "\tsettings.json exists: leaving untouched\n"
  fi
}

# setup_claude
```

- [ ] **Step 2: constants.sh** — after the line `VIM_INSTALL=$INSTALL_DIR/vim-installs.sh` add:

```sh
CLAUDE_SETUP=$INSTALL_DIR/claude-setup.sh
CLAUDE_DIR=$WORKING_DIR/claude
```

- [ ] **Step 3: first-day-install.sh** — after the line `source $APPLICATIONS_INSTALL` add `source $CLAUDE_SETUP`; after the line `  setup_zsh` (inside the `IS_SETUP` block) add `  setup_claude`.

- [ ] **Step 4: Syntax check:** `bash -n src/install_scripts/claude-setup.sh && bash -n first-day-install.sh` → no output.

- [ ] **Step 5: Commit:**

```bash
git add src/install_scripts/claude-setup.sh src/constants.sh first-day-install.sh
git commit -m "feat(claude): setup_claude symlinks canonical config into ~/.claude

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

### Task 4: Live verification on this machine

**Files:** none (behavioral test)

- [ ] **Step 1: Run it:** `cd ~/install-scripts && sh -c '. src/constants.sh; . src/install_scripts/claude-setup.sh; setup_claude'`
Expected: "Backing up existing CLAUDE.md…", "Linking…" for CLAUDE.md + sdd.md + hydrate-context.md, "settings.json exists: leaving untouched".
- [ ] **Step 2: Run again (idempotency):** same command → all "already linked" + "leaving untouched", nothing else.
- [ ] **Step 3: Verify links + content:**

```bash
readlink ~/.claude/CLAUDE.md          # → /Users/tanner/install-scripts/claude/CLAUDE.md (~ expansion ok)
readlink ~/.claude/commands/sdd.md    # → …/install-scripts/claude/commands/sdd.md
head -1 ~/.claude/CLAUDE.md           # → "- don't make extensive md files for everything"
ls ~/.attic | grep claude-backup      # → 3 backups
```

### Task 5: README + push + PR

**Files:**
- Modify: `README.md` (append usage section)

- [ ] **Step 1: Append to README.md:**

```markdown

## Claude config sync

Machine-agnostic Claude Code config lives in `claude/` and is symlinked into `~/.claude`
by `setup_claude` (runs in `first-day-install.sh`, or standalone:
`sh -c '. src/constants.sh; . src/install_scripts/claude-setup.sh; setup_claude'`).

- Edit `~/.claude/CLAUDE.md` or a synced command on any machine → the symlink writes into
  this repo → commit + push; `git pull` on other machines to sync.
- `templates/claude-settings.json` seeds `~/.claude/settings.json` on first run only.
- `claude/hooks/` is a reference library (test-safety guard, scoped lint) to copy into
  project repos' `.claude/hooks/` — not auto-installed.
```

- [ ] **Step 2: Commit + push + PR:**

```bash
git add README.md && git commit -m "docs: Claude config sync usage

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
git push -u origin claude-config-sync
gh pr create --repo Twoody/mac-config --base master --head claude-config-sync \
  --title "Claude config sync: canonical ~/.claude config, symlink installer" \
  --body "$(cat <<'EOF'
Adds a mechanism to carry machine-agnostic Claude Code config between environments, in the repo's live-source idiom (repo is canonical; symlinks; git pull = sync).

- `claude/` — canonical global CLAUDE.md + commands (`/sdd`, `/hydrate-context`) + reusable repo-hook library
- `templates/claude-settings.json` — first-run-only settings bootstrap (plugins + ponytail marketplace)
- `src/install_scripts/claude-setup.sh` — idempotent `setup_claude()`: backs up real files to `$ATTIC`, symlinks, never overwrites settings; wired into `first-day-install.sh`
- Spec + plan in `docs/superpowers/`

Verified live: fresh run backs up + links, second run is a no-op, `~/.claude` resolves through the symlinks.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- [ ] **Step 3: Verify:** `gh pr view --repo Twoody/mac-config --json url -q .url` returns the PR URL.
