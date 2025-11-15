#!/bin/bash
# Enhanced release workflow using GitHub CLI
# This script automates the complete release process

set -e

# Source helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/gh-helpers.sh"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
VERSION=$1
BASE_BRANCH="${2:-develop}"
TARGET_BRANCH="main"

if [ -z "$VERSION" ]; then
    echo -e "${RED}❌ Usage: $0 <version> [base-branch]${NC}"
    echo "Example: $0 1.0.0"
    echo "Example: $0 1.0.1 main  # For hotfix"
    exit 1
fi

echo -e "${GREEN}🚀 DevOps Demo Project - Automated Release${NC}"
echo "=============================================="
echo "Version: $VERSION"
echo "Base: $BASE_BRANCH → Target: $TARGET_BRANCH"
echo

# Check prerequisites
check_gh_auth || exit 1

# Step 1: Verify we're on the base branch
echo -e "${YELLOW}📍 Step 1: Verify base branch${NC}"
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$BASE_BRANCH" ]; then
    echo -e "${YELLOW}⚠️  Not on $BASE_BRANCH, switching...${NC}"
    git checkout $BASE_BRANCH
    git pull origin $BASE_BRANCH
fi
echo -e "${GREEN}✅ On $BASE_BRANCH${NC}"

# Step 2: Create release branch
RELEASE_BRANCH="release/$VERSION"
echo
echo -e "${YELLOW}📝 Step 2: Create release branch${NC}"
if git show-ref --verify --quiet refs/heads/$RELEASE_BRANCH; then
    echo -e "${RED}❌ Branch $RELEASE_BRANCH already exists!${NC}"
    exit 1
fi

git checkout -b $RELEASE_BRANCH
echo -e "${GREEN}✅ Created $RELEASE_BRANCH${NC}"

# Step 3: Update version in files
echo
echo -e "${YELLOW}🔄 Step 3: Update version files${NC}"

# Update app version
if [ -f "app/main.py" ]; then
    sed -i.bak "s/VERSION = .*/VERSION = os.getenv('APP_VERSION', '$VERSION')/" app/main.py
    rm app/main.py.bak 2>/dev/null || true
    echo "✅ Updated app/main.py"
fi

# Update Chart version
if [ -f "helm/devops-demo/Chart.yaml" ]; then
    sed -i.bak "s/version: .*/version: $VERSION/" helm/devops-demo/Chart.yaml
    sed -i.bak "s/appVersion: .*/appVersion: \"$VERSION\"/" helm/devops-demo/Chart.yaml
    rm helm/devops-demo/Chart.yaml.bak 2>/dev/null || true
    echo "✅ Updated helm/devops-demo/Chart.yaml"
fi

# Update pyproject.toml
if [ -f "pyproject.toml" ]; then
    sed -i.bak "s/version = \".*\"/version = \"$VERSION\"/" pyproject.toml
    rm pyproject.toml.bak 2>/dev/null || true
    echo "✅ Updated pyproject.toml"
fi

# Step 4: Update CHANGELOG
echo
echo -e "${YELLOW}📋 Step 4: Update CHANGELOG${NC}"
if [ -f "CHANGELOG.md" ]; then
    # Get commits since last tag
    LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    
    if [ -n "$LAST_TAG" ]; then
        echo "Generating changelog from $LAST_TAG to HEAD..."
        CHANGES=$(git log $LAST_TAG..HEAD --pretty=format:"- %s (%h)" --no-merges)
    else
        echo "No previous tag found, generating from all commits..."
        CHANGES=$(git log --pretty=format:"- %s (%h)" --no-merges --max-count=20)
    fi
    
    # Add new version to changelog
    {
        echo "## [$VERSION] - $(date +%Y-%m-%d)"
        echo
        echo "$CHANGES"
        echo
        cat CHANGELOG.md
    } > CHANGELOG.md.new
    mv CHANGELOG.md.new CHANGELOG.md
    
    echo -e "${GREEN}✅ Updated CHANGELOG.md${NC}"
else
    echo -e "${YELLOW}⚠️  CHANGELOG.md not found, skipping${NC}"
fi

# Step 5: Commit changes
echo
echo -e "${YELLOW}💾 Step 5: Commit changes${NC}"
git add -A
git commit -m "chore: bump version to $VERSION

- Update version in app/main.py
- Update Helm chart version
- Update pyproject.toml
- Update CHANGELOG.md

Prepared for release v$VERSION"

echo -e "${GREEN}✅ Changes committed${NC}"

# Step 6: Push release branch
echo
echo -e "${YELLOW}🚀 Step 6: Push release branch${NC}"
git push -u origin $RELEASE_BRANCH
echo -e "${GREEN}✅ Pushed to origin/$RELEASE_BRANCH${NC}"

# Step 7: Create Pull Request
echo
echo -e "${YELLOW}📬 Step 7: Create Pull Request to $TARGET_BRANCH${NC}"

PR_BODY="## Release $VERSION

This PR contains the release preparation for version $VERSION.

### Changes
$(git log $BASE_BRANCH..$RELEASE_BRANCH --pretty=format:"- %s" --no-merges)

### Checklist
- [x] Version bumped in all files
- [x] CHANGELOG updated
- [ ] All tests pass (verify CI)
- [ ] Documentation updated
- [ ] Ready for review

### Deployment
After merging this PR:
1. Tag \`v$VERSION\` will be created automatically
2. Docker image will be built and pushed to GHCR
3. GitHub release will be created
4. Helm values will be updated
5. ArgoCD will sync and deploy

**Merging this PR will trigger production deployment!**

---

*Automated release PR created by DevOps workflow*"

PR_URL=$(gh pr create \
    --title "Release $VERSION" \
    --body "$PR_BODY" \
    --base $TARGET_BRANCH \
    --head $RELEASE_BRANCH \
    --label "release" \
    --assignee @me)

PR_NUMBER=$(echo $PR_URL | grep -o '[0-9]*$')

echo -e "${GREEN}✅ Pull Request created!${NC}"
echo "   URL: $PR_URL"
echo "   Number: #$PR_NUMBER"

# Step 8: Wait for CI
echo
echo -e "${YELLOW}⏳ Step 8: Waiting for CI checks...${NC}"
echo "You can monitor the CI status with:"
echo "  gh pr checks $PR_NUMBER --watch"
echo
read -p "Wait for CI to complete? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    gh pr checks $PR_NUMBER --watch
    
    # Check if all passed
    FAILED=$(gh pr checks $PR_NUMBER --json state,conclusion --jq '[.[] | select(.state == "COMPLETED" and .conclusion != "SUCCESS")] | length')
    
    if [ "$FAILED" -eq 0 ]; then
        echo -e "${GREEN}✅ All CI checks passed!${NC}"
    else
        echo -e "${RED}❌ Some CI checks failed!${NC}"
        gh pr checks $PR_NUMBER
        exit 1
    fi
fi

# Step 9: Request reviews
echo
echo -e "${YELLOW}👥 Step 9: Request reviews${NC}"
echo "PR is ready for review. The following will happen after merge:"
echo "  1. Tag v$VERSION will be created"
echo "  2. Docker image will be built"
echo "  3. Release will be published"
echo "  4. Changes will be merged back to $BASE_BRANCH"
echo
echo "Open PR in browser to review:"
echo "  gh pr view $PR_NUMBER --web"
echo
read -p "Auto-merge when approved and CI passes? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    gh pr merge $PR_NUMBER --auto --squash
    echo -e "${GREEN}✅ Auto-merge enabled!${NC}"
    echo "PR will merge automatically when:"
    echo "  • All required reviews are approved"
    echo "  • All CI checks pass"
    echo "  • No conflicts exist"
fi

# Summary
echo
echo -e "${GREEN}🎉 Release workflow initiated successfully!${NC}"
echo "=============================================="
echo
echo "📋 Summary:"
echo "  Version: $VERSION"
echo "  Branch: $RELEASE_BRANCH"
echo "  PR: #$PR_NUMBER"
echo "  URL: $PR_URL"
echo
echo "📝 Next steps:"
echo "  1. Review the PR: gh pr view $PR_NUMBER --web"
echo "  2. Approve the PR (or request approval)"
echo "  3. Merge the PR manually or wait for auto-merge"
echo "  4. Monitor deployment: gh run list --workflow cd.yml"
echo
echo "🔍 Monitor progress:"
echo "  gh pr view $PR_NUMBER        # View PR status"
echo "  gh pr checks $PR_NUMBER      # Check CI status"
echo "  gh pr merge $PR_NUMBER       # Merge when ready"
echo
