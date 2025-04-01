bind "set show-all-if-ambiguous" &> /dev/null
bind "set bell-style none" &> /dev/null

HISTCONTROL=ignoreboth
HISTFILESIZE=100000
HISTSIZE=10000

if [ -f /etc/bashrc       ]; then . /etc/bashrc;       fi
if [ -f ~/.bash_functions ]; then . ~/.bash_functions; fi
if [ -f ~/.bash_aliases   ]; then . ~/.bash_aliases;   fi

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
alias ip='ip -c'
alias ls='ls --color=always'
alias lsa='ls -A'
alias lh='ls -AlhBgoX'
alias lss='ls --color=never --format=single-column'
alias ll='ls -AlB'
alias mv='mv -i'
alias pwd='pwd && pwd -P'
alias ping='ping -q -c 2 -i 0.2'
alias py='python'
alias shrink='sed "s/:/: /g;s/\t//g;s/ \+/ /g"'
alias sortu='sort -fuimsb =--parallel=4'
alias shasum="sha256sum"
alias table='column -t'
alias tar_up="tar --remove-files -czf"
alias vim='vim -p'
alias watch='watch -p -n 1'
alias stripcolor='sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK//g' # strips color codes to make editor usage easier...needs to be piped into
									# if ^M digraph appears at EOL, this is Windows/DOS format (CR-LF vs LF)
									# in vim running :e ++ff=dos then :set ff=unix finally :wq works, as does dos2unix


current_branch () { git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'; }
trash () { for f in "${@:1}"; do mv $f ~/.trash; done }

go_back () {
    [ -z "$1" ] && NUM=1 || NUM="$1"
    for i in $(seq 1 "$NUM"); do cd ..; done
	clear; ls
}

hcli () {
    [ -z "$1" ] && hcli help

    case "$1" in
        help)
            local COL='\033[1;31m'
            local COL2='\033[;32m'
            local ORIG='\033[3;37m'
            local OUT='\033[;37m'
            printf "${COL}"
            printf "________________________________________________________________________________________\n"
            printf "\n"
            printf " Argument   -> Description\n"
            printf "________________________________________________________________________________________\n"
            printf "\n"
            printf "  branch    -> Print the current git branch, or nothing if not in repo\n"
            printf "  disk      -> Print the formatted disk usage\n"
            printf "  dev       -> Move to local dev location\n"
            printf "  extract   -> Extract compressed data at location specified\n"
            printf "  funcs     -> Prints all bash functions in current environment\n"
            printf "  save      -> Save current environment setup into ~/dev/bash_stuff\n"
            printf "  reload    -> Reload bash environment\n"
            printf "  trash     -> Move to a recycling bin, rather than full delete\n"
            printf "  update    -> Update local repos if no arg, specified location if present, cleanup if arg 3 == clean\n"
            ;;

        branch)
            current_branch
            ;;

        dev)
            cd ${HOME}/dev
            ;;
            
        disk)
            df | head -n 1 && df | tail -n +2 | sort -nk 5
            ;;

        extract)
            if [[ -f $2 ]]; then
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

            else
                echo "$2 is not a valid input file to extract"
            fi
            ;;


        funcs)  
            delcare -F | awk '{print $3}' | grep -v "^_" | sort -fu;
            ;;

        save)  
            rsync ~/.bashrc ~/dev/bash_stuff/bashrc
            rsync ~/.vimrc ~/dev/bash_stuff/vimrc
            rsync ~/.gitconfig ~/dev/bash_stuff/gitconfig
            ;;

        reload)
            . ~/.bashrc
            ;;

        trash)
            trash "${@:2}"
            ;;

        update)
            local COL='\033[1;31m'
            local COL2='\033[;32m'
            local ORIG='\033[3;37m'
            local OUT='\033[;37m'
            local loc="$2"

            [ "$2" == "." ] && loc=`pwd`
            printf '\n\n${COL}Updating Repos in $loc${ORIG}'

            pushd $(loc) &> /dev/null
            FOLDERS=($(ls --color=never -d */))
            for folder in "${FOLDERS[@]}"; do
                cd "$loc"/"$folder"
                if [ -d ".git" ]; then
                    printf "\n${COL2}  Updating $folder${ORIG}\n"
                    git remote update
                    [ "$3" == "clean" ] && git gc
                fi
            done

            popd > /dev/null
            printf "${OUT}"
            ;;

        ?)
            echo "Argument $1 unrecognized. Use hcli help for more detail"
            ;;

        *)
            hcli reload
            ;;


    esac


}

