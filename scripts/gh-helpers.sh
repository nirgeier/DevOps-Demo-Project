#!/usr/bin/env bash

###############################################################################
# GitHub CLI Helper Functions
# Reusable functions for GitHub automation and workflow management
###############################################################################

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

# Check if gh is installed and authenticated
check_gh_auth() {
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) not found. Install with: ./scripts/install-gh.sh"
        return 1
    fi
    
    if ! gh auth status &> /dev/null; then
        log_error "Not authenticated with GitHub. Run: gh auth login"
        return 1
    fi
    
    return 0
}

# Check if in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir &> /dev/null; then
        log_error "Not in a git repository"
        return 1
    fi
    return 0
}

# Get current branch name
get_current_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null
}

# Get default branch name (main or master)
get_default_branch() {
    git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"
}

# Get repository owner and name
get_repo_info() {
    gh repo view --json owner,name --jq '.owner.login + "/" + .name' 2>/dev/null
}

# Check if branch exists
branch_exists() {
    local branch=$1
    git rev-parse --verify "$branch" &> /dev/null
}

# Check if remote branch exists
remote_branch_exists() {
    local branch=$1
    git ls-remote --heads origin "$branch" | grep -q "$branch"
}

# Create and push branch
create_and_push_branch() {
    local branch=$1
    local base_branch=${2:-$(get_default_branch)}
    
    if branch_exists "$branch"; then
        log_warn "Branch $branch already exists locally"
        return 1
    fi
    
    git checkout -b "$branch" "$base_branch"
    git push -u origin "$branch"
}

# Check CI status for a branch
check_ci_status() {
    local branch=${1:-$(get_current_branch)}
    
    log_info "Checking CI status for branch: $branch"
    
    if gh run list --branch "$branch" --limit 1 --json status,conclusion,name 2>/dev/null; then
        return 0
    else
        log_warn "No CI runs found for branch: $branch"
        return 1
    fi
}

# Wait for CI to complete
wait_for_ci() {
    local branch=${1:-$(get_current_branch)}
    local timeout=${2:-600}  # 10 minutes default
    
    log_info "Waiting for CI to complete on branch: $branch"
    
    local start_time=$(date +%s)
    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [ $elapsed -gt $timeout ]; then
            log_error "CI timeout after $timeout seconds"
            return 1
        fi
        
        local status=$(gh run list --branch "$branch" --limit 1 --json status --jq '.[0].status' 2>/dev/null)
        
        if [ "$status" = "completed" ]; then
            local conclusion=$(gh run list --branch "$branch" --limit 1 --json conclusion --jq '.[0].conclusion' 2>/dev/null)
            if [ "$conclusion" = "success" ]; then
                log_info "✅ CI passed!"
                return 0
            else
                log_error "❌ CI failed with conclusion: $conclusion"
                return 1
            fi
        fi
        
        log_info "CI status: $status (elapsed: ${elapsed}s)"
        sleep 10
    done
}

# Create PR with template
create_devops_pr() {
    local title=$1
    local body=$2
    local base=${3:-develop}
    local draft=${4:-false}
    
    local pr_args=(
        --title "$title"
        --body "$body"
        --base "$base"
    )
    
    if [ "$draft" = "true" ]; then
        pr_args+=(--draft)
    fi
    
    gh pr create "${pr_args[@]}"
}

# List open PRs
list_open_prs() {
    log_section "Open Pull Requests"
    gh pr list --state open
}

# Check PR status
pr_status() {
    local pr_number=$1
    
    if [ -z "$pr_number" ]; then
        log_error "PR number required"
        return 1
    fi
    
    gh pr view "$pr_number" --json number,title,state,isDraft,mergeable,reviews,statusCheckRollup
}

# Auto-merge PR when approved
auto_merge_approved() {
    local pr_number=$1
    local merge_method=${2:-squash}  # squash, merge, or rebase
    
    if [ -z "$pr_number" ]; then
        log_error "PR number required"
        return 1
    fi
    
    log_info "Enabling auto-merge for PR #$pr_number with method: $merge_method"
    
    gh pr merge "$pr_number" --auto --"$merge_method" --delete-branch
}

# Create release
create_release() {
    local tag=$1
    local title=$2
    local notes=${3:-""}
    local draft=${4:-false}
    local prerelease=${5:-false}
    
    if [ -z "$tag" ]; then
        log_error "Tag required"
        return 1
    fi
    
    local release_args=(
        "$tag"
        --title "$title"
    )
    
    if [ -n "$notes" ]; then
        release_args+=(--notes "$notes")
    else
        release_args+=(--generate-notes)
    fi
    
    if [ "$draft" = "true" ]; then
        release_args+=(--draft)
    fi
    
    if [ "$prerelease" = "true" ]; then
        release_args+=(--prerelease)
    fi
    
    gh release create "${release_args[@]}"
}

# Get latest release
get_latest_release() {
    gh release view --json tagName --jq '.tagName' 2>/dev/null || echo ""
}

# Bump version
bump_version() {
    local version=$1
    local bump_type=${2:-patch}  # major, minor, or patch
    
    if [ -z "$version" ]; then
        log_error "Version required"
        return 1
    fi
    
    # Remove 'v' prefix if present
    version=${version#v}
    
    IFS='.' read -r major minor patch <<< "$version"
    
    case "$bump_type" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            log_error "Invalid bump type: $bump_type (use: major, minor, patch)"
            return 1
            ;;
    esac
    
    echo "v$major.$minor.$patch"
}

# Generate changelog
generate_changelog() {
    local from_tag=${1:-$(get_latest_release)}
    local to_ref=${2:-HEAD}
    
    if [ -z "$from_tag" ]; then
        log_warn "No previous release found, generating full changelog"
        git log --pretty=format:"- %s (%h)" "$to_ref"
    else
        log_info "Generating changelog from $from_tag to $to_ref"
        git log --pretty=format:"- %s (%h)" "$from_tag..$to_ref"
    fi
}

# Trigger workflow
trigger_workflow() {
    local workflow_name=$1
    local ref=${2:-$(get_current_branch)}
    
    if [ -z "$workflow_name" ]; then
        log_error "Workflow name required"
        return 1
    fi
    
    log_info "Triggering workflow: $workflow_name on ref: $ref"
    gh workflow run "$workflow_name" --ref "$ref"
}

# Download workflow artifacts
download_artifacts() {
    local run_id=${1:-$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')}
    local dest_dir=${2:-.}
    
    if [ -z "$run_id" ]; then
        log_error "Run ID required"
        return 1
    fi
    
    log_info "Downloading artifacts from run: $run_id to $dest_dir"
    gh run download "$run_id" --dir "$dest_dir"
}

# Export functions for sourcing
export -f check_gh_auth
export -f check_git_repo
export -f get_current_branch
export -f get_default_branch
export -f get_repo_info
export -f branch_exists
export -f remote_branch_exists
export -f create_and_push_branch
export -f check_ci_status
export -f wait_for_ci
export -f create_devops_pr
export -f list_open_prs
export -f pr_status
export -f auto_merge_approved
export -f create_release
export -f get_latest_release
export -f bump_version
export -f generate_changelog
export -f trigger_workflow
export -f download_artifacts

log_info "GitHub helper functions loaded successfully"
