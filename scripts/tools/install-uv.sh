#!/usr/bin/env bash

###############################################################################
# Install uv - An extremely fast Python package installer and resolver
# Supports: macOS, Linux, Windows (WSL)
###############################################################################

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Check if uv is already installed
if command -v uv &> /dev/null; then
    CURRENT_VERSION=$(uv --version 2>/dev/null | awk '{print $2}' || echo "unknown")
    log_info "uv is already installed (version: ${CURRENT_VERSION})"
    read -p "Do you want to reinstall/upgrade? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping uv installation"
        exit 0
    fi
fi

detect_os

# Check for package manager installation on macOS
if [[ "$OS" == "darwin" ]] && command -v brew &> /dev/null; then
    log_info "Homebrew detected. Installing uv via brew..."
    brew install uv
    
    if command -v uv &> /dev/null; then
        INSTALLED_VERSION=$(uv --version | awk '{print $2}')
        log_info "✅ uv successfully installed via Homebrew!"
        log_info "Version: $INSTALLED_VERSION"
        log_info "Location: $(which uv)"
    fi
    exit 0
fi

# Use official installation script for other systems
log_info "Using official uv installation script..."

curl -LsSf https://astral.sh/uv/install.sh | sh

# Source the shell configuration to update PATH
source $HOME/.local/bin/env 2>/dev/null || true

# Verify installation
if command -v uv &> /dev/null; then
    INSTALLED_VERSION=$(uv --version | awk '{print $2}')
    log_info "✅ uv successfully installed!"
    log_info "Version: $INSTALLED_VERSION"
    log_info "Location: $(which uv)"
    
    log_info ""
    log_info "Common uv commands:"
    log_info "  uv pip install <package>  - Install a package"
    log_info "  uv pip list                - List installed packages"
    log_info "  uv venv                    - Create a virtual environment"
    log_info "  uv --help                  - Show help"
else
    log_error "Installation failed. uv not found in PATH"
    log_warn "You may need to restart your shell or run:"
    log_warn "  export PATH=\"\$HOME/.cargo/bin:\$PATH\""
    exit 1
fi

log_info ""
log_info "🎉 Installation complete!"
log_info "Note: You may need to restart your shell for changes to take effect."
