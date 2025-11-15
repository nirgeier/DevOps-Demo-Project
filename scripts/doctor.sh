#!/usr/bin/env bash

###############################################################################
# DevOps Toolchain Health Check & Diagnostics
# Comprehensive diagnostics for all DevOps tools in this project
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
TOOL="${1:-all}"

show_usage() {
    cat << EOF
Usage: $(basename "$0") [TOOL]

Run health checks for DevOps tools in this project.

Options:
  all          Check all tools (default)
  gh           GitHub CLI only
  oc           OpenShift CLI only
  docker       Docker only
  kubectl      Kubernetes only
  helm         Helm only
  python       Python environment only
  quick        Quick check (essential tools only)

Examples:
  $(basename "$0")           # Check all tools
  $(basename "$0") gh        # Check GitHub CLI only
  $(basename "$0") quick     # Quick essential checks
  
Individual diagnostic scripts:
  ./scripts/gh-doctor.sh         # Detailed GitHub CLI diagnostics
  ./scripts/openshift-doctor.sh  # Detailed OpenShift CLI diagnostics
  
EOF
    exit 0
}

if [ "$TOOL" = "--help" ] || [ "$TOOL" = "-h" ]; then
    show_usage
fi

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          DevOps Toolchain Health Check                       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo

# Track issues
ISSUES_FOUND=0
CHECKS_RUN=0

check_tool() {
    local tool_name=$1
    local tool_cmd=$2
    local install_script=$3
    local optional=${4:-false}
    
    CHECKS_RUN=$((CHECKS_RUN + 1))
    
    if command -v "$tool_cmd" &> /dev/null; then
        local version=$("$tool_cmd" --version 2>&1 | head -1 || echo "installed")
        echo -e "${GREEN}✅ $tool_name${NC} - $version"
        return 0
    else
        if [ "$optional" = "true" ]; then
            echo -e "${YELLOW}⚠️  $tool_name${NC} - Not installed (optional)"
            echo "   → Install: $install_script"
        else
            echo -e "${RED}❌ $tool_name${NC} - Not installed"
            echo "   → Install: $install_script"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
        return 1
    fi
}

check_github_cli() {
    echo -e "${CYAN}🔍 GitHub CLI (gh)${NC}"
    if check_tool "GitHub CLI" "gh" "./scripts/install-gh.sh"; then
        # Check authentication
        if gh auth status &> /dev/null; then
            echo -e "   ${GREEN}✓${NC} Authenticated"
        else
            echo -e "   ${YELLOW}⚠${NC} Not authenticated (run: gh auth login)"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
        echo "   → Run: ./scripts/gh-doctor.sh (detailed diagnostics)"
    fi
    echo
}

check_openshift_cli() {
    echo -e "${CYAN}🔍 OpenShift CLI (oc)${NC}"
    if check_tool "OpenShift CLI" "oc" "./scripts/install-openshift.sh" "true"; then
        # Check authentication
        if oc whoami &> /dev/null; then
            local user=$(oc whoami 2>/dev/null)
            echo -e "   ${GREEN}✓${NC} Authenticated as: $user"
        else
            echo -e "   ${YELLOW}⚠${NC} Not authenticated (run: oc login <server>)"
        fi
        echo "   → Run: ./scripts/openshift-doctor.sh (detailed diagnostics)"
    fi
    echo
}

check_docker() {
    echo -e "${CYAN}🔍 Docker${NC}"
    if check_tool "Docker" "docker" "./scripts/install-docker.sh"; then
        # Check if docker daemon is running
        if docker ps &> /dev/null; then
            echo -e "   ${GREEN}✓${NC} Docker daemon running"
        else
            echo -e "   ${RED}✗${NC} Docker daemon not running"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    fi
    echo
}

check_kubectl() {
    echo -e "${CYAN}🔍 Kubernetes CLI (kubectl)${NC}"
    if check_tool "kubectl" "kubectl" "./scripts/install-kubectl.sh"; then
        # Check cluster connection
        if kubectl cluster-info &> /dev/null; then
            echo -e "   ${GREEN}✓${NC} Connected to cluster"
        else
            echo -e "   ${YELLOW}⚠${NC} Not connected to cluster"
        fi
    fi
    echo
}

check_helm() {
    echo -e "${CYAN}🔍 Helm${NC}"
    check_tool "Helm" "helm" "./scripts/install-helm.sh"
    echo
}

check_python() {
    echo -e "${CYAN}🔍 Python Environment${NC}"
    if command -v python3 &> /dev/null; then
        local version=$(python3 --version 2>&1)
        echo -e "${GREEN}✅ Python${NC} - $version"
        
        # Check virtual environment
        if [ -d ".venv" ]; then
            echo -e "   ${GREEN}✓${NC} Virtual environment exists"
            
            # Check if activated
            if [ -n "$VIRTUAL_ENV" ]; then
                echo -e "   ${GREEN}✓${NC} Virtual environment active"
            else
                echo -e "   ${YELLOW}⚠${NC} Virtual environment not active"
                echo "   → Run: source .venv/bin/activate"
            fi
        else
            echo -e "   ${YELLOW}⚠${NC} No virtual environment"
            echo "   → Run: ./scripts/init.sh or uv venv"
        fi
        
        # Check uv
        if command -v uv &> /dev/null; then
            local uv_version=$(uv --version 2>&1)
            echo -e "   ${GREEN}✓${NC} uv installed - $uv_version"
        else
            echo -e "   ${YELLOW}⚠${NC} uv not installed (recommended)"
            echo "   → Install: ./scripts/install-uv.sh"
        fi
    else
        echo -e "${RED}❌ Python${NC} - Not installed"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
    echo
}

check_optional_tools() {
    echo -e "${CYAN}🔍 Optional Tools${NC}"
    check_tool "k9s" "k9s" "./scripts/install-k9s.sh" "true"
    check_tool "ArgoCD CLI" "argocd" "./scripts/install-argocd.sh" "true"
    echo
}

check_git_status() {
    echo -e "${CYAN}🔍 Git Repository${NC}"
    CHECKS_RUN=$((CHECKS_RUN + 1))
    
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git branch --show-current)
        local remote=$(git config --get remote.origin.url 2>/dev/null || echo "none")
        echo -e "${GREEN}✅ Git Repository${NC}"
        echo "   Branch: $branch"
        echo "   Remote: $remote"
    else
        echo -e "${RED}❌ Not a git repository${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
    echo
}

# Main execution
case $TOOL in
    all)
        check_git_status
        check_python
        check_github_cli
        check_docker
        check_kubectl
        check_helm
        check_openshift_cli
        check_optional_tools
        ;;
    gh|github)
        check_github_cli
        echo -e "${BLUE}For detailed GitHub CLI diagnostics, run:${NC}"
        echo "  ./scripts/gh-doctor.sh"
        ;;
    oc|openshift)
        check_openshift_cli
        echo -e "${BLUE}For detailed OpenShift CLI diagnostics, run:${NC}"
        echo "  ./scripts/openshift-doctor.sh"
        ;;
    docker)
        check_docker
        ;;
    kubectl|kubernetes|k8s)
        check_kubectl
        ;;
    helm)
        check_helm
        ;;
    python|py)
        check_python
        ;;
    quick)
        echo -e "${BLUE}Quick Check (Essential Tools)${NC}"
        echo
        check_git_status
        check_python
        check_github_cli
        check_docker
        ;;
    *)
        echo -e "${RED}Unknown tool: $TOOL${NC}"
        echo
        show_usage
        ;;
esac

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed! ($CHECKS_RUN/$CHECKS_RUN)${NC}"
    echo
    echo "Your DevOps toolchain is ready!"
else
    echo -e "${YELLOW}⚠️  Found $ISSUES_FOUND issue(s) in $CHECKS_RUN checks${NC}"
    echo
    echo "Fix the issues above and run again:"
    echo "  ./scripts/doctor.sh"
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Additional help
if [ $ISSUES_FOUND -gt 0 ] || [ "$TOOL" = "all" ]; then
    echo -e "${CYAN}💡 Quick Fixes:${NC}"
    echo "  • Install all tools:     ./scripts/init.sh"
    echo "  • Activate Python env:   source .venv/bin/activate"
    echo "  • GitHub CLI login:      gh auth login"
    echo "  • OpenShift login:       oc login <server-url>"
    echo "  • Start Docker:          open -a Docker (macOS)"
    echo
    echo -e "${CYAN}📚 Resources:${NC}"
    echo "  • Main README:           cat README.md"
    echo "  • GitHub CLI Guide:      cat gh-study/README.md"
    echo "  • OpenShift Guide:       cat openshift-study/README.md"
    echo "  • Project Improvements:  cat PROJECT_IMPROVEMENTS.md"
    echo
fi

exit $ISSUES_FOUND
