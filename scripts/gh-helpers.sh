# GitHub CLI Integration Examples for DevOps-Demo-Project
# This file contains reusable GitHub CLI automation scripts

# Source this file in your scripts:
# source scripts/gh-helpers.sh

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if gh is installed and authenticated
check_gh_auth() {
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI not installed!${NC}"
        echo "Install with: ./scripts/install-gh.sh"
        return 1
    fi
    
    if ! gh auth status > /dev/null 2>&1; then
        echo -e "${RED}❌ Not authenticated with GitHub!${NC}"
        echo "Run: gh auth login"
        return 1
    fi
    
    return 0
}

# Create a pull request with standard template
create_devops_pr() {
    local title="$1"
    local body="$2"
    local base="${3:-develop}"
    
    check_gh_auth || return 1
    
    local branch=$(git branch --show-current)
    local type=$(echo $branch | cut -d'/' -f1)
    
    # Determine label based on branch type
    case $type in
        feature) label="enhancement" ;;
        bugfix|hotfix) label="bug" ;;
        release) label="release" ;;
        *) label="chore" ;;
    esac
    
    echo -e "${GREEN}📝 Creating PR: $title${NC}"
    gh pr create \
        --title "$title" \
        --body "$body" \
        --base "$base" \
        --label "$label" \
        --web
}

# Check CI status for current branch
check_ci_status() {
    check_gh_auth || return 1
    
    echo -e "${YELLOW}🔍 Checking CI status...${NC}"
    gh run list --branch $(git branch --show-current) --limit 5
}

# Wait for CI to complete
wait_for_ci() {
    local max_wait="${1:-300}"  # Default 5 minutes
    local interval=10
    local elapsed=0
    
    check_gh_auth || return 1
    
    local branch=$(git branch --show-current)
    echo -e "${YELLOW}⏳ Waiting for CI to complete on $branch...${NC}"
    
    while [ $elapsed -lt $max_wait ]; do
        local status=$(gh run list --branch $branch --limit 1 --json status,conclusion --jq '.[0].status')
        
        if [ "$status" == "completed" ]; then
            local conclusion=$(gh run list --branch $branch --limit 1 --json conclusion --jq '.[0].conclusion')
            if [ "$conclusion" == "success" ]; then
                echo -e "${GREEN}✅ CI passed!${NC}"
                return 0
            else
                echo -e "${RED}❌ CI failed!${NC}"
                return 1
            fi
        fi
        
        echo "Still running... ($elapsed/$max_wait seconds)"
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    
    echo -e "${RED}❌ Timeout waiting for CI${NC}"
    return 1
}

# Create a release with auto-generated notes
create_release() {
    local version="$1"
    local tag="v$version"
    
    check_gh_auth || return 1
    
    echo -e "${GREEN}🚀 Creating release $tag...${NC}"
    
    # Check if tag exists
    if git rev-parse $tag >/dev/null 2>&1; then
        echo -e "${RED}❌ Tag $tag already exists!${NC}"
        return 1
    fi
    
    # Create and push tag
    git tag -a $tag -m "Release $version"
    git push origin $tag
    
    # Create GitHub release
    gh release create $tag \
        --title "Release $version" \
        --generate-notes
    
    echo -e "${GREEN}✅ Release $tag created!${NC}"
}

# List open PRs for current repo
list_open_prs() {
    check_gh_auth || return 1
    
    echo -e "${YELLOW}📋 Open Pull Requests:${NC}"
    gh pr list --state open
}

# Check PR status
pr_status() {
    local pr_number="$1"
    
    check_gh_auth || return 1
    
    if [ -z "$pr_number" ]; then
        echo "Usage: pr_status <pr_number>"
        return 1
    fi
    
    echo -e "${YELLOW}📊 PR #$pr_number Status:${NC}"
    gh pr view $pr_number
    echo
    echo -e "${YELLOW}🔍 Checks:${NC}"
    gh pr checks $pr_number
}

# Auto-merge approved PRs
auto_merge_approved() {
    check_gh_auth || return 1
    
    echo -e "${YELLOW}🔍 Checking for approved PRs...${NC}"
    
    gh pr list --state open --json number,title,reviews,statusCheckRollup | jq -c '.[]' | while read pr; do
        local pr_number=$(echo $pr | jq -r '.number')
        local title=$(echo $pr | jq -r '.title')
        local approved=$(echo $pr | jq '[.reviews[] | select(.state == "APPROVED")] | length')
        
        if [ "$approved" -ge 1 ]; then
            echo -e "${GREEN}✅ PR #$pr_number is approved: $title${NC}"
            
            # Check if CI passed
            local checks_state=$(echo $pr | jq -r '.statusCheckRollup.state // "PENDING"')
            
            if [ "$checks_state" == "SUCCESS" ]; then
                echo "🚀 All checks passed. Merging..."
                gh pr merge $pr_number --squash --delete-branch
                echo -e "${GREEN}✅ Merged!${NC}"
            else
                echo -e "${YELLOW}⏳ Waiting for checks: $checks_state${NC}"
            fi
        fi
    done
}

# Create issue from error log
create_issue_from_error() {
    local title="$1"
    local error_message="$2"
    
    check_gh_auth || return 1
    
    local body="## Error Report

**Timestamp:** $(date)
**Host:** $(hostname)
**Branch:** $(git branch --show-current)

## Error Message

\`\`\`
$error_message
\`\`\`

## Context

Automated error report from DevOps pipeline.
"
    
    echo -e "${YELLOW}🐛 Creating error report issue...${NC}"
    gh issue create \
        --title "$title" \
        --body "$body" \
        --label "bug,automated"
    
    echo -e "${GREEN}✅ Issue created!${NC}"
}

# Trigger workflow
trigger_workflow() {
    local workflow="$1"
    shift
    local inputs="$@"
    
    check_gh_auth || return 1
    
    echo -e "${GREEN}🔄 Triggering workflow: $workflow${NC}"
    gh workflow run $workflow $inputs
    
    echo -e "${GREEN}✅ Workflow triggered!${NC}"
    echo "Monitor with: gh run list --workflow $workflow"
}

# Get latest release version
get_latest_release() {
    check_gh_auth || return 1
    
    gh release view --json tagName -q .tagName 2>/dev/null || echo "none"
}

# Download release artifacts
download_release_artifacts() {
    local tag="$1"
    local dest="${2:-.}"
    
    check_gh_auth || return 1
    
    if [ -z "$tag" ]; then
        echo "Usage: download_release_artifacts <tag> [destination]"
        return 1
    fi
    
    echo -e "${YELLOW}📥 Downloading artifacts from $tag...${NC}"
    gh release download $tag --dir "$dest"
    echo -e "${GREEN}✅ Downloaded to: $dest${NC}"
}

# Export functions
export -f check_gh_auth
export -f create_devops_pr
export -f check_ci_status
export -f wait_for_ci
export -f create_release
export -f list_open_prs
export -f pr_status
export -f auto_merge_approved
export -f create_issue_from_error
export -f trigger_workflow
export -f get_latest_release
export -f download_release_artifacts
