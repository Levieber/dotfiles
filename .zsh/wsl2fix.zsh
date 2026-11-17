WINDOWS_USERNAME=gblev

# Fix Interop Error that randomly occurs in vscode terminal when using WSL2
fix_wsl2_interop() {
    for i in $(pstree -np -s $$ | grep -o -E '[0-9]+'); do
        if [[ -e "/run/WSL/${i}_interop" ]]; then
            export WSL_INTEROP=/run/WSL/${i}_interop
        fi
    done
}

### Export specific Windows paths
# Use this along with:
# [interop]
# appendWindowsPath = false
# on /etc/wsl.conf to fix: https://github.com/zsh-users/zsh-syntax-highlighting/issues/790
export PATH="$PATH:/mnt/c/Users/$WINDOWS_USERNAME/AppData/Local/Microsoft/WindowsApps"
export PATH="$PATH:/mnt/c/Users/$WINDOWS_USERNAME/AppData/Local/Programs/Microsoft VS Code/bin"
export PATH="$PATH:/mnt/c/Users/$WINDOWS_USERNAME/AppData/Local/Programs/Microsoft VS Code Insiders/bin"
export PATH="$PATH:/mnt/c/Users/$WINDOWS_USERNAME/AppData/Local/Programs/cursor/resources/app/bin"
export PATH="$PATH:/mnt/c/Program Files/Docker/Docker/resources/bin"
export PATH="$PATH:/mnt/c/ProgramData/DockerDesktop/version-bin"
export PATH="$PATH:/mnt/c/WINDOWS"
export PATH="$PATH:/mnt/c/WINDOWS/System32"
export PATH="$PATH:/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0"

### Session services that a desktop gets from GNOME
# ssh-agent: OpenSSH's systemd user socket (`systemctl --user enable --now ssh-agent.socket`)
[[ -z "$SSH_AUTH_SOCK" && -S "$XDG_RUNTIME_DIR/openssh_agent" ]] && export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/openssh_agent"
# Open URLs (gh/claude logins) in the Windows default browser (wrapper: explorer.exe exits 1 on success)
export BROWSER="$HOME/.zsh/bin/win-browser"
