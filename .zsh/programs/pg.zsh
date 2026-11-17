# libpq is keg-only in Homebrew, so psql and friends aren't on PATH by default
[[ -d "$BREW_PREFIX/opt/libpq/bin" ]] && export PATH="$BREW_PREFIX/opt/libpq/bin:$PATH"
