# zshrc file to set up Brett's command-line environment, including settings for
# tmux. These instructions assume a home directory name of /home/brett. On any
# given system, install git (package is usually git-core), generate ssh keys
# (ssh-keygen), put id_rsa.pub into github account, copy the github project
# location, then do this in /home/brett:
#
# git clone git@github.com:BrettRasmussen/brettenv.git .brettenv
#
# (Or whatever the github project path is and desired location on the system.)
#
# Then set up these aliases in the standard .zshrc file (probably
# /home/brett/.zshrc):
#
# alias brettenv='source ~/.brettenv/zshrc'
# export TERM=screen-256color
# alias bmux='tmux -f ~/.brettenv/tmux.conf'
#
# If you want other accounts on the same system to have access to these
# settings, put those same three lines in those users' .zshrc files as well, and
# make a symlink /home/brett/.brettenv directory in those users' home
# directories (note that /home/brett/.brettenv must be readable by those users;
# if it can't be, then you'll need to put the brettenv directory somewhere
# world-readable and link to it from all locations, including /home/brett).
# Once this is done, you can get Brett's environment by typing "brettenv" or
# "bmux" from a prompt.
#
# If you always want a given user account to use this environment, put the
# following in the standard .zshrc file after the lines above:
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
# tmux session from within an existing one, which allows ~/.zshrc to be
# sourced at any time without fear of getting nested tmux sessions.
#
# See tmux.conf for an example of how to get tmux to always start up with the
# brettenv settings turned on.


# OH MY ZSH CAPABILITIES -------------------------------------------------------
#
# The following were some good ideas that came with Oh My Zsh that I'd like to
# look into getting to work now that Oh My Zsh is gone.
#
# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"
#-------------------------------------------------------------------------------


# ZSH CONFIG -------------------------------------------------------------------

# Set your $PATH.
export PATH="$HOME/bin:/usr/local/opt/postgresql@13/bin:/usr/local/bin:$PATH"

# Set the prompt.
# see https://voracious.dev/blog/a-guide-to-customizing-the-zsh-shell-prompt
# see https://arjanvandergaag.nl/blog/customize-zsh-prompt-with-vcs-info.html
# see https://salferrarello.com/zsh-git-status-prompt/
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' formats ' (%F{green}%b%u%c%f)'
zstyle ':vcs_info:git:*' actionformats ' (%F{green}%b|%a%u%c%f)'
precmd() { vcs_info }
setopt prompt_subst
PROMPT='[%n@%m %F{red}%1~%f${vcs_info_msg_0_}]$ '

# Disable history sharing across concurrent shell sessions.
unsetopt inc_append_history
unsetopt share_history

# Options for command-line history.
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS

# Move to beginning of line on up/down.
bindkey -M vicmd j vi-down-line-or-history
bindkey -M vicmd k vi-up-line-or-history

# Allow # comments on command-line.
setopt INTERACTIVE_COMMENTS

# Print a message on command-line when programs exit with non-zero value.
setopt PRINT_EXIT_VALUE

# Tab completion.
zstyle ':completion:*' menu select
fpath=(/usr/local/share/zsh-completions $fpath)
zmodload zsh/complist
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z-_}={A-Za-z_-}'

# Source the completions file.
# source $HOME/.brettenv/zsh-completion.conf

# Get the setup stuff shared by bash and zsh.
source $HOME/.brettenv/sharedrc
