#!/usr/bin/env bash
set -u

deny() {
  jq -cn --arg reason "$1" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
  exit 0
}

ancestor_pids() {
  local pid=${PPID}
  while [[ ${pid} =~ ^[0-9]+$ ]] && ((pid > 1)); do
    echo "${pid}"
    pid=$(ps -o ppid= -p "${pid}" 2>/dev/null | tr -d '[:space:]')
  done
  echo 1
}

check_kill_args() {
  local -a args
  read -ra args <<<"$1"
  local i=0
  case ${args[0]-} in
    -l | -L) return ;;
    -s | -n) i=2 ;;
    --) ;;
    -*) i=1 ;;
  esac
  local -a pids=()
  local arg
  for arg in "${args[@]:i}"; do
    [[ ${arg} =~ ^[0-9]*[\<\>] ]] && break
    [[ ${arg} == -- ]] && continue
    [[ ${arg} =~ ^%[0-9]*$ ]] && continue
    [[ ${arg} =~ ^[1-9][0-9]*$ ]] || deny "kill only accepts literal positive PIDs (got '${arg}'). Variables, command substitutions, process groups and 'xargs kill' can match unintended processes such as Claude Code itself. Look up the PIDs first (e.g. 'pgrep -af'), confirm each one is the intended target, then run kill with those numbers."
    pids+=("${arg}")
  done
  ((${#pids[@]})) || return
  local ancestors pid
  ancestors=$(ancestor_pids)
  for pid in "${pids[@]}"; do
    if grep -qx "${pid}" <<<"${ancestors}"; then
      deny "PID ${pid} is an ancestor of this hook (Claude Code itself or a process hosting it). Killing it would end this session."
    fi
  done
}

cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null)
[[ -n ${cmd} ]] || exit 0

if [[ ${cmd} =~ (^|[^[:alnum:]_.-])(pkill|killall)([^[:alnum:]_.-]|$) ]]; then
  deny "pkill/killall are forbidden. Find the target PID with pgrep and kill only that PID."
fi

if [[ ${cmd} =~ xargs[^\;\&\|]*[[:space:]]kill([[:space:]]|$) ]]; then
  deny "'xargs kill' is forbidden because it kills PIDs that were not reviewed. Look up the PIDs first, confirm them, then run kill with those numbers."
fi

# shellcheck disable=SC2016
kill_re='(^|[;&|(`{]|\$\(|[[:space:]](do|then|else|sudo|command|builtin|exec|env))[[:space:]]*kill([[:space:]]+([^;&|)`}'$'\n'']*))?([;&|)`}'$'\n'']|$)'
rest=${cmd}
while [[ ${rest} =~ ${kill_re} ]]; do
  check_kill_args "${BASH_REMATCH[4]}"
  rest=${rest#*"${BASH_REMATCH[0]}"}
done
exit 0
