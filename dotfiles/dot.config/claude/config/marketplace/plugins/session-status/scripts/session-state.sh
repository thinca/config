#!/usr/bin/env bash
set -u

input=$(cat)
event=$(jq -r '.hook_event_name // empty' <<<"${input}" 2>/dev/null)
sid=$(jq -r '.session_id // empty' <<<"${input}" 2>/dev/null)
[[ -n ${event} && -n ${sid} ]] || exit 0

dir=${CLAUDE_CONFIG_DIR:-${HOME}/.claude}/session-state
mkdir -p "${dir}"
state_file=${dir}/${sid}.state
subs_file=${dir}/${sid}.subs
bg_file=${dir}/${sid}.bg
start_file=${dir}/${sid}.start
rl_file=${dir}/${sid}.rl
acct_file=${dir}/${sid}.acct
# Transcript path, pane, and the cwd the session started in. <sid>.sess (written by
# statusline) only carries pid and cwd, which tells you WHICH session but not where to
# read its transcript from. That cwd is the CURRENT one and moves whenever the session
# cd's, so deriving the transcript path from it would miss; keep what the hook hands us.
where_file=${dir}/${sid}.where
# Whether the session is stopped waiting for input: the same condition that already
# sends ntfy and marks the tmux pane unread on Notification, exposed for outside readers.
# Kept out of <sid>.state because statusline only tests that against "running", so a new
# value there would change what it renders. Waiting is a third state, so it lives apart.
waiting_file=${dir}/${sid}.waiting

with_lock() {
  (
    flock -x 9
    "$@"
  ) 9>>"${subs_file}.lock"
}

# shellcheck disable=SC2329  # invoked through with_lock
add_sub() {
  grep -qxF "$1" "${subs_file}" 2>/dev/null || echo "$1" >>"${subs_file}"
}

# shellcheck disable=SC2329  # invoked through with_lock
remove_sub() {
  [[ -f ${subs_file} ]] || return 0
  grep -vxF "$1" "${subs_file}" >"${subs_file}.tmp" 2>/dev/null || true
  mv "${subs_file}.tmp" "${subs_file}"
}

agent_id=$(jq -r '.agent_id // empty' <<<"${input}" 2>/dev/null)

tmux_viewing() {
  [[ -n ${TMUX:-} && -n ${TMUX_PANE:-} ]] || return 2
  local v
  v=$(tmux display-message -p -t "${TMUX_PANE}" '#{pane_active},#{window_active},#{session_attached}' 2>/dev/null) || return 2
  local pa wa sa
  IFS=, read -r pa wa sa <<<"${v}"
  [[ ${pa} == 1 && ${wa} == 1 && ${sa:-0} != 0 ]]
}

tmux_mark_unread() {
  [[ -n ${TMUX:-} && -n ${TMUX_PANE:-} ]] || return 0
  tmux set-option -w -t "${TMUX_PANE}" @notified 1 2>/dev/null || true
}

tmux_clear_unread() {
  [[ -n ${TMUX:-} && -n ${TMUX_PANE:-} ]] || return 0
  tmux set-option -uw -t "${TMUX_PANE}" @notified 2>/dev/null || true
}

fmt_dur() {
  local s=$1
  if ((s >= 60)); then
    printf '%dm%02ds' $((s / 60)) $((s % 60))
  else
    printf '%ds' "${s}"
  fi
}

ntfy_send() {
  [[ -z ${CLAUDE_NO_NOTIFY:-} && -n ${NTFY_URL:-} && -n ${NTFY_TOPIC:-} ]] || return 0
  local title=$1 prio=$2 tags=$3 body=$4
  local -a auth=()
  [[ -n ${NTFY_TOKEN:-} ]] && auth=(-H "Authorization: Bearer ${NTFY_TOKEN}")
  curl -sS -m 8 \
    -H "Title: ${title}" -H "Priority: ${prio}" -H "Tags: ${tags}" \
    "${auth[@]}" \
    -d "${body}" \
    "${NTFY_URL%/}/${NTFY_TOPIC}" >/dev/null 2>&1 || true
}

session_label() {
  local cwd host
  cwd=$(jq -r '.cwd // empty' <<<"${input}" 2>/dev/null)
  host=$(uname -n 2>/dev/null || echo "?")
  printf '%s · %s' "${host}" "${cwd##*/}"
}

case ${event} in
  SessionStart)
    find "${dir}" -maxdepth 1 -type f -mtime +30 -delete 2>/dev/null || true
    # Pin the account this session runs as. statusLine shares rate limits between
    # sessions through a per-account file, but .claude.json only ever holds the LAST
    # /login, so a session still running under the previous account would publish its
    # numbers under the new account's name. This fires on resume too, so it re-pins.
    jq -r '.oauthAccount.accountUuid // empty' \
      "${CLAUDE_CONFIG_DIR:-${HOME}}/.claude.json" >"${acct_file}" 2>/dev/null || true
    transcript=$(jq -r '.transcript_path // empty' <<<"${input}" 2>/dev/null)
    if [[ -n ${transcript} ]]; then
      started_in=$(jq -r '.cwd // empty' <<<"${input}" 2>/dev/null)
      printf '%s\t%s\t%s\n' "${transcript}" "${TMUX_PANE:-}" "${started_in}" >"${where_file}"
    fi
    ;;
  UserPromptSubmit)
    echo running >"${state_file}"
    with_lock : >/dev/null
    : >"${subs_file}"
    echo 0 >"${bg_file}"
    date +%s >"${start_file}"
    rm -f "${waiting_file}"
    tmux_clear_unread
    ;;
  Stop | StopFailure)
    echo idle >"${state_file}"
    # Whatever it was waiting on is resolved; the turn is back to the user, not a wait.
    rm -f "${waiting_file}"
    # Background subagents (Agent run_in_background) do NOT fire SubagentStart/Stop,
    # so they never reach $subs_file. They do appear in background_tasks (like
    # workflows), which is only present on this turn-end snapshot. Count both types.
    running_bg=$(jq '[.background_tasks[]? | select(.status == "running" and (.type == "workflow" or .type == "subagent"))] | length' <<<"${input}" 2>/dev/null)
    [[ ${running_bg} =~ ^[0-9]+$ ]] || running_bg=0
    echo "${running_bg}" >"${bg_file}"
    tmux_viewing || tmux_mark_unread
    start=$(cat "${start_file}" 2>/dev/null || true)
    if [[ ${start} =~ ^[0-9]+$ ]]; then
      elapsed=$(($(date +%s) - start))
      threshold=${NTFY_THRESHOLD:-300}
      if ((elapsed >= threshold)); then
        dur=$(fmt_dur "${elapsed}")
        label=$(session_label)
        ntfy_send "Claude done (${dur})" 3 white_check_mark "${label}"
      fi
    fi
    ;;
  Notification)
    matcher=$(jq -r '.matcher // .notification_type // empty' <<<"${input}" 2>/dev/null)
    if [[ -z ${matcher} || ${matcher} == permission_prompt ]]; then
      label=$(session_label)
      ntfy_send "Claude needs input" 4 warning "${label}"
      date +%s >"${waiting_file}"
      tmux_viewing || tmux_mark_unread
    fi
    ;;
  SubagentStart)
    [[ -n ${agent_id} ]] && with_lock add_sub "${agent_id}"
    ;;
  SubagentStop)
    [[ -n ${agent_id} ]] && with_lock remove_sub "${agent_id}"
    ;;
  SessionEnd)
    rm -f "${state_file}" "${subs_file}" "${subs_file}.lock" "${bg_file}" "${start_file}" "${rl_file}" \
      "${acct_file}" "${where_file}" "${waiting_file}"
    ;;
  *) ;;
esac
exit 0
