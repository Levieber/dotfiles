# Vim Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# History
HISTSIZE=1000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Variables
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
export XDG_CONFIG_HOME="$HOME/.config"
export GPG_TTY=$(tty)
export HISTORY_IGNORE='(export AWS_*|AWS_*=*)'
