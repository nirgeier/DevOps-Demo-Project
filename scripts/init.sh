#!/usr/bin/env bash

###############################################################################
# Initialize DevOps Demo Project
# This script sets up the entire development environment
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

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

log_section "DevOps Demo Project - Initialization"

# Check for required tools
check_requirements() {
    log_section "Checking Requirements"
    
    local missing_tools=()
    
    # Check for basic tools
    for tool in git curl; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=($tool)
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_error "Please install them before continuing"
        exit 1
    fi
    
    log_info "✅ Basic requirements satisfied"
}

# Install DevOps tools
install_devops_tools() {
    log_section "Installing DevOps Tools"
    
    read -p "Do you want to install kubectl, helm, k9s, gh, uv, Docker, and ArgoCD CLI? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warn "Skipping DevOps tools installation"
        return 0
    fi
    
    # Make scripts executable
    chmod +x "$SCRIPT_DIR"/*.sh
    
    # Install uv (Python package manager)
    log_info "Installing uv..."
    "$SCRIPT_DIR/install-uv.sh"
    
    # Install Docker
    log_info "Installing Docker..."
    "$SCRIPT_DIR/install-docker.sh"
    
    # Install kubectl
    log_info "Installing kubectl..."
    "$SCRIPT_DIR/install-kubectl.sh"
    
    # Install helm
    log_info "Installing helm..."
    "$SCRIPT_DIR/install-helm.sh"
    
    # Install k9s
    log_info "Installing k9s..."
    "$SCRIPT_DIR/install-k9s.sh"
    
    # Install GitHub CLI
    log_info "Installing GitHub CLI (gh)..."
    "$SCRIPT_DIR/install-gh.sh"
    
    # Install OpenShift CLI (optional)
    read -p "Do you want to install OpenShift CLI (oc)? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installing OpenShift CLI..."
        "$SCRIPT_DIR/install-openshift.sh"
    fi
    
    # Install ArgoCD CLI (optional)
    read -p "Do you want to install ArgoCD CLI? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installing ArgoCD CLI..."
        "$SCRIPT_DIR/install-argocd.sh"
    fi
    
    log_info "✅ DevOps tools installed"
}

# Setup Python environment
setup_python_env() {
    log_section "Setting Up Python Environment"
    
    # Check if uv is available
    if ! command -v uv &> /dev/null; then
        log_warn "uv not found. Attempting to use pip instead..."
        
        # Create virtual environment with standard tools
        if ! command -v python3 &> /dev/null; then
            log_error "Python 3 is required but not found"
            exit 1
        fi
        
        python3 -m venv .venv
        # Cross-platform activation
        if [[ -f ".venv/bin/activate" ]]; then
            source .venv/bin/activate
        elif [[ -f ".venv/Scripts/activate" ]]; then
            source .venv/Scripts/activate
        fi
        pip install --upgrade pip
        pip install -e ".[dev]"
    else
        log_info "Creating Python virtual environment with uv..."
        uv venv
        # Cross-platform activation
        if [[ -f ".venv/bin/activate" ]]; then
            source .venv/bin/activate
        elif [[ -f ".venv/Scripts/activate" ]]; then
            source .venv/Scripts/activate
        fi
        uv pip install -e ".[dev]"
    fi
    
    log_info "✅ Python environment ready"
}

# Run tests
run_tests() {
    log_section "Running Tests"
    
    # Cross-platform activation check
    if [[ -f ".venv/bin/activate" ]]; then
        source .venv/bin/activate
        log_info "Running pytest..."
        pytest tests/ -v --cov=app --cov-report=term
        log_info "✅ Tests passed"
    elif [[ -f ".venv/Scripts/activate" ]]; then
        source .venv/Scripts/activate
        log_info "Running pytest..."
        pytest tests/ -v --cov=app --cov-report=term
        log_info "✅ Tests passed"
    else
        log_warn "Virtual environment not found. Skipping tests."
    fi
}

# Setup Git hooks (GitFlow)
setup_git_hooks() {
    log_section "Setting Up Git Hooks"
    
    mkdir -p .git/hooks
    
    # Pre-commit hook
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Run tests before commit
if [[ -d ".venv" ]]; then
    # Cross-platform activation
    if [[ -f ".venv/bin/activate" ]]; then
        source .venv/bin/activate
    elif [[ -f ".venv/Scripts/activate" ]]; then
        source .venv/Scripts/activate
    fi
    pytest tests/ -q || exit 1
fi
EOF
    
    chmod +x .git/hooks/pre-commit
    log_info "✅ Git hooks configured"
}

# Display next steps
show_next_steps() {
    log_section "Setup Complete! 🎉"
    
    cat << EOF
${GREEN}Your DevOps Demo Project is ready!${NC}

${YELLOW}Next Steps:${NC}

1. ${BLUE}Activate the Python environment:${NC}
   # On Unix/macOS/Linux:
   source .venv/bin/activate
   # On Windows (Git Bash):
   source .venv/Scripts/activate
   # On Windows (PowerShell):
   .venv\Scripts\Activate.ps1

2. ${BLUE}Verify your setup:${NC}
   ./scripts/doctor.sh              # Quick health check all tools
   ./scripts/verify-setup.sh        # Comprehensive verification

3. ${BLUE}Run the application locally:${NC}
   python app/main.py
   # Or with gunicorn:
   gunicorn --bind 0.0.0.0:8080 app.main:app

4. ${BLUE}Build and run with Docker:${NC}
   docker build -f docker/Dockerfile -t devops-demo:latest .
   docker run -p 8080:8080 devops-demo:latest
   # Or use docker-compose:
   docker-compose -f docker/docker-compose.yml up

5. ${BLUE}Run tests:${NC}
   pytest tests/ -v --cov=app

6. ${BLUE}Access the application:${NC}
   http://localhost:8080

${YELLOW}DevOps Tools Quick Check:${NC}
   ./scripts/doctor.sh                # All tools
   ./scripts/doctor.sh gh             # GitHub CLI only
   ./scripts/doctor.sh oc             # OpenShift CLI only
   ./scripts/doctor.sh quick          # Essential tools only

${YELLOW}GitHub CLI Quick Start:${NC}
   gh auth login                      # Authenticate with GitHub
   gh repo view                       # View repository info
   ./scripts/gh-doctor.sh             # Detailed diagnostics
   ./scripts/gh-create-pr.sh          # Create PR from current branch
   ./scripts/gh-release.sh 1.0.0      # Create new release
   cd gh-study/labs && ./lab1-setup.sh  # Start GitHub CLI labs

${YELLOW}OpenShift CLI Quick Start (if installed):${NC}
   oc login <server-url>              # Authenticate with OpenShift
   oc new-project my-project          # Create new project
   oc new-app python:3.9~<repo>       # Deploy from source
   oc get all                         # View all resources
   ./scripts/openshift-doctor.sh      # Detailed diagnostics
   cd openshift-study/labs && ./lab1-setup.sh  # Start OpenShift labs

${YELLOW}Available Endpoints:${NC}
   GET  /              - Welcome message
   GET  /health        - Health check
   GET  /ready         - Readiness check
   GET  /api/info      - Application info
   POST /api/echo      - Echo endpoint

${YELLOW}GitFlow Branches:${NC}
   - main       : Production-ready code
   - develop    : Integration branch
   - feature/*  : New features
   - release/*  : Release preparation
   - hotfix/*   : Production fixes

${YELLOW}Documentation:${NC}
   • Main README:           README.md
   • GitHub CLI Guide:      gh-study/README.md
   • OpenShift Guide:       openshift-study/README.md
   • Project Improvements:  PROJECT_IMPROVEMENTS.md
   • Quick References:      gh-study/QUICKSTART.md
                            openshift-study/QUICKSTART.md

EOF
}

# Main execution
main() {
    check_requirements
    install_devops_tools
    setup_python_env
    run_tests
    setup_git_hooks
    show_next_steps
}

# Run main function
main
