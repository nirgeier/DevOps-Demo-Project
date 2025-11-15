#!/usr/bin/env bash

###############################################################################
# Install GitHub CLI (gh)
# This script installs the GitHub CLI tool for macOS, Linux, and Windows
###############################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_section() { echo -e "\n${BLUE}==== $1 ====${NC}\n"; }

# Detect OS
detect_os() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    case "$OS" in
        darwin)
            OS="macos"
            ;;
        linux)
            OS="linux"
            ;;
        mingw*|msys*|cygwin*)
            OS="windows"
            ;;
    esac
    log_info "Detected OS: $OS"
}

# Check if gh is already installed
check_existing() {
    if command -v gh &> /dev/null; then
        CURRENT_VERSION=$(gh --version | head -1)
        log_warn "GitHub CLI is already installed: $CURRENT_VERSION"
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping installation"
            exit 0
        fi
    fi
}

# Install on macOS
install_macos() {
    log_section "Installing GitHub CLI on macOS"
    
    if command -v brew &> /dev/null; then
        log_info "Using Homebrew to install GitHub CLI..."
        brew install gh
    else
        log_error "Homebrew not found. Please install Homebrew first:"
        log_info "Visit: https://brew.sh/"
        exit 1
    fi
}

# Install on Linux
install_linux() {
    log_section "Installing GitHub CLI on Linux"
    
    # Detect Linux distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        log_error "Cannot detect Linux distribution"
        exit 1
    fi
    
    case "$DISTRO" in
        ubuntu|debian)
            log_info "Installing for Debian/Ubuntu..."
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update
            sudo apt install gh -y
            ;;
        fedora|rhel|centos)
            log_info "Installing for Fedora/RHEL/CentOS..."
            sudo dnf install 'dnf-command(config-manager)' -y
            sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
            sudo dnf install gh -y
            ;;
        *)
            log_error "Unsupported Linux distribution: $DISTRO"
            log_info "Please install manually from: https://github.com/cli/cli#installation"
            exit 1
            ;;
    esac
}

# Install on Windows
install_windows() {
    log_error "Please install GitHub CLI manually on Windows"
    log_info "Options:"
    log_info "1. Download from: https://cli.github.com/"
    log_info "2. Or use: winget install --id GitHub.cli"
    log_info "3. Or use: choco install gh"
    exit 1
}

# Verify installation
verify_installation() {
    log_section "Verifying Installation"
    
    if command -v gh &> /dev/null; then
        VERSION=$(gh --version | head -1)
        log_info "✅ GitHub CLI installed successfully!"
        log_info "$VERSION"
        
        echo ""
        log_info "Next steps:"
        echo "  1. Authenticate: gh auth login"
        echo "  2. Check status: gh auth status"
        echo "  3. View help: gh --help"
        echo ""
        log_info "Run './scripts/gh-doctor.sh' for detailed diagnostics"
    else
        log_error "❌ Installation failed - gh command not found"
        exit 1
    fi
}

# Main execution
main() {
    log_section "GitHub CLI Installation"
    
    detect_os
    check_existing
    
    case "$OS" in
        macos)
            install_macos
            ;;
        linux)
            install_linux
            ;;
        windows)
            install_windows
            ;;
        *)
            log_error "Unsupported operating system: $OS"
            exit 1
            ;;
    esac
    
    verify_installation
}

# Run main function
main
