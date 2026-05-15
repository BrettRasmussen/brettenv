# Define global environment variables
export BRETTENV_PATH="${HOME}/.brettenv"
export GOPATH="${HOME}/.go"

# Ensure path is a unique array (prevents tmux duplicates)
typeset -U path

# Define $PATH using zsh's path array. We use += to append or path=(... $path) to prepend. This
# preserves anything already in the path while ensuring our bins exist.
path=(
  "./bin"
  "${HOME}/bin"
  "${BRETTENV_PATH}/bin"
  "${GOPATH}"
  "/opt/homebrew/bin"
  "/opt/homebrew/opt/openssl@1.1/bin"
  $path
)
