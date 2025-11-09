#!/usr/bin/env bash

###############################################################################
# Common functions and variables for installation scripts
###############################################################################

# Common variables
INSTALL_DIR="/usr/local/bin"

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
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Detect OS
detect_os() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    log_info "Detected OS: $OS"
}

# Detect OS and architecture
detect_os_arch() {
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
}