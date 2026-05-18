# ~/.zshrc (managed by GNU Stow from ~/.brettenv)

# Only execute for interactive shells
if [[ -o interactive ]]; then

  # 1. Source the main environment payload
  if [[ -f "$HOME/.brettenv/zshrc.main" ]]; then
    source "$HOME/.brettenv/zshrc.main"
  fi

  # 2. Auto-launch tmux if we aren't already in it
  if [[ -z "$TMUX" ]]; then
    tmux
  fi

  # 3. Source local, machine-specific overrides (has the final say)
  if [[ -f "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
  fi

fi
