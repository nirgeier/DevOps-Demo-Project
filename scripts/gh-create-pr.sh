#!/usr/bin/env bash

###############################################################################
# Create GitHub Pull Request
# Automates PR creation with proper labeling and template
###############################################################################

set -euo pipefail

# Source helper functions
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/gh-helpers.sh"

# Main function
main() {
    log_section "Create Pull Request"
    
    # Check prerequisites
    check_gh_auth || exit 1
    check_git_repo || exit 1
    
    # Get current branch
    CURRENT_BRANCH=$(get_current_branch)
    log_info "Current branch: $CURRENT_BRANCH"
    
    # Detect PR type from branch name
    if [[ "$CURRENT_BRANCH" == feature/* ]]; then
        PR_TYPE="feature"
        BASE_BRANCH="develop"
    elif [[ "$CURRENT_BRANCH" == bugfix/* ]] || [[ "$CURRENT_BRANCH" == fix/* ]]; then
        PR_TYPE="bugfix"
        BASE_BRANCH="develop"
    elif [[ "$CURRENT_BRANCH" == hotfix/* ]]; then
        PR_TYPE="hotfix"
        BASE_BRANCH="main"
    elif [[ "$CURRENT_BRANCH" == release/* ]]; then
        PR_TYPE="release"
        BASE_BRANCH="main"
    else
        PR_TYPE="other"
        BASE_BRANCH="develop"
    fi
    
    log_info "PR type detected: $PR_TYPE"
    log_info "Target branch: $BASE_BRANCH"
    
    # Create PR
    log_info "Creating pull request..."
    gh pr create --base "$BASE_BRANCH" --fill
    
    log_info "✅ Pull request created successfully!"
}

# Run main function
main "$@"
