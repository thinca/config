if [[ -d ~/.asdf ]]; then
	source ~/.asdf/asdf.sh
	fpath=(${ASDF_DIR}/completions $fpath)
fi
export RUBY_CONFIGURE_OPTS="--enable-shared"
export PYTHON_CONFIGURE_OPTS="--enable-shared"
# Need patch to asdf-perl
export PERL_CONFIGURE_OPTS="-Duseshrplib"
export ASDF_RACKET_CONFIG_FLAGS="--disable-futures --disable-places --disable-gracket --disable-docs"
if [[ "${SYSTEM_NAME}" != "mac" ]]; then
	ASDF_RACKET_CONFIG_FLAGS="--enable-dynlib ${ASDF_RACKET_CONFIG_FLAGS}"
fi
export NODEJS_CHECK_SIGNATURES="no"

export ASDF_SKIP_RESHIM=1
