#!/bin/bash
# Lab 3: Issue Management with GitHub CLI
# Learn to create, list, and manage issues

set -e

echo "🎓 Lab 3: Issue Management"
echo "=========================="
echo

# Check if in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository!"
    echo "   Please run this script from your project directory"
    exit 1
fi

echo "✅ Step 1: List Existing Issues"
echo "================================"
echo
echo "All open issues:"
gh issue list

echo
echo "Issues assigned to you:"
gh issue list --assignee @me

echo
echo "Issues with 'bug' label:"
gh issue list --label bug

echo
read -p "Press Enter to continue..."

echo
echo "🆕 Step 2: Create a New Issue"
echo "=============================="
echo
echo "Creating a sample bug issue..."

ISSUE_NUMBER=$(gh issue create \
    --title "Bug: Sample issue for Lab 3" \
    --body "This is a test issue created during the GitHub CLI lab.

## Description
Sample issue to demonstrate GitHub CLI capabilities.

## Steps to Reproduce
1. Run lab3-issues.sh
2. Observe this issue being created

## Expected Behavior
Issue should be created successfully.

## Actual Behavior
Issue created! 🎉" \
    --label "bug,lab" \
    --assignee @me | grep -o '[0-9]*$')

echo "✅ Issue created: #$ISSUE_NUMBER"

echo
echo "📋 Step 3: View Issue Details"
echo "=============================="
echo
gh issue view $ISSUE_NUMBER

echo
echo "With JSON output:"
gh issue view $ISSUE_NUMBER --json number,title,state,labels,assignees | jq '.'

echo
read -p "Press Enter to continue..."

echo
echo "💬 Step 4: Add a Comment"
echo "========================"
echo
gh issue comment $ISSUE_NUMBER --body "Adding a comment via GitHub CLI! 💻

This demonstrates how to interact with issues programmatically."

echo "✅ Comment added!"

echo
echo "View with comments:"
gh issue view $ISSUE_NUMBER --comments

echo
read -p "Press Enter to continue..."

echo
echo "✏️ Step 5: Update the Issue"
echo "==========================="
echo
echo "Adding another label..."
gh issue edit $ISSUE_NUMBER --add-label "documentation"

echo "Updating title..."
gh issue edit $ISSUE_NUMBER --title "Bug: Sample issue for Lab 3 (Updated)"

echo "✅ Issue updated!"
gh issue view $ISSUE_NUMBER

echo
read -p "Press Enter to continue..."

echo
echo "✅ Step 6: Close the Issue"
echo "=========================="
echo
read -p "Close the test issue? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    gh issue close $ISSUE_NUMBER --comment "Closing this test issue. Lab 3 complete! 🎉"
    echo "✅ Issue #$ISSUE_NUMBER closed"
else
    echo "ℹ️  Issue kept open: #$ISSUE_NUMBER"
    echo "   Close manually: gh issue close $ISSUE_NUMBER"
fi

echo
echo "🎓 Key Commands Learned:"
echo "========================"
echo "  gh issue list             # List issues"
echo "  gh issue list --assignee @me  # Your issues"
echo "  gh issue list --label bug     # Filter by label"
echo "  gh issue create           # Create new issue"
echo "  gh issue view 123         # View issue details"
echo "  gh issue comment 123      # Add comment"
echo "  gh issue edit 123         # Update issue"
echo "  gh issue close 123        # Close issue"
echo "  gh issue reopen 123       # Reopen issue"
echo
echo "🎉 Lab 3 Complete!"
echo "=================="
echo
echo "Next: Run lab4-pull-requests.sh to learn PR management"
