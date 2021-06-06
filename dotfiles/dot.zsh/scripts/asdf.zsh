if [[ ! -d ~/.asdf ]]; then
	return
fi
source ~/.asdf/asdf.sh
fpath=(${ASDF_DIR}/completions $fpath)
export RUBY_CONFIGURE_OPTS="--enable-shared"
export PYTHON_CONFIGURE_OPTS="--enable-shared"
# Need patch to asdf-perl
export PERL_CONFIGURE_OPTS="-Duseshrplib"
export ASDF_RACKET_CONFIG_FLAGS="--enable-bcdefault --disable-futures --disable-places --disable-gracket --disable-docs"
if [[ "${SYSTEM_NAME}" != "mac" ]]; then
	ASDF_RACKET_CONFIG_FLAGS="--enable-dynlib ${ASDF_RACKET_CONFIG_FLAGS}"
fi
export NODEJS_CHECK_SIGNATURES="no"

export ASDF_SKIP_RESHIM=1

asdf-update-global() {
	local plugin_name current_ver latest_ver
	for plugin_name in $(asdf plugin list); do
		if [[ ${plugin_name} == "perl" ]]; then
			continue
		fi
		latest_ver=$(asdf latest "${plugin_name}")
		if [[ -z ${latest_ver} || ${latest_ver} =~ RC ]]; then
			continue
		fi
		current_ver=$(asdf current "${plugin_name}" | sed -e 's/^\S\+\s*//' -e 's/ .*//')
		if [[ ${latest_ver} != ${current_ver} ]]; then
			echo "${plugin_name} ${current_ver} -> ${latest_ver}"
			asdf install "${plugin_name}" "${latest_ver}" && \
				asdf global "${plugin_name}" "${latest_ver}" $(asdf current "${plugin_name}" | sed -e 's/^\S\+\s*\S\+\s*//' -e 's/\s*\S\+$//') && \
				asdf uninstall "${plugin_name}" "${current_ver}"
		fi
	done
}

# FIXME: When there is no Java environment
export JAVA_HOME="$(asdf where java)"
