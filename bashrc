# NOTE: My new preferred shell is zsh. This file is still around for use on
# those systems where zsh might not be found, and should still work as
# described. Normally, just ignore this file and look in zshrc instead.
#
# bashrc file to set up Brett's command-line environment, including settings for
# tmux.  These instructions assume a home directory name of /home/brett.  On any
# given system, install git (package is usually git-core), generate ssh keys
# (ssh-keygen), put id_rsa.pub into github account, copy the github project
# location, then do this in /home/brett:
#
# git clone git@github.com:BrettRasmussen/brettenv.git .brettenv
#
# (Or whatever the github project path is and desired location on the system.)
#
# Then set up these aliases in the standard bashrc file (probably
# /home/brett/.bashrc):
#
# alias brettenv='source ~/.brettenv/bashrc'
# export TERM=screen-256color
# alias bmux='tmux -f ~/.brettenv/tmux.conf'
#
# If you want other accounts on the same system to have access to these
# settings, put those same three lines in those users' bashrc files as well, and
# make a symlink /home/brett/.brettenv directory in those users' home
# directories (note that /home/brett/.brettenv must be readable by those users;
# if it can't be, then you'll need to put the brettenv directory somewhere
# world-readable and link to it from all locations, including /home/brett).
# Once this is done, you can get Brett's environment by typing "brettenv" or
# "bmux" from a prompt.
#
# If you always want a given user account to use this environment, put the
# following in the standard bashrc file after the lines above:
#
# if [[ -n "$PS1" ]]; then
#   brettenv
#   if [[ -z $TMUX ]]; then
#     bmux
#   fi
# fi
#
# In this case, the outer "if" block prevents them being run if the login is
# non-interactive, and the one around the bmux call prevents launching a new
# tmux session from within an existing one, which allows ~/.bashrc to be
# sourced at any time without fear of getting nested tmux sessions.
#
# See tmux.conf for an example of how to get tmux to always start up with the
# brettenv settings turned on.
#-------------------------------------------------------------------------------

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

# Customized prompt.
# To understand the color codes, see:
# http://unix.stackexchange.com/questions/124407/what-color-codes-can-i-use-in-my-ps1-prompt
# http://en.wikipedia.org/wiki/ANSI_escape_code#Colors
export PS1="\[\033[38;5;222m\][\u@\h:\W]\$(__git_ps1 '(%s)')$\[\033[00m\] "
#export PS1="\[\033[01;32m\][\u@\h:\W]\$(__git_ps1 '(%s)')$\[\033[00m\] "
#export PS1='[\u@\h:\W]$ '

# use vi mode for the command line
set -o vi

# case-insensitive globbing in bash
shopt -s nocaseglob

# Get the setup stuff shared by bash and zsh.
source $HOME/.brettenv/sharedrc
