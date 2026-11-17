# Mise (https://github.com/jdx/mise) installs the CLI tools in .config/mise/config.toml.
# Activate it before anything else runs those tools (fzf, zoxide, starship, ...).
# mise itself comes from apt on Linux and Homebrew on macOS; `mise bootstrap` installs the rest.
(( $+commands[mise] )) && eval "$(mise activate zsh --shims)"
