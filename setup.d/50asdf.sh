if which git >/dev/null; then
	if [[ ! -d ~/.asdf ]]; then
		git clone https://github.com/asdf-vm/asdf.git ~/.asdf
		(
			cd ~/.asdf
			git -c advice.detachedHead=false checkout "$(git describe --abbrev=0 --tags)"
		)
		if [[ -f "${CONFIG_BASE}/setup.d/asdf-plugins.txt" ]]; then
			source ~/.zsh/scripts/asdf.zsh
			while read name url; do
				asdf plugin add "${name}" "${url}"
			done < "${CONFIG_BASE}/setup.d/asdf-plugins.txt"
			asdf install
		fi
	fi
fi
