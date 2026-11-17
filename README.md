# Dotfiles

My shell and editor setup for Linux, WSL2 and macOS: zsh with zinit, Starship, Neovim (LazyVim), mise, and a Catppuccin Mocha theme across the terminal tools.

[mise](https://mise.jdx.dev) sets up a whole machine from this repo: it links the files into place (`mise dotfiles`), installs the system packages and the CLI tools, and sets zsh as the login shell (`mise bootstrap`).

Based on an earlier version of dotfiles from [arthur404dev](https://github.com/arthur404dev).

## What's in it

| Path | What it does |
| --- | --- |
| `.config/mise/config.toml` | mise settings and tools: Node (LTS), Bun, pnpm, Python, uv, and the CLI tools (bat, delta, eza, fzf, gh, Neovim, ripgrep, Starship, zoxide, awscli, k9s, kubectl, just, hyperfine, lazydocker, railway). |
| `.config/mise/conf.d/dotfiles.toml` | The files mise links into `$HOME`, as relative symlinks into `~/dotfiles`. |
| `.config/mise/conf.d/packages.toml` | System packages for every machine: apt repositories (mise, Claude Code, Docker) and packages on Linux, Homebrew packages on macOS, and zsh as the login shell. |
| `.config/mise/config.desktop.toml` | The `desktop` environment for Linux desktops (not WSL): Ghostty, VS Code, Chrome, snaps and Proton Pass. |
| `.zshrc` | Loads everything below, in order. |
| `.zsh/zinit.zsh`, `.zsh/plugins.zsh` | [zinit](https://github.com/zdharma-continuum/zinit) with syntax highlighting, completions, autosuggestions, fzf-tab and history substring search. |
| `.zsh/config.zsh` | Key bindings and history (shared between sessions, no duplicates). |
| `.zsh/helpers.zsh` | Detects the OS (`IS_MACOS`, `IS_LINUX`, `IS_WSL`). |
| `.zsh/mise.zsh` | Activates mise, so the tools it installs are on `PATH` before anything else uses them. |
| `.zsh/homebrew.zsh` | macOS only: puts Homebrew on `PATH`. |
| `.zsh/programs/*.zsh` | Aliases and config per tool: bat, eza, fzf, Neovim, zoxide, and `psql` on macOS. Each one skips itself while its tool isn't installed. |
| `.zsh/functions.zsh` | Shell functions (below). |
| `.zsh/wsl2fix.zsh` | Fixes WSL2 interop errors in VS Code terminals and adds Windows tools to `PATH`. |
| `.zsh/starship.zsh`, `.config/starship.toml` | [Starship](https://starship.rs) prompt, with icons for the current distro and device. |
| `.config/nvim` | [LazyVim](https://www.lazyvim.org) with TypeScript, ESLint, Prettier, Markdown and Copilot extras. |
| `.config/bat`, `.config/delta` | Catppuccin Mocha themes for bat and delta (git diffs). |
| `.config/git` | Shared git config (signing, delta, aliases), global ignores and the allowed SSH signers. Your name and email stay in `~/.gitconfig` (see [Set up git](#3-set-up-git)). |
| `.config/gh`, `.config/k9s`, `.config/ghostty` | GitHub CLI, k9s and Ghostty settings. gh's `hosts.yml` (tokens) is never committed. |
| `scripts/install-proton-pass.sh` | Installs the Proton Pass `.deb` after checking its SHA-512 (Proton has no apt repository). |

## Functions

- `install` / `uninstall`: install or remove a package with brew, apt, pacman, dnf or yum (Homebrew on macOS, apt elsewhere by default). CLI tools belong in mise instead: `mise use -g <tool>`.
- `sg`: search the code with ripgrep, pick a match in fzf with a bat preview, and open it in Neovim at that line.
- `wtmerge`: merge a git worktree's branch into the main checkout, then remove the worktree and delete the branch. Pick the worktree with fzf or pass its name; `-k` keeps the worktree, `-f` unlocks one that a running Claude Code session still holds.

## Setup

### 1. Bootstrap the machine

**Ubuntu and WSL2.** Install `git` and `curl`, then run mise once from a temporary copy. mise installs itself from its apt repository during the bootstrap, so the temporary copy can go afterwards:

```sh
sudo apt update && sudo apt install -y git curl
curl -fsSL https://mise.run | MISE_INSTALL_PATH=/tmp/mise sh

/tmp/mise bootstrap --from https://github.com/Levieber/dotfiles.git \
  --from-dir ~/dotfiles --config-dir .config/mise
```

On a Linux desktop, add the `desktop` environment once; `--save-env` remembers it for later runs:

```sh
/tmp/mise -E desktop bootstrap --save-env --from https://github.com/Levieber/dotfiles.git \
  --from-dir ~/dotfiles --config-dir .config/mise
```

Don't add the apt repositories by hand first (for example `add-apt-repository ppa:jdxcode/mise`): mise writes its own `mise-<name>.sources` files, and apt stops working when the same repository is listed twice with different keys.

**macOS.** Install [Homebrew](https://brew.sh) and mise, then bootstrap:

```sh
brew install mise
mise bootstrap --from https://github.com/Levieber/dotfiles.git \
  --from-dir ~/dotfiles --config-dir .config/mise
```

The bootstrap clones the repo to `~/dotfiles`, links `~/.config/mise` and the other files, installs the packages and tools, and sets zsh as your login shell (log out and back in). It asks before adding apt repositories; `--dry-run` shows every change without making it.

The prompt and `ls` use icons, so set your terminal's font to a [Nerd Font](https://www.nerdfonts.com).

### 2. Keep it up to date

Run `mise bootstrap` again any time: it only changes what differs from the config, and the Proton Pass hook only installs it when it's missing.

- `mise bootstrap status --missing` lists what isn't set up yet.
- `mise dot status` shows the links; `mise dot diff` shows what `mise dot apply` would change.
- `mise upgrade` updates the CLI tools; apt updates mise, Claude Code and the system packages.
- Proton Pass updates stay manual: quit it from the tray, then run `scripts/install-proton-pass.sh`.

### 3. Set up git

The shared settings come from `~/.config/git/config`. Your identity stays out of the repo, in `~/.gitconfig`, which git reads after the shared file (so `git config --global` writes there):

```ini
[user]
  name = Your Name
  email = you@example.com
```

- Commits and tags are signed with SSH (`gpg.format = ssh`), using `~/.ssh/id_ed25519.pub`. Upload that key to GitHub as a **signing** key too, or point `user.signingkey` at another key in `~/.gitconfig`.
- `~/.config/git/allowed_signers` lists the keys `git log --show-signature` trusts. After a key rotation, keep the old key's line so older commits still verify locally.

### 4. Docker (rootless)

The bootstrap installs Docker Engine but leaves it off. To run it rootless (no root-equivalent `docker` group):

```sh
sudo systemctl disable --now docker.service docker.socket containerd
dockerd-rootless-setuptool.sh install
systemctl --user enable --now docker
sudo loginctl enable-linger "$USER"
```

`.zsh/config.zsh` points `DOCKER_HOST` at the rootless socket.
