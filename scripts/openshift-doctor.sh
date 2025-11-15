#!/usr/bin/env bash

###############################################################################
# OpenShift CLI Doctor - Comprehensive Diagnostics
# This script performs detailed health checks on OpenShift CLI installation
###############################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Issue counter
ISSUES_FOUND=0

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; ISSUES_FOUND=$((ISSUES_FOUND + 1)); }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; ISSUES_FOUND=$((ISSUES_FOUND + 1)); }
log_section() { echo -e "\n${BLUE}==== $1 ====${NC}\n"; }
log_test() { echo -e "${CYAN}[TEST]${NC} $1"; }

# Check if oc is installed
check_installation() {
    log_section "1. Installation Check"
    
    log_test "Checking if oc command is available..."
    if command -v oc &> /dev/null; then
        log_info "✅ oc command found at: $(which oc)"
    else
        log_error "❌ oc command not found"
        log_info "Install with: ./scripts/install-openshift.sh"
        return 1
    fi
}

# Check version
check_version() {
    log_section "2. Version Information"
    
    log_test "Retrieving OpenShift CLI version..."
    if VERSION=$(oc version --client 2>/dev/null); then
        echo "$VERSION"
        log_info "✅ Version retrieved successfully"
    else
        log_warn "⚠️  Could not retrieve version information"
    fi
}

# Check authentication status
check_auth() {
    log_section "3. Authentication Status"
    
    log_test "Checking if logged into a cluster..."
    if oc whoami &> /dev/null; then
        USER=$(oc whoami 2>/dev/null)
        SERVER=$(oc whoami --show-server 2>/dev/null || echo "unknown")
        log_info "✅ Logged in as: $USER"
        log_info "✅ Server: $SERVER"
    else
        log_warn "⚠️  Not logged into any OpenShift cluster"
        log_info "Login with: oc login <cluster-url>"
    fi
}

# Check current project/namespace
check_project() {
    log_section "4. Current Project"
    
    if oc whoami &> /dev/null; then
        log_test "Checking current project..."
        if PROJECT=$(oc project -q 2>/dev/null); then
            log_info "✅ Current project: $PROJECT"
        else
            log_warn "⚠️  No project selected"
            log_info "Create/select with: oc new-project <name> or oc project <name>"
        fi
    else
        log_warn "⚠️  Not logged in - skipping project check"
    fi
}

# Check cluster access
check_cluster_access() {
    log_section "5. Cluster Access"
    
    if oc whoami &> /dev/null; then
        log_test "Testing cluster API access..."
        if oc get nodes &> /dev/null; then
            NODE_COUNT=$(oc get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
            log_info "✅ Can access cluster - $NODE_COUNT node(s) found"
        else
            log_warn "⚠️  Cannot list nodes (may not have permissions)"
        fi
        
        log_test "Testing project/namespace access..."
        if oc get pods &> /dev/null; then
            POD_COUNT=$(oc get pods --no-headers 2>/dev/null | wc -l | tr -d ' ')
            log_info "✅ Can list pods - $POD_COUNT pod(s) in current project"
        else
            log_warn "⚠️  Cannot list pods in current project"
        fi
    else
        log_warn "⚠️  Not logged in - skipping cluster access checks"
    fi
}

# Check permissions
check_permissions() {
    log_section "6. User Permissions"
    
    if oc whoami &> /dev/null; then
        log_test "Checking if user can create resources..."
        
        # Check if user can create pods
        if oc auth can-i create pods &> /dev/null; then
            log_info "✅ Can create pods"
        else
            log_warn "⚠️  Cannot create pods"
        fi
        
        # Check if user can create projects
        if oc auth can-i create projects &> /dev/null; then
            log_info "✅ Can create projects"
        else
            log_warn "⚠️  Cannot create projects"
        fi
        
        # Check if user is cluster admin
        if oc auth can-i '*' '*' --all-namespaces &> /dev/null; then
            log_info "✅ User has cluster-admin privileges"
        else
            log_info "ℹ️  User does not have cluster-admin privileges (normal)"
        fi
    else
        log_warn "⚠️  Not logged in - skipping permission checks"
    fi
}

# Check configuration
check_config() {
    log_section "7. Configuration"
    
    log_test "Checking kubeconfig location..."
    if [ -n "${KUBECONFIG:-}" ]; then
        log_info "✅ KUBECONFIG set to: $KUBECONFIG"
    else
        log_info "ℹ️  Using default kubeconfig: ~/.kube/config"
    fi
    
    log_test "Checking config file existence..."
    CONFIG_FILE="${KUBECONFIG:-$HOME/.kube/config}"
    if [ -f "$CONFIG_FILE" ]; then
        log_info "✅ Config file exists: $CONFIG_FILE"
        
        # Check file permissions
        PERMS=$(stat -f "%Lp" "$CONFIG_FILE" 2>/dev/null || stat -c "%a" "$CONFIG_FILE" 2>/dev/null)
        if [ "$PERMS" = "600" ] || [ "$PERMS" = "400" ]; then
            log_info "✅ Config file has secure permissions: $PERMS"
        else
            log_warn "⚠️  Config file has insecure permissions: $PERMS (should be 600)"
        fi
    else
        log_warn "⚠️  Config file not found: $CONFIG_FILE"
    fi
}

# Check connectivity
check_connectivity() {
    log_section "8. Network Connectivity"
    
    if oc whoami &> /dev/null; then
        SERVER=$(oc whoami --show-server 2>/dev/null || echo "")
        if [ -n "$SERVER" ]; then
            log_test "Testing connectivity to cluster API..."
            if curl -k -s --connect-timeout 5 "$SERVER" &> /dev/null; then
                log_info "✅ Can reach cluster API server"
            else
                log_warn "⚠️  Cannot reach cluster API server"
            fi
        fi
    else
        log_warn "⚠️  Not logged in - skipping connectivity check"
    fi
}

# Check common issues
check_common_issues() {
    log_section "9. Common Issues Check"
    
    log_test "Checking for certificate issues..."
    if oc whoami &> /dev/null; then
        if oc get nodes 2>&1 | grep -q "certificate"; then
            log_error "❌ Certificate validation errors detected"
            log_info "Try: oc login --insecure-skip-tls-verify <cluster-url>"
        else
            log_info "✅ No certificate issues detected"
        fi
    fi
    
    log_test "Checking for token expiration..."
    if oc whoami &> /dev/null; then
        if oc get pods 2>&1 | grep -q "Unauthorized\|401"; then
            log_error "❌ Authentication token may be expired"
            log_info "Re-login with: oc login <cluster-url>"
        else
            log_info "✅ No token expiration detected"
        fi
    fi
}

# Show helpful commands
show_helpful_commands() {
    log_section "10. Helpful Commands"
    
    cat << EOF
${CYAN}Authentication:${NC}
  oc login <cluster-url>              # Login to cluster
  oc logout                           # Logout from cluster
  oc whoami                          # Show current user
  oc whoami --show-server            # Show cluster URL
  oc whoami --show-token             # Show auth token

${CYAN}Project Management:${NC}
  oc projects                        # List all projects
  oc project <name>                  # Switch to project
  oc new-project <name>              # Create new project
  oc delete project <name>           # Delete project

${CYAN}Resource Management:${NC}
  oc get all                         # List all resources
  oc get pods                        # List pods
  oc get services                    # List services
  oc get routes                      # List routes
  oc describe pod <name>             # Pod details
  oc logs <pod-name>                 # View pod logs
  oc logs -f <pod-name>              # Follow pod logs

${CYAN}Application Deployment:${NC}
  oc new-app <image>                 # Deploy from image
  oc new-app python~<git-url>        # Deploy from source
  oc expose svc/<service-name>       # Create route
  oc scale dc/<name> --replicas=3    # Scale deployment

${CYAN}Troubleshooting:${NC}
  oc status                          # Show project status
  oc get events                      # View cluster events
  oc debug pod/<pod-name>            # Debug pod
  oc port-forward <pod> 8080:8080    # Port forward

${CYAN}Documentation:${NC}
  oc explain pods                    # Explain resource
  oc --help                         # Show help
EOF
}

# Display summary
show_summary() {
    log_section "Summary"
    
    if [ $ISSUES_FOUND -eq 0 ]; then
        echo -e "${GREEN}✅ All checks passed! OpenShift CLI is properly configured.${NC}"
    elif [ $ISSUES_FOUND -le 3 ]; then
        echo -e "${YELLOW}⚠️  Found $ISSUES_FOUND minor issue(s). Review warnings above.${NC}"
    else
        echo -e "${RED}❌ Found $ISSUES_FOUND issue(s). Please review the output above.${NC}"
    fi
    
    echo ""
    log_info "Issues found: $ISSUES_FOUND"
}

# Main execution
main() {
    echo -e "${BLUE}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║          OpenShift CLI - Comprehensive Diagnostics           ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    check_installation || exit 1
    check_version
    check_auth
    check_project
    check_cluster_access
    check_permissions
    check_config
    check_connectivity
    check_common_issues
    show_helpful_commands
    show_summary
}

# Run main function
main
