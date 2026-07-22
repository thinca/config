#!/usr/bin/env bash
set -u

input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input" 2>/dev/null)
case $cmd in *git*) ;; *) exit 0 ;; esac

hook_cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)
[[ -n $hook_cwd && -d $hook_cwd ]] && cd "$hook_cwd"

git rev-parse --git-dir >/dev/null 2>&1 || exit 0

strip_quotes() {
  local s=$1
  s=${s%\'}; s=${s#\'}
  s=${s%\"}; s=${s#\"}
  printf '%s' "$s"
}

new='' base=''

parse_create_flag() {
  local rest=${1%%[;|&]*}
  local -a w=()
  read -ra w <<<"$rest" || true
  local i
  for ((i = 0; i < ${#w[@]}; i++)); do
    case ${w[i]} in
      --create=*)
        new=${w[i]#--create=}
        ;;
      -b | -B | -c | --create)
        new=${w[i + 1]:-}
        local next=${w[i + 2]:-}
        case $next in '' | -*) ;; *) base=$next ;; esac
        ;;
      *)
        continue
        ;;
    esac
    return
  done
}

if [[ $cmd == *checkout\ * ]]; then
  parse_create_flag "${cmd#*checkout }"
fi
if [[ -z $new && $cmd == *switch\ * ]]; then
  parse_create_flag "${cmd#*switch }"
fi
if [[ -z $new && $cmd =~ git[[:space:]]+branch[[:space:]]+([^;|\&]+) ]]; then
  read -ra w <<<"${BASH_REMATCH[1]}" || true
  if ((${#w[@]} >= 1)) && [[ ${w[0]} != -* ]]; then
    new=${w[0]}
    if ((${#w[@]} >= 2)) && [[ ${w[1]} != -* ]]; then
      base=${w[1]}
    else
      base=$(git symbolic-ref --short -q HEAD || true)
    fi
  fi
fi

new=$(strip_quotes "${new:-}")
base=$(strip_quotes "${base:-}")

[[ -n $new ]] || exit 0
git show-ref --verify --quiet "refs/heads/$new" || exit 0
git config "branch.${new}.base" >/dev/null 2>&1 && exit 0

# コマンドから取った明示的な base 候補が実在する ref でなければ破棄する。
# (リダイレクト等の混入で "2>" のようなゴミを掴むことがあるため)
if [[ -n $base ]] && ! git rev-parse --verify --quiet "${base}^{commit}" >/dev/null 2>&1; then
  base=''
fi

if [[ -z $base ]]; then
  base=$(git rev-parse --abbrev-ref '@{-1}' 2>/dev/null || true)
fi

if [[ $base == */* ]] && git remote | grep -qxF "${base%%/*}"; then
  base=${base#*/}
fi
[[ -n $base && $base != "$new" ]] || exit 0

git config "branch.${new}.base" "$base" || exit 0
printf '{"systemMessage": "base branch of %s set to %s"}\n' "$new" "$base"
