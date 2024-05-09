if [[ ! -f ~/.local/bin/mise ]]; then
	curl https://mise.run | sh
	mkdir -p ~/.zsh/functions/Completion
	mise completion zsh > ~/.zsh/functions/Completion/_mise
fi
eval "$(~/.local/bin/mise activate zsh)"

export RUBY_CONFIGURE_OPTS="--enable-shared"
export PYTHON_CONFIGURE_OPTS="--enable-shared"
# Need patch to asdf-perl
export PERL_CONFIGURE_OPTS="-Duseshrplib"
export ASDF_RACKET_CONFIG_FLAGS="--enable-bcdefault --disable-futures --disable-places --disable-gracket --disable-docs"
if [[ "${SYSTEM_NAME}" != "mac" ]]; then
	ASDF_RACKET_CONFIG_FLAGS="--enable-dynlib ${ASDF_RACKET_CONFIG_FLAGS}"
fi
export NODEJS_CHECK_SIGNATURES="no"
