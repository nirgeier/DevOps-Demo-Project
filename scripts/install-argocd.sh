#!/usr/bin/env bash

###############################################################################
# Install ArgoCD CLI - GitOps continuous delivery tool
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

# Check if ArgoCD CLI is already installed
if command -v argocd &> /dev/null; then
    CURRENT_VERSION=$(argocd version --client --short 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    log_info "ArgoCD CLI is already installed (version: ${CURRENT_VERSION})"
    read -p "Do you want to reinstall/upgrade? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping ArgoCD CLI installation"
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
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        log_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

log_info "Detected OS: $OS, Architecture: $ARCH"

# Get latest stable version
log_info "Fetching latest stable ArgoCD version..."
ARGOCD_VERSION=$(curl -L -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
log_info "Latest stable version: $ARGOCD_VERSION"

# Download ArgoCD CLI
DOWNLOAD_URL="https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-${OS}-${ARCH}"
log_info "Downloading ArgoCD CLI from: $DOWNLOAD_URL"

TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

curl -L "$DOWNLOAD_URL" -o "$TMP_DIR/argocd"

# Install ArgoCD CLI
log_info "Installing ArgoCD CLI..."
chmod +x "$TMP_DIR/argocd"

# Determine install location
if [[ "$OS" == "darwin" ]]; then
    INSTALL_DIR="/usr/local/bin"
else
    INSTALL_DIR="${HOME}/.local/bin"
    mkdir -p "$INSTALL_DIR"
fi

# Move to install directory
if [[ -w "$INSTALL_DIR" ]]; then
    mv "$TMP_DIR/argocd" "$INSTALL_DIR/"
else
    log_warn "Requires sudo to install to $INSTALL_DIR"
    sudo mv "$TMP_DIR/argocd" "$INSTALL_DIR/"
fi

# Verify installation
if command -v argocd &> /dev/null; then
    INSTALLED_VERSION=$(argocd version --client --short 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "installed")
    log_info "✅ ArgoCD CLI successfully installed!"
    log_info "Version: $INSTALLED_VERSION"
    log_info "Location: $(which argocd)"
    
    # Setup ArgoCD CLI completion (optional)
    log_info ""
    log_info "To enable ArgoCD CLI autocompletion, add this to your shell profile:"
    log_info "  For bash: source <(argocd completion bash)"
    log_info "  For zsh: source <(argocd completion zsh)"
    
    # Show common commands
    log_info ""
    log_info "Common ArgoCD CLI commands:"
    log_info "  argocd login <server>           - Login to ArgoCD server"
    log_info "  argocd app list                 - List applications"
    log_info "  argocd app get <app>            - Get application details"
    log_info "  argocd app sync <app>           - Sync application"
    log_info "  argocd app history <app>        - Show deployment history"
else
    log_error "Installation failed. ArgoCD CLI not found in PATH"
    log_info "Please add $INSTALL_DIR to your PATH"
    exit 1
fi

log_info ""
log_info "🎉 Installation complete!"
log_info ""
log_info "Next steps:"
log_info "  1. Install ArgoCD in your Kubernetes cluster:"
log_info "     kubectl create namespace argocd"
log_info "     kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
log_info ""
log_info "  2. Access ArgoCD UI:"
log_info "     kubectl port-forward svc/argocd-server -n argocd 8080:443"
log_info ""
log_info "  3. Get admin password:"
log_info "     kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
log_info ""
log_info "  4. Login with CLI:"
log_info "     argocd login localhost:8080"
log_info ""
log_info "Documentation: https://argo-cd.readthedocs.io/"
