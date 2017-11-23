link() {
	local src=$1
	local dest=$2
	if [[ -a "${src}" ]]; then
		[[ -L "${dest}" ]] && rm -f "${dest}"
		[[ ! -a "${dest}" ]] && ln -f -s -v "${src}" "${dest}"
	fi
}

pushd "${HOME}"

for path in "${CONFIG_BASE}"/dotfiles/dot.*
do
	filename="$(basename "${path}")"
	link "${path}" ~/"${filename#dot}"
done

link "${CONFIG_BASE}/firefox/dot.vimperatorrc" ~/.vimperatorrc
link "${CONFIG_BASE}/firefox/vimperator" ~/.vimperator

mkdir -p ~/share
link "${CONFIG_BASE}/bin" ~/share/bin

popd
