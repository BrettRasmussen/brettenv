export BRETTENV_PATH="${HOME}/.brettenv"
export PATH="${PATH}:${HOME}/bin:${BRETTENV_PATH}/bin"
# export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - --no-rehash bash)"
