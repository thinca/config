###########################################################################
# The system detection.
[[ -f ~/.zsh/system ]] && source ~/.zsh/system

# Disable ^Q and ^S.
stty -ixon

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

path=(~/.local/bin(N-/) $path)

if [[ "${TERM}" == "rxvt-unicode" ]]; then
	TERM=xterm-256color
fi

# An option like "--quit-if-one-screen" of "less" is not exist in lv...
# export PAGER=lv
# export LV='-c'
export PAGER=less
export LESS='--no-init --LONG-PROMPT --ignore-case --silent --quit-if-one-screen --RAW-CONTROL-CHARS'

export EDITOR=vim

# GnuPG
export GPG_TTY=$(tty)


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

if [[ ! -f ~/.local/share/powerlevel10k/powerlevel10k.zsh-theme ]] && type git >/dev/null; then
	git clone git@github.com:romkatv/powerlevel10k ~/.local/share/powerlevel10k
fi
if [[ -f ~/.local/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
	[[ ! -f ~/.zsh/p10k.zsh ]] || source ~/.zsh/p10k.zsh
	source ~/.local/share/powerlevel10k/powerlevel10k.zsh-theme
fi


###########################################################################
# aliases.
if type exa >/dev/null; then
	alias ls='exa -F   --group-directories-first --git'
	alias ll='exa -Fl  --group-directories-first --git'
	alias la='exa -Fla --group-directories-first --git'
	alias tree='exa -F --group-directories-first --tree --git'
	alias treel='exa -Fl --group-directories-first --tree --git'
else
	alias ls='ls -F   --color=auto'
	alias ll='ls -Fl  --color=auto'
	alias la='ls -FlA --color=auto'
	alias tree='tree -F --dirsfirst'
fi

# Usage: etime vim
alias etime='ps -o cmd,etime -C'

# replace rm
if [[ -e /etc/bsnap/home-rm ]]; then
	rm() {
		local arg snap=no will_err=no paths=()
		for arg in "$@"; do
			if [[ "${arg[1]}" != "-" ]]; then
				paths+=("${arg}")
				if [[ ! -e "${arg}" ]]; then
					will_err=yes
				elif [[ "$(realpath ${arg})" =~ ^"${HOME}" ]]; then
					snap=yes
				fi
			fi
		done
		if [[ "${snap}" == "yes" && "${will_err}" == "no" ]]; then
			bsnap -c home-rm create "$(basename "${paths[1]}")"
			command rm -fr "${paths[@]}"
		else
			command rm "$@"
		fi
	}
elif type trash-put &>/dev/null; then
	alias rm=trash-put
fi
alias del=/bin/rm

# global aliases.
alias -g L="| ${PAGER}"
alias -g G="| grep $1"
alias -g V="| vim -R -"

alias -g NL='>/dev/null'
alias -g NLL='&>/dev/null'


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
	if [[ ((-n "${WINDOW}" && -z "${DISPLAY}") || -n "${TMUX}") && -z "${VIM}" ]]; then
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
autoload -Uz add-zsh-hook

# on GNU Screen or tmux
if __is_screen; then
	function __preexec_on_screen() {
		local line="$3"
		local args=("${(z)line}")
		local cmd
		if [[ "${(t)args}" == "array-local" ]]; then
			while __is_prefix_cmd "${args[1]}"
			do
				shift args
			done
			cmd="${args[1]}"
		else
			cmd="${args}"
		fi
		shift 1 args 2>/dev/null
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
	add-zsh-hook preexec __preexec_on_screen
	add-zsh-hook precmd __precmd_on_screen

	function tmux-session-refresh() {
		unset $(tmux show-env | sed -n 's/^-//p')
		eval export $(tmux show-env | sed -n 's/$/"/; s/=/="/p')
	}
fi

###########################################################################
# Load other scripts.

() {
	local f
	for f in ~/.zsh/scripts/*.zsh(N); do
		[[ -r "${f}" ]] && source "${f}"
	done
}

[[ -r ~/.zsh/"${SYSTEM_NAME}".zsh ]] && source ~/.zsh/"${SYSTEM_NAME}".zsh
[[ -r ~/.config/zsh/local.zsh ]] && source ~/.config/zsh/local.zsh

# Delete the duplicate entry.
typeset -U path
typeset -U manpath

# Automatically start Tmux session
[[ -f ~/.zsh/tmux ]] && source ~/.zsh/tmux

fpath=(~/.zsh/functions/Completion(N-/) $fpath)
autoload -U compinit
compinit

# vim: ft=zsh
