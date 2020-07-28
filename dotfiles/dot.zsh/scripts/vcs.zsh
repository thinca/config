autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '%s:[%b]' '%s'
zstyle ':vcs_info:*' actionformats '%s:[%b](%a)' '%s'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true


autoload -Uz is-at-least
if is-at-least 4.3.10; then
	zstyle ':vcs_info:git:*' check-for-changes true
	zstyle ':vcs_info:git:*' stagedstr "+"
	zstyle ':vcs_info:git:*' unstagedstr "-"
	zstyle ':vcs_info:git:*' formats '%s:[%b] %c%u'
fi


function update_vcs_info() {
	psvar=()
	LANG=C vcs_info 2>/dev/null
	[[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"

	if [[ -z "$vcs_info_msg_1_" ]]; then
		alias x='echo "Here is not working directory."'
	else
		alias x=$vcs_info_msg_1_
	fi
}
precmd_functions+=update_vcs_info

alias s=svn
alias g=git
