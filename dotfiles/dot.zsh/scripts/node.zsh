path=(./node_modules/.bin $path)
if [[ -d "${ASDF_DIR}" ]]; then
	manpath=($(asdf where nodejs)/.npm/share/man(N-/) $manpath)
fi
