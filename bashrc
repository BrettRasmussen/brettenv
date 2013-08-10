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
# alias bmux='tmux -f ~/.brettenv/tmux.conf -2'
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
# If you always want a given user account to use this environment, put the
# following in the standard bashrc file after the aliases above:
#
# if [[ -n "$PS1" ]]; then
#   brettenv
#   bmux
# fi
#
# In this case, the "if" block prevents them being run if the login is
# non-interactive.
#
# See tmux.conf for an example of how to get tmux to always start up with the
# brettenv settings turned on.  Note that the -2 in the tmux call aliased
# above means that tmux will assume 256-color mode (useful for vi color
# schemes, cursor highlighting, and the like).


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

# set up ~/bin
if [ -d ~/bin ]; then
  export PATH=~/bin:${PATH}
fi

# get aliases
if [ -f ~/.brettenv/alias ]; then
  source ~/.brettenv/alias
fi

# get system-specific stuff
if [ -f ~/.brettenv/local ]; then
  source ~/.brettenv/local
fi

# If this user is in the rvm group, enable the rvm shell script.
if groups | grep -q rvm ; then
  if [ -f "/etc/profile.d/rvm.sh" ];
  then
    source "/etc/profile.d/rvm.sh";
  else
    source "/usr/local/lib/rvm"
  fi
fi

# This loads RVM into a shell session.  Overrides system-wide rvm setup.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
