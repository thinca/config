#!/usr/bin/env bash
set -u

usage() {
  cat >&2 <<'USAGE'
usage: create-branch.sh <new-branch> [<base>]

Creates a new git branch and records the base in branch.<name>.base.

Naming rules:
  - No "/"
  - No user/owner name (e.g. thinca-, feature/thinca/)
  - If related to an Issue, prefix with "issue<number>-"
USAGE
  exit 2
}

new=${1:-}
base_arg=${2:-}

[[ -n ${new} ]] || usage

case ${new} in
  */*)
    printf 'error: branch name must not contain "/": %s\n' "${new}" >&2
    exit 1
    ;;
esac

# ユーザー名混在を禁止 (config user.name と github username)
user_name=$(git config --get user.name || true)
user_email=$(git config --get user.email || true)
gh_user=${user_email%%@*}

owner_candidates=()
[[ -n ${user_name} ]] && owner_candidates+=("${user_name}")
[[ -n ${gh_user} && ${gh_user} != "${user_name}" ]] && owner_candidates+=("${gh_user}")

lower_new=$(printf '%s' "${new}" | tr '[:upper:]' '[:lower:]')
for cand in "${owner_candidates[@]}"; do
  [[ -n ${cand} ]] || continue
  lower_cand=$(printf '%s' "${cand}" | tr '[:upper:]' '[:lower:]')
  case ${lower_new} in
    "${lower_cand}"-* | *-"${lower_cand}"-* | *-"${lower_cand}")
      printf 'error: branch name must not contain the user name %q: %s\n' "${cand}" "${new}" >&2
      exit 1
      ;;
  esac
done

existing=$(git show-ref --verify --quiet "refs/heads/${new}"; echo $?)
if (( existing == 0 )); then
  printf 'error: branch already exists: %s\n' "${new}" >&2
  exit 1
fi

default_base=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)

if [[ -n ${base_arg} ]]; then
  if ! git rev-parse --verify --quiet "${base_arg}^{commit}" >/dev/null 2>&1; then
    printf 'error: base ref does not exist: %s\n' "${base_arg}" >&2
    exit 1
  fi
  base=${base_arg}
else
  base=${default_base}
fi

case ${base} in
  issue[0-9]*-*) ;;
  '' | *' '*) base=${default_base} ;;
esac

[[ -n ${base} && ${base} != "${new}" ]] || {
  printf 'error: could not determine base branch for %s\n' "${new}" >&2
  exit 1
}

git switch -c "${new}" "${base}" || exit 1
git config "branch.${new}.base" "${base}"
printf '%s (base: %s)\n' "${new}" "${base}"
