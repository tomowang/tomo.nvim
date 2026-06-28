#!/usr/bin/env bash

# tomo.nvim - Installer Script
# Works on macOS and Linux. Supports curl pipe and local execution.

set -euo pipefail

REPO_URL="https://github.com/tomowang/tomo.nvim.git"
TARGET_DIR="$HOME/.config/nvim"

# Colors & Formatting (only if stdout is a TTY)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    BOLD=''
    RESET=''
fi

# Print helper functions
info() {
    printf "${BLUE}[INFO]${RESET} %b\n" "$1"
}

success() {
    printf "${GREEN}[SUCCESS]${RESET} %b\n" "$1"
}

warn() {
    printf "${YELLOW}[WARN]${RESET} %b\n" "$1"
}

error() {
    printf "${RED}[ERROR]${RESET} %b\n" "$1"
}

check_mark() {
    printf "${GREEN}✓${RESET} %b\n" "$1"
}

cross_mark() {
    printf "${RED}✗${RESET} %b\n" "$1"
}

warning_mark() {
    printf "${YELLOW}⚠${RESET} %b\n" "$1"
}

# Print logo
show_logo() {
    cat << 'EOF'
  _                             _   _ _ __ ___  
 | |_ ___  _ __ ___   ___      | \ | | | '_ ` _ \ 
 | __/ _ \| '_ ` _ \ / _ \     |  \| | | | | | | |
 | || (_) | | | | | | (_) |    | |\  | | | | | | |
  \__\___/|_| |_| |_|\___/_____|_| \_|_|_| |_| |_|
                        |_____|                   
EOF
    printf "\n${BOLD}Welcome to the tomo.nvim installer!${RESET}\n\n"
}

# Check command existence
check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# Check if fd or fdfind exists
find_fd() {
    if check_cmd fd || check_cmd fdfind; then
        return 0
    else
        return 1
    fi
}

# Compare versions (semver)
# Returns 0 if $1 >= $2, 1 otherwise
version_ge() {
    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i=${#ver1[@]}; i<3; i++)); do
        ver1[i]=0
    done
    for ((i=${#ver2[@]}; i<3; i++)); do
        ver2[i]=0
    done
    for ((i=0; i<3; i++)); do
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 0
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 1
        fi
    done
    return 0
}

# Get OS name
get_os() {
    uname -s
}

# Suggest installation command for missing tools
suggest_install() {
    local tool="$1"
    local os
    os=$(get_os)
    
    case "$os" in
        Darwin)
            case "$tool" in
                nvim) echo "brew install neovim" ;;
                git) echo "brew install git" ;;
                rg) echo "brew install ripgrep" ;;
                make) echo "xcode-select --install" ;;
                compiler) echo "xcode-select --install" ;;
                fd) echo "brew install fd" ;;
            esac
            ;;
        Linux)
            if check_cmd apt-get; then
                case "$tool" in
                    nvim) echo "sudo apt install neovim" ;;
                    git) echo "sudo apt install git" ;;
                    rg) echo "sudo apt install ripgrep" ;;
                    make) echo "sudo apt install build-essential" ;;
                    compiler) echo "sudo apt install build-essential" ;;
                    fd) echo "sudo apt install fd-find" ;;
                esac
            elif check_cmd pacman; then
                case "$tool" in
                    nvim) echo "sudo pacman -S neovim" ;;
                    git) echo "sudo pacman -S git" ;;
                    rg) echo "sudo pacman -S ripgrep" ;;
                    make) echo "sudo pacman -S make" ;;
                    compiler) echo "sudo pacman -S gcc" ;;
                    fd) echo "sudo pacman -S fd" ;;
                esac
            elif check_cmd dnf; then
                case "$tool" in
                    nvim) echo "sudo dnf install neovim" ;;
                    git) echo "sudo dnf install git" ;;
                    rg) echo "sudo dnf install ripgrep" ;;
                    make) echo "sudo dnf install make" ;;
                    compiler) echo "sudo dnf install gcc gcc-c++" ;;
                    fd) echo "sudo dnf install fd-find" ;;
                esac
            else
                case "$tool" in
                    nvim) echo "Install neovim via your package manager or prebuilt binary." ;;
                    git) echo "Install git via your package manager." ;;
                    rg) echo "Install ripgrep (rg) via your package manager." ;;
                    make) echo "Install GNU make via your package manager." ;;
                    compiler) echo "Install gcc or clang via your package manager." ;;
                    fd) echo "Install fd (or fd-find) via your package manager." ;;
                esac
            fi
            ;;
        *)
            echo "Install $tool using your system's package manager."
            ;;
    esac
}

# Verify system dependencies
check_dependencies() {
    local missing_req=0
    local missing_rec=0

    info "Checking system dependencies..."

    # Git
    if check_cmd git; then
        check_mark "git: Installed ($(git --version | head -n1))"
    else
        cross_mark "git: Not found (Required for cloning plugins)"
        missing_req=$((missing_req + 1))
    fi

    # Neovim
    if check_cmd nvim; then
        local nvim_ver_str
        nvim_ver_str=$(nvim --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)
        if [ -n "$nvim_ver_str" ]; then
            if version_ge "$nvim_ver_str" "0.8.0"; then
                check_mark "neovim: Installed (v$nvim_ver_str >= 0.8.0)"
            else
                cross_mark "neovim: Installed (v$nvim_ver_str) but version >= 0.8.0 is required."
                missing_req=$((missing_req + 1))
            fi
        else
            warning_mark "neovim: Installed but could not determine version."
        fi
    else
        cross_mark "neovim: Not found (Required editor)"
        missing_req=$((missing_req + 1))
    fi

    # C Compiler
    local compiler=""
    if check_cmd gcc; then
        compiler="gcc"
    elif check_cmd clang; then
        compiler="clang"
    fi

    if [ -n "$compiler" ]; then
        check_mark "C Compiler: Installed ($compiler) (Required for compiling Treesitter parsers and Telescope FZF)"
    else
        warning_mark "C Compiler (gcc/clang): Not found (Required for compiling Treesitter parsers and Telescope FZF)"
        missing_rec=$((missing_rec + 1))
    fi

    # Make
    if check_cmd make; then
        check_mark "make: Installed (Required for compiling Telescope FZF)"
    else
        warning_mark "make: Not found (Required for compiling Telescope FZF)"
        missing_rec=$((missing_rec + 1))
    fi

    # Ripgrep
    if check_cmd rg; then
        check_mark "ripgrep (rg): Installed (Required for Telescope search)"
    else
        warning_mark "ripgrep (rg): Not found (Required for Telescope search)"
        missing_rec=$((missing_rec + 1))
    fi

    # FD
    if find_fd; then
        local fd_cmd="fd"
        if check_cmd fdfind; then
            fd_cmd="fdfind"
        fi
        check_mark "fd: Installed ($fd_cmd) (Recommended for Telescope file finding)"
    else
        warning_mark "fd/fdfind: Not found (Recommended for Telescope file finding)"
        missing_rec=$((missing_rec + 1))
    fi

    # Handle missing required dependencies
    if [ "$missing_req" -gt 0 ]; then
        echo ""
        error "Missing required dependencies. Please install them and run the script again."
        echo ""
        echo "Suggestions for installation:"
        if ! check_cmd git; then
            echo "  Git: $(suggest_install git)"
        fi
        if ! check_cmd nvim; then
            echo "  Neovim: $(suggest_install nvim)"
        fi
        exit 1
    fi

    # Handle missing recommended dependencies
    if [ "$missing_rec" -gt 0 ]; then
        echo ""
        warn "Some recommended dependencies are missing. Neovim will still work, but some features might be limited."
        echo "Suggestions for installation:"
        if [ -z "$compiler" ]; then
            echo "  C Compiler: $(suggest_install compiler)"
        fi
        if ! check_cmd make; then
            echo "  Make: $(suggest_install make)"
        fi
        if ! check_cmd rg; then
            echo "  Ripgrep: $(suggest_install rg)"
        fi
        if ! find_fd; then
            echo "  FD: $(suggest_install fd)"
        fi
        echo ""
    fi
}

# Main installer execution
main() {
    show_logo
    
    # 1. Dependency checks
    check_dependencies

    # 2. Detect local vs remote installation
    local is_local=false
    if [ -f "init.lua" ] && [ -d "lua" ] && [ -d ".git" ]; then
        local current_remote
        current_remote=$(git remote get-url origin 2>/dev/null || true)
        if [[ "$current_remote" == *"tomowang/tomo.nvim"* ]]; then
            is_local=true
        fi
    fi

    # 3. Detect edge case: Running installer from inside the target directory itself
    local real_target
    local real_pwd
    real_target=$(realpath "$TARGET_DIR" 2>/dev/null || readlink -f "$TARGET_DIR" 2>/dev/null || echo "$TARGET_DIR")
    real_pwd=$(pwd -P 2>/dev/null || pwd)

    if [ "$real_target" = "$real_pwd" ]; then
        info "Running installer from inside target directory ($TARGET_DIR)."
        info "Skipping copying/cloning. Proceeding to bootstrap plugins..."
    else
        # Make sure parent directory exists
        mkdir -p "$(dirname "$TARGET_DIR")"

        # Check if target directory already exists
        if [ -d "$TARGET_DIR" ] || [ -L "$TARGET_DIR" ]; then
            local is_tomo_repo=false
            if [ -d "$TARGET_DIR/.git" ]; then
                local remote_url
                remote_url=$(git -C "$TARGET_DIR" remote get-url origin 2>/dev/null || true)
                if [[ "$remote_url" == *"tomowang/tomo.nvim"* ]]; then
                    is_tomo_repo=true
                fi
            fi

            if [ "$is_tomo_repo" = true ]; then
                info "Existing tomo.nvim configuration detected at $TARGET_DIR. Updating..."
                if git -C "$TARGET_DIR" pull; then
                    success "Successfully updated the configuration in $TARGET_DIR."
                else
                    error "Failed to update target repository using 'git pull'."
                    exit 1
                fi
            else
                warn "Target directory '$TARGET_DIR' already exists and is not a clone of tomo.nvim."
                printf "${BOLD}Would you like to back it up and overwrite it? [y/N]: ${RESET}"
                
                # Read response from /dev/tty (handles piping to bash)
                local response
                read -r response < /dev/tty
                
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    local backup_dir="${TARGET_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
                    info "Backing up existing configuration to $backup_dir..."
                    if mv "$TARGET_DIR" "$backup_dir"; then
                        success "Backup created successfully."
                    else
                        error "Failed to back up directory. Aborting."
                        exit 1
                    fi
                else
                    error "Installation aborted by user."
                    exit 1
                fi
            fi
        fi

        # Install files if target directory doesn't exist now
        if [ ! -d "$TARGET_DIR" ]; then
            if [ "$is_local" = true ]; then
                info "Copying files from local repository to $TARGET_DIR..."
                mkdir -p "$TARGET_DIR"
                for item in init.lua lazy-lock.json lua LICENSE README.md; do
                    if [ -e "$item" ]; then
                        cp -R "$item" "$TARGET_DIR/"
                    fi
                done
                if [ -d ".git" ]; then
                    cp -R .git "$TARGET_DIR/"
                fi
                success "Successfully copied local configuration."
            else
                info "Cloning tomo.nvim repository from GitHub..."
                if git clone "$REPO_URL" "$TARGET_DIR"; then
                    success "Successfully cloned configuration to $TARGET_DIR."
                else
                    error "Failed to clone repository from $REPO_URL."
                    exit 1
                fi
            fi
        fi
    fi

    # 4. Ask to pre-install plugins headlessly
    printf "\n${BOLD}Would you like to install Neovim plugins now? [Y/n]: ${RESET}"
    local install_plugins
    read -r install_plugins < /dev/tty
    
    if [[ ! "$install_plugins" =~ ^[Nn]$ ]]; then
        info "Installing plugins and treesitter parsers (this may take a minute)..."
        # Run nvim headlessly to bootstrap lazy.nvim and trigger Lazy sync
        if nvim --headless "+Lazy! sync" +qa; then
            success "All plugins and parser dependencies installed successfully!"
        else
            warn "Some errors occurred during headless installation. Run 'nvim' to finish installing interactively."
        fi
    else
        info "Skipping automatic plugin installation. They will install automatically the first time you run 'nvim'."
    fi

    # Post-install notice
    printf "\n"
    success "tomo.nvim installation complete!"
    echo "--------------------------------------------------------"
    echo "  - To start using it, run: nvim"
    echo "  - To check health of your setup in Neovim, run: :checkhealth"
    echo "  - We highly recommend installing a Nerd Font to display icons."
    echo "--------------------------------------------------------"
}

main "$@"
