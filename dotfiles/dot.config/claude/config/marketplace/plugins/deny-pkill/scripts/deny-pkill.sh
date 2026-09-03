#!/usr/bin/env bash
set -u

cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null)
[[ -n ${cmd} ]] || exit 0

if [[ ${cmd} =~ (^|[^[:alnum:]_.-])(pkill|killall)([^[:alnum:]_.-]|$) ]]; then
  cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"pkill/killall are forbidden. Find the target PID with pgrep and kill only that PID."}}
JSON
fi
exit 0
