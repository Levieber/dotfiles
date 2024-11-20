# ZSH Plugins list

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit load zsh-users/zsh-history-substring-search
zinit ice wait atload_history_substring_search_config

# Loads completions
autoload -U compinit && compinit -C
