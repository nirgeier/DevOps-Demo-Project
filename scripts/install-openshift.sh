#!/usr/bin/env bash

###############################################################################
# Install OpenShift CLI (oc)
# This script installs the OpenShift CLI tool for macOS, Linux, and Windows
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

# Detect OS and architecture
detect_platform() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    case "$OS" in
        darwin)
            OS="mac"
            ;;
        linux)
            OS="linux"
            ;;
        mingw*|msys*|cygwin*)
            OS="windows"
            ;;
    esac
    
    case "$ARCH" in
        x86_64|amd64)
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
    
    log_info "Detected platform: $OS-$ARCH"
}

# Check if oc is already installed
check_existing() {
    if command -v oc &> /dev/null; then
        CURRENT_VERSION=$(oc version --client 2>/dev/null | grep "Client Version" | awk '{print $3}' || echo "unknown")
        log_warn "OpenShift CLI is already installed: $CURRENT_VERSION"
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping installation"
            exit 0
        fi
    fi
}

# Install on macOS using Homebrew
install_macos() {
    log_section "Installing OpenShift CLI on macOS"
    
    if command -v brew &> /dev/null; then
        log_info "Using Homebrew to install OpenShift CLI..."
        brew install openshift-cli
    else
        log_info "Homebrew not found. Installing from source..."
        install_from_source
    fi
}

# Install on Linux
install_linux() {
    log_section "Installing OpenShift CLI on Linux"
    install_from_source
}

# Install from source (cross-platform)
install_from_source() {
    log_info "Installing OpenShift CLI from official source..."
    
    # Create temporary directory
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
    
    # Download URL (using stable version)
    BASE_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable"
    
    case "$OS" in
        mac)
            if [ "$ARCH" = "arm64" ]; then
                FILE="openshift-client-mac-arm64.tar.gz"
            else
                FILE="openshift-client-mac.tar.gz"
            fi
            ;;
        linux)
            if [ "$ARCH" = "arm64" ]; then
                FILE="openshift-client-linux-arm64.tar.gz"
            else
                FILE="openshift-client-linux.tar.gz"
            fi
            ;;
        windows)
            FILE="openshift-client-windows.zip"
            ;;
    esac
    
    log_info "Downloading from $BASE_URL/$FILE..."
    
    if ! curl -LO "$BASE_URL/$FILE"; then
        log_error "Failed to download OpenShift CLI"
        cd - > /dev/null
        rm -rf "$TMP_DIR"
        exit 1
    fi
    
    # Extract
    log_info "Extracting..."
    if [[ "$FILE" == *.tar.gz ]]; then
        tar -xzf "$FILE"
    elif [[ "$FILE" == *.zip ]]; then
        unzip "$FILE"
    fi
    
    # Install to /usr/local/bin
    log_info "Installing to /usr/local/bin..."
    if [ -w /usr/local/bin ]; then
        mv oc /usr/local/bin/
        chmod +x /usr/local/bin/oc
    else
        sudo mv oc /usr/local/bin/
        sudo chmod +x /usr/local/bin/oc
    fi
    
    # Also install kubectl if present
    if [ -f kubectl ]; then
        if [ -w /usr/local/bin ]; then
            mv kubectl /usr/local/bin/
            chmod +x /usr/local/bin/kubectl
        else
            sudo mv kubectl /usr/local/bin/
            sudo chmod +x /usr/local/bin/kubectl
        fi
    fi
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$TMP_DIR"
}

# Verify installation
verify_installation() {
    log_section "Verifying Installation"
    
    if command -v oc &> /dev/null; then
        VERSION=$(oc version --client 2>/dev/null | grep "Client Version" | awk '{print $3}' || echo "unknown")
        log_info "✅ OpenShift CLI installed successfully!"
        log_info "Version: $VERSION"
        
        # Show basic help
        echo ""
        log_info "Quick start:"
        echo "  oc login <cluster-url>        # Login to OpenShift cluster"
        echo "  oc new-project <name>         # Create new project"
        echo "  oc get all                    # View all resources"
        echo "  oc --help                     # Show help"
        echo ""
        log_info "Run './scripts/openshift-doctor.sh' for detailed diagnostics"
    else
        log_error "❌ Installation failed - oc command not found"
        exit 1
    fi
}

# Main execution
main() {
    log_section "OpenShift CLI Installation"
    
    detect_platform
    check_existing
    
    case "$OS" in
        mac)
            install_macos
            ;;
        linux)
            install_linux
            ;;
        windows)
            log_error "Please install OpenShift CLI manually on Windows"
            log_info "Download from: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/"
            exit 1
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
