#!/usr/bin/env bash

###############################################################################
# Verification Script - Test All Improvements
# Verifies that all scripts, documentation, and configurations are correct
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

log_test() { echo -e "${CYAN}[TEST]${NC} $1"; TOTAL_CHECKS=$((TOTAL_CHECKS + 1)); }
log_pass() { echo -e "${GREEN}  ✅ PASS${NC} $1"; PASSED_CHECKS=$((PASSED_CHECKS + 1)); }
log_fail() { echo -e "${RED}  ❌ FAIL${NC} $1"; FAILED_CHECKS=$((FAILED_CHECKS + 1)); }
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_section() { echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${BLUE}$1${NC}"; echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

log_section "DevOps Demo Project - Verification Suite"
log_info "Running comprehensive checks on all improvements..."
echo

# ═══════════════════════════════════════════════════════════════════════════
# Section 1: File Existence Checks
# ═══════════════════════════════════════════════════════════════════════════

log_section "1. File Existence Checks"

log_test "Check install-openshift.sh exists"
if [ -f "scripts/install-openshift.sh" ]; then
    log_pass "scripts/install-openshift.sh found"
else
    log_fail "scripts/install-openshift.sh NOT found"
fi

log_test "Check openshift-doctor.sh exists"
if [ -f "scripts/openshift-doctor.sh" ]; then
    log_pass "scripts/openshift-doctor.sh found"
else
    log_fail "scripts/openshift-doctor.sh NOT found"
fi

log_test "Check PROJECT_IMPROVEMENTS.md exists"
if [ -f "PROJECT_IMPROVEMENTS.md" ]; then
    log_pass "PROJECT_IMPROVEMENTS.md found"
else
    log_fail "PROJECT_IMPROVEMENTS.md NOT found"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Section 2: Script Permissions
# ═══════════════════════════════════════════════════════════════════════════

log_section "2. Script Permissions"

log_test "Check install-openshift.sh is executable"
if [ -x "scripts/install-openshift.sh" ]; then
    log_pass "install-openshift.sh is executable"
else
    log_fail "install-openshift.sh is NOT executable"
fi

log_test "Check openshift-doctor.sh is executable"
if [ -x "scripts/openshift-doctor.sh" ]; then
    log_pass "openshift-doctor.sh is executable"
else
    log_fail "openshift-doctor.sh is NOT executable"
fi

log_test "Check all lab scripts are executable"
gh_labs=$(find gh-study/labs -name "*.sh" ! -perm +111 2>/dev/null | wc -l | tr -d ' ')
oc_labs=$(find openshift-study/labs -name "*.sh" ! -perm +111 2>/dev/null | wc -l | tr -d ' ')
if [ "$gh_labs" -eq 0 ] && [ "$oc_labs" -eq 0 ]; then
    log_pass "All lab scripts are executable"
else
    log_fail "$((gh_labs + oc_labs)) lab scripts are not executable"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Section 3: Script Syntax Validation
# ═══════════════════════════════════════════════════════════════════════════

log_section "3. Script Syntax Validation"

log_test "Validate install-openshift.sh syntax"
if bash -n scripts/install-openshift.sh 2>/dev/null; then
    log_pass "install-openshift.sh has valid syntax"
else
    log_fail "install-openshift.sh has syntax errors"
fi

log_test "Validate openshift-doctor.sh syntax"
if bash -n scripts/openshift-doctor.sh 2>/dev/null; then
    log_pass "openshift-doctor.sh has valid syntax"
else
    log_fail "openshift-doctor.sh has syntax errors"
fi

log_test "Validate gh-doctor.sh syntax"
if bash -n scripts/gh-doctor.sh 2>/dev/null; then
    log_pass "gh-doctor.sh has valid syntax"
else
    log_fail "gh-doctor.sh has syntax errors"
fi

log_test "Validate init.sh syntax"
if bash -n scripts/init.sh 2>/dev/null; then
    log_pass "init.sh has valid syntax"
else
    log_fail "init.sh has syntax errors"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Section 4: Documentation Updates
# ═══════════════════════════════════════════════════════════════════════════

log_section "4. Documentation Updates"

log_test "Check README.md contains OpenShift section"
if grep -q "## 🚀 OpenShift Integration" README.md; then
    log_pass "README.md has OpenShift section"
else
    log_fail "README.md missing OpenShift section"
fi

log_test "Check README.md mentions install-openshift.sh"
if grep -q "install-openshift.sh" README.md; then
    log_pass "README.md references install-openshift.sh"
else
    log_fail "README.md missing install-openshift.sh reference"
fi

log_test "Check README.md mentions openshift-doctor.sh"
if grep -q "openshift-doctor.sh" README.md; then
    log_pass "README.md references openshift-doctor.sh"
else
    log_fail "README.md missing openshift-doctor.sh reference"
fi

log_test "Check README.md has OpenShift CLI in prerequisites"
if grep -q "OpenShift CLI (oc)" README.md; then
    log_pass "README.md lists OpenShift CLI in prerequisites"
else
    log_fail "README.md missing OpenShift CLI in prerequisites"
fi

log_test "Check README.md links to openshift-study"
if grep -q "openshift-study/README.md" README.md; then
    log_pass "README.md links to OpenShift study guide"
else
    log_fail "README.md missing link to OpenShift study guide"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Section 5: Configuration Files
# ═══════════════════════════════════════════════════════════════════════════

log_section "5. Configuration Files"

log_test "Check .gitignore has OpenShift patterns"
if grep -q "# OpenShift temporary files" .gitignore; then
    log_pass ".gitignore has OpenShift section"
else
    log_fail ".gitignore missing OpenShift section"
fi

log_test "Check .gitignore excludes .openshift/"
if grep -q ".openshift/" .gitignore; then
    log_pass ".gitignore excludes .openshift/"
else
    log_fail ".gitignore missing .openshift/ pattern"
fi

log_test "Check .gitignore excludes *.kubeconfig"
if grep -q "*.kubeconfig" .gitignore; then
    log_pass ".gitignore excludes *.kubeconfig"
else
    log_fail ".gitignore missing *.kubeconfig pattern"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Section 6: Script Content Validation
# ═══════════════════════════════════════════════════════════════════════════

log_section "6. Script Content Validation"

log_test "Check gh-doctor.sh mentions OpenShift"
if grep -q "OpenShift" scripts/gh-doctor.sh; then
    log_pass "gh-doctor.sh includes OpenShift checks"
else
    log_fail "gh-doctor.sh missing OpenShift checks"
fi

log_test "Check init.sh offers OpenShift installation"
if grep -q "OpenShift CLI" scripts/init.sh; then
    log_pass "init.sh offers OpenShift CLI installation"
else
    log_fail "init.sh missing OpenShift CLI option"
fi

log_test "Check install-openshift.sh has error handling"
if grep -q "set -euo pipefail" scripts/install-openshift.sh; then
    log_pass "install-openshift.sh has proper error handling"
else
    log_fail "install-openshift.sh missing error handling"
fi

log_test "Check openshift-doctor.sh counts issues"
if grep -q "ISSUES_FOUND" scripts/openshift-doctor.sh; then
    log_pass "openshift-doctor.sh tracks issues"
else
    log_fail "openshift-doctor.sh missing issue tracking"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Section 7: Study Materials
# ═══════════════════════════════════════════════════════════════════════════

log_section "7. Study Materials"

log_test "Check gh-study directory exists"
if [ -d "gh-study" ]; then
    log_pass "gh-study directory found"
else
    log_fail "gh-study directory NOT found"
fi

log_test "Check gh-study has README.md"
if [ -f "gh-study/README.md" ]; then
    log_pass "gh-study/README.md found"
else
    log_fail "gh-study/README.md NOT found"
fi

log_test "Check gh-study has 6 lab scripts"
gh_lab_count=$(ls -1 gh-study/labs/*.sh 2>/dev/null | wc -l | tr -d ' ')
if [ "$gh_lab_count" -eq 6 ]; then
    log_pass "gh-study has all 6 labs"
else
    log_fail "gh-study has $gh_lab_count labs (expected 6)"
fi

log_test "Check openshift-study directory exists"
if [ -d "openshift-study" ]; then
    log_pass "openshift-study directory found"
else
    log_fail "openshift-study directory NOT found"
fi

log_test "Check openshift-study has README.md"
if [ -f "openshift-study/README.md" ]; then
    log_pass "openshift-study/README.md found"
else
    log_fail "openshift-study/README.md NOT found"
fi

log_test "Check openshift-study has 6 lab scripts"
oc_lab_count=$(ls -1 openshift-study/labs/*.sh 2>/dev/null | wc -l | tr -d ' ')
if [ "$oc_lab_count" -eq 6 ]; then
    log_pass "openshift-study has all 6 labs"
else
    log_fail "openshift-study has $oc_lab_count labs (expected 6)"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Section 8: Script Integration
# ═══════════════════════════════════════════════════════════════════════════

log_section "8. Script Integration"

log_test "Check scripts directory has all install scripts"
install_scripts=("install-uv.sh" "install-docker.sh" "install-kubectl.sh" "install-helm.sh" "install-k9s.sh" "install-gh.sh" "install-openshift.sh" "install-argocd.sh")
missing_installs=0
for script in "${install_scripts[@]}"; do
    if [ ! -f "scripts/$script" ]; then
        missing_installs=$((missing_installs + 1))
    fi
done
if [ "$missing_installs" -eq 0 ]; then
    log_pass "All install scripts present (${#install_scripts[@]}/${#install_scripts[@]})"
else
    log_fail "$missing_installs install scripts missing"
fi

log_test "Check scripts directory has doctor scripts"
if [ -f "scripts/gh-doctor.sh" ] && [ -f "scripts/openshift-doctor.sh" ]; then
    log_pass "Both doctor scripts present"
else
    log_fail "Missing doctor scripts"
fi

log_test "Check scripts directory has helper scripts"
helper_scripts=("gh-helpers.sh" "gh-create-pr.sh" "gh-release.sh")
missing_helpers=0
for script in "${helper_scripts[@]}"; do
    if [ ! -f "scripts/$script" ]; then
        missing_helpers=$((missing_helpers + 1))
    fi
done
if [ "$missing_helpers" -eq 0 ]; then
    log_pass "All helper scripts present (${#helper_scripts[@]}/${#helper_scripts[@]})"
else
    log_fail "$missing_helpers helper scripts missing"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Section 9: Project Structure
# ═══════════════════════════════════════════════════════════════════════════

log_section "9. Project Structure"

log_test "Check app directory exists"
if [ -d "app" ] && [ -f "app/main.py" ]; then
    log_pass "app directory with main.py found"
else
    log_fail "app directory or main.py missing"
fi

log_test "Check tests directory exists"
if [ -d "tests" ] && [ -f "tests/test_main.py" ]; then
    log_pass "tests directory with test_main.py found"
else
    log_fail "tests directory or test_main.py missing"
fi

log_test "Check docker directory exists"
if [ -d "docker" ] && [ -f "docker/Dockerfile" ]; then
    log_pass "docker directory with Dockerfile found"
else
    log_fail "docker directory or Dockerfile missing"
fi

log_test "Check helm directory exists"
if [ -d "helm/devops-demo" ]; then
    log_pass "helm/devops-demo directory found"
else
    log_fail "helm/devops-demo directory missing"
fi

log_test "Check argocd directory exists"
if [ -d "argocd" ]; then
    log_pass "argocd directory found"
else
    log_fail "argocd directory missing"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Section 10: Tool Availability (Optional)
# ═══════════════════════════════════════════════════════════════════════════

log_section "10. Tool Availability (Optional)"

log_test "Check if gh is installed"
if command -v gh &> /dev/null; then
    VERSION=$(gh --version 2>/dev/null | head -1 || echo "installed")
    log_pass "gh is installed: $VERSION"
else
    log_info "gh not installed (optional - run ./scripts/install-gh.sh)"
fi

log_test "Check if oc is installed"
if command -v oc &> /dev/null; then
    VERSION=$(oc version --client 2>/dev/null | head -1 || echo "installed")
    log_pass "oc is installed: $VERSION"
else
    log_info "oc not installed (optional - run ./scripts/install-openshift.sh)"
fi

log_test "Check if kubectl is installed"
if command -v kubectl &> /dev/null; then
    VERSION=$(kubectl version --client 2>/dev/null | head -1 || echo "installed")
    log_pass "kubectl is installed: $VERSION"
else
    log_info "kubectl not installed (run ./scripts/install-kubectl.sh)"
fi

log_test "Check if helm is installed"
if command -v helm &> /dev/null; then
    VERSION=$(helm version --short 2>/dev/null || echo "installed")
    log_pass "helm is installed: $VERSION"
else
    log_info "helm not installed (run ./scripts/install-helm.sh)"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════════════════

log_section "Verification Summary"

echo -e "${BLUE}Total Checks:${NC}  $TOTAL_CHECKS"
echo -e "${GREEN}Passed:${NC}        $PASSED_CHECKS"
echo -e "${RED}Failed:${NC}        $FAILED_CHECKS"
echo

PASS_RATE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

if [ "$FAILED_CHECKS" -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 ALL CHECKS PASSED! (100%)${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "${GREEN}✅ All improvements are working correctly!${NC}"
    echo
    echo "Next Steps:"
    echo "  1. Test the scripts manually:"
    echo "     ./scripts/gh-doctor.sh"
    echo "     ./scripts/openshift-doctor.sh"
    echo
    echo "  2. Install OpenShift CLI:"
    echo "     ./scripts/install-openshift.sh"
    echo
    echo "  3. Start learning:"
    echo "     cd gh-study/labs && ./lab1-setup.sh"
    echo "     cd openshift-study/labs && ./lab1-setup.sh"
    echo
    exit 0
elif [ "$PASS_RATE" -ge 90 ]; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⚠️  MOSTLY PASSED ($PASS_RATE%)${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "${YELLOW}Minor issues detected. Review failed checks above.${NC}"
    echo
    exit 1
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}❌ SIGNIFICANT ISSUES FOUND ($PASS_RATE%)${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "${RED}Multiple checks failed. Please review the output above.${NC}"
    echo
    exit 1
fi
