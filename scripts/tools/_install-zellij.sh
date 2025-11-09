#!/usr/bin/env bash

###############################################################################
# Install Zellij - A terminal workspace with batteries included
# Supports: macOS (Intel/Apple Silicon), Linux (x86_64/ARM64)
###############################################################################

set -euo pipefail

# Source shared logging and color definitions
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
# Check if zellij is already installed
if command -v zellij &> /dev/null; then
    CURRENT_VERSION=$(zellij --version 2>/dev/null | awk '{print $2}' || echo "unknown")
    log_info "zellij is already installed (version: ${CURRENT_VERSION})"
    read -p "Do you want to reinstall/upgrade? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping zellij installation"
        exit 0
    fi
fi

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $ARCH in
    x86_64)
        ARCH="amd64"
        ARCH_NAME="x86_64"
        ;;
    aarch64)
        ARCH="arm64"
        ARCH_NAME="aarch64"
        ;;
    arm64)
        ARCH="arm64"
        ARCH_NAME="aarch64"
        ;;
    *)
        log_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

log_info "Detected OS: $OS, Architecture: $ARCH"

# Check for package manager installation on macOS
if [[ "$OS" == "darwin" ]] && command -v brew &> /dev/null; then
    log_info "Homebrew detected. Installing zellij via brew..."
    brew install zellij
    
    if command -v zellij &> /dev/null; then
        INSTALLED_VERSION=$(zellij --version 2>/dev/null | awk '{print $2}')
        log_info "✅ zellij successfully installed via Homebrew!"
        log_info "Version: $INSTALLED_VERSION"
        log_info "Location: $(which zellij)"
    fi
    exit 0
fi

# Get latest release version from GitHub
log_info "Fetching latest zellij release..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
log_info "Latest version: v$LATEST_VERSION"

# Construct download URL
case $OS in
    darwin)
        TARGET="apple-darwin"
        ;;
    linux)
        TARGET="unknown-linux-musl"
        ;;
    *)
        log_error "Unsupported OS: $OS"
        exit 1
        ;;
esac

FILENAME="zellij-${ARCH_NAME}-${TARGET}.tar.gz"
DOWNLOAD_URL="https://github.com/zellij-org/zellij/releases/download/v${LATEST_VERSION}/${FILENAME}"

log_info "Downloading zellij from: $DOWNLOAD_URL"
curl -LO "$DOWNLOAD_URL"

# Extract archive
log_info "Extracting archive..."
tar -xzf "$FILENAME"

# Install zellij
log_info "Installing zellij..."
chmod +x zellij

# Determine install location
if [[ "$OS" == "darwin" ]]; then
    INSTALL_DIR="/usr/local/bin"
else
    INSTALL_DIR="${HOME}/.local/bin"
    mkdir -p "$INSTALL_DIR"
fi

# Move to install directory
if [[ -w "$INSTALL_DIR" ]]; then
    mv zellij "$INSTALL_DIR/"
else
    log_warn "Requires sudo to install to $INSTALL_DIR"
    sudo mv zellij "$INSTALL_DIR/"
fi

# Verify installation
if command -v zellij &> /dev/null; then
    INSTALLED_VERSION=$(zellij --version 2>/dev/null | awk '{print $2}')
    log_info "✅ zellij successfully installed!"
    log_info "Version: $INSTALLED_VERSION"
    log_info "Location: $(which zellij)"
    
    log_info ""
    log_info "Usage: Run 'zellij' to start the terminal multiplexer"
    log_info "  Use 'Ctrl+t' for commands"
    log_info "  Use 'Ctrl+t ?' for help"
    log_info "  Use 'Ctrl+t d' to detach"
else
    log_error "Installation failed. zellij not found in PATH"
    log_info "Please add $INSTALL_DIR to your PATH"
    exit 1
fi

log_info ""
log_info "🎉 Installation complete!"