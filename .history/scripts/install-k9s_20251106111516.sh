#!/usr/bin/env bash

###############################################################################
# Install k9s - Kubernetes CLI To Manage Your Clusters In Style
# Supports: macOS (Intel/Apple Silicon), Linux (x86_64/ARM64)
###############################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if k9s is already installed
if command -v k9s &> /dev/null; then
    CURRENT_VERSION=$(k9s version --short 2>/dev/null | grep Version | awk '{print $2}' || echo "unknown")
    log_info "k9s is already installed (version: ${CURRENT_VERSION})"
    read -p "Do you want to reinstall/upgrade? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping k9s installation"
        exit 0
    fi
fi

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
    arm64)
        ARCH="arm64"
        ;;
    *)
        log_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

log_info "Detected OS: $OS, Architecture: $ARCH"

# Check for package manager installation on macOS
if [[ "$OS" == "darwin" ]] && command -v brew &> /dev/null; then
    log_info "Homebrew detected. Installing k9s via brew..."
    brew install derailed/k9s/k9s
    
    if command -v k9s &> /dev/null; then
        INSTALLED_VERSION=$(k9s version --short 2>/dev/null | grep Version | awk '{print $2}')
        log_info "✅ k9s successfully installed via Homebrew!"
        log_info "Version: $INSTALLED_VERSION"
        log_info "Location: $(which k9s)"
    fi
    exit 0
fi

# Get latest release version from GitHub
log_info "Fetching latest k9s release..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
log_info "Latest version: v$LATEST_VERSION"

# Construct download URL
case $OS in
    darwin)
        PLATFORM="Darwin"
        ;;
    linux)
        PLATFORM="Linux"
        ;;
    *)
        log_error "Unsupported OS: $OS"
        exit 1
        ;;
esac

FILENAME="k9s_${PLATFORM}_${ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/derailed/k9s/releases/download/v${LATEST_VERSION}/${FILENAME}"

log_info "Downloading k9s from: $DOWNLOAD_URL"

TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

cd "$TMP_DIR"
curl -LO "$DOWNLOAD_URL"

# Extract archive
log_info "Extracting archive..."
tar -xzf "$FILENAME"

# Install k9s
log_info "Installing k9s..."
chmod +x k9s

# Determine install location
if [[ "$OS" == "darwin" ]]; then
    INSTALL_DIR="/usr/local/bin"
else
    INSTALL_DIR="${HOME}/.local/bin"
    mkdir -p "$INSTALL_DIR"
fi

# Move to install directory
if [[ -w "$INSTALL_DIR" ]]; then
    mv k9s "$INSTALL_DIR/"
else
    log_warn "Requires sudo to install to $INSTALL_DIR"
    sudo mv k9s "$INSTALL_DIR/"
fi

# Verify installation
if command -v k9s &> /dev/null; then
    INSTALLED_VERSION=$(k9s version --short 2>/dev/null | grep Version | awk '{print $2}')
    log_info "✅ k9s successfully installed!"
    log_info "Version: $INSTALLED_VERSION"
    log_info "Location: $(which k9s)"
    
    log_info ""
    log_info "Usage: Run 'k9s' to start the Kubernetes CLI"
    log_info "  Use ':' to access commands"
    log_info "  Use '?' for help"
    log_info "  Use 'Ctrl+c' to quit"
else
    log_error "Installation failed. k9s not found in PATH"
    log_info "Please add $INSTALL_DIR to your PATH"
    exit 1
fi

log_info ""
log_info "🎉 Installation complete!"
