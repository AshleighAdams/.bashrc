# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

if [ $TILEX_ID ] || [ $VTE_VERSION ]; then
	source /etc/profile.d/vte.sh
	source /usr/share/tilix/scripts/tilix_int.sh
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Kobra's stuff:
alias rm='trash-put'

# luarocks install cw
#if [ -n "$PS1" ]; then PATH=`cw-definitions-path`:$PATH; export PATH; fi

alias please='sudo $(history -p !-1)'

# for gcc colours
export GCC_COLORS=auto

#function cd {
#	command cd "$1" > /dev/null # pipe stdout, but not stderr
#	local ret=$?
#	
#	if [[ $ret == 0 ]]; then
#		# \r     = return to start of line
#		# \e[1A  = move cursor up a line
#		# \e[J   = clear everything after the cursor
#		echo -ne "\r\e[1A\e[J"
#	fi
#	
#	return $ret
#}


# alias ..="cd .."
# shopt -s autocd # ../.. Dropbox/ etc... changes dir
# canonical, <offset> <bytes> <ascii>
alias hexdump="hexdump -C"
alias gource="gource --max-files 0 -i 0"
alias markauto="sudo apt-mark auto "
alias gedit="GTK_THEME=AdwaitaAccent:dark gedit"
alias ping="ping -n"
alias make="make -j3" # make should use 3 threads to build

# This clear is the real one.
#alias clear="echo -ne '\033c'"

export DEBFULLNAME="Ashleigh Adams"
export DEBEMAIL="ashleigh.k.adams@gmail.com"
export PATH="$PATH:~/.local/bin"


# 256 colour support
if [ "$TERM" == "xterm" ]; then
    # No it isn't, it's gnome-terminal
    export TERM=xterm-256color
fi
if [ ! -z "$TERMCAP" ] && [ "$TERM" == "screen" ]; then                         
    export TERMCAP=$(echo $TERMCAP | sed -e 's/Co#8/Co#256/g')                  
fi 


bold=`echo -en "\e[1;39m"`
orange=`echo -en "\e[38;5;208m"`
red=`echo -en "\e[1;31m"`
green=`echo -en "\e[1;32m"`
yellow=`echo -en "\e[1;33m"`
blue=`echo -en "\e[1;34m"`
lightblue=`echo -en "\e[1;36m"`
reset=`echo -en "\e[0m"`
invert=`echo -en "\e[7m"`
underline=`echo -en "\e[4m"`
italic=`echo -en "\e[3m"`
blink=`echo -en "\e[5m"`

# Inject git branch into dir
# Functions
git_branch=""
git_branch_sep=":"
basedir=""
default_colours=$'\e[m'
_CAP_=`echo -ne "\01"`
_END_=`echo -ne "\02"`
function get_git_branch {
	local dir=. head
	local depth="0"
	
	until [ "$dir" -ef / ]; do
		depth=`expr $depth + 1`
		if [ -f "$dir/.git/HEAD" ]; then
			head=$(< "$dir/.git/HEAD")
			if [[ $head == ref:\ refs/heads/* ]]; then
				git_branch="${head##*/}"
			elif [[ $head != '' ]]; then
				git_branch="detached*"
			else
				git_branch="unknown*"
			fi
			
			local col="$green"
			local STAGED="`git status --porcelain 2>/dev/null| egrep "^ ?M" | wc -l`"
			if [[ $STAGED != "0" ]]; then
				git_branch="~$git_branch"
			fi
			
			git_branch="$git_branch_sep$_CAP_$col$_END_$git_branch$_CAP_$reset$_END_"
			PROMPT_DIRTRIM="$depth"
			return
		fi
	dir="../$dir"
	done
	git_branch=""
	PROMPT_DIRTRIM="4" # default value
}

return_code=""
return_code_gfx=""
return_code_bad="$red"
prompt_path="$(pwd)"
function get_return_code {
	local ret="$?"
	if [[ $ret == "0" ]]; then
		return_code_gfx="";
		return_code="";
	else
		return_code_gfx="$return_code_bad";
		return_code=""; # in case colours arn't avil
	fi
	
	if [[ -e "$HOME/.cdcompact" ]]; then
		prompt_path="$(pwd | "$HOME/.cdcompact")"
	else
		prompt_path="$(pwd)"
	fi
}

PROMPT_COMMAND="get_return_code; get_git_branch; $PROMPT_COMMAND"
#PROMPT_NOCOMPACT=yes

if [ "$color_prompt" = yes ]; then
	user="\u"
	usercol=""
	host="\h"
	hostcol=""
	#path="\w"
	path="\$prompt_path"

	pathcol=""

	prom="\[\$return_code_gfx\]\\$\[$reset\]"
	gitb="\$git_branch"

	if [[ "`whoami`" == "kobra" ]]; then
		#user="\[$bold$orange\]$user\[$reset\]"
		usercol="$orange"
	elif [[ "`whoami`" == "root" ]]; then
		#user="\[$bold$red\]$user\[$reset\]"
		usercol="$red"
	fi

	if [[ "`hostname`" == "pc" ]]; then
		#host="\[$red\]$host\[$reset\]"
		hostcol="$red"
	elif [[ "`hostname`" == "lappy" ]]; then
		#host="\[$green\]$host\[$reset\]"
		hostcol="$green"
	elif [[ "`hostname`" == "pi" ]]; then
		hostcol="$yellow"
	elif [[ "`hostname`" == "vps" ]]; then
		#host="\[$lightblue\]$host\[$reset\]"
		hostcol="$lightblue"
	fi



	if [[ "$PROMPT_NOCOMPACT" != "yes" ]]; then
		return_code_bad="$italic$usercol"
		PS1=`echo "\[$hostcol\]$path\[$reset\]$gitb\[$usercol\]$prom "`
	else
		export CDCOMPACT_TRUNK_GIT=ascii
		export CDCOMPACT_TRUNK_MINUNIQUE=0
		export CDCOMPACT_TRUNK_HOMESAMEUSER=always

		prom="\[\$return_code_gfx\]\$return_code\\$\[$reset\]"
		path="\[$blue\]$path\[$reset\]"
		PS1=`echo "\[$bold$usercol\]$user\[$reset\]@\[$bold$hostcol\]$host\[$reset\]:$path$gitb$prom "`
	fi



	#if [ "`hostname`" == "pc" ]; then
	#	PS1="\[\e[1;39m\e[38;5;208m\]\u\[\e[0m\]@\[\e[1;31m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[1;39m\e[1;32m\]\$git_branch\[\e[0m\]\$ "
	#elif [ "`hostname`" == "laptop" ]; then
	#	PS1="\[\e[1;39m\e[38;5;208m\]\u\[\e[0m\]@\[\e[1;32m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[1;39m\e[1;32m\]\$git_branch\[\e[0m\]\$ "
	#else
	#	PS1="\[\e[1;32m\]\u\[\e[0m\]@\[\e[1;36m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[1;39m\e[1;32m\]\$git_branch\[\e[0m\]\$ "
	#fi
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
*)
	;;
esac

function update_bashrc {
	wget "https://raw.githubusercontent.com/AshleighAdams/.bashrc/master/.bashrc" -O ~/.bashrc
}

function update_cdcompact {
	wget "https://raw.githubusercontent.com/AshleighAdams/.bashrc/master/.cdcompact" -O ~/.cdcompact
	chmod +x ~/.cdcompact
}

