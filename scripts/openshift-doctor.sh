#!/bin/bash
# OpenShift CLI Health Check & Diagnostic Tool
# Diagnoses common OpenShift CLI issues and provides solutions

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 OpenShift CLI Health Check & Diagnostics${NC}"
echo "=============================================="
echo

# Track issues
ISSUES_FOUND=0

# Check 1: oc Installation
echo -e "${YELLOW}[1/8] Checking oc installation...${NC}"
if command -v oc &> /dev/null; then
    VERSION=$(oc version --client -o json 2>/dev/null | grep -o '"gitVersion":"[^"]*"' | cut -d'"' -f4 || oc version --client 2>/dev/null | head -1 || echo "installed")
    echo -e "${GREEN}✅ oc is installed: $VERSION${NC}"
    
    # Check kubectl compatibility
    if command -v kubectl &> /dev/null; then
        KUBECTL_VERSION=$(kubectl version --client -o json 2>/dev/null | grep -o '"gitVersion":"[^"]*"' | cut -d'"' -f4 || echo "installed")
        echo -e "${GREEN}✅ kubectl is also available: $KUBECTL_VERSION${NC}"
    fi
else
    echo -e "${RED}❌ oc is not installed${NC}"
    echo "   → Install with: ./scripts/install-openshift.sh"
    echo "   → Or visit: https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo

# Check 2: Authentication
echo -e "${YELLOW}[2/8] Checking authentication...${NC}"
if oc whoami &> /dev/null; then
    USERNAME=$(oc whoami 2>/dev/null)
    SERVER=$(oc whoami --show-server 2>/dev/null)
    echo -e "${GREEN}✅ Authenticated with OpenShift${NC}"
    echo "   User: $USERNAME"
    echo "   Server: $SERVER"
    
    # Check token expiry
    TOKEN=$(oc whoami --show-token 2>/dev/null || echo "")
    if [ -n "$TOKEN" ]; then
        echo -e "${GREEN}✅ Token is active${NC}"
    fi
else
    echo -e "${RED}❌ Not authenticated with OpenShift${NC}"
    echo "   → Run: oc login https://api.your-cluster.example.com:6443"
    echo "   → Or get login command from web console:"
    echo "     1. Click your username (top right)"
    echo "     2. Click 'Copy login command'"
    echo "     3. Click 'Display Token'"
    echo "     4. Copy and paste the oc login command"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo

# Check 3: Current Project
echo -e "${YELLOW}[3/8] Checking current project...${NC}"
if oc whoami &> /dev/null; then
    CURRENT_PROJECT=$(oc project -q 2>/dev/null || echo "none")
    if [ "$CURRENT_PROJECT" != "none" ]; then
        echo -e "${GREEN}✅ Current project: $CURRENT_PROJECT${NC}"
        
        # List accessible projects
        PROJECT_COUNT=$(oc projects -q 2>/dev/null | wc -l | tr -d ' ')
        echo "   Accessible projects: $PROJECT_COUNT"
    else
        echo -e "${YELLOW}⚠️  No current project selected${NC}"
        echo "   → Switch to a project: oc project <project-name>"
        echo "   → Create new project: oc new-project my-project"
    fi
else
    echo -e "${YELLOW}⚠️  Cannot check project (not authenticated)${NC}"
fi
echo

# Check 4: Cluster Access
echo -e "${YELLOW}[4/8] Checking cluster access...${NC}"
if oc whoami &> /dev/null; then
    # Check if can access cluster info
    if oc cluster-info &> /dev/null; then
        echo -e "${GREEN}✅ Can access cluster information${NC}"
    else
        echo -e "${YELLOW}⚠️  Limited cluster access${NC}"
        echo "   → You may have restricted permissions"
    fi
    
    # Check if admin (node access)
    if oc get nodes &> /dev/null; then
        NODE_COUNT=$(oc get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
        echo -e "${GREEN}✅ Cluster admin access (can view $NODE_COUNT nodes)${NC}"
    else
        echo -e "${YELLOW}⚠️  No cluster admin access (cannot view nodes)${NC}"
        echo "   → This is normal for regular users"
    fi
else
    echo -e "${YELLOW}⚠️  Cannot check cluster access (not authenticated)${NC}"
fi
echo

# Check 5: Resource Access
echo -e "${YELLOW}[5/8] Checking resource access...${NC}"
if oc whoami &> /dev/null && oc project -q &> /dev/null; then
    # Check pod access
    if oc get pods &> /dev/null; then
        POD_COUNT=$(oc get pods --no-headers 2>/dev/null | wc -l | tr -d ' ')
        echo -e "${GREEN}✅ Can access pods ($POD_COUNT in current project)${NC}"
    else
        echo -e "${YELLOW}⚠️  Cannot access pods${NC}"
    fi
    
    # Check service access
    if oc get services &> /dev/null; then
        SVC_COUNT=$(oc get services --no-headers 2>/dev/null | wc -l | tr -d ' ')
        echo -e "${GREEN}✅ Can access services ($SVC_COUNT in current project)${NC}"
    fi
    
    # Check route access
    if oc get routes &> /dev/null; then
        ROUTE_COUNT=$(oc get routes --no-headers 2>/dev/null | wc -l | tr -d ' ')
        echo -e "${GREEN}✅ Can access routes ($ROUTE_COUNT in current project)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Cannot check resource access (not authenticated or no project)${NC}"
fi
echo

# Check 6: Configuration
echo -e "${YELLOW}[6/8] Checking oc configuration...${NC}"
if command -v oc &> /dev/null; then
    CONFIG_FILE="$HOME/.kube/config"
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${GREEN}✅ Configuration file exists: $CONFIG_FILE${NC}"
        
        # Check contexts
        CONTEXT_COUNT=$(oc config get-contexts --no-headers 2>/dev/null | wc -l | tr -d ' ')
        CURRENT_CONTEXT=$(oc config current-context 2>/dev/null || echo "none")
        echo "   Contexts: $CONTEXT_COUNT"
        echo "   Current: $CURRENT_CONTEXT"
    else
        echo -e "${YELLOW}⚠️  No configuration file found${NC}"
        echo "   → Will be created after first oc login"
    fi
else
    echo -e "${YELLOW}⚠️  oc not installed${NC}"
fi
echo

# Check 7: Network Connectivity
echo -e "${YELLOW}[7/8] Checking network connectivity...${NC}"
if oc whoami --show-server &> /dev/null; then
    SERVER=$(oc whoami --show-server 2>/dev/null)
    SERVER_HOST=$(echo $SERVER | sed 's|https://||' | sed 's|:.*||')
    
    if ping -c 1 "$SERVER_HOST" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Can reach OpenShift server: $SERVER_HOST${NC}"
    else
        echo -e "${YELLOW}⚠️  Cannot ping server (may be blocked by firewall)${NC}"
        echo "   → Try: curl -k $SERVER/healthz"
    fi
    
    # Check API accessibility
    if curl -k -s "$SERVER/healthz" -o /dev/null; then
        echo -e "${GREEN}✅ API server is accessible${NC}"
    else
        echo -e "${RED}❌ Cannot reach API server${NC}"
        echo "   → Check your network connection"
        echo "   → Check firewall settings"
        echo "   → Verify VPN if required"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    echo -e "${YELLOW}⚠️  Cannot check connectivity (not logged in)${NC}"
fi
echo

# Check 8: Helper Scripts and Labs
echo -e "${YELLOW}[8/8] Checking OpenShift study materials...${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
STUDY_DIR="$PROJECT_ROOT/openshift-study"

if [ -d "$STUDY_DIR" ]; then
    echo -e "${GREEN}✅ OpenShift study materials found: $STUDY_DIR${NC}"
    
    # Check labs
    LABS_DIR="$STUDY_DIR/labs"
    if [ -d "$LABS_DIR" ]; then
        LAB_COUNT=$(ls -1 "$LABS_DIR"/*.sh 2>/dev/null | wc -l | tr -d ' ')
        echo -e "${GREEN}✅ Found $LAB_COUNT lab exercises${NC}"
        
        # Check if executable
        NON_EXEC=$(find "$LABS_DIR" -name "*.sh" ! -perm +111 2>/dev/null | wc -l | tr -d ' ')
        if [ "$NON_EXEC" -gt 0 ]; then
            echo -e "${YELLOW}⚠️  $NON_EXEC lab scripts are not executable${NC}"
            echo "   → Run: chmod +x $LABS_DIR/*.sh"
        else
            echo -e "${GREEN}✅ All lab scripts are executable${NC}"
        fi
    fi
    
    # Check README
    if [ -f "$STUDY_DIR/README.md" ]; then
        echo -e "${GREEN}✅ Study guide available${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  OpenShift study materials not found${NC}"
    echo "   → Expected at: $STUDY_DIR"
fi
echo

# Summary
echo "=============================================="
if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed! OpenShift CLI is ready to use.${NC}"
    echo
    echo "Quick Start Commands:"
    echo "  oc status                  # View project status"
    echo "  oc get all                 # List all resources"
    echo "  oc get pods                # List pods"
    echo "  oc logs <pod>              # View pod logs"
    echo "  oc new-app <image>         # Deploy application"
    echo "  oc expose svc/<name>       # Create route"
    echo "  cd openshift-study/labs    # Start learning labs"
else
    echo -e "${RED}⚠️  Found $ISSUES_FOUND issue(s) that need attention.${NC}"
    echo
    echo "Recommended Actions:"
    echo "  1. Fix the issues listed above"
    echo "  2. Run this script again to verify"
    echo "  3. See openshift-study/README.md for help"
fi
echo

# Suggest next steps
echo "📚 Resources:"
echo "  • OpenShift Docs: https://docs.openshift.com/"
echo "  • Learning Portal: https://learn.openshift.com/"
echo "  • Study Guide: openshift-study/README.md"
echo "  • Quick Start: openshift-study/QUICKSTART.md"
echo "  • Interactive Labs: openshift-study/labs/"
echo "  • Get help: oc help"
echo

exit $ISSUES_FOUND
