# Keep PATH free of duplicates and put the user's own bin directories first
typeset -U path PATH
path=(~/.local/bin(N) ~/bin(N) $path)
