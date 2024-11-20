# If zoxide is not installed, install it
ensure_package zoxide -s

alias cd="z"

eval "$(zoxide init zsh)"
