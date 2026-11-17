# On Linux psql comes from apt (postgresql-client). On macOS Homebrew's libpq is
# keg-only, so psql and friends aren't on PATH by default.
[[ -n "$BREW_PREFIX" && -d "$BREW_PREFIX/opt/libpq/bin" ]] && export PATH="$BREW_PREFIX/opt/libpq/bin:$PATH"
