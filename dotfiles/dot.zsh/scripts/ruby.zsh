unset RUBYOPT

path=(./.bundle/bin $path)

alias -s rb=ruby
alias bi='bundle install'

function __chpwd_on_gemfile_local() {
	if [[ -f "Gemfile.private" ]]; then
		export BUNDLE_GEMFILE="./Gemfile.private"
	else
		unset BUNDLE_GEMFILE
	fi
}
add-zsh-hook chpwd __chpwd_on_gemfile_local

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
add-zsh-hook precmd __precmd_update_gemfile_local_lock
