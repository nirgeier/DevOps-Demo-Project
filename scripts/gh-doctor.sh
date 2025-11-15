#!/bin/bash
# GitHub CLI Health Check & Diagnostic Tool
# Diagnoses common GitHub CLI issues and provides solutions

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 GitHub CLI Health Check & Diagnostics${NC}"
echo "=========================================="
echo

# Track issues
ISSUES_FOUND=0

# Check 1: gh Installation
echo -e "${YELLOW}[1/7] Checking gh installation...${NC}"
if command -v gh &> /dev/null; then
    VERSION=$(gh --version | head -1)
    echo -e "${GREEN}✅ gh is installed: $VERSION${NC}"
else
    echo -e "${RED}❌ gh is not installed${NC}"
    echo "   → Install with: ./scripts/install-gh.sh"
    echo "   → Or visit: https://cli.github.com/manual/installation"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo

# Check 2: Authentication
echo -e "${YELLOW}[2/7] Checking authentication...${NC}"
if gh auth status > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Authenticated with GitHub${NC}"
    gh auth status 2>&1 | grep "Logged in to" | sed 's/^/   /'
    gh auth status 2>&1 | grep "Token:" | sed 's/^/   /'
else
    echo -e "${RED}❌ Not authenticated with GitHub${NC}"
    echo "   → Run: gh auth login"
    echo "   → Choose: GitHub.com → HTTPS → Browser authentication"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo

# Check 3: Git Repository
echo -e "${YELLOW}[3/7] Checking git repository...${NC}"
if git rev-parse --git-dir > /dev/null 2>&1; then
    REPO_NAME=$(git config --get remote.origin.url | sed 's/.*[:/]\([^/]*\/[^/]*\)\.git/\1/' || echo "unknown")
    BRANCH=$(git branch --show-current)
    echo -e "${GREEN}✅ In a git repository${NC}"
    echo "   Repository: $REPO_NAME"
    echo "   Branch: $BRANCH"
    
    # Check if gh can access repo
    if gh repo view > /dev/null 2>&1; then
        echo -e "${GREEN}✅ GitHub CLI can access this repository${NC}"
    else
        echo -e "${YELLOW}⚠️  GitHub CLI cannot access this repository${NC}"
        echo "   → Make sure you have access to the repository"
        echo "   → Check if the repository is private and you're authenticated"
    fi
else
    echo -e "${YELLOW}⚠️  Not in a git repository${NC}"
    echo "   → Navigate to a git repository to use gh with repo context"
fi
echo

# Check 4: API Rate Limit
echo -e "${YELLOW}[4/7] Checking API rate limit...${NC}"
if command -v gh &> /dev/null && gh auth status > /dev/null 2>&1; then
    RATE_LIMIT=$(gh api rate_limit --jq '.rate.remaining' 2>/dev/null || echo "0")
    RATE_TOTAL=$(gh api rate_limit --jq '.rate.limit' 2>/dev/null || echo "0")
    RATE_RESET=$(gh api rate_limit --jq '.rate.reset' 2>/dev/null || echo "0")
    
    if [ "$RATE_LIMIT" -gt 100 ]; then
        echo -e "${GREEN}✅ API rate limit: $RATE_LIMIT / $RATE_TOTAL remaining${NC}"
    elif [ "$RATE_LIMIT" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  API rate limit low: $RATE_LIMIT / $RATE_TOTAL remaining${NC}"
        RESET_TIME=$(date -r "$RATE_RESET" "+%H:%M:%S" 2>/dev/null || echo "soon")
        echo "   → Rate limit resets at: $RESET_TIME"
    else
        echo -e "${RED}❌ API rate limit exceeded${NC}"
        RESET_TIME=$(date -r "$RATE_RESET" "+%H:%M:%S" 2>/dev/null || echo "soon")
        echo "   → Rate limit resets at: $RESET_TIME"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    echo -e "${YELLOW}⚠️  Cannot check rate limit (not authenticated)${NC}"
fi
echo

# Check 5: Configuration
echo -e "${YELLOW}[5/7] Checking gh configuration...${NC}"
if command -v gh &> /dev/null; then
    CONFIG=$(gh config list 2>/dev/null || echo "")
    if [ -n "$CONFIG" ]; then
        echo -e "${GREEN}✅ Configuration found:${NC}"
        echo "$CONFIG" | sed 's/^/   /'
    else
        echo -e "${YELLOW}⚠️  No configuration found${NC}"
        echo "   → Set editor: gh config set editor vim"
        echo "   → Set protocol: gh config set git_protocol https"
    fi
else
    echo -e "${YELLOW}⚠️  gh not installed${NC}"
fi
echo

# Check 6: Network Connectivity
echo -e "${YELLOW}[6/7] Checking network connectivity...${NC}"
if ping -c 1 github.com > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Can reach github.com${NC}"
else
    echo -e "${RED}❌ Cannot reach github.com${NC}"
    echo "   → Check your internet connection"
    echo "   → Check firewall settings"
    echo "   → Try: curl -I https://github.com"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo

# Check 7: Helper Scripts
echo -e "${YELLOW}[7/8] Checking DevOps helper scripts...${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPERS_PATH="$SCRIPT_DIR/gh-helpers.sh"

if [ -f "$HELPERS_PATH" ]; then
    echo -e "${GREEN}✅ Helper functions available: $HELPERS_PATH${NC}"
    
    # Check if executable
    if [ -x "$HELPERS_PATH" ]; then
        echo -e "${GREEN}✅ Helper script is executable${NC}"
    else
        echo -e "${YELLOW}⚠️  Helper script not executable${NC}"
        echo "   → Run: chmod +x $HELPERS_PATH"
    fi
    
    # Check if can source
    if bash -n "$HELPERS_PATH" 2>/dev/null; then
        echo -e "${GREEN}✅ Helper script has valid syntax${NC}"
    else
        echo -e "${RED}❌ Helper script has syntax errors${NC}"
        bash -n "$HELPERS_PATH" 2>&1 | sed 's/^/   /'
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    echo -e "${YELLOW}⚠️  Helper functions not found${NC}"
    echo "   → Expected: $HELPERS_PATH"
fi
echo

# Check 8: OpenShift CLI (optional but recommended)
echo -e "${YELLOW}[8/8] Checking OpenShift CLI integration...${NC}"
if command -v oc &> /dev/null; then
    OC_VERSION=$(oc version --client -o json 2>/dev/null | grep -o '"gitVersion":"[^"]*"' | cut -d'"' -f4 || echo "installed")
    echo -e "${GREEN}✅ OpenShift CLI is installed: $OC_VERSION${NC}"
    
    # Check if authenticated
    if oc whoami &> /dev/null; then
        OC_USER=$(oc whoami 2>/dev/null)
        OC_SERVER=$(oc whoami --show-server 2>/dev/null)
        echo -e "${GREEN}✅ Authenticated with OpenShift${NC}"
        echo "   User: $OC_USER"
        echo "   Server: $OC_SERVER"
    else
        echo -e "${YELLOW}⚠️  Not authenticated with OpenShift${NC}"
        echo "   → Run: oc login <server-url>"
        echo "   → Or run: ./scripts/openshift-doctor.sh for detailed diagnostics"
    fi
    
    # Check for OpenShift study materials
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    OPENSHIFT_STUDY="$PROJECT_ROOT/openshift-study"
    if [ -d "$OPENSHIFT_STUDY" ]; then
        echo -e "${GREEN}✅ OpenShift study materials available${NC}"
        echo "   → Start labs: cd openshift-study/labs && ./lab1-setup.sh"
    fi
else
    echo -e "${YELLOW}⚠️  OpenShift CLI not installed (optional)${NC}"
    echo "   → Install with: ./scripts/install-openshift.sh"
    echo "   → Or skip if not using OpenShift"
fi
echo

# Summary
echo "=========================================="
if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed! GitHub CLI is ready to use.${NC}"
    echo
    echo "Quick Start Commands:"
    echo "  gh repo view              # View current repository"
    echo "  gh pr list                # List pull requests"
    echo "  gh issue list             # List issues"
    echo "  ./scripts/gh-create-pr.sh # Create PR from current branch"
    echo "  cd gh-study/labs          # Start learning labs"
else
    echo -e "${RED}⚠️  Found $ISSUES_FOUND issue(s) that need attention.${NC}"
    echo
    echo "Recommended Actions:"
    echo "  1. Fix the issues listed above"
    echo "  2. Run this script again to verify"
    echo "  3. See gh-study/README.md for help"
fi
echo

# Suggest next steps
echo "📚 Resources:"
echo "  • GitHub CLI Manual: https://cli.github.com/manual/"
echo "  • Study Guide: gh-study/README.md"
echo "  • Quick Start: gh-study/QUICKSTART.md"
echo "  • Interactive Labs: gh-study/labs/"
echo "  • Get help: gh help"
echo

exit $ISSUES_FOUND
