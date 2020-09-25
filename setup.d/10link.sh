link() {
	local src=$1
	local dest=$2
	if [[ -a "${src}" ]]; then
		[[ -L "${dest}" ]] && rm -f "${dest}"
		[[ ! -a "${dest}" ]] && ln -f -s -v "${src}" "${dest}"
	fi
}

pushd "${HOME}"

relative_base=${CONFIG_BASE#${HOME}/}

for path in "${relative_base}"/dotfiles/dot.*
do
	filename="$(basename "${path}")"
	link "${path}" ~/"${filename#dot}"
done

mkdir -p ~/share
link "${relative_base}/bin" ~/share/bin

popd
