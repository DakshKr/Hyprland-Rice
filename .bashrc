#
# ~/.bashrc
#


# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias c="clear"
alias g="git"
alias n="nvim"


PS1='[\u@\h \W]\$ '
eval "$(starship init bash)"


