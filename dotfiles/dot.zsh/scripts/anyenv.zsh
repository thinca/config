path=(~/.anyenv/bin(N-/) $path)

if which anyenv &>/dev/null; then
	eval "$(anyenv init -)"
fi

export RUBY_CONFIGURE_OPTS="--enable-shared"
export PYTHON_CONFIGURE_OPTS="--enable-shared"
