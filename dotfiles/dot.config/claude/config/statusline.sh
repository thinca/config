#!/usr/bin/env bash
set -u
# C.UTF-8: keep C's numeric/date formatting but make string ops (e.g. the window
# title truncation below) count characters, not bytes, so multibyte session names
# are not cut mid-character.
export LC_ALL=C.UTF-8

input=$(cat)

j() { jq -r "$1 // empty" <<<"${input}"; }

model=$(j '.model.display_name')
effort=$(j '.effort.level')
sname=$(j '.session_name')
sid=$(j '.session_id')
cur_dir=$(j '.workspace.current_dir')
dir=${cur_dir##*/}
branch=$(git -C "${cur_dir:-.}" symbolic-ref --short -q HEAD 2>/dev/null || true)

state_dir=${CLAUDE_CONFIG_DIR:-${HOME}/.claude}/session-state

# tmux window title. When more than one live session shares this directory, append
# the session name to tell them apart; when this is the only one, keep it short as
# `claude:<dir>`. Liveness is by PID ($PPID is the claude process), so crashed and
# detached sessions are handled correctly. session_name is only in the statusLine
# JSON (not hook inputs), so this must live here rather than in a plugin hook.
if [[ -n ${TMUX:-} && -n ${TMUX_PANE:-} ]]; then
  title="claude:${dir}"
  if [[ -n ${cur_dir} ]]; then
    # write our marker only when it changed (PID/cwd are stable), so a steady
    # session does no per-render disk writes. Reads below hit the page cache.
    sess_line="${PPID}"$'\t'"${cur_dir}"
    prev_sess=$(cat "${state_dir}/${sid}.sess" 2>/dev/null || true)
    if [[ ${prev_sess} != "${sess_line}" ]]; then
      mkdir -p "${state_dir}"
      printf '%s\n' "${sess_line}" >"${state_dir}/${sid}.sess"
    fi
    n=0
    for f in "${state_dir}"/*.sess; do
      [[ -e ${f} ]] || continue
      IFS=$'\t' read -r spid sdir <"${f}" || true
      [[ -n ${spid} && -n ${sdir} ]] || continue
      [[ ${sdir} == "${cur_dir}" ]] || continue
      kill -0 "${spid}" 2>/dev/null && n=$((n + 1))
    done
    if ((n >= 2)); then
      wlabel=${sname:-${sid:0:6}}
      wlabel=${wlabel:0:28}
      title="claude:${dir}:${wlabel}"
    fi
  fi
  tmux rename-window -t "${TMUX_PANE}" "${title}" 2>/dev/null || true
fi

ctx=$(j '.context_window.used_percentage')
five=$(j '.rate_limits.five_hour.used_percentage')
five_reset=$(j '.rate_limits.five_hour.resets_at')
week=$(j '.rate_limits.seven_day.used_percentage')
week_reset=$(j '.rate_limits.seven_day.resets_at')

# Cross-session usage cache: an idle session's rate_limits only refresh on its own
# API responses, so they go stale while other sessions consume quota. rate_limits is
# statusLine-only (not available to hooks), so publish from here. Publish only when
# our reading CHANGED from the previous render (a change == a fresh API response), and
# never on the first render of a session (a resumed session's first value may be old).
# This handles both increases and Anthropic's mid-window resets to 0%, and keeps a
# stale idle value from overwriting a fresh one. Display the shared (freshest) value.
# Scope the shared file per account: one config dir is reused across accounts (switched
# via /login) and their billing differs, so an unscoped file shows one account's limits
# under another. Prefer the uuid the SessionStart hook pinned for us; .claude.json holds
# only the last /login, which is not necessarily the account this session runs as.
acct=$(cat "${state_dir}/${sid}.acct" 2>/dev/null || true)
[[ -n ${acct} ]] || acct=$(jq -r '.oauthAccount.accountUuid // empty' "${CLAUDE_CONFIG_DIR:-${HOME}}/.claude.json" 2>/dev/null || true)
usage_file=${state_dir}/usage${acct:+-${acct}}.json
rl_file=${state_dir}/${sid}.rl
if [[ -n ${five} || -n ${week} ]]; then
  rl_now="${five}|${five_reset}|${week}|${week_reset}"
  if [[ -f ${rl_file} ]]; then
    rl_prev=$(cat "${rl_file}" 2>/dev/null || true)
    if [[ ${rl_now} != "${rl_prev}" ]]; then
      printf '%s' "${rl_now}" >"${rl_file}"
      printf '%s' "${rl_now}" >"${usage_file}.tmp" 2>/dev/null && mv "${usage_file}.tmp" "${usage_file}" 2>/dev/null || true
    fi
  else
    mkdir -p "${state_dir}"
    printf '%s' "${rl_now}" >"${rl_file}"
  fi
fi
# Trust the shared value only once this session has had a reading of its own: a plan
# that reports no rate_limits at all (team seats) must not show another account's
# numbers, and $rl_file is the record that we ever received any.
if [[ -f ${rl_file} ]]; then
  shared_rl=$(cat "${usage_file}" 2>/dev/null || true)
  if [[ -n ${shared_rl} ]]; then
    IFS='|' read -r five five_reset week week_reset <<<"${shared_rl}"
  fi
fi

# A cached percentage is only meaningful until its window rolls over, and resets_at says
# when that is — so it expires itself without an arbitrary TTL.
now=$(date +%s)
if [[ ${five_reset} =~ ^[0-9]+$ ]] && ((five_reset <= now)); then five='' five_reset=''; fi
if [[ ${week_reset} =~ ^[0-9]+$ ]] && ((week_reset <= now)); then week='' week_reset=''; fi

fmt_reset() {
  local ts=$1 day today
  day=$(date -d "@${ts}" +%Y%m%d 2>/dev/null || true)
  today=$(date +%Y%m%d)
  if [[ ${day} == "${today}" ]]; then
    date -d "@${ts}" +%H:%M
  else
    date -d "@${ts}" '+%m/%d %H:%M'
  fi
}

pct_color() {
  local p=${1%%.*}
  if ((p >= 80)); then
    printf '\033[31m'
  elif ((p >= 50)); then
    printf '\033[33m'
  else
    printf '\033[32m'
  fi
}

dim=$'\033[2m'
reset=$'\033[0m'
green=$'\033[32m'
cyan=$'\033[36m'
sep=" ${dim}|${reset} "

state=$(cat "${state_dir}/${sid}.state" 2>/dev/null || true)
subs=$(grep -c . "${state_dir}/${sid}.subs" 2>/dev/null || true)
bg=$(cat "${state_dir}/${sid}.bg" 2>/dev/null || true)

subs_active=0
[[ -n ${subs} && ${subs} != 0 ]] && subs_active=1
bg_active=0
[[ -n ${bg} && ${bg} != 0 ]] && bg_active=1

if [[ ${state} == running || ${subs_active} == 1 || ${bg_active} == 1 ]]; then
  ind="${green}*${reset}"
else
  ind="${dim}-${reset}"
fi
# sub: live subagents (sync + workflow agents, via SubagentStart/Stop)
# bg:  background tasks running at last turn-end (workflows + background subagents)
((subs_active)) && ind+=" ${cyan}sub:${subs}${reset}"
((bg_active)) && ind+=" ${cyan}bg:${bg}${reset}"

out="${ind} ${model:-Claude}"
[[ -n ${effort} ]] && out+=" ${dim}${effort}${reset}"
[[ -n ${sname} ]] && out+="${sep}${cyan}${sname}${reset}"
[[ -n ${dir} ]] && out+="${sep}${dir}"
[[ -n ${branch} ]] && out+=" ${dim}(${branch})${reset}"
[[ -n ${ctx} ]] && out+="${sep}Ctx $(pct_color "${ctx}")${ctx%%.*}%${reset}"
render_win() { # label pct reset_ts
  [[ -n $2 ]] || return 0
  local r=''
  [[ -n $3 ]] && r=" ${dim}@$(fmt_reset "$3")${reset}"
  out+="${sep}$1 $(pct_color "$2")${2%%.*}%${reset}${r}"
}
render_win 5h "${five}" "${five_reset}"
render_win 7d "${week}" "${week_reset}"

printf '%s\n' "${out}"
