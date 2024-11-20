# If neovim is not installed, install it
ensure_package neovim -b nvim -s

# Alias to open neovim
alias vim="nvim"
export EDITOR=nvim