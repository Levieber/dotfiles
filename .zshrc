# Code from https://github.com/arthur404dev/dotfiles

export XDG_CONFIG_HOME="$HOME/.config"
export GPG_TTY=$(tty)

# Load Package Manager (zinit)
[[ -f ~/.zsh/zinit.zsh ]] && source ~/.zsh/zinit.zsh

# Load Helpers
[[ -f ~/.zsh/helpers.zsh ]] && source ~/.zsh/helpers.zsh

# Load Functions, Aliases and Config
[[ -f ~/.zsh/functions.zsh ]] && source ~/.zsh/functions.zsh
[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
[[ -f ~/.zsh/config.zsh ]] && source ~/.zsh/config.zsh
[[ -f ~/.zsh/path.zsh ]] && source ~/.zsh/path.zsh
[[ -f ~/.zsh/completions.zsh ]] && source ~/.zsh/completions.zsh

# Load Plugins
[[ -f ~/.zsh/plugins.zsh ]] && source ~/.zsh/plugins.zsh

# Starship Configuration
[[ -f ~/.zsh/starship.zsh ]] && source ~/.zsh/starship.zsh

# Load Homebrew and fix WSL2 interop
[[ -f ~/.zsh/homebrew.zsh ]] && source ~/.zsh/homebrew.zsh
$IS_WSL && [[ -f ~/.zsh/wsl2fix.zsh ]] && source ~/.zsh/wsl2fix.zsh

# Load Mise
[[ -f ~/.zsh/mise.zsh ]] && source ~/.zsh/mise.zsh

# Load All Programs from /programs
for file in ~/.zsh/programs/*; do
    source $file
done
