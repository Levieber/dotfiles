# macOS only: put Homebrew on PATH. It's installed by hand (https://brew.sh) before
# `mise bootstrap`, which then installs the `brew:`/`brew-cask:` packages.
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    BREW_PREFIX=/opt/homebrew
fi
