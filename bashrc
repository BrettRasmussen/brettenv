# prompt with git branch displayed
__git_ps1 ()
{
  local b="$(git symbolic-ref HEAD 2>/dev/null)"
  if [ -n "$b" ]; then
    if [ -n "$1" ]; then
      printf "$1" "${b##refs/heads/}"
    else
      printf " (%s)" "${b##refs/heads/}"
    fi
  fi
}

export PS1="\[\033[01;31m\][\u@\h:\W]\$(__git_ps1 '(%s)')$\[\033[00m\] "
#export PS1='[\u@\h:\W]$ '

# various environment variables
export EDITOR='vi -u ~/.brettenv/vimrc'
export EMAIL=brett.rasmussen@twoedge.com

# show timestamps for history
export HISTTIMEFORMAT='(%F %T) '

# use vi mode for the command line
set -o vi

# xmodmap stuff, including swapping esc and del
#xmodmap ~/.brettenv/Xmodmap

# use my settings (including vi mode) for programs using readline
export INPUTRC='~/.brettenv/inputrc'

# case-insensitive globbing in bash
shopt -s nocaseglob

# portable aliases
alias ls='ls -F'
alias l='ls -lFh'
alias la='l -a'
alias u='cd ../'
alias b='cd -'
alias pg='ping google.com'
alias sc='script/console'
alias vi='vim -u ~/.brettenv/vimrc'
alias vim='vim -u ~/.brettenv/vimrc'
alias mvim='mvim -u ~/.brettenv/vimrc -U ~/.brettenv/mvimrc'
alias gvim='gvim -u ~/.brettenv/vimrc -U ~/.brettenv/gvimrc'
alias ack='ack-grep'

# get system-specific stuff
if [ -f ~/.brettenv/local ]; then
  source ~/.brettenv/local
fi
