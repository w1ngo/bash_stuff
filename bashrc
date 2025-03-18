bind "set show-all-if-ambiguous" &> /dev/null
bind "set bell-style none" &> /dev/null
stty -tostop # prevent background jobs from trying to print to terminal

HISTCONTROL=ignoreboth
HISTFILESIZE=100000
HISTSIZE=10000

if [ -f /etc/bashrc ]; then . /etc/bashrc; fi
if [ -f ~/.bash_functions ]; then . ~/.bash_functions; fi
if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases; fi

# export PS1='\n\e[0;37m[\W\e[1;35m`current_branch_short`\e[m]\n\$\e[0;32m '
export PS1='\n\[\e[;37m\][\[\e[3;36m\]\u\[\e[;37m\]@\[\e[;35m\]\h\[\e[;37m\] \w\[\e[3;33m\]`current_branch`\[\e[;37m]\]\n\$\[\e[;32m\] '
export TERM='xterm-256color'

# export PATH="$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/,$ENV_PATH}))')" # remove path dupes

alias ls='ls --color=always'
alias lsa='ls -A'
alias lh='ls -AlhBgoX'
alias lss='ls --color=never--format=single-column'
alias ll='ls -AlB'
alias ..='go_back'
alias py='python'
alias grep='grep --color=always'
alias grepr='grep -riI'
alias shrink='sed "s|\t||g" | tr -s " "' # sed "s/:/: /;s/\t//g;s/ \+/ /g" | sort -fu
alias mv='mv -i'
alias cp='cp -i'
alias cls='clear; ls'
alias ping='ping -q -c 2 -i 0.2'
alias ip='ip -c'
alias sortu='sort -fuimsb =--parallel=4'
alias cscope='cscope -qR'
alias tar_up="tar --remove-files -czf"
alias awk='gawk -O '
alias shasum="sha256sum"
alias vim='vim -p'

export CSCOPE_EDITOR=vim
export EDITOR=vim

current_branch () { git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'; }
disk_usage () { df | head -n 1 && df | tail -n +2 | sort -nk 5; }
hexdump () { od -x $1; }
my_find () { find . -name $1; }
reload () { . ~/.bashrc; }
trash () { for f in "${@:1}"; do mv $f ~/.trash; done }

zip_up () { tar -czvf "$1.tgz" "${@:3}"; }

trash () { for f in "${@:1}"; do mv $f ~/.trash; done }

# tweaks grep a little in the way I like
Grep () {
	command="grep --color=always -riI"
	for arg in "$@"; do command+=" -e $arg"; done
	$command | sed 's/:/: /g;s/\t//g;s/ \+/ /g' | sort -fuimsb --parallel=4
}

go_back () {
	if [[ -n "$1" ]]; then
		for i in $(seq 1 "$1"); do cd ..; done
	else
		cd ..
	fi
	clear
	ls
}

update_env () {
    rsync ~/.bashrc ~/dev/bash_stuff/bashrc
    rsync ~/.vimrc ~/dev/bash_stuff/vimrc
}

update_repos () {
	pushd $(pwd) > /dev/null
	COL='\033[1;31m'
	COL2='\033[;32m'
	ORIG='\033[3;37m'
	OUT='\033[;37m'

	printf '\n\n${COL}Updating Repos in $loc${ORIG}'
	cd "$1" && FOLDERS=($(ls --color=never -d */))
	for folder in "${FOLDERS[@]}"; do
		cd "$loc"/"$folder"
		if [ -d ".git" ]; then
			printf "\n${COL2}  Updating $folder${ORIG}\n"
			git remote update
			if [ "$2" == "clean" ]; then git gc; fi
		fi
	done

	popd > /dev/null
	printf "${OUT}"
}

list_functions () {
	if [[ "#$" == 0 ]]; then declare -F | awk '{print $3}' | sort -fu;
 	else					 delcare -F | awk '{print $3}' | grep -v "^_" | sort -fu;
  	fi
}

# arg 1 should be absolute path to folder storing the clones
update_clones () {
	LOC=$(pwd)
	cd $1
	FOLDERS=($(ls --color=never -d */))

	for folder in "${FOLDERS[@]}"; do
		cd $1/folder
		if [ -d ".git" ]; then
			echo "Update folder: $folder"
			git remote update
			echo
		fi
	done

	cd $LOC
}

extract () {
	if [[ -f $1 ]]; then
		case "$1" in
			*.tar.bz2)	tar xzjf	$1 ;;
			*.targz)	tar xvzf	$1 ;;
			*.bz2)		bunzip		$1 ;;
			*.rar)		unrar x		$1 ;;
			*.gz)		gunzip		$1 ;;
			*.tar)		tar xvf		$1 ;;
			*.zip)		unzip		$1 ;;
			*.7z)		7z x		$1 ;;
			*)	echo "Don't know how to extract $1" ;;
		esac

	else
		echo "$1 is not a valid input file to extract"
	fi
}

