set -eu

link() {
	local src=$1
	local dest=$2
	if [[ -a "${src}" ]]; then
		[[ -L "${dest}" ]] && rm -f "${dest}"
		[[ ! -a "${dest}" ]] && ln -f -s -v "${src}" "${dest}"
	fi
}

case "${OS}" in
	Mac) CONFIG_DIR="${HOME}"/Library/Preferences ;;
	Linux) CONFIG_DIR="${HOME}"/.config ;;
esac
mkdir -p "${CONFIG_DIR}"

if [[ -d "${CONFIG_BASE}"/dotfiles/dot.config ]]; then
	for path in "${CONFIG_BASE}"/dotfiles/dot.config/*
	do
		filename="$(basename "${path}")"
		link "${path}" "${CONFIG_DIR}/${filename}"
	done
fi
