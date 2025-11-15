#!/usr/bin/env bash

###############################################################################
# GitHub CLI Doctor - Comprehensive Diagnostics
# This script performs detailed health checks on GitHub CLI installation
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

# Check if gh is installed
check_installation() {
    log_section "1. Installation Check"
    
    log_test "Checking if gh command is available..."
    if command -v gh &> /dev/null; then
        log_info "✅ gh command found at: $(which gh)"
    else
        log_error "❌ gh command not found"
        log_info "Install with: ./scripts/install-gh.sh"
        return 1
    fi
}

# Check version
check_version() {
    log_section "2. Version Information"
    
    log_test "Retrieving GitHub CLI version..."
    if VERSION=$(gh --version 2>/dev/null); then
        echo "$VERSION"
        log_info "✅ Version retrieved successfully"
        
        # Check if version is recent
        CURRENT_VERSION=$(echo "$VERSION" | grep "gh version" | awk '{print $3}')
        log_info "Current version: $CURRENT_VERSION"
    else
        log_warn "⚠️  Could not retrieve version information"
    fi
}

# Check authentication status
check_auth() {
    log_section "3. Authentication Status"
    
    log_test "Checking authentication status..."
    if gh auth status &> /dev/null; then
        log_info "✅ Authenticated with GitHub"
        
        # Show auth status details
        AUTH_INFO=$(gh auth status 2>&1)
        echo "$AUTH_INFO" | grep -E "Logged in|account|Token"
        
        # Check scopes
        log_test "Checking authentication scopes..."
        if echo "$AUTH_INFO" | grep -q "repo"; then
            log_info "✅ Has 'repo' scope"
        else
            log_warn "⚠️  Missing 'repo' scope"
        fi
        
        if echo "$AUTH_INFO" | grep -q "workflow"; then
            log_info "✅ Has 'workflow' scope"
        else
            log_warn "⚠️  Missing 'workflow' scope (needed for Actions)"
        fi
    else
        log_error "❌ Not authenticated with GitHub"
        log_info "Authenticate with: gh auth login"
        return 1
    fi
}

# Check repository access
check_repo_access() {
    log_section "4. Repository Access"
    
    if gh auth status &> /dev/null; then
        log_test "Checking if in a git repository..."
        if git rev-parse --git-dir &> /dev/null; then
            log_info "✅ Inside a git repository"
            
            log_test "Checking remote repository..."
            if gh repo view &> /dev/null; then
                REPO_INFO=$(gh repo view --json name,owner,isPrivate,defaultBranchRef 2>/dev/null)
                REPO_NAME=$(echo "$REPO_INFO" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
                REPO_OWNER=$(echo "$REPO_INFO" | grep -o '"login":"[^"]*"' | cut -d'"' -f4)
                log_info "✅ Can access remote repository: $REPO_OWNER/$REPO_NAME"
            else
                log_warn "⚠️  Cannot access remote repository"
            fi
        else
            log_warn "⚠️  Not inside a git repository"
        fi
    else
        log_warn "⚠️  Not authenticated - skipping repository check"
    fi
}

# Check GitHub API access
check_api_access() {
    log_section "5. GitHub API Access"
    
    if gh auth status &> /dev/null; then
        log_test "Testing GitHub API connectivity..."
        if gh api user &> /dev/null; then
            USER=$(gh api user --jq .login 2>/dev/null)
            log_info "✅ API access working - authenticated as: $USER"
        else
            log_error "❌ Cannot access GitHub API"
        fi
        
        log_test "Checking API rate limit..."
        if RATE_LIMIT=$(gh api rate_limit 2>/dev/null); then
            REMAINING=$(echo "$RATE_LIMIT" | grep -o '"remaining":[0-9]*' | head -1 | cut -d':' -f2)
            LIMIT=$(echo "$RATE_LIMIT" | grep -o '"limit":[0-9]*' | head -1 | cut -d':' -f2)
            log_info "✅ API rate limit: $REMAINING/$LIMIT remaining"
            
            if [ "$REMAINING" -lt 100 ]; then
                log_warn "⚠️  Low API rate limit remaining"
            fi
        else
            log_warn "⚠️  Could not check rate limit"
        fi
    else
        log_warn "⚠️  Not authenticated - skipping API check"
    fi
}

# Check permissions
check_permissions() {
    log_section "6. Repository Permissions"
    
    if gh auth status &> /dev/null && git rev-parse --git-dir &> /dev/null; then
        if gh repo view &> /dev/null; then
            log_test "Checking repository permissions..."
            
            # Check if user can push
            REPO_INFO=$(gh repo view --json viewerPermission 2>/dev/null)
            PERMISSION=$(echo "$REPO_INFO" | grep -o '"viewerPermission":"[^"]*"' | cut -d'"' -f4)
            
            case "$PERMISSION" in
                ADMIN)
                    log_info "✅ User has ADMIN permissions"
                    ;;
                WRITE)
                    log_info "✅ User has WRITE permissions"
                    ;;
                READ)
                    log_warn "⚠️  User has READ-only permissions"
                    ;;
                *)
                    log_warn "⚠️  Unknown permission level: $PERMISSION"
                    ;;
            esac
        fi
    else
        log_warn "⚠️  Cannot check permissions (not in repo or not authenticated)"
    fi
}

# Check GitHub Actions
check_actions() {
    log_section "7. GitHub Actions"
    
    if gh auth status &> /dev/null && git rev-parse --git-dir &> /dev/null; then
        if gh repo view &> /dev/null; then
            log_test "Checking if Actions are enabled..."
            
            if gh api repos/:owner/:repo/actions/permissions &> /dev/null; then
                log_info "✅ Can access GitHub Actions settings"
                
                # Check recent workflow runs
                log_test "Checking recent workflow runs..."
                if RUNS=$(gh run list --limit 5 2>/dev/null); then
                    RUN_COUNT=$(echo "$RUNS" | wc -l | tr -d ' ')
                    if [ "$RUN_COUNT" -gt 0 ]; then
                        log_info "✅ Found $RUN_COUNT recent workflow runs"
                    else
                        log_info "ℹ️  No recent workflow runs"
                    fi
                else
                    log_warn "⚠️  Cannot list workflow runs"
                fi
            else
                log_warn "⚠️  Cannot access GitHub Actions (may not have workflow scope)"
            fi
        fi
    else
        log_warn "⚠️  Cannot check Actions (not in repo or not authenticated)"
    fi
}

# Check extensions
check_extensions() {
    log_section "8. GitHub CLI Extensions"
    
    log_test "Checking installed extensions..."
    if EXTENSIONS=$(gh extension list 2>/dev/null); then
        if [ -n "$EXTENSIONS" ]; then
            log_info "✅ Installed extensions:"
            echo "$EXTENSIONS"
        else
            log_info "ℹ️  No extensions installed"
        fi
    else
        log_warn "⚠️  Could not list extensions"
    fi
}

# Check configuration
check_config() {
    log_section "9. Configuration"
    
    log_test "Checking gh configuration..."
    
    # Check default editor
    if EDITOR=$(gh config get editor 2>/dev/null); then
        log_info "✅ Default editor: $EDITOR"
    else
        log_info "ℹ️  No default editor configured"
        log_info "Set with: gh config set editor <editor>"
    fi
    
    # Check git protocol
    if PROTOCOL=$(gh config get git_protocol 2>/dev/null); then
        log_info "✅ Git protocol: $PROTOCOL"
    else
        log_info "ℹ️  Using default git protocol (https)"
    fi
    
    # Check browser
    if BROWSER=$(gh config get browser 2>/dev/null); then
        log_info "✅ Browser: $BROWSER"
    else
        log_info "ℹ️  Using default browser"
    fi
}

# Check common issues
check_common_issues() {
    log_section "10. Common Issues Check"
    
    log_test "Checking for token expiration..."
    if gh auth status 2>&1 | grep -q "token expired\|expired token"; then
        log_error "❌ Authentication token has expired"
        log_info "Re-authenticate with: gh auth login"
    else
        log_info "✅ No token expiration detected"
    fi
    
    log_test "Checking for network connectivity..."
    if curl -s --connect-timeout 5 https://api.github.com &> /dev/null; then
        log_info "✅ Can reach GitHub API"
    else
        log_error "❌ Cannot reach GitHub API (network issue?)"
    fi
    
    log_test "Checking for OpenShift CLI conflicts..."
    if command -v oc &> /dev/null; then
        OC_VERSION=$(oc version --client 2>/dev/null | head -1 || echo "unknown")
        log_info "ℹ️  OpenShift CLI is also installed: $OC_VERSION"
        log_info "Both tools can coexist without conflicts"
    fi
}

# Show helpful commands
show_helpful_commands() {
    log_section "11. Helpful Commands"
    
    cat << EOF
${CYAN}Authentication:${NC}
  gh auth login                      # Authenticate with GitHub
  gh auth logout                     # Logout from GitHub
  gh auth status                     # Check auth status
  gh auth refresh                    # Refresh auth token

${CYAN}Repository:${NC}
  gh repo view                       # View repository info
  gh repo clone <owner>/<repo>       # Clone repository
  gh repo fork                       # Fork repository
  gh repo create                     # Create new repository

${CYAN}Pull Requests:${NC}
  gh pr list                         # List pull requests
  gh pr create                       # Create pull request
  gh pr view <number>                # View PR details
  gh pr checkout <number>            # Checkout PR locally
  gh pr merge <number>               # Merge pull request

${CYAN}Issues:${NC}
  gh issue list                      # List issues
  gh issue create                    # Create new issue
  gh issue view <number>             # View issue details
  gh issue close <number>            # Close issue

${CYAN}GitHub Actions:${NC}
  gh workflow list                   # List workflows
  gh workflow run <name>             # Trigger workflow
  gh run list                        # List workflow runs
  gh run view <id>                   # View run details
  gh run watch                       # Watch current run

${CYAN}Releases:${NC}
  gh release list                    # List releases
  gh release create <tag>            # Create release
  gh release view <tag>              # View release

${CYAN}Configuration:${NC}
  gh config set editor <editor>      # Set default editor
  gh config set git_protocol ssh     # Use SSH for git
  gh extension list                  # List extensions

${CYAN}Documentation:${NC}
  gh --help                          # Show help
  gh <command> --help                # Command help
EOF
}

# Display summary
show_summary() {
    log_section "Summary"
    
    if [ $ISSUES_FOUND -eq 0 ]; then
        echo -e "${GREEN}✅ All checks passed! GitHub CLI is properly configured.${NC}"
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
║           GitHub CLI - Comprehensive Diagnostics             ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    check_installation || exit 1
    check_version
    check_auth
    check_repo_access
    check_api_access
    check_permissions
    check_actions
    check_extensions
    check_config
    check_common_issues
    show_helpful_commands
    show_summary
}

# Run main function
main
