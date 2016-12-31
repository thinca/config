#!/bin/bash

set -eu

basedir="$(realpath "$(dirname "$0")")"

karabiner="/Applications/Karabiner.app/Contents/Library/bin/karabiner"
if [[ -x "${karabiner}" ]]; then
	echo "Karabiner: restore settings"
	bash "${basedir}/karabiner/import.sh"
	mkdir -p "${HOME}/Library/Application Support/Karabiner"
	rm -f "${HOME}/Library/Application Support/Karabiner/private.xml"
	ln -f -s -v "${basedir}/karabiner/private.xml" "${HOME}/Library/Application Support/Karabiner/private.xml"
fi
