#!/bin/bash
# Create a feature PR using GitHub CLI with DevOps best practices

set -e

# Source helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/gh-helpers.sh"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get current branch info
CURRENT_BRANCH=$(git branch --show-current)
BRANCH_TYPE=$(echo $CURRENT_BRANCH | cut -d'/' -f1)
BRANCH_NAME=$(echo $CURRENT_BRANCH | cut -d'/' -f2-)

# Check prerequisites
check_gh_auth || exit 1

echo -e "${GREEN}📝 Create Pull Request for DevOps Demo Project${NC}"
echo "================================================"
echo "Current branch: $CURRENT_BRANCH"
echo

# Determine target branch based on branch type
case $BRANCH_TYPE in
    feature|bugfix)
        TARGET_BRANCH="develop"
        ;;
    hotfix)
        TARGET_BRANCH="main"
        ;;
    release)
        TARGET_BRANCH="main"
        ;;
    *)
        echo -e "${YELLOW}⚠️  Unknown branch type: $BRANCH_TYPE${NC}"
        read -p "Enter target branch [develop]: " TARGET_BRANCH
        TARGET_BRANCH=${TARGET_BRANCH:-develop}
        ;;
esac

echo "Target branch: $TARGET_BRANCH"
echo

# Determine PR type and label
case $BRANCH_TYPE in
    feature)
        PR_PREFIX="feat"
        LABEL="enhancement"
        TYPE_EMOJI="✨"
        ;;
    bugfix)
        PR_PREFIX="fix"
        LABEL="bug"
        TYPE_EMOJI="🐛"
        ;;
    hotfix)
        PR_PREFIX="fix"
        LABEL="bug,hotfix"
        TYPE_EMOJI="🚨"
        ;;
    release)
        PR_PREFIX="chore"
        LABEL="release"
        TYPE_EMOJI="🚀"
        ;;
    *)
        PR_PREFIX="chore"
        LABEL="chore"
        TYPE_EMOJI="🔧"
        ;;
esac

# Generate PR title from branch name
PR_TITLE="$PR_PREFIX: $(echo $BRANCH_NAME | tr '-' ' ')"

echo -e "${YELLOW}📋 PR Details:${NC}"
echo "  Title: $PR_TITLE"
echo "  Label: $LABEL"
echo "  Type: $TYPE_EMOJI $BRANCH_TYPE"
echo

# Check if branch is pushed
if ! git ls-remote --exit-code --heads origin $CURRENT_BRANCH > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Branch not pushed to origin${NC}"
    read -p "Push now? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        git push -u origin $CURRENT_BRANCH
        echo -e "${GREEN}✅ Branch pushed${NC}"
    else
        echo -e "${RED}❌ Cannot create PR without pushing branch${NC}"
        exit 1
    fi
fi

# Get commit messages for PR body
COMMITS=$(git log origin/$TARGET_BRANCH..$CURRENT_BRANCH --pretty=format:"- %s" --no-merges)

if [ -z "$COMMITS" ]; then
    echo -e "${RED}❌ No commits found!${NC}"
    echo "Make sure you have committed changes and your branch is ahead of $TARGET_BRANCH"
    exit 1
fi

# Generate PR body
PR_BODY="## $TYPE_EMOJI Description

<!-- Describe your changes in detail -->

## 📝 Changes

$COMMITS

## 🧪 Type of Change

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🔧 Configuration change
- [ ] ♻️ Code refactoring

## ✅ Testing

- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed
- [ ] CI checks pass

## 📋 Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests added for changes
- [ ] All tests pass locally

## 🔗 Related Issues

<!-- Link related issues: Closes #123, Fixes #456 -->

## 📸 Screenshots (if applicable)

<!-- Add screenshots to help explain your changes -->

## 🚀 Deployment Notes

<!-- Any special deployment considerations -->

---

**Branch:** \`$CURRENT_BRANCH\`
**Target:** \`$TARGET_BRANCH\`"

# Show preview
echo -e "${YELLOW}📄 PR Preview:${NC}"
echo "==============================================="
echo "Title: $PR_TITLE"
echo "-----------------------------------------------"
echo "$PR_BODY"
echo "==============================================="
echo

# Confirm creation
read -p "Create this PR? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "PR creation cancelled"
    exit 0
fi

# Check if draft
read -p "Create as draft? (y/N) " -n 1 -r
echo
DRAFT_FLAG=""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    DRAFT_FLAG="--draft"
fi

# Create PR
echo -e "${YELLOW}🚀 Creating pull request...${NC}"

PR_URL=$(gh pr create \
    --title "$PR_TITLE" \
    --body "$PR_BODY" \
    --base "$TARGET_BRANCH" \
    --head "$CURRENT_BRANCH" \
    --label "$LABEL" \
    $DRAFT_FLAG)

PR_NUMBER=$(echo $PR_URL | grep -o '[0-9]*$')

echo -e "${GREEN}✅ Pull Request created!${NC}"
echo "   URL: $PR_URL"
echo "   Number: #$PR_NUMBER"
echo

# Request reviewers
read -p "Request reviewers? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Available users:"
    gh api repos/:owner/:repo/collaborators --jq '.[].login' | head -10
    echo
    read -p "Enter reviewer usernames (comma-separated): " REVIEWERS
    if [ -n "$REVIEWERS" ]; then
        gh pr edit $PR_NUMBER --add-reviewer "$REVIEWERS"
        echo -e "${GREEN}✅ Reviewers requested${NC}"
    fi
fi

# Auto-assign to self
echo
read -p "Assign to yourself? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    gh pr edit $PR_NUMBER --add-assignee @me
    echo -e "${GREEN}✅ Assigned to you${NC}"
fi

# Open in browser
echo
read -p "Open in browser? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    gh pr view $PR_NUMBER --web
fi

# Summary
echo
echo -e "${GREEN}🎉 Pull Request created successfully!${NC}"
echo "=============================================="
echo
echo "📋 Quick commands:"
echo "  gh pr view $PR_NUMBER              # View PR"
echo "  gh pr view $PR_NUMBER --web        # Open in browser"
echo "  gh pr checks $PR_NUMBER            # Check CI status"
echo "  gh pr ready $PR_NUMBER             # Mark as ready (if draft)"
echo "  gh pr review $PR_NUMBER            # Review PR"
echo "  gh pr merge $PR_NUMBER --squash    # Merge PR"
echo
echo "🔍 Monitor CI:"
echo "  gh pr checks $PR_NUMBER --watch"
echo
echo "💬 Add comments:"
echo "  gh pr comment $PR_NUMBER --body 'Your comment'"
echo
