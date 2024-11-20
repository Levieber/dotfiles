# Mise configuration (https://github.com/jdx/mise)

if [ ! -f $BREW_PREFIX/bin/mise ]; then
  echo "mise not found. Installing..."
  $BREW_PREFIX/bin/brew install mise
fi

eval "$(~/.local/bin/mise activate zsh)"
