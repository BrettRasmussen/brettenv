# bashrc file to set up Brett's command-line environment, including settings for
# tmux.  These instructions assume a home directory name of /home/brett.  On any
# given system, install git (package is usually git-core), generate ssh keys
# (ssh-keygen), put id_rsa.pub into github account, copy the github project
# location, then do this in /home/brett:
#
# git clone git@github.com:BrettRasmussen/brettenv.git .brettenv
#
# (Or whatever the github project path is and desired location on the system.)
# Then set up these aliases in the standard bashrc file (probably
# /home/brett/.bashrc):
#
# alias brettenv='source ~/.brettenv/bashrc'
# alias bmux='source ~/.brettenv/tmux.conf'
#
# If you want other accounts on the same system to have access to these
# settings, put those same two lines in those users' bashrc files as well, and
# make a symlink /home/brett/.brettenv directory in those users' home
# directories (note that /home/brett/.brettenv must be readable by those users;
# if it can't be, then you'll need to put the brettenv directory somewhere
# world-readable and link to it from all locations, including /home/brett).
# Once this is done, you can get Brett's environment by typing "brettenv" or
# "bmux" from a prompt.
#
# If you always want a given user account to use this environment, put another
# line in the standard bashrc file after the aliases above:
#
# brettenv
#
# See tmux.conf for an example of how to get tmux to always start up with the
# brettenv settings turned on.


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
export ACKRC='~/.brettenv/ackrc'

# show timestamps for history
export HISTTIMEFORMAT='(%F %T) '

# use vi mode for the command line
set -o vi

# use my settings (including vi mode) for programs using readline
export INPUTRC='~/.brettenv/inputrc'

# case-insensitive globbing in bash
shopt -s nocaseglob

# portable aliases
alias ls='ls -F --color=auto'
alias l='ls -lFh'
alias la='l -a'
alias u='cd ../'
alias b='cd -'
alias pg='ping google.com'
alias sc='script/console'
alias vi='vim -u ~/.brettenv/vimrc'
alias vim='vim -u ~/.brettenv/vimrc'
alias vib='vim -u ~/.brettenv/vimrc'
alias mvim='mvim -u ~/.brettenv/vimrc -U ~/.brettenv/mvimrc'
alias gvim='gvim -u ~/.brettenv/vimrc -U ~/.brettenv/gvimrc'
alias ack='ack-grep -a'
alias sudo='sudo env PATH=$PATH'

# get system-specific stuff
if [ -f ~/.brettenv/local ]; then
  source ~/.brettenv/local
fi

# This loads RVM into a shell session.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
