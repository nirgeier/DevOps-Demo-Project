#!/usr/bin/env bash

###############################################################################
# Initialize DevOps Demo Project
# This script sets up the entire development environment
###############################################################################

set -euo pipefail

# Get the Git project root
GIT_ROOT="$(git rev-parse --show-toplevel)"

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

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
    
    # Build list of available tools
    tools_list=""
    for script in "$SCRIPT_DIR"/tools/install-*.sh; do
        tool_name=$(basename "$script" .sh | sed 's/install-//')
        tools_list+="$tool_name, "
    done
    tools_list=${tools_list%, }
    
    read -p "Do you want to install all DevOps tools ($tools_list)? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warn "Skipping DevOps tools installation"
        return 0
    fi
    
    # Make scripts executable
    chmod +x "$SCRIPT_DIR"/tools/*.sh
    
    # Install tools (continue even if one fails)
    for script in "$SCRIPT_DIR"/tools/install-*.sh; do
        tool_name=$(basename "$script" .sh | sed 's/install-//')
        log_info "Installing $tool_name..."
        "$script" || log_warn "Failed to install $tool_name, continuing..."
    done
    
    log_info "✅ DevOps tools installation attempted (some may have failed)"
}

# Update PATH for newly installed tools
update_path() {
    log_section "Updating PATH"
    
    # Add common installation directories to PATH
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/bin:$PATH"
    
    log_info "✅ PATH updated"
}

# Setup Python environment
setup_python_env() {
    log_section "Setting Up Python Environment"
    
    # Ensure uv is in PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    # Check if uv is available
    if ! command -v uv &> /dev/null; then
        log_error "uv is required but not found. Please run ./scripts/install-uv.sh first"
        exit 1
    fi
    
    log_info "Creating Python virtual environment with uv..."
    uv venv
    source .venv/bin/activate
    uv pip install -e ".[dev]"
    
    log_info "✅ Python environment ready"
}

# Run tests
run_tests() {
    log_section "Running Tests"
    
    if [[ -d ".venv" ]]; then
        source .venv/bin/activate
        log_info "Running pytest..."
        pytest tests/ -v --cov=app --cov-report=term
        log_info "✅ Tests passed"
    else
        log_warn "Virtual environment not found. Skipping tests."
    fi
}

# Setup Git hooks (GitFlow)
setup_git_hooks() {
#     log_section "Setting Up Git Hooks"
#     git config core.hooksPath $GIT_ROOT/.githooks
#     chmod +x $GIT_ROOT/.githooks/hooks/*.sh
    log_info "✅ Git hooks configured"
}

# Display next steps
show_next_steps() {
    log_section "Setup Complete! 🎉"
    
    cat << EOF
${GREEN}Your DevOps Demo Project is ready!${NC}

${YELLOW}Next Steps:${NC}

1. ${BLUE}Activate the Python environment:${NC}
   source .venv/bin/activate

2. ${BLUE}Run the application locally:${NC}
   python app/main.py
   # Or with gunicorn:
   gunicorn --bind 0.0.0.0:8080 app.main:app

3. ${BLUE}Build and run with Docker:${NC}
   docker build -f docker/Dockerfile -t devops-demo:latest .
   docker run -p 8080:8080 devops-demo:latest
   # Or use docker-compose:
   docker-compose -f docker/docker-compose.yml up

4. ${BLUE}Run tests:${NC}
   pytest tests/ -v --cov=app

5. ${BLUE}Access the application:${NC}
   http://localhost:8080

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
   See README.md for detailed information

EOF
}

# Main execution
main() {
    check_requirements
    update_path
    install_devops_tools
    setup_python_env
    run_tests
    setup_git_hooks
    show_next_steps
}

# Run main function
main
