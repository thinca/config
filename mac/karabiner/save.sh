#!/bin/bash

set -eu

basedir="$(realpath "$(dirname "$0")")"

/Applications/Karabiner.app/Contents/Library/bin/karabiner export > "${basedir}/import.sh"
