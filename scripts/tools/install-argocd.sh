#!/usr/bin/env bash

###############################################################################
# Install ArgoCD CLI - GitOps continuous delivery tool
# Supports: macOS (Intel/Apple Silicon), Linux (x86_64/ARM64)
###############################################################################

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

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

detect_os_arch

# Get latest stable version
log_info "Fetching latest stable ArgoCD version..."
ARGOCD_VERSION=$(curl -L -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
log_info "Latest stable version: $ARGOCD_VERSION"

# Download ArgoCD CLI
DOWNLOAD_URL="https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-${OS}-${ARCH}"

log_info "Downloading ArgoCD CLI from: $DOWNLOAD_URL"
curl -LO "$DOWNLOAD_URL"

# Install ArgoCD CLI
log_info "Installing ArgoCD CLI..."

# Determine install location
mkdir -p "$INSTALL_DIR"
export PATH="$INSTALL_DIR:$PATH"
rm -f "$INSTALL_DIR/argocd"
mv "argocd-${OS}-${ARCH}" "$INSTALL_DIR/argocd"
chmod +x "$INSTALL_DIR/argocd"

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
