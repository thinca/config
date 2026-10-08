#!/usr/bin/env bash
set -u

cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null)
[[ -n ${cmd} ]] || exit 0

is_branch_create=0

if [[ ${cmd} =~ (^|[;&|[:space:]])git[[:space:]]+checkout([[:space:]]+[^;&|]*)?[[:space:]]-b([[:space:]]|$) ]] \
  || [[ ${cmd} =~ (^|[;&|[:space:]])git[[:space:]]+checkout([[:space:]]+[^;&|]*)?[[:space:]]-B([[:space:]]|$) ]]; then
  is_branch_create=1
elif [[ ${cmd} =~ (^|[;&|[:space:]])git[[:space:]]+switch([[:space:]]+[^;&|]*)?[[:space:]]-c([[:space:]]|$) ]] \
  || [[ ${cmd} =~ (^|[;&|[:space:]])git[[:space:]]+switch([[:space:]]+[^;&|]*)?[[:space:]]-C([[:space:]]|$) ]] \
  || [[ ${cmd} =~ (^|[;&|[:space:]])git[[:space:]]+switch([[:space:]]+[^;&|]*)?[[:space:]]--create([[:space:]]|$) ]]; then
  is_branch_create=1
elif [[ ${cmd} =~ (^|[;&|[:space:]])git[[:space:]]+branch[[:space:]]+([^[:space:];&|]+) ]]; then
  first=${BASH_REMATCH[2]}
  case ${first} in
    -* | '') ;;
    *) is_branch_create=1 ;;
  esac
fi

if (( is_branch_create )); then
  cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"git のブランチ作成コマンドは直接使用せず、git-branch-create プラグインの create-branch.sh を使ってください。命名ルールの強制と branch.<name>.base 記録が自動化されます。"}}
JSON
fi
exit 0
