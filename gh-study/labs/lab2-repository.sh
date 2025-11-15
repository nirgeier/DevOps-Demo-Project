#!/bin/bash
# Lab 2: Repository Management with GitHub CLI
# Learn to create, clone, and manage repositories

set -e

echo "🎓 Lab 2: Repository Management"
echo "================================"
echo

# Check authentication
if ! gh auth status > /dev/null 2>&1; then
    echo "❌ Not authenticated! Run lab1-setup.sh first"
    exit 1
fi

echo "✅ Step 1: List Your Repositories"
echo "=================================="
echo
echo "All your repositories:"
gh repo list --limit 10

echo
echo "📊 With JSON output:"
gh repo list --limit 5 --json name,owner,url | jq '.'

echo
read -p "Press Enter to continue..."

echo
echo "📦 Step 2: View Repository Details"
echo "==================================="
echo
echo "Viewing current repository:"
gh repo view

echo
echo "Repository statistics:"
gh repo view --json name,description,stargazerCount,forkCount,openIssues

echo
read -p "Press Enter to continue..."

echo
echo "🆕 Step 3: Create a Test Repository"
echo "===================================="
echo
TEST_REPO="gh-lab-test-$(date +%s)"
echo "Creating repository: $TEST_REPO"

gh repo create $TEST_REPO \
    --public \
    --description "Test repository for GitHub CLI lab" \
    --add-readme

echo "✅ Repository created!"
echo

echo "📋 Step 4: Clone the Repository"
echo "================================"
echo
TEMP_DIR="/tmp/$TEST_REPO"
gh repo clone $TEST_REPO $TEMP_DIR
echo "✅ Cloned to: $TEMP_DIR"

echo
echo "📝 Step 5: Make Some Changes"
echo "============================"
cd $TEMP_DIR
echo "# GitHub CLI Lab" > TEST.md
echo "This is a test file created during Lab 2" >> TEST.md
git add TEST.md
git commit -m "docs: add test file"
git push
echo "✅ Changes pushed!"

echo
echo "🔍 Step 6: View Repository Again"
echo "================================="
gh repo view

echo
echo "🧹 Step 7: Cleanup"
echo "=================="
echo
read -p "Delete the test repository? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    gh repo delete $TEST_REPO --yes
    rm -rf $TEMP_DIR
    echo "✅ Test repository deleted"
else
    echo "ℹ️  Repository kept: $TEST_REPO"
    echo "   Delete manually: gh repo delete $TEST_REPO --yes"
fi

echo
echo "🎓 Key Commands Learned:"
echo "========================"
echo "  gh repo list              # List repositories"
echo "  gh repo view              # View repo details"
echo "  gh repo create            # Create new repo"
echo "  gh repo clone             # Clone repository"
echo "  gh repo delete            # Delete repository"
echo "  gh repo fork              # Fork repository"
echo
echo "🎉 Lab 2 Complete!"
echo "=================="
echo
echo "Next: Run lab3-issues.sh to learn issue management"
