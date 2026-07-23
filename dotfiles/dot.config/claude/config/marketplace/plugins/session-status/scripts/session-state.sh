#!/usr/bin/env bash
set -u

input=$(cat)
event=$(jq -r '.hook_event_name // empty' <<<"$input" 2>/dev/null)
sid=$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null)
[[ -n $event && -n $sid ]] || exit 0

dir=${CLAUDE_CONFIG_DIR:-$HOME/.claude}/session-state
mkdir -p "$dir"
state_file=$dir/$sid.state
subs_file=$dir/$sid.subs
bg_file=$dir/$sid.bg
start_file=$dir/$sid.start

with_lock() {
  (
    flock -x 9
    "$@"
  ) 9>>"$subs_file.lock"
}

add_sub() {
  grep -qxF "$1" "$subs_file" 2>/dev/null || echo "$1" >>"$subs_file"
}

remove_sub() {
  [[ -f $subs_file ]] || return 0
  grep -vxF "$1" "$subs_file" >"$subs_file.tmp" 2>/dev/null || true
  mv "$subs_file.tmp" "$subs_file"
}

agent_id=$(jq -r '.agent_id // empty' <<<"$input" 2>/dev/null)

tmux_viewing() {
  [[ -n ${TMUX:-} && -n ${TMUX_PANE:-} ]] || return 2
  local v
  v=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_active},#{window_active},#{session_attached}' 2>/dev/null) || return 2
  local pa wa sa
  IFS=, read -r pa wa sa <<<"$v"
  [[ $pa == 1 && $wa == 1 && ${sa:-0} != 0 ]]
}

tmux_mark_unread() {
  [[ -n ${TMUX:-} && -n ${TMUX_PANE:-} ]] || return 0
  tmux set-option -w -t "$TMUX_PANE" @notified 1 2>/dev/null || true
}

tmux_clear_unread() {
  [[ -n ${TMUX:-} && -n ${TMUX_PANE:-} ]] || return 0
  tmux set-option -uw -t "$TMUX_PANE" @notified 2>/dev/null || true
}

tmux_set_title() {
  [[ -n ${TMUX:-} && -n ${TMUX_PANE:-} ]] || return 0
  local cwd
  cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)
  [[ -n $cwd ]] || return 0
  tmux rename-window -t "$TMUX_PANE" "claude:${cwd##*/}" 2>/dev/null || true
}

fmt_dur() {
  local s=$1
  if ((s >= 60)); then
    printf '%dm%02ds' $((s / 60)) $((s % 60))
  else
    printf '%ds' "$s"
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
  cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)
  host=$(uname -n 2>/dev/null || echo "?")
  printf '%s · %s' "$host" "${cwd##*/}"
}

case $event in
  SessionStart)
    find "$dir" -maxdepth 1 -type f -mtime +30 -delete 2>/dev/null || true
    tmux_set_title
    ;;
  UserPromptSubmit)
    echo running >"$state_file"
    with_lock : >/dev/null
    : >"$subs_file"
    echo 0 >"$bg_file"
    date +%s >"$start_file"
    tmux_clear_unread
    tmux_set_title
    ;;
  Stop | StopFailure)
    echo idle >"$state_file"
    running_wf=$(jq '[.background_tasks[]? | select(.status == "running" and .type == "workflow")] | length' <<<"$input" 2>/dev/null)
    [[ $running_wf =~ ^[0-9]+$ ]] || running_wf=0
    echo "$running_wf" >"$bg_file"
    tmux_viewing || tmux_mark_unread
    start=$(cat "$start_file" 2>/dev/null || true)
    if [[ $start =~ ^[0-9]+$ ]]; then
      elapsed=$(($(date +%s) - start))
      threshold=${NTFY_THRESHOLD:-300}
      if ((elapsed >= threshold)); then
        ntfy_send "Claude done ($(fmt_dur "$elapsed"))" 3 white_check_mark "$(session_label)"
      fi
    fi
    ;;
  Notification)
    matcher=$(jq -r '.matcher // .notification_type // empty' <<<"$input" 2>/dev/null)
    if [[ -z $matcher || $matcher == permission_prompt ]]; then
      ntfy_send "Claude needs input" 4 warning "$(session_label)"
      tmux_viewing || tmux_mark_unread
    fi
    ;;
  SubagentStart)
    [[ -n $agent_id ]] && with_lock add_sub "$agent_id"
    ;;
  SubagentStop)
    [[ -n $agent_id ]] && with_lock remove_sub "$agent_id"
    ;;
  SessionEnd)
    rm -f "$state_file" "$subs_file" "$subs_file.lock" "$bg_file" "$start_file"
    ;;
esac
exit 0
