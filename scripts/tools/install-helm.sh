#!/usr/bin/env bash

###############################################################################
# Install Helm - Kubernetes package manager
# Supports: macOS, Linux
###############################################################################

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Check if Helm is already installed
if command -v helm &> /dev/null; then
    CURRENT_VERSION=$(helm version --short 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    log_info "Helm is already installed (version: ${CURRENT_VERSION})"
    read -p "Do you want to reinstall/upgrade? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping Helm installation"
        exit 0
    fi
fi

detect_os

# Check for package manager installation on macOS
if [[ "$OS" == "darwin" ]] && command -v brew &> /dev/null; then
    log_info "Homebrew detected. Installing Helm via brew..."
    brew install helm
    
    if command -v helm &> /dev/null; then
        INSTALLED_VERSION=$(helm version --short 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')
        log_info "✅ Helm successfully installed via Homebrew!"
        log_info "Version: $INSTALLED_VERSION"
        log_info "Location: $(which helm)"
    fi
    exit 0
fi

# Use official installation script
log_info "Using official Helm installation script..."

# Set custom install directory to avoid sudo
export HELM_INSTALL_DIR="$INSTALL_DIR"
export PATH="$INSTALL_DIR:$PATH"
mkdir -p "$HELM_INSTALL_DIR"

TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

cd "$TMP_DIR"
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o get_helm.sh
chmod 700 get_helm.sh

# Run installation script
./get_helm.sh

# Verify installation
if command -v helm &> /dev/null; then
    INSTALLED_VERSION=$(helm version --short 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')
    log_info "✅ Helm successfully installed!"
    log_info "Version: $INSTALLED_VERSION"
    log_info "Location: $(which helm)"
    
    # Setup helm completion (optional)
    log_info ""
    log_info "To enable Helm autocompletion, add this to your shell profile:"
    log_info "  For bash: source <(helm completion bash)"
    log_info "  For zsh: source <(helm completion zsh)"
    
    # Add common repositories
    log_info ""
    read -p "Do you want to add common Helm repositories? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Adding stable repository..."
        helm repo add stable https://charts.helm.sh/stable || true
        log_info "Adding bitnami repository..."
        helm repo add bitnami https://charts.bitnami.com/bitnami || true
        log_info "Updating repositories..."
        helm repo update
        log_info "✅ Repositories added and updated!"
    fi
else
    log_error "Installation failed. Helm not found in PATH"
    exit 1
fi

log_info ""
log_info "🎉 Installation complete!"
