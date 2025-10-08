# ZSH Plugins list

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit load zsh-users/zsh-history-substring-search

# Loads completions
autoload -Uz compinit
compinit -C
