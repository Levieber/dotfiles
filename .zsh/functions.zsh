if_exists() {
  command -v $1 >/dev/null 2>&1
}

sg() {
  rg --color=always --line-number --no-heading --smart-case "${*:-}" |
    fzf --ansi \
      --color "hl:-1:underline,hl+:-1:underline:reverse" \
      --border \
      --tmux=80% \
      --delimiter : \
      --preview "bat --number --color=always {1} --highlight-line {2}" \
      --header-first \
      --header="Refine search and press enter to open file (press ctrl-c to exit)" \
      --preview-window "up,60%,border-bottom,+{2}+3/3,~3" \
      --bind "enter:become(nvim {1} +{2})"
}

install() {
  SILENT=false
  SUPRESS=false
  package_name=""
  binary_name=""
  package_manager="brew"
  binary_path=""
  install_cmd=""

  # Help message function
  show_help() {
    echo "Usage: install [OPTIONS] PACKAGE [BINARY_NAME] [PACKAGE_MANAGER]"
    echo ""
    echo "Install packages across different package managers"
    echo ""
    echo "Arguments:"
    echo "  PACKAGE          Name of the package to install"
    echo "  BINARY_NAME      Name of the binary to check (defaults to PACKAGE)"
    echo "  PACKAGE_MANAGER  Package manager to use (brew/apt/pacman/dnf/yum) (defaults to brew)"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message and exit"
    echo "  -s, --silent    Suppress all output except errors"
    echo "  -su, --suppress Suppress only 'already installed' messages"
    echo ""
    echo "Examples:"
    echo "  install bat"
    echo "  install -s bat"
    echo "  install python-pip pip apt"
    echo "  install --silent python-pip pip apt"
  }

  # Parse flags
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
    -h | --help)
      show_help
      return 0
      ;;
    -s | --silent)
      SILENT=true
      ;;
    -su | --suppress)
      SUPRESS=true
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1"
      echo "Try 'install --help' for more information."
      return 1
      ;;
    *)

      # Assign positional parameters to variables
      if [ -z "$package_name" ]; then
        package_name=$1
        binary_name=$1
      elif [ -z "$binary_name" ]; then
        binary_name=$1
      else
        package_manager=$1
      fi
      ;;

    esac
    shift
  done

  # Validate required parameters
  if [ -z "$package_name" ]; then
    echo "Error: Package name is required."
    echo "Try 'install --help' for more information."
    return 1
  fi

  # Set the binary path and install command based on package manager
  case $package_manager in
  "brew")
    binary_path="$BREW_PREFIX/bin/$binary_name"
    install_cmd="$BREW_PREFIX/bin/brew install $package_name"
    ;;
  "apt")
    binary_path="/usr/bin/$binary_name"
    install_cmd="sudo apt install -y $package_name"
    ;;
  "pacman")
    binary_path="/usr/bin/$binary_name"
    install_cmd="sudo pacman -S --noconfirm $package_name"
    ;;
  "dnf")
    binary_path="/usr/bin/$binary_name"
    install_cmd="sudo dnf install -y $package_name"
    ;;
  "yum")
    binary_path="/usr/bin/$binary_name"
    install_cmd="sudo yum install -y $package_name"
    ;;
  *)
    echo "Error: Unsupported package manager: $package_manager"
    echo "Supported package managers: brew, apt, pacman, dnf, yum"
    return 1
    ;;
  esac

  # Check if the binary is already installed
  if [ ! -f $binary_path ]; then
    [ "$SILENT" = false ] && echo "(1/2) Installing $package_name..."
    if eval $install_cmd; then
      [ "$SILENT" = false ] && echo "(2/2) Successfully installed $package_name."
    else
      echo "(2/2) Error: Failed to install $package_name."
      return 1
    fi
  else
    [ "$SILENT" = false ] && [ "$SUPRESS" = false ] && echo "(1/1) $package_name is already installed."
  fi
}

uninstall() {
  SILENT=false
  SUPPRESS=false
  package_name=""
  binary_name=""
  package_manager=""

  # Help message function
  show_help() {
    echo "Usage: uninstall [OPTIONS] PACKAGE [BINARY_NAME]"
    echo ""
    echo "Uninstall packages by detecting their package manager"
    echo ""
    echo "Arguments:"
    echo "  PACKAGE          Name of the package to uninstall"
    echo "  BINARY_NAME      Name of the binary to check (defaults to PACKAGE)"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message and exit"
    echo "  -s, --silent    Suppress all output except errors"
    echo "  -su, --suppress Suppress only 'not found' messages"
    echo ""
    echo "Examples:"
    echo "  uninstall bat"
    echo "  uninstall -s bat"
    echo "  uninstall python-pip pip"
  }

  # Parse flags
  while [[ "$#" -gt 0 ]]; do
    case $1 in
    -h | --help)
      show_help
      return 0
      ;;
    -s | --silent)
      SILENT=true
      ;;
    -su | --suppress)
      SUPPRESS=true
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1"
      echo "Try 'uninstall --help' for more information."
      return 1
      ;;
    *)
      # Assign positional parameters
      if [ -z "$package_name" ]; then
        package_name=$1
        binary_name=$1 # Default binary name to package name
      elif [ -z "$binary_name" ]; then
        binary_name=$1
      fi
      ;;
    esac
    shift
  done

  # Validate required parameters
  if [ -z "$package_name" ]; then
    echo "Error: Package name is required"
    echo "Try 'uninstall --help' for more information."
    return 1
  fi

  # Detect package manager based on binary location
  if [ -f "$BREW_PREFIX/bin/$binary_name" ]; then
    package_manager="brew"
    binary_path="$BREW_PREFIX/bin/$binary_name"
  elif [ -f "/usr/bin/$binary_name" ]; then
    # Check for apt first (Debian/Ubuntu)
    if command -v apt >/dev/null 2>&1; then
      package_manager="apt"
    # Then check for pacman (Arch)
    elif command -v pacman >/dev/null 2>&1; then
      package_manager="pacman"
    # Then check for dnf (Fedora)
    elif command -v dnf >/dev/null 2>&1; then
      package_manager="dnf"
    fi
    binary_path="/usr/bin/$binary_name"
  else
    [ "$SUPPRESS" = false ] && [ "$SILENT" = false ] && echo "Package $package_name not found or not installed"
    return 1
  fi

  # Set uninstall command based on detected package manager
  local uninstall_cmd=""
  case $package_manager in
  "brew")
    uninstall_cmd="$BREW_PREFIX/bin/brew uninstall $package_name"
    ;;
  "apt")
    uninstall_cmd="sudo apt remove -y $package_name"
    ;;
  "pacman")
    uninstall_cmd="sudo pacman -R --noconfirm $package_name"
    ;;
  "dnf")
    uninstall_cmd="sudo dnf remove -y $package_name"
    ;;
  *)
    echo "Error: Could not determine package manager for $package_name"
    return 1
    ;;
  esac

  # Uninstall the package
  [ "$SILENT" = false ] && echo "(1/2) Uninstalling $package_name using $package_manager..."
  if eval "$uninstall_cmd"; then
    [ "$SILENT" = false ] && echo "(2/2) Successfully uninstalled $package_name"
    # Verify removal
    if [ -f "$binary_path" ]; then
      echo "(1/1) Warning: Binary $binary_name still exists at $binary_path"
    fi
  else
    echo "(1/1) Error: Failed to uninstall $package_name"
    return 1
  fi
}

ensure_package() {
  SILENT=false
  SUPPRESS=false
  package_name=""
  binary_name=""
  package_manager=""
  FLAGS=()

  # Help message function
  show_help() {
    echo "Usage: ensure_package [OPTIONS] PACKAGE"
    echo ""
    echo "Ensure a package is installed, installing it if necessary"
    echo ""
    echo "Arguments:"
    echo "  PACKAGE          Name of the package to ensure"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message and exit"
    echo "  -s, --silent    Suppress all output"
    echo "  -su, --suppress Suppress only 'already installed' messages"
    echo "  -b, --binary    Specify binary name (defaults to package name)"
    echo "  -p, --package-manager  Package manager to use (defaults to auto-detect)"
    echo ""
    echo "Examples:"
    echo "  ensure_package bat"
    echo "  ensure_package -s bat"
    echo "  ensure_package python-pip -b pip -p apt"
  }

  if [[ "$ENSURE_PACKAGES" == "false" ]]; then
    return 0
  fi

  # Parse flags
  while [[ "$#" -gt 0 ]]; do
    case $1 in
    -h | --help)
      show_help
      return 0
      ;;
    -s | --silent)
      SILENT=true
      FLAGS+=("-s")
      ;;
    -su | --suppress)
      SUPPRESS=true
      FLAGS+=("-su")
      ;;
    -b | --binary)
      shift
      binary_name=$1
      ;;
    -p | --package-manager)
      shift
      package_manager=$1
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1"
      echo "Try 'ensure_package --help' for more information."
      return 1
      ;;
    *)
      if [ -z "$package_name" ]; then
        package_name=$1
      else
        echo "Error: Unexpected argument: $1"
        echo "Try 'ensure_package --help' for more information."
        return 1
      fi
      ;;
    esac
    shift
  done

  # Validate required parameters
  if [ -z "$package_name" ]; then
    echo "Error: Package name is required"
    echo "Try 'ensure_package --help' for more information."
    return 1
  fi

  # Set binary name to package name if not specified
  if [ -z "$binary_name" ]; then
    binary_name=$package_name
  fi

  # First check if the command already exists
  if command -v "$binary_name" >/dev/null 2>&1; then
    [ "$SILENT" = false ] && [ "$SUPPRESS" = false ] && echo "Package $package_name is already installed"
    return 0
  fi

  # Auto-detect package manager if not specified
  if [ -z "$package_manager" ]; then
    if command -v brew >/dev/null 2>&1; then
      package_manager="brew"
    elif command -v apt >/dev/null 2>&1; then
      package_manager="apt"
    elif command -v pacman >/dev/null 2>&1; then
      package_manager="pacman"
    elif command -v dnf >/dev/null 2>&1; then
      package_manager="dnf"
    else
      echo "Error: Could not detect package manager"
      return 1
    fi
  fi

  # Only install if the command doesn't exist
  install "${FLAGS[@]}" "$package_name" "$binary_name" "$package_manager"
}
