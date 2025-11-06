#!/usr/bin/env bash

###############################################################################
# Install Docker - Container runtime platform
# Supports: macOS, Linux (Ubuntu/Debian, RHEL/CentOS/Fedora, Arch)
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
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    CURRENT_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    log_info "Docker is already installed (version: ${CURRENT_VERSION})"
    read -p "Do you want to reinstall/upgrade? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping Docker installation"
        exit 0
    fi
fi

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
log_info "Detected OS: $OS"

###############################################################################
# macOS Installation
###############################################################################
install_docker_macos() {
    log_step "Installing Docker Desktop for macOS..."
    
    # Check for Homebrew
    if command -v brew &> /dev/null; then
        log_info "Installing Docker Desktop via Homebrew..."
        brew install --cask docker
        
        log_info "✅ Docker Desktop installed via Homebrew!"
        log_warn ""
        log_warn "⚠️  IMPORTANT: Docker Desktop needs to be started manually"
        log_warn "    1. Open Docker Desktop from Applications"
        log_warn "    2. Complete the setup wizard"
        log_warn "    3. Wait for Docker to start (whale icon in menu bar)"
        log_warn ""
        
    else
        log_warn "Homebrew not found. Installing via download..."
        log_info ""
        log_info "Please follow these steps to install Docker Desktop:"
        log_info "  1. Visit: https://www.docker.com/products/docker-desktop/"
        log_info "  2. Download Docker Desktop for Mac (Intel or Apple Silicon)"
        log_info "  3. Open the .dmg file and drag Docker to Applications"
        log_info "  4. Launch Docker Desktop from Applications"
        log_info "  5. Complete the setup wizard"
        log_info ""
        
        read -p "Press Enter when Docker Desktop is installed and running..."
    fi
}

###############################################################################
# Linux Installation
###############################################################################
install_docker_linux() {
    log_step "Installing Docker Engine for Linux..."
    
    # Detect Linux distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION_ID=${VERSION_ID:-}
    else
        log_error "Cannot detect Linux distribution"
        exit 1
    fi
    
    case $DISTRO in
        ubuntu|debian)
            install_docker_debian_based
            ;;
        rhel|centos|fedora|rocky|almalinux)
            install_docker_rhel_based
            ;;
        arch|manjaro)
            install_docker_arch
            ;;
        *)
            log_error "Unsupported Linux distribution: $DISTRO"
            log_info "Please visit https://docs.docker.com/engine/install/ for manual installation"
            exit 1
            ;;
    esac
}

install_docker_debian_based() {
    log_info "Installing Docker on Debian/Ubuntu-based system..."
    
    # Update package index
    log_step "Updating package index..."
    sudo apt-get update -qq
    
    # Install prerequisites
    log_step "Installing prerequisites..."
    sudo apt-get install -y -qq \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    log_step "Adding Docker GPG key..."
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/${DISTRO}/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Set up repository
    log_step "Adding Docker repository..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${DISTRO} \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    log_step "Installing Docker Engine..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
    
    configure_docker_linux
}

install_docker_rhel_based() {
    log_info "Installing Docker on RHEL/CentOS/Fedora-based system..."
    
    # Install prerequisites
    log_step "Installing prerequisites..."
    sudo yum install -y yum-utils
    
    # Add Docker repository
    log_step "Adding Docker repository..."
    sudo yum-config-manager --add-repo https://download.docker.com/linux/${DISTRO}/docker-ce.repo
    
    # Install Docker Engine
    log_step "Installing Docker Engine..."
    sudo yum install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
    
    configure_docker_linux
}

install_docker_arch() {
    log_info "Installing Docker on Arch Linux..."
    
    # Install Docker
    log_step "Installing Docker..."
    sudo pacman -S --noconfirm docker docker-compose
    
    configure_docker_linux
}

configure_docker_linux() {
    # Start and enable Docker service
    log_step "Starting Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Add current user to docker group
    log_step "Adding user to docker group..."
    sudo usermod -aG docker $USER
    
    log_info "✅ Docker Engine installed successfully!"
    log_warn ""
    log_warn "⚠️  IMPORTANT: Please log out and log back in for group changes to take effect"
    log_warn "    Or run: newgrp docker"
    log_warn ""
}

###############################################################################
# Main Installation
###############################################################################

case $OS in
    darwin)
        install_docker_macos
        ;;
    linux)
        install_docker_linux
        ;;
    *)
        log_error "Unsupported operating system: $OS"
        log_info "Please visit https://docs.docker.com/get-docker/ for manual installation"
        exit 1
        ;;
esac

# Verify installation
log_step "Verifying Docker installation..."

# Wait for Docker to be ready (especially on macOS)
MAX_RETRIES=30
RETRY_COUNT=0
while ! docker info &> /dev/null; do
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        log_error "Docker is not responding. Please ensure Docker is running."
        log_info "For macOS: Launch Docker Desktop from Applications"
        log_info "For Linux: Run 'sudo systemctl start docker'"
        exit 1
    fi
    log_info "Waiting for Docker to start... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
    RETRY_COUNT=$((RETRY_COUNT + 1))
done

if docker --version &> /dev/null; then
    INSTALLED_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    log_info "✅ Docker successfully installed and running!"
    log_info "Version: $INSTALLED_VERSION"
    log_info "Location: $(which docker)"
    
    # Test Docker with hello-world
    log_step "Testing Docker installation..."
    if docker run --rm hello-world &> /dev/null; then
        log_info "✅ Docker test successful!"
    else
        log_warn "Docker is installed but test failed. You may need to restart or check permissions."
    fi
    
    # Show Docker Compose version
    if docker compose version &> /dev/null; then
        COMPOSE_VERSION=$(docker compose version --short)
        log_info "Docker Compose version: $COMPOSE_VERSION"
    fi
else
    log_error "Installation verification failed. Docker not found in PATH"
    exit 1
fi

log_info ""
log_info "🎉 Installation complete!"
log_info ""
log_info "Next steps:"
log_info "  • Test Docker: docker run hello-world"
log_info "  • Build an image: docker build -t myapp ."
log_info "  • Run a container: docker run -p 8080:8080 myapp"
log_info "  • Use Docker Compose: docker compose up"
log_info ""
log_info "Documentation: https://docs.docker.com/"
