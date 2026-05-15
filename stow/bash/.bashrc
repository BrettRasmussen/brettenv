# Minimal brettenv-related bashrc file that can be symlinked to $HOME/.bashrc and will then load up
# the main configuration if in an interactive shell or the "brettenv" command is called.

alias brettenv='source ${BRETTENV_PATH}/bashrc.main'

if [[ -n "$PS1" ]]; then
  brettenv
  if [[ -z $TMUX ]]; then
    bmux
  fi
fi
