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
export PS1='\n\[\e[;37m\][\[\e[3;36m\]\h\[\e[;37m\] \w\[\e[3;35m\]`current_branch`\[\e[;37m]\]\n\$\[\e[;32m\] '
export TERM='xterm-256color'

export PATH="$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/,$ENV_PATH}))')" # remove path dupes
