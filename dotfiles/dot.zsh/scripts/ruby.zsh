unset RUBYOPT

alias -s rb=ruby
alias bi='bundle install --path vendor/bundle --binstubs .bundle/bin'

function __chpwd_on_gemfile_local() {
	if [[ -f "Gemfile.private" ]]; then
		export BUNDLE_GEMFILE="./Gemfile.private"
	else
		unset BUNDLE_GEMFILE
	fi
}
chpwd_functions+=__chpwd_on_gemfile_local

function __precmd_update_gemfile_local_lock() {
	if [[ \
			-d '.bundle' && \
			-n "${BUNDLE_GEMFILE}" && \
			-f "${BUNDLE_GEMFILE}" && \
			( ! -f "${BUNDLE_GEMFILE}.lock" || \
				( "Gemfile.lock" -nt "${BUNDLE_GEMFILE}.lock" ) ) ]]; then
		cp "Gemfile.lock" "${BUNDLE_GEMFILE}.lock"
		bundle install
	fi
}
precmd_functions+=__precmd_update_gemfile_local_lock
