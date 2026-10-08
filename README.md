# Dotfiles

My shell and editor setup for Linux, WSL2 and macOS: zsh with zinit, Starship, Neovim (LazyVim), mise, and a Catppuccin Mocha theme across the terminal tools.

Based on an earlier version of dotfiles from [arthur404dev](https://github.com/arthur404dev).

## What's in it

| Path | What it does |
| --- | --- |
| `.zshrc` | Loads everything below, in order. |
| `.zsh/zinit.zsh`, `.zsh/plugins.zsh` | [zinit](https://github.com/zdharma-continuum/zinit) with syntax highlighting, completions, autosuggestions, fzf-tab and history substring search. |
| `.zsh/config.zsh` | Key bindings and history (shared between sessions, no duplicates). |
| `.zsh/helpers.zsh` | Detects the OS (`IS_MACOS`, `IS_LINUX`, `IS_WSL`). |
| `.zsh/homebrew.zsh` | Installs Homebrew (or Linuxbrew) if it's missing and puts it on `PATH`. |
| `.zsh/programs/*.zsh` | One file per tool. Each installs its tool on first run if it's missing, then sets its aliases and config: bat, delta, eza, fzf, gh, lazydocker, mise, Neovim, ripgrep, zoxide. |
| `.zsh/functions.zsh` | Shell functions (below). |
| `.zsh/wsl2fix.zsh` | Fixes WSL2 interop errors in VS Code terminals and adds Windows tools to `PATH`. |
| `.zsh/starship.zsh`, `.config/starship.toml` | [Starship](https://starship.rs) prompt, with icons for the current distro and device. Installs Starship if it's missing. |
| `.config/nvim` | [LazyVim](https://www.lazyvim.org) with TypeScript, ESLint, Prettier, Markdown and Copilot extras. |
| `.config/mise/config.toml` | [mise](https://mise.jdx.dev) tool versions: Node (LTS), Bun, pnpm, Yarn, Python, Java. |
| `.config/bat`, `.config/delta` | Catppuccin Mocha themes for bat and delta (git diffs). |
| `.gitconfig.bak` | Template for `~/.gitconfig` (see [Set up git](#3-set-up-git)). |

## Functions

- `install` / `uninstall`: install or remove a package with brew, apt, pacman, dnf or yum (brew by default).
- `ensure_package`: install a package only if its binary is missing. The files in `.zsh/programs` use it.
- `sg`: search the code with ripgrep, pick a match in fzf with a bat preview, and open it in Neovim at that line.
- `wtmerge`: merge a git worktree's branch into the main checkout, then remove the worktree and delete the branch. Pick the worktree with fzf or pass its name; `-k` keeps the worktree, `-f` unlocks one that a running Claude Code session still holds.

## Setup

### 1. Install zsh

The setup also needs `git` and `curl`: zinit clones itself with git, and Homebrew installs with curl.

```sh
# Ubuntu, Debian and WSL2
sudo apt update && sudo apt install -y zsh git curl

# Fedora
sudo dnf install -y zsh git curl

# Arch
sudo pacman -S --needed zsh git curl
```

On macOS, zsh is already the default shell; install git with `xcode-select --install`.

Make zsh your default shell, then log out and back in (on WSL2, close and reopen the terminal):

```sh
chsh -s "$(which zsh)"
```

The prompt and `ls` use icons, so set your terminal's font to a [Nerd Font](https://www.nerdfonts.com).

### 2. Link the files

Clone the repo to `~/dotfiles` and link the files into place:

```sh
git clone https://github.com/Levieber/dotfiles.git ~/dotfiles

ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.zsh ~/.zsh
mkdir -p ~/.config
for item in bat delta mise nvim starship.toml; do
  ln -s ~/dotfiles/.config/$item ~/.config/$item
done
```

Then open a new zsh session. On the first run, zinit, Homebrew, Starship and the tools in `.zsh/programs` install themselves if they're missing.

### 3. Set up git

`.gitconfig.bak` is a template for `~/.gitconfig`. Copy it instead of linking it, since your copy holds your own name, email and signing key:

```sh
cp ~/dotfiles/.gitconfig.bak ~/.gitconfig
```

Then edit `~/.gitconfig`:

- In `[user]`, uncomment `name`, `email` and `signingkey` and fill them in.
- Commits and tags are signed (`gpgsign = true`), so `signingkey` needs a GPG key that's also added to your GitHub account. To skip signing, set both `gpgsign` values to `false`.
- `core.editor` is VS Code (`code`); change it if you use another editor.

The template also uses delta as the pager with the Catppuccin theme (from the linked `~/.config/delta`), pushes to a branch of the same name and sets it as upstream, uses `main` as the default branch, and adds `git undo` (undo the last commit, keeping its changes).
