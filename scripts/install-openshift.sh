#!/usr/bin/env bash

###############################################################################
# OpenShift CLI (oc) Installation Script
# Installs the latest version of the OpenShift CLI tool
###############################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_section() { echo -e "\n${BLUE}==== $1 ====${NC}\n"; }

log_section "OpenShift CLI (oc) Installation"

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            OS="macOS"
            ;;
        Linux*)
            OS="Linux"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            OS="Windows"
            ;;
        *)
            OS="Unknown"
            ;;
    esac
    log_info "Detected OS: $OS"
}

# Check if oc is already installed
check_existing() {
    if command -v oc &> /dev/null; then
        CURRENT_VERSION=$(oc version --client -o json 2>/dev/null | grep -o '"gitVersion":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
        log_warn "OpenShift CLI is already installed: $CURRENT_VERSION"
        read -p "Do you want to reinstall/upgrade? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
}

# Install on macOS
install_macos() {
    log_info "Installing OpenShift CLI on macOS..."
    
    if command -v brew &> /dev/null; then
        log_info "Using Homebrew..."
        brew install openshift-cli
    else
        log_warn "Homebrew not found. Installing manually..."
        
        # Download latest oc client
        log_info "Downloading latest OpenShift CLI..."
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        # Determine architecture
        if [[ $(uname -m) == "arm64" ]]; then
            ARCH="arm64"
        else
            ARCH="amd64"
        fi
        
        OC_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-mac-${ARCH}.tar.gz"
        
        curl -LO "$OC_URL"
        tar -xzf openshift-client-mac-${ARCH}.tar.gz
        
        # Install to /usr/local/bin
        sudo mv oc /usr/local/bin/
        sudo chmod +x /usr/local/bin/oc
        
        # Install kubectl symlink if it doesn't exist
        if ! command -v kubectl &> /dev/null; then
            sudo mv kubectl /usr/local/bin/ 2>/dev/null || true
            sudo chmod +x /usr/local/bin/kubectl 2>/dev/null || true
        fi
        
        # Cleanup
        cd -
        rm -rf "$TEMP_DIR"
    fi
}

# Install on Linux
install_linux() {
    log_info "Installing OpenShift CLI on Linux..."
    
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Determine architecture
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
    
    OC_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux-${ARCH}.tar.gz"
    
    log_info "Downloading from: $OC_URL"
    curl -LO "$OC_URL"
    tar -xzf openshift-client-linux-${ARCH}.tar.gz
    
    # Install to /usr/local/bin
    sudo mv oc /usr/local/bin/
    sudo chmod +x /usr/local/bin/oc
    
    # Install kubectl symlink if it doesn't exist
    if ! command -v kubectl &> /dev/null; then
        sudo mv kubectl /usr/local/bin/ 2>/dev/null || true
        sudo chmod +x /usr/local/bin/kubectl 2>/dev/null || true
    fi
    
    # Cleanup
    cd -
    rm -rf "$TEMP_DIR"
}

# Install on Windows
install_windows() {
    log_error "Windows installation requires manual steps:"
    echo ""
    echo "1. Download oc.exe from:"
    echo "   https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-windows.zip"
    echo ""
    echo "2. Extract the zip file"
    echo "3. Add the directory to your PATH"
    echo ""
    echo "Or use Chocolatey:"
    echo "   choco install openshift-cli"
    exit 1
}

# Setup completion
setup_completion() {
    log_info "Setting up shell completion..."
    
    case "$SHELL" in
        */bash)
            COMPLETION_DIR="/usr/local/etc/bash_completion.d"
            if [[ ! -d "$COMPLETION_DIR" ]]; then
                sudo mkdir -p "$COMPLETION_DIR"
            fi
            oc completion bash | sudo tee "$COMPLETION_DIR/oc" > /dev/null
            log_info "Bash completion installed. Reload your shell with: source ~/.bashrc"
            ;;
        */zsh)
            COMPLETION_DIR="/usr/local/share/zsh/site-functions"
            if [[ ! -d "$COMPLETION_DIR" ]]; then
                sudo mkdir -p "$COMPLETION_DIR"
            fi
            oc completion zsh | sudo tee "$COMPLETION_DIR/_oc" > /dev/null
            log_info "Zsh completion installed. Reload your shell with: source ~/.zshrc"
            ;;
        *)
            log_warn "Unknown shell. Manual completion setup may be required."
            ;;
    esac
}

# Verify installation
verify_installation() {
    log_section "Verifying Installation"
    
    if command -v oc &> /dev/null; then
        VERSION=$(oc version --client -o json 2>/dev/null | grep -o '"gitVersion":"[^"]*"' | cut -d'"' -f4 || oc version --client 2>/dev/null | head -1 || echo "installed")
        log_info "✅ OpenShift CLI installed successfully"
        log_info "Version: $VERSION"
        
        # Check kubectl compatibility
        if command -v kubectl &> /dev/null; then
            KUBECTL_VERSION=$(kubectl version --client -o json 2>/dev/null | grep -o '"gitVersion":"[^"]*"' | cut -d'"' -f4 || echo "installed")
            log_info "kubectl is also available: $KUBECTL_VERSION"
        fi
        
        return 0
    else
        log_error "❌ OpenShift CLI installation failed"
        return 1
    fi
}

# Display next steps
show_next_steps() {
    log_section "Installation Complete! 🎉"
    
    cat << 'EOF'
OpenShift CLI (oc) is ready to use!

Next Steps:

1. Authenticate with your OpenShift cluster:
   oc login https://api.your-cluster.example.com:6443

   Or get login command from web console:
   - Click your username (top right)
   - Click "Copy login command"
   - Click "Display Token"
   - Copy and paste the oc login command

2. Verify authentication:
   oc whoami
   oc whoami --show-server

3. List your projects:
   oc projects

4. Switch to a project:
   oc project <project-name>

5. Create a new project:
   oc new-project my-project

6. Deploy an application:
   oc new-app python:3.9~https://github.com/your/repo

7. Start learning:
   cd openshift-study/labs
   ./lab1-setup.sh

Common Commands:
   oc get pods              # List pods
   oc get all               # List all resources
   oc logs <pod>            # View logs
   oc describe pod <pod>    # Describe pod
   oc status                # Project status

Resources:
   • OpenShift Docs: https://docs.openshift.com/
   • Learning Portal: https://learn.openshift.com/
   • Study Guide: openshift-study/README.md
   • Interactive Labs: openshift-study/labs/

EOF
}

# Main installation
main() {
    detect_os
    check_existing
    
    case $OS in
        macOS)
            install_macos
            ;;
        Linux)
            install_linux
            ;;
        Windows)
            install_windows
            ;;
        *)
            log_error "Unsupported operating system: $OS"
            exit 1
            ;;
    esac
    
    if verify_installation; then
        setup_completion
        show_next_steps
    else
        log_error "Installation verification failed"
        exit 1
    fi
}

# Run main function
main
