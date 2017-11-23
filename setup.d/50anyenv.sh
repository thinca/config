__install_anyenv() {
	git clone https://github.com/riywo/anyenv ~/.anyenv
	mkdir -p ~/.anyenv/plugins
	git clone https://github.com/znz/anyenv-git.git ~/.anyenv/plugins/anyenv-git
	git clone https://github.com/znz/anyenv-update.git ~/.anyenv/plugins/anyenv-update
}

__install_envs() {
	for env in rbenv pyenv plenv
	do
		~/.anyenv/bin/anyenv install ${env}
	done
}

__install_rbenv_plugins() {
	local rbenv_root="$(rbenv root)"
	git clone https://github.com/ianheggie/rbenv-binstubs.git "${rbenv_root}/plugins/rbenv-binstubs"
	git clone https://github.com/rbenv/rbenv-default-gems.git "${rbenv_root}/plugins/rbenv-default-gems"
	ln -f -s -v "${CONFIG_BASE}/rbenv/default-gems" "${rbenv_root}/default-gems"
}

if which git >/dev/null; then
	if [[ ! -d ~/.anyenv ]]; then
		__install_anyenv
		__install_envs
		__install_rbenv_plugins
	fi
fi
