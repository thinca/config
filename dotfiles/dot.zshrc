###########################################################################
# The system detection.
[ -f ~/.zsh/system ] && source ~/.zsh/system

###########################################################################
# Preload.
[ -f ~/.zsh/tmux ] && source ~/.zsh/tmux

# Disable ^Q and ^S.
stty -ixon

fpath=(~/.zsh/functions/Completion(N-/) $fpath)
autoload -U compinit
compinit

autoload -U colors
colors

autoload -U url-quote-magic

zle -N self-insert url-quote-magic

# Historical backward/forward search with linehead string.
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

autoload zmv
alias zmv='noglob zmv -W'

# Use zed - a text editor written by zsh.
autoload zed


###########################################################################
# Environment variables.
if [[ "${TERM}" == "linux" ]]; then
	export LANG=en_US.UTF-8
else
	export LANG=ja_JP.UTF-8
fi
if [[ -n "${FORCE_LANG}" ]]; then
	export LANG="${FORCE_LANG}"
fi

if [[ -d ~/share/Dropbox ]]; then
	export DROPBOX_HOME=~/share/Dropbox
	path=("${DROPBOX_HOME}"/bin(N-/) $path)
fi

path=(~/local/bin(N-/) ~/local/app/*(N-/) ~/local/app/*/bin(N-/) $path)

if [[ "${TERM}" == "rxvt-unicode" ]]; then
	TERM=xterm-256color
fi

# An option like "--quit-if-one-screen" of "less" is not exist in lv...
# export PAGER=lv
# export LV='-c'
export PAGER=less
export LESS='--no-init --LONG-PROMPT --ignore-case --silent --quit-if-one-screen --RAW-CONTROL-CHARS'

export EDITOR=vim


###########################################################################
# Options.

# allow tab completion in the middle of a word
setopt complete_in_word

## keep background processes at full speed
#setopt NOBGNICE
## restart running processes on exit
#setopt HUP

## history
#setopt APPEND_HISTORY
## for sharing history between zsh processes
#setopt INC_APPEND_HISTORY
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt share_history
setopt extended_history
setopt hist_no_store

## never ever beep ever
setopt no_beep

# Perform cd if command is directory.
setopt auto_cd
# Make cd push the old directory onto the directory stack.
setopt auto_pushd
# Do not push multiple copies of the same directory onto the directory stack.
setopt pushd_ignore_dups
# setopt correct
setopt list_packed
# Treat single word simple commands without redirection as candidates for
# resumption of an existing job.
setopt auto_resume
# disable flow control with Ctrl-S/Ctrl-Q
setopt no_flow_control

setopt multios

setopt extended_glob

# Enable {a-z}
setopt brace_ccl

## automatically decide when to page a list of completions
#LISTMAX=0

## disable mail checking
#MAILCHECK=0


###########################################################################
# Style settings.
export CLICOLOR=1
export LSCOLORS=gxfxxxxxcxxxxxxxxxgxgx
export LS_COLORS='di=01;36:ln=01;35:ex=01;32'
zstyle ':completion:*' list-colors 'di=36' 'ln=35' 'ex=32'
#zstyle ':completion:*' list-colors ''
#zstyle ':completion::complete:*' use-cache 1

zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}'
zstyle ':completion:*:(processes|jobs)' menu yes select=2

# auto-fu.zsh
# bindkey -N isearch
# { . ~/.zsh/auto-fu; auto-fu-install; }
# zstyle ':auto-fu:highlight' input white,bold
# zstyle ':auto-fu:highlight' completion fg=gray
# zstyle ':auto-fu:var' postdisplay ''
# zle-line-init () {auto-fu-init;}; zle -N zle-line-init


###########################################################################
# Prompt settings.

# Expand the environment variable in prompt.
setopt prompt_subst

# Normal prompt.
PROMPT="
%B%(#.${fg[yellow]}.${fg[green]})[%n@%m]%~ ${fg[magenta]}%1v%(?.. ${fg[red]}%?${reset_color})${reset_color}%b
%# "


###########################################################################
# aliases.
alias ls='ls -F   --color=auto'
alias ll='ls -Fl  --color=auto'
alias la='ls -FlA --color=auto'

alias tree='tree -F --dirsfirst'

# Usage: etime vim
alias etime='ps -o cmd,etime -C'

function docker-sweep-images() {
	local images="$(docker images --filter "dangling=true" --quiet --no-trunc)"
	if [[ -z "${images}" ]] || docker rmi  ${(f)images}
}
function docker-sweep-containers() {
	local created="$(docker ps --all --filter "status=created" --quiet --no-trunc)"
	[[ -z "${created}" ]] || docker rm -f ${(f)created}
	local exited="$(docker ps --all --filter "status=exited" --quiet --no-trunc)"
	[[ -z "${exited}" ]] || docker rm ${(f)exited}
}

# replace rm
if which trash-put &>/dev/null; then
	alias rm=trash-put
fi
alias del=/bin/rm

# global aliases.
alias -g L="| ${PAGER}"
alias -g G="| grep $1"
alias -g V="| vim -R -"

alias -g NL='>/dev/null'
alias -g NLL='&>/dev/null'


# Suffix aliases.
alias -s txt=cat
alias -s log='tail -F'

alias -s gz=zcat
alias -s bz2=bzcat

alias -s php=php
alias -s scm=gosh
alias -s lua=lua
alias -s io=io
alias -s sh=sh
alias -s bash=bash
alias -s zsh=zsh
alias -s exe=mono
alias -s jar='java -jar'

# A script language may be executed.
for ext in java c h cpp html xhtml xml yaml; do
	alias -s $ext='$EDITOR'
done


###########################################################################
# key bindings.
bindkey -v '^n' history-beginning-search-forward-end
bindkey -v '^p' history-beginning-search-backward-end
bindkey -v '^q' push-line
bindkey -a '/' history-incremental-search-backward
bindkey -a '?' history-incremental-search-forward
bindkey -a 'q' push-line
bindkey -a 'u' undo
bindkey -a '\C-r' redo


###########################################################################
# Functions for this file.

function __is_screen() {
	if [[ (-n "${WINDOW}" && -z "${DISPLAY}") || -n "${TMUX}" ]]; then
		return 0
	fi
	return 1
}

function __is_prefix_cmd() {
	local cmd="$1"
	[[ "${cmd}" == "rlwrap" ]] && return 0
	[[ "${cmd}" == *=* ]] && return 0
	return 1
}

function screen-name() {
	echo -ne "\ek$1\e\\"
}

###########################################################################
# hook functions.
typeset -ga preexec_functions
typeset -ga precmd_functions
typeset -ga chpwd_functions

# on GNU Screen or tmux
if __is_screen; then
	function __preexec_on_screen() {
		line="$3"
		args="${(z)line}"
		if [[ "${(t)args}" == "array" ]]; then
			while __is_prefix_cmd "${args[1]}"
			do
				shift args
			done
			cmd="${args[1]}"
		else
			cmd="${args}"
		fi
		shift args 2>/dev/null
		case "${cmd}" in
			man|ssh)
				screen-name "${cmd}:${args[*]}"
				;;
			*)
				screen-name "#${cmd}"
				;;
		esac
	}
	function __precmd_on_screen() {
		local d
		if [[ "${PWD}" == "${HOME}" ]]; then
			d='~'
		else
			d="${PWD:t}"
		fi
		screen-name "${d}/"
	}
	preexec_functions+=__preexec_on_screen
	precmd_functions+=__precmd_on_screen

	function tmux-session-refresh() {
		unset $(tmux show-env | sed -n 's/^-//p')
		eval export $(tmux show-env | sed -n 's/$/"/; s/=/="/p')
	}
fi

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

###########################################################################
# Load other scripts.

for f in ~/.zsh/scripts/*.zsh(N); do
	[[ -r "${f}" ]] && source "${f}"
done

[[ -r ~/.zsh/"${SYSTEM}".zsh ]] && source ~/.zsh/"${SYSTEM}".zsh
[[ -r ~/.zsh/local ]] && source ~/.zsh/local

typeset -U path  # Delete the duplicate entry.

# vim: ft=zsh
