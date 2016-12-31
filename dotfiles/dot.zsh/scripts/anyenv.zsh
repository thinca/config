path=(~/.anyenv/bin(N-/) $path)

if which anyenv &>/dev/null; then
	eval "$(anyenv init -)"
fi

export PYTHON_CONFIGURE_OPTS="--enable-shared"
