set -eu

link() {
	local src=$1
	local dest=$2
	if [[ -a "${src}" ]]; then
		[[ -L "${dest}" ]] && rm -f "${dest}"
		[[ ! -a "${dest}" ]] && ln -f -s -v "${src}" "${dest}"
	fi
}

mk_links() {
	local config_dir=$1

	mkdir -p "${config_dir}"
	for path in "${CONFIG_BASE}"/dotfiles/dot.config/*
	do
		filename="$(basename "${path}")"
		link "${path}" "${config_dir}/${filename}"
	done
}

if [[ -d "${CONFIG_BASE}"/dotfiles/dot.config ]]; then
	case "${OS}" in
		Mac)
			mk_links "${HOME}"/Library/Preferences
			mk_links "${HOME}"/.config
			;;
		Linux)
			mk_links "${HOME}"/.config
			;;
	esac
fi
