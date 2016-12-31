#!/bin/bash

set -eu

export CONFIG_BASE="$(realpath "$(dirname "$0")")"

for f in "${CONFIG_BASE}"/setup.d/*.sh; do
	[[ -r "${f}" ]] && bash "${f}"
done

[[ "$(uname)" == "Darwin" ]] && "${CONFIG_BASE}/mac/setup.sh"

exec "${SHELL}" -l
