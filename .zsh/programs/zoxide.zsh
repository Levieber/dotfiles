(( $+commands[zoxide] )) || return 0

alias cd="z"

eval "$(zoxide init zsh)"
