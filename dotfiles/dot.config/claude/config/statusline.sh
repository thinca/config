#!/usr/bin/env bash
set -u
# C.UTF-8: keep C's numeric/date formatting but make string ops (e.g. the window
# title truncation below) count characters, not bytes, so multibyte session names
# are not cut mid-character.
export LC_ALL=C.UTF-8

input=$(cat)

j() { jq -r "$1 // empty" <<<"$input"; }

model=$(j '.model.display_name')
effort=$(j '.effort.level')
sname=$(j '.session_name')
sid=$(j '.session_id')
cur_dir=$(j '.workspace.current_dir')
dir=${cur_dir##*/}
branch=$(git -C "${cur_dir:-.}" symbolic-ref --short -q HEAD 2>/dev/null || true)

# tmux window title. When more than one live session shares this directory, append
# the session name to tell them apart; when this is the only one, keep it short as
# `claude:<dir>`. Liveness is by PID ($PPID is the claude process), so crashed and
# detached sessions are handled correctly. session_name is only in the statusLine
# JSON (not hook inputs), so this must live here rather than in a plugin hook.
if [[ -n ${TMUX:-} && -n ${TMUX_PANE:-} ]]; then
  title="claude:${dir}"
  if [[ -n $cur_dir ]]; then
    st=${CLAUDE_CONFIG_DIR:-$HOME/.claude}/session-state
    # write our marker only when it changed (PID/cwd are stable), so a steady
    # session does no per-render disk writes. Reads below hit the page cache.
    sess_line="${PPID}"$'\t'"${cur_dir}"
    if [[ $(cat "${st}/${sid}.sess" 2>/dev/null) != "$sess_line" ]]; then
      mkdir -p "$st"
      printf '%s\n' "$sess_line" >"${st}/${sid}.sess"
    fi
    n=0
    for f in "$st"/*.sess; do
      [[ -e $f ]] || continue
      IFS=$'\t' read -r spid sdir <"$f" || true
      [[ -n $spid && -n $sdir ]] || continue
      [[ $sdir == "$cur_dir" ]] || continue
      kill -0 "$spid" 2>/dev/null && n=$((n + 1))
    done
    if ((n >= 2)); then
      wlabel=${sname:-${sid:0:6}}
      wlabel=${wlabel:0:28}
      title="claude:${dir}:${wlabel}"
    fi
  fi
  tmux rename-window -t "$TMUX_PANE" "$title" 2>/dev/null || true
fi

ctx=$(j '.context_window.used_percentage')
five=$(j '.rate_limits.five_hour.used_percentage')
five_reset=$(j '.rate_limits.five_hour.resets_at')
week=$(j '.rate_limits.seven_day.used_percentage')
week_reset=$(j '.rate_limits.seven_day.resets_at')
cost=$(j '.cost.total_cost_usd')

# Cross-session usage cache: an idle session's rate_limits only refresh on its own
# API responses, so they go stale while other sessions consume quota. rate_limits is
# statusLine-only (not available to hooks), so publish from here. Publish only when
# our reading CHANGED from the previous render (a change == a fresh API response), and
# never on the first render of a session (a resumed session's first value may be old).
# This handles both increases and Anthropic's mid-window resets to 0%, and keeps a
# stale idle value from overwriting a fresh one. Display the shared (freshest) value.
usage_state_dir=${CLAUDE_CONFIG_DIR:-$HOME/.claude}/session-state
usage_file=$usage_state_dir/usage.json
rl_file=$usage_state_dir/${sid}.rl
if [[ -n $five || -n $week ]]; then
  rl_now="${five}|${five_reset}|${week}|${week_reset}"
  if [[ -f $rl_file ]]; then
    if [[ $rl_now != "$(cat "$rl_file" 2>/dev/null)" ]]; then
      printf '%s' "$rl_now" >"$rl_file"
      printf '%s' "$rl_now" >"${usage_file}.tmp" 2>/dev/null && mv "${usage_file}.tmp" "$usage_file" 2>/dev/null || true
    fi
  else
    mkdir -p "$usage_state_dir"
    printf '%s' "$rl_now" >"$rl_file"
  fi
fi
shared_rl=$(cat "$usage_file" 2>/dev/null || true)
if [[ -n $shared_rl ]]; then
  IFS='|' read -r five five_reset week week_reset <<<"$shared_rl"
fi

fmt_reset() {
  local ts=$1
  if [[ $(date -d "@${ts}" +%Y%m%d) == "$(date +%Y%m%d)" ]]; then
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

state_dir=${CLAUDE_CONFIG_DIR:-$HOME/.claude}/session-state
state=$(cat "${state_dir}/${sid}.state" 2>/dev/null || true)
subs=$(grep -c . "${state_dir}/${sid}.subs" 2>/dev/null || true)
bg=$(cat "${state_dir}/${sid}.bg" 2>/dev/null || true)

subs_active=0
[[ -n $subs && $subs != 0 ]] && subs_active=1
bg_active=0
[[ -n $bg && $bg != 0 ]] && bg_active=1

if [[ $state == running || $subs_active == 1 || $bg_active == 1 ]]; then
  ind="${green}*${reset}"
else
  ind="${dim}-${reset}"
fi
# sub: live subagents (sync + workflow agents, via SubagentStart/Stop)
# bg:  background tasks running at last turn-end (workflows + background subagents)
((subs_active)) && ind+=" ${cyan}sub:${subs}${reset}"
((bg_active)) && ind+=" ${cyan}bg:${bg}${reset}"

out="${ind} ${model:-Claude}"
[[ -n $effort ]] && out+=" ${dim}${effort}${reset}"
[[ -n $sname ]] && out+="${sep}${cyan}${sname}${reset}"
[[ -n $dir ]] && out+="${sep}${dir}"
[[ -n $branch ]] && out+=" ${dim}(${branch})${reset}"
[[ -n $ctx ]] && out+="${sep}Ctx $(pct_color "$ctx")${ctx%%.*}%${reset}"
if [[ -n $five ]]; then
  r=''
  [[ -n $five_reset ]] && r=" ${dim}@$(fmt_reset "$five_reset")${reset}"
  out+="${sep}5h $(pct_color "$five")${five%%.*}%${reset}${r}"
fi
if [[ -n $week ]]; then
  r=''
  [[ -n $week_reset ]] && r=" ${dim}@$(fmt_reset "$week_reset")${reset}"
  out+="${sep}7d $(pct_color "$week")${week%%.*}%${reset}${r}"
fi
[[ -n $cost ]] && out+="${sep}\$$(printf '%.2f' "$cost")"

printf '%s\n' "$out"
