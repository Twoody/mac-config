#!/usr/bin/env bash
# PreToolUse(Bash) guard for the "Local test safety" policy in CLAUDE.md.
# Blocks vitest invocations that bypass the bounded test:ai script, since
# unbounded vitest runs were hanging and crashing the machine.

input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"

[ -z "$cmd" ] && exit 0
[[ "$cmd" == *"test:ai"* ]] && exit 0

reason=""
while IFS= read -r seg; do
  seg="$(printf '%s' "$seg" | sed -E 's/^[[:space:]]+//')"
  read -ra tok <<< "$seg"
  [ "${#tok[@]}" -eq 0 ] && continue

  case "${tok[0]:-}" in
    vitest)
      reason="Direct 'vitest' invocation is blocked (it can spawn unbounded worker processes and hang/crash the machine). Use 'npm run test:ai -w <package>' or 'npm run test:ai --workspaces --if-present' instead."
      ;;
    npx)
      if [[ "${tok[1]:-}" == "vitest" ]]; then
        reason="Direct 'npx vitest' invocation is blocked. Use 'npm run test:ai -w <package>' instead."
      fi
      ;;
    npm)
      if [[ "${tok[1]:-}" == "test" ]]; then
        reason="'npm test' is blocked by project policy. Use 'npm run test:ai -w <package>' or 'npm run test:ai --workspaces --if-present' instead."
      elif [[ "${tok[1]:-}" == "run" && ( "${tok[2]:-}" == "test" || "${tok[2]:-}" == "test:watch" ) ]]; then
        reason="'npm run ${tok[2]}' is blocked by project policy. Use 'npm run test:ai -w <package>' or 'npm run test:ai --workspaces --if-present' instead."
      fi
      ;;
    turbo)
      if [[ "${tok[1]:-}" == "test" || ( "${tok[1]:-}" == "run" && "${tok[2]:-}" == "test" ) ]] && [[ "$cmd" != *"--concurrency"* ]]; then
        reason="'turbo run test' without --concurrency can fan out vitest across every workspace in parallel and is blocked. Use 'npm run test:ai --workspaces --if-present' instead."
      fi
      ;;
  esac

  [ -n "$reason" ] && break
done < <(printf '%s\n' "$cmd" | sed -E 's/(&&|\|\||;|\|)/\n/g')

if [ -n "$reason" ]; then
  jq -n --arg reason "$reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
fi
exit 0
