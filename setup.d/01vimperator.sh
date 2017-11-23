set -eu

if [[ ! -d ~/.local/share/vimperator/plugins ]]; then
	git clone https://github.com/vimpr/vimperator-plugins ~/.local/share/vimperator/plugins
fi
