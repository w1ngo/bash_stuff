bind "set show-all-if-ambiguous" &> /dev/null
bind "set bell-style none" &> /dev/null

HISTCONTROL=ignoreboth
HISTFILESIZE=100000
HISTSIZE=10000

[ -f /etc/bashrc       ] && . /etc/bashrc
[ -f ~/.bash_functions ] && . ~/.bash_functions
[ -f ~/.bash_aliases   ] && . ~/.bash_aliases

export PS1='\n\[\e[;37m\][\[\e[3;36m\]\u\[\e[;37m\]@\[\e[;35m\]\h\[\e[;37m\] \w\[\e[3;33m\]`current_branch`\[\e[;37m]\]\n\$\[\e[;32m\] '
export TERM='xterm-256color'
export PATH="$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/,$ENV{PATH}))')" # remove path dupes
export CSCOPE_EDITOR=vim
export EDITOR=vim

alias ..='go_back'
alias awk='gawk -O '
alias cp='cp -i'
alias cscope='cscope -qR'
alias cls='clear; ls'
alias disassemble='objdump -dCl'
alias demangle='c++filt'
alias grep='grep --color=always'
alias grepr='grep -riI'
alias ipcbra='ip -c -br a'
alias ls='ls --color=always'
alias lsa='ls -A'
alias lh='ls -AlhBgoX'
alias mv='mv -i'
alias ping='ping -q -c 2 -i 0.2'
alias py='python'
alias shrink='sed "s/:/: /g;s/\t//g;s/ \+/ /g"'
alias sortu='sort -fuimsb =--parallel=4'
alias shasum="sha256sum"
alias table='column -t'
alias tar_up="tar --remove-files -czf"
alias vim='vim -p'
alias watch='watch -p -n 1'


current_branch () { git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'; }
trash () { for f in "${@:1}"; do mv $f ~/.trash; done }

go_back () {
    [ -z "$1" ] && NUM=1 || NUM="$1"
    for i in $(seq 1 "$NUM"); do cd ..; done
	clear; ls
}

_help_hcli () {
local COL='\033[1;31m'
local OUT='\033[;37m'

printf "${COL}"
cat << EOF
________________________________________________________________________________________

 Argument   -> Description
________________________________________________________________________________________

  branch    -> Print the current git branch, or nothing if not in repo
  disk      -> Print the formatted disk usage
  dev       -> Move to local dev location
  extract   -> Extract compressed data at location specified
  funcs     -> Prints all bash functions in current environment
  save      -> Save current environment setup into ~/dev/bash_stuff
  reload    -> Reload bash environment
  trash     -> Move to a recycling bin, rather than full delete
  update    -> Update local repos if no arg, specified location if present, cleanup if arg 3 == clean
EOF
printf "${OUT}"
}

hcli () {
    [ -z "$1" ] && hcli help

    case "$1" in
        "")     _help_hcli ;;
        branch) current_branch ;;
        dev)    cd ${HOME}/dev ;;
        disk)   df -h | head -n 1 && df -h | tail -n +2 | sort -nk 5 ;;
        funcs)  declare -F | awk '{print $3}' | grep -v "^_" | sort -fu; ;;
        reload) . ~/.bashrc ;;
        trash)  trash "${@:2}" ;;

        extract)
            shift 1
            case "$2" in
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
            ;;

        save)  
            rsync ~/.bashrc ~/dev/bash_stuff/bashrc
            rsync ~/.vimrc ~/dev/bash_stuff/vimrc
            rsync ~/.gitconfig ~/dev/bash_stuff/gitconfig
            sudo rsync ~/.bashrc /root/.bashrc
            sudo rsync ~/.vimrc /root/.vimrc
            ;;

        update)
            local COL='\033[1;31m'
            local ORIG='\033[;37m'
            local loc="$2"

            [ "$2" == "." ] && loc=`pwd`
            printf '\n\n${COL}Updating Repos in $loc${ORIG}'

            pushd $(loc) &> /dev/null
            FOLDERS=($(ls --color=never -d */))
            for folder in "${FOLDERS[@]}"; do
                cd "$loc"/"$folder"
                if [ -d ".git" ]; then
                    printf "\n    ${COL}  Updating $folder${ORIG}\n"
                    git remote update
                    [ "$3" == "clean" ] && git gc
                fi
            done

            popd > /dev/null
            ;;

        ?) echo "Argument $1 unrecognized. Use hcli help for more detail" ;;
    esac
}

_hcli_autocomplete () {
    local opts="branch disk dev extract funcs save reload trash update"
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) ) 
    return 0
}

complete -F _hcli_autocomplete hcli


