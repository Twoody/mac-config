#!/usr/bin/env bash
# PostToolUse(Edit|Write): check-lint ONLY the files just edited.
# Whole-repo lint on every edit stacked up under parallel agents; scoped is cheap.
# Check-only on purpose — a mutating (--fix) hook re-triggers File-Changed edit errors.
lintable=()
for f in $CLAUDE_FILE_PATHS; do
  case "$f" in
    *.js|*.mjs|*.cjs|*.vue) [ -f "$f" ] && lintable+=("$f") ;;
  esac
done
[ ${#lintable[@]} -eq 0 ] && exit 0
npx eslint --no-error-on-unmatched-pattern "${lintable[@]}"
