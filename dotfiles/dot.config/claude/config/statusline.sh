#!/usr/bin/env bash
set -u
export LC_ALL=C

input=$(cat)

j() { jq -r "$1 // empty" <<<"$input"; }

model=$(j '.model.display_name')
effort=$(j '.effort.level')
sname=$(j '.session_name')
sid=$(j '.session_id')
cur_dir=$(j '.workspace.current_dir')
dir=${cur_dir##*/}
branch=$(git -C "${cur_dir:-.}" symbolic-ref --short -q HEAD 2>/dev/null || true)

ctx=$(j '.context_window.used_percentage')
five=$(j '.rate_limits.five_hour.used_percentage')
five_reset=$(j '.rate_limits.five_hour.resets_at')
week=$(j '.rate_limits.seven_day.used_percentage')
week_reset=$(j '.rate_limits.seven_day.resets_at')
cost=$(j '.cost.total_cost_usd')

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
wf=$(cat "${state_dir}/${sid}.bg" 2>/dev/null || true)

subs_active=0
[[ -n $subs && $subs != 0 ]] && subs_active=1
wf_active=0
[[ -n $wf && $wf != 0 ]] && wf_active=1

if [[ $state == running || $subs_active == 1 || $wf_active == 1 ]]; then
  ind="${green}*${reset}"
else
  ind="${dim}-${reset}"
fi
((subs_active)) && ind+=" ${cyan}sub:${subs}${reset}"
((wf_active)) && ind+=" ${cyan}wf:${wf}${reset}"

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
