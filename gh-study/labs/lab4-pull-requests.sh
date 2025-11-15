#!/bin/bash
# Lab 4: Pull Request Workflows with GitHub CLI
# Learn to create, review, and merge pull requests

set -e

echo "🎓 Lab 4: Pull Request Workflows"
echo "================================="
echo

# Check if in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository!"
    exit 1
fi

# Save current branch
ORIGINAL_BRANCH=$(git branch --show-current)

echo "✅ Step 1: List Existing Pull Requests"
echo "======================================="
echo
echo "All open PRs:"
gh pr list

echo
echo "Your PRs:"
gh pr list --author @me

echo
echo "PRs with specific label:"
gh pr list --label enhancement

echo
read -p "Press Enter to continue..."

echo
echo "🆕 Step 2: Create a Feature Branch"
echo "==================================="
echo
BRANCH_NAME="lab4/test-pr-$(date +%s)"
echo "Creating branch: $BRANCH_NAME"
git checkout -b $BRANCH_NAME

echo
echo "📝 Step 3: Make Some Changes"
echo "============================"
echo
TEST_FILE="lab4-test-$(date +%s).md"
cat > $TEST_FILE << 'EOF'
# GitHub CLI Lab 4 Test File

This file was created during Lab 4 to demonstrate PR workflows.

## Features

- Creating branches
- Making commits
- Creating pull requests
- Reviewing PRs
- Merging PRs

## Cleanup

This file and its PR will be cleaned up after the lab.
EOF

git add $TEST_FILE
git commit -m "docs: add Lab 4 test file"
git push -u origin $BRANCH_NAME

echo "✅ Changes pushed to: $BRANCH_NAME"

echo
echo "🔀 Step 4: Create Pull Request"
echo "==============================="
echo
PR_URL=$(gh pr create \
    --title "docs: Add Lab 4 test file" \
    --body "This PR is created as part of GitHub CLI Lab 4.

## Changes
- Added test markdown file
- Demonstrates PR workflow

## Type of Change
- [x] Documentation update
- [ ] Bug fix
- [ ] New feature

## Testing
- [x] Manual testing completed
- [x] Lab verified

This PR can be safely merged or closed after the lab." \
    --label "documentation,lab" \
    --draft)

PR_NUMBER=$(echo $PR_URL | grep -o '[0-9]*$')
echo "✅ Draft PR created: #$PR_NUMBER"
echo "   URL: $PR_URL"

echo
echo "📋 Step 5: View PR Details"
echo "=========================="
echo
gh pr view $PR_NUMBER

echo
echo "View diff:"
gh pr diff $PR_NUMBER

echo
read -p "Press Enter to continue..."

echo
echo "✏️ Step 6: Update the PR"
echo "========================"
echo
echo "Converting from draft to ready..."
gh pr ready $PR_NUMBER

echo "Adding a comment..."
gh pr comment $PR_NUMBER --body "PR is now ready for review! ✅

This was created during Lab 4 to demonstrate GitHub CLI capabilities."

echo "✅ PR updated!"
gh pr view $PR_NUMBER

echo
read -p "Press Enter to continue..."

echo
echo "👀 Step 7: Check PR Status"
echo "=========================="
echo
echo "Checking PR checks/CI status..."
gh pr checks $PR_NUMBER

echo
echo "PR status in JSON:"
gh pr view $PR_NUMBER --json number,title,state,statusCheckRollup | jq '.'

echo
read -p "Press Enter to continue..."

echo
echo "⭐ Step 8: Review the PR"
echo "========================"
echo
echo "Options for review:"
echo "  1. Approve"
echo "  2. Request changes"
echo "  3. Comment only"
echo "  4. Skip review"
echo
read -p "Choose option (1-4): " -n 1 REVIEW_OPTION
echo

case $REVIEW_OPTION in
    1)
        gh pr review $PR_NUMBER --approve --body "Looks good! Lab 4 demonstration complete. ✅"
        echo "✅ PR approved!"
        ;;
    2)
        gh pr review $PR_NUMBER --request-changes --body "Please update the documentation before merging."
        echo "📝 Changes requested"
        ;;
    3)
        gh pr review $PR_NUMBER --comment --body "Great work on this lab exercise!"
        echo "💬 Comment added"
        ;;
    4)
        echo "⏭️  Skipping review"
        ;;
esac

echo
read -p "Press Enter to continue..."

echo
echo "🔀 Step 9: Merge Options"
echo "========================"
echo
echo "Would you like to merge this PR?"
echo "  1. Merge (creates merge commit)"
echo "  2. Squash and merge"
echo "  3. Rebase and merge"
echo "  4. Don't merge (cleanup)"
echo
read -p "Choose option (1-4): " -n 1 MERGE_OPTION
echo

case $MERGE_OPTION in
    1)
        gh pr merge $PR_NUMBER --merge --delete-branch
        echo "✅ PR merged with merge commit!"
        ;;
    2)
        gh pr merge $PR_NUMBER --squash --delete-branch
        echo "✅ PR squashed and merged!"
        ;;
    3)
        gh pr merge $PR_NUMBER --rebase --delete-branch
        echo "✅ PR rebased and merged!"
        ;;
    4)
        gh pr close $PR_NUMBER --comment "Closing this test PR. Lab 4 complete!"
        git push origin --delete $BRANCH_NAME
        echo "✅ PR closed and branch deleted"
        ;;
esac

echo
echo "🧹 Step 10: Cleanup"
echo "==================="
echo
git checkout $ORIGINAL_BRANCH

# If file was merged or PR closed, clean up
if [[ $MERGE_OPTION -ne 4 ]] && [ -f "$TEST_FILE" ]; then
    echo "Test file still exists. You may want to remove it:"
    echo "  git rm $TEST_FILE"
    echo "  git commit -m 'chore: remove lab test file'"
    echo "  git push"
fi

echo
echo "🎓 Key Commands Learned:"
echo "========================"
echo "  gh pr list                # List pull requests"
echo "  gh pr create              # Create new PR"
echo "  gh pr create --draft      # Create draft PR"
echo "  gh pr view 123            # View PR details"
echo "  gh pr diff 123            # View PR diff"
echo "  gh pr ready 123           # Mark PR ready"
echo "  gh pr comment 123         # Add comment"
echo "  gh pr review 123          # Review PR"
echo "  gh pr checks 123          # Check CI status"
echo "  gh pr merge 123           # Merge PR"
echo "  gh pr close 123           # Close PR"
echo "  gh pr checkout 123        # Checkout PR locally"
echo
echo "🎉 Lab 4 Complete!"
echo "=================="
echo
echo "Next: Run lab5-actions.sh to learn GitHub Actions management"
