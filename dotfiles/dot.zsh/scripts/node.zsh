path=(./node_modules/.bin $path)
if [[ -d ~/.local/share/mise ]]; then
	manpath=($(mise where nodejs)/.npm/share/man(N-/) $manpath)
fi
