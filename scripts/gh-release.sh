#!/usr/bin/env bash

###############################################################################
# Create GitHub Release
# Automates release creation with version management
###############################################################################

set -euo pipefail

# Source helper functions
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/gh-helpers.sh"

# Main function
main() {
    local version=$1
    
    if [ -z "$version" ]; then
        log_error "Usage: $0 <version>"
        log_info "Example: $0 1.0.0"
        exit 1
    fi
    
    log_section "Create Release: v$version"
    
    # Check prerequisites
    check_gh_auth || exit 1
    check_git_repo || exit 1
    
    # Create release tag
    log_info "Creating release tag: v$version"
    git tag -a "v$version" -m "Release v$version"
    git push origin "v$version"
    
    # Create GitHub release
    log_info "Creating GitHub release..."
    gh release create "v$version" --generate-notes --title "Release v$version"
    
    log_info "✅ Release v$version created successfully!"
}

# Run main function
main "$@"
