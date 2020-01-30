if [[ -d ~/.asdf ]]; then
	source ~/.asdf/asdf.sh
	source ~/.asdf/completions/asdf.bash
fi
export RUBY_CONFIGURE_OPTS="--enable-shared"
export PYTHON_CONFIGURE_OPTS="--enable-shared"
# Need patch to asdf-perl
export PERL_CONFIGURE_OPTS="-Duseshrplib"
export ASDF_RACKET_CONFIG_FLAGS="--disable-futures --disable-places --disable-gracket --disable-docs"
