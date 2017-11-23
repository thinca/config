set -eu

link() {
	local src=$1
	local dest=$2
	if [[ -a "${src}" ]]; then
		[[ -L "${dest}" ]] && rm -f "${dest}"
		[[ ! -a "${dest}" ]] && ln -f -s -v "${src}" "${dest}"
	fi
}

mkdir -p "${HOME}"/.config

if [[ -d "${CONFIG_BASE}"/dotfiles/dot.config ]]; then
	for path in "${CONFIG_BASE}"/dotfiles/dot.config/*
	do
		filename="$(basename "${path}")"
		link "${path}" "${HOME}/.config/${filename}"
	done
fi
