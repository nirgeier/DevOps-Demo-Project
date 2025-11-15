# GitHub CLI (gh) Mastery Guide 🚀

> **Complete hands-on guide to becoming a GitHub CLI expert with practical labs and real-world DevOps integration**

![GitHub CLI](https://img.shields.io/badge/GitHub-CLI-blue?logo=github)
![Shell](https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh-green)
![DevOps](https://img.shields.io/badge/DevOps-Ready-orange)

## 📋 Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Authentication](#authentication)
- [Core Concepts](#core-concepts)
- [Command Structure](#command-structure)
- [Lab Exercises](#lab-exercises)
  - [Lab 1: Basic Setup & Authentication](#lab-1-basic-setup--authentication)
  - [Lab 2: Repository Management](#lab-2-repository-management)
  - [Lab 3: Issue & Project Management](#lab-3-issue--project-management)
  - [Lab 4: Pull Request Workflows](#lab-4-pull-request-workflows)
  - [Lab 5: GitHub Actions & CI/CD](#lab-5-github-actions--cicd)
  - [Lab 6: Release Management](#lab-6-release-management)
  - [Lab 7: Advanced Automation](#lab-7-advanced-automation)
  - [Lab 8: Extensions & Customization](#lab-8-extensions--customization)
- [Real-World Integration](#real-world-integration)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Cheat Sheet](#cheat-sheet)
- [Resources](#resources)

---

## 🎯 Introduction

GitHub CLI (`gh`) is a powerful command-line tool that brings GitHub functionality to your terminal. It's essential for:

- **DevOps Automation**: Integrate GitHub operations into CI/CD pipelines
- **Developer Productivity**: Streamline common Git workflows
- **CI/CD Integration**: Automate releases, PRs, and deployments
- **Team Collaboration**: Manage issues, reviews, and projects efficiently

### Why GitHub CLI?

✅ **Faster workflow** - No context switching to browser  
✅ **Scriptable** - Automate repetitive tasks  
✅ **CI/CD friendly** - Perfect for GitHub Actions  
✅ **Powerful** - Access full GitHub API  
✅ **Extensible** - Create custom extensions

---

## 📦 Installation

### macOS (Homebrew)
```bash
brew install gh
```

### Linux (Debian/Ubuntu)
```bash
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y
```

### Other Methods
```bash
# Windows (Scoop)
scoop install gh

# Windows (Chocolatey)
choco install gh

# From source
go install github.com/cli/cli/v2/cmd/gh@latest
```

### Verify Installation
```bash
gh --version
# gh version 2.x.x (latest)
```

---

## 🔐 Authentication

### Initial Setup
```bash
# Interactive authentication
gh auth login

# Select options:
# - GitHub.com (or GitHub Enterprise)
# - HTTPS (recommended) or SSH
# - Authenticate via browser (easiest)
# - Choose default git protocol
```

### Token-Based Authentication
```bash
# Using environment variable
export GH_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"

# Using echo for non-interactive
echo "ghp_xxxxxxxxxxxxxxxxxxxx" | gh auth login --with-token

# Check authentication status
gh auth status
```

### Multiple Accounts
```bash
# Login to multiple accounts
gh auth login --hostname github.com --user account1
gh auth login --hostname github.com --user account2

# Switch between accounts
gh auth switch --user account1
```

---

## 🧩 Core Concepts

### Command Categories

```
gh <command> <subcommand> [flags]
```

| Category | Commands | Purpose |
|----------|----------|---------|
| **Repositories** | `repo` | Create, clone, fork, view repos |
| **Issues** | `issue` | Create, list, view, close issues |
| **Pull Requests** | `pr` | Create, review, merge, check PRs |
| **Releases** | `release` | Create, list, download releases |
| **Actions** | `run`, `workflow` | Manage GitHub Actions |
| **Gists** | `gist` | Create and manage gists |
| **API** | `api` | Call GitHub REST/GraphQL API |
| **Auth** | `auth` | Authenticate with GitHub |

### Output Formats

```bash
# Default: Human-readable
gh repo list

# JSON output (scriptable)
gh repo list --json name,owner,url

# Template output (custom format)
gh repo list --template '{{range .}}{{.name}}: {{.url}}{{"\n"}}{{end}}'

# JQ processing
gh repo list --json name,url | jq '.[] | select(.name | contains("demo"))'
```

---

## 🔬 Lab Exercises

### Lab 1: Basic Setup & Authentication

**Objective**: Install, authenticate, and configure GitHub CLI

#### Tasks:

1️⃣ **Install GitHub CLI**
```bash
# macOS
brew install gh

# Verify
gh --version
```

2️⃣ **Authenticate with GitHub**
```bash
# Interactive login
gh auth login

# Follow prompts:
# - Select GitHub.com
# - Choose HTTPS
# - Authenticate via browser
```

3️⃣ **Verify Authentication**
```bash
# Check status
gh auth status

# Test with a simple command
gh repo list

# View authenticated user
gh api user --jq '.login'
```

4️⃣ **Configure Defaults**
```bash
# Set default repo (in a repo directory)
gh repo set-default

# Set default editor
gh config set editor vim

# Set default git protocol
gh config set git_protocol https

# View all configs
gh config list
```

5️⃣ **Enable Autocompletion**
```bash
# For bash
gh completion -s bash > /usr/local/etc/bash_completion.d/gh

# For zsh
gh completion -s zsh > /usr/local/share/zsh/site-functions/_gh

# Reload shell
source ~/.zshrc  # or ~/.bashrc
```

**✅ Verification**:
```bash
gh auth status
gh config list
gh --help
```

**Expected Output**:
```
✓ Logged in to github.com as your-username
✓ Git operations for github.com configured to use https protocol.
✓ Token: *******************

editor=vim
git_protocol=https
pager=less

Work seamlessly with GitHub from the command line.
```

---

### Lab 2: Repository Management

**Objective**: Master repository operations with GitHub CLI

#### Tasks:

1️⃣ **View Repository Information**
```bash
# View current repo
gh repo view

# View specific repo
gh repo view owner/repo

# View in browser
gh repo view --web

# Get repo as JSON
gh repo view --json name,description,url,stargazerCount
```

**Expected Output**:
```
nirgeier/DevOps-Demo-Project
A complete DevOps CI/CD pipeline demonstration project

  Python Flask application with Docker, Kubernetes, and ArgoCD

VIEW ON GITHUB
  https://github.com/nirgeier/DevOps-Demo-Project

  ✓ 5 stars  ✓ 2 forks  ✓ 3 open issues
  Updated: 2 hours ago
```

2️⃣ **List Repositories**
```bash
# List your repos
gh repo list

# List with filters
gh repo list --limit 50
gh repo list --public
gh repo list --private
gh repo list --source  # Exclude forks
gh repo list --archived

# List specific user's repos
gh repo list nirgeier

# Format output
gh repo list --json name,url,stargazerCount
```

3️⃣ **Create a New Repository**
```bash
# Interactive creation
gh repo create

# Create with flags
gh repo create my-new-repo --public --description "My demo repo"

# Create and clone
gh repo create my-new-repo --public --clone

# Create from template
gh repo create my-project --template owner/template-repo

# Create with README
gh repo create my-repo --public --add-readme

# Create with .gitignore
gh repo create my-repo --public --gitignore Python
```

4️⃣ **Clone Repositories**
```bash
# Clone your repo
gh repo clone my-repo

# Clone with org/user
gh repo clone nirgeier/DevOps-Demo-Project

# Clone to specific directory
gh repo clone owner/repo target-dir
```

5️⃣ **Fork Repositories**
```bash
# Fork a repo
gh repo fork owner/repo

# Fork and clone
gh repo fork owner/repo --clone

# Fork and add remote
gh repo fork owner/repo --remote
```

6️⃣ **Archive & Delete**
```bash
# Archive a repo
gh repo archive owner/repo

# Delete a repo (careful!)
gh repo delete owner/repo --yes
```

**✅ Practice Exercise**:
```bash
# Create a test repository
gh repo create gh-lab-test --public --description "GitHub CLI Lab Test"

# Clone it
gh repo clone gh-lab-test
cd gh-lab-test

# View details
gh repo view

# Clean up
cd ..
gh repo delete gh-lab-test --yes
```

---

### Lab 3: Issue & Project Management

**Objective**: Efficiently manage issues and track work

#### Tasks:

1️⃣ **List Issues**
```bash
# List all issues
gh issue list

# Filter by state
gh issue list --state open
gh issue list --state closed
gh issue list --state all
```

**Expected Output**:
```
Showing 5 of 5 open issues in nirgeier/DevOps-Demo-Project

#15  Bug: Login fails with special characters     bug            about 2 hours ago
#14  Feature: Add user profile page              enhancement    about 5 hours ago
#13  Documentation: Update API guide              documentation  about 1 day ago
#12  CI: Fix flaky test in test_main.py          ci/cd          about 2 days ago
#11  Enhancement: Improve error messages         enhancement    about 3 days ago

# Filter by assignee
gh issue list --assignee @me
gh issue list --assignee username

# Filter by label
gh issue list --label bug
gh issue list --label "good first issue"

# Filter by author
gh issue list --author username

# Limit results
gh issue list --limit 20

# JSON output
gh issue list --json number,title,state,labels
```

2️⃣ **View Issue Details**
```bash
# View issue
gh issue view 123

# View in browser
gh issue view 123 --web

# Get JSON data
gh issue view 123 --json number,title,body,state,labels,assignees

# View comments
gh issue view 123 --comments
```

3️⃣ **Create Issues**
```bash
# Interactive creation
gh issue create

# With flags
gh issue create --title "Bug: App crashes on startup" \
  --body "Description of the bug..." \
  --label bug \
  --assignee @me

# From file
gh issue create --title "Feature request" --body-file issue-template.md

# With multiple labels
gh issue create --title "Enhancement" \
  --body "Add new feature" \
  --label enhancement,priority-high

# Assign to multiple users
gh issue create --title "Team task" \
  --body "Collaborative work" \
  --assignee user1,user2

# Add to project
gh issue create --title "Sprint task" \
  --body "Task description" \
  --project "Sprint 1"
```

4️⃣ **Update Issues**
```bash
# Close an issue
gh issue close 123

# Reopen an issue
gh issue reopen 123

# Add comment
gh issue comment 123 --body "This is fixed in PR #124"

# Edit issue
gh issue edit 123 --title "New title"
gh issue edit 123 --body "Updated description"
gh issue edit 123 --add-label bug
gh issue edit 123 --remove-label enhancement
gh issue edit 123 --add-assignee username
```

5️⃣ **Issue Status Updates**
```bash
# Pin issue
gh issue pin 123

# Unpin issue
gh issue unpin 123

# Lock conversation
gh issue lock 123 --reason spam

# Unlock conversation
gh issue unlock 123

# Transfer issue to another repo
gh issue transfer 123 owner/other-repo
```

**✅ Practice Exercise**:
```bash
# Create a bug issue
gh issue create \
  --title "Bug: Login fails with special characters" \
  --body "When using @ symbol in username, login fails" \
  --label bug,priority-high \
  --assignee @me

# List your issues
gh issue list --assignee @me

# View the created issue
gh issue view 1

# Add a comment
gh issue comment 1 --body "Working on a fix"

# Close when done
gh issue close 1 --comment "Fixed in commit abc123"
```

---

### Lab 4: Pull Request Workflows

**Objective**: Master the PR workflow from creation to merge

#### Tasks:

1️⃣ **List Pull Requests**
```bash
# List all PRs
gh pr list

# Filter by state
gh pr list --state open
gh pr list --state closed
gh pr list --state merged
gh pr list --state all
```

**Expected Output**:
```
Showing 3 of 3 open pull requests in nirgeier/DevOps-Demo-Project

#42  feat: Add health endpoint documentation    feature/health-docs     about 1 hour ago
#41  fix: Resolve Docker build issue            bugfix/docker-fix       about 3 hours ago
#40  chore: Update dependencies                 chore/deps-update       about 1 day ago

# Filter by author
gh pr list --author @me
gh pr list --author username

# Filter by assignee
gh pr list --assignee @me

# Filter by label
gh pr list --label bug

# Filter by base branch
gh pr list --base main
gh pr list --base develop

# Search PRs
gh pr list --search "fix bug"

# JSON output
gh pr list --json number,title,state,headRefName
```

2️⃣ **View Pull Request**
```bash
# View PR details
gh pr view 42

# View in browser
gh pr view 42 --web

# View diff
gh pr diff 42

# View comments
gh pr view 42 --comments

# Get JSON data
gh pr view 42 --json number,title,body,state,reviews,commits
```

3️⃣ **Create Pull Request**
```bash
# Interactive creation
gh pr create

# With flags
gh pr create --title "Fix: Resolve login bug" \
  --body "This PR fixes the login issue by..." \
  --base main \
  --head feature/fix-login

# From current branch
git checkout -b feature/new-feature
# ... make changes ...
git push -u origin feature/new-feature
gh pr create --fill  # Uses commit message as title/body

# Draft PR
gh pr create --draft --title "WIP: New feature"

# With reviewers
gh pr create --title "Add tests" \
  --body "Comprehensive test suite" \
  --reviewer user1,user2

# With assignees
gh pr create --title "Feature" \
  --assignee @me \
  --reviewer reviewer1

# From template
gh pr create --template .github/pull_request_template.md

# Auto-merge when checks pass
gh pr create --title "Update deps" \
  --body "Dependency updates" \
  --auto-merge
```

4️⃣ **Review Pull Requests**
```bash
# Checkout PR locally
gh pr checkout 42

# Review with comments
gh pr review 42

# Approve PR
gh pr review 42 --approve

# Request changes
gh pr review 42 --request-changes --body "Please fix the tests"

# Comment without approval
gh pr review 42 --comment --body "Looks good overall"

# Approve with comment
gh pr review 42 --approve --body "LGTM! 🚀"
```

5️⃣ **Check PR Status**
```bash
# View PR checks
gh pr checks 42

# View specific check
gh pr checks 42 --watch

# Wait for checks to complete
gh pr checks 42 --interval 10
```

6️⃣ **Merge Pull Request**
```bash
# Merge PR (creates merge commit)
gh pr merge 42

# Squash and merge
gh pr merge 42 --squash

# Rebase and merge
gh pr merge 42 --rebase

# Merge and delete branch
gh pr merge 42 --squash --delete-branch

# Auto-merge when ready
gh pr merge 42 --auto --squash

# Merge with custom commit message
gh pr merge 42 --squash --subject "feat: add new feature" --body "Complete implementation"
```

7️⃣ **Update Pull Request**
```bash
# Edit PR
gh pr edit 42 --title "New title"
gh pr edit 42 --body "Updated description"
gh pr edit 42 --add-label bug
gh pr edit 42 --remove-label enhancement
gh pr edit 42 --add-reviewer user1
gh pr edit 42 --add-assignee @me

# Mark as ready (from draft)
gh pr ready 42

# Close without merging
gh pr close 42

# Reopen closed PR
gh pr reopen 42
```

8️⃣ **PR Comments**
```bash
# Add comment
gh pr comment 42 --body "Please update the documentation"

# Add comment to specific line
gh pr comment 42 --body "Fix this typo" --line 15 --file src/main.py
```

**✅ Complete PR Workflow Exercise**:
```bash
# 1. Create feature branch
git checkout -b feature/add-health-endpoint

# 2. Make changes
echo "# Health endpoint" >> README.md
git add README.md
git commit -m "feat: add health endpoint documentation"
git push -u origin feature/add-health-endpoint

# 3. Create PR
gh pr create \
  --title "feat: Add health endpoint documentation" \
  --body "Adds comprehensive docs for the health endpoint" \
  --label documentation \
  --reviewer teammate

# 4. Check PR status
gh pr view

# 5. Check CI status
gh pr checks --watch

# 6. Self-review (on another machine/account)
gh pr review --approve --body "Documentation looks great!"

# 7. Merge when ready
gh pr merge --squash --delete-branch

# 8. Switch back to main
git checkout main
git pull
```

---

### Lab 5: GitHub Actions & CI/CD

**Objective**: Manage GitHub Actions workflows via CLI

#### Tasks:

1️⃣ **List Workflows**
```bash
# List all workflows
gh workflow list

# View workflow details
gh workflow view ci.yml

# View in browser
gh workflow view ci.yml --web
```

**Expected Output**:
```
ci.yml        CI - Build and Test                     active  45
cd.yml        CD - Build and Deploy                   active  32
release.yml   Release Management                      active  15
gitflow.yml   GitFlow - Branch Validation             active  89
```

2️⃣ **Run Workflows**
```bash
# Run workflow manually
gh workflow run ci.yml

# Run with inputs
gh workflow run release.yml --field version=1.0.0

# Run on specific branch
gh workflow run ci.yml --ref develop
```

3️⃣ **List Workflow Runs**
```bash
# List all runs
gh run list

# List runs for specific workflow
gh run list --workflow ci.yml

# Filter by status
gh run list --status success
gh run list --status failure
gh run list --status in_progress

# Filter by branch
gh run list --branch main

# Limit results
gh run list --limit 20

# JSON output
gh run list --json databaseId,status,conclusion,workflowName
```

4️⃣ **View Run Details**
```bash
# View latest run
gh run view

# View specific run
gh run view 123456789

# View in browser
gh run view 123456789 --web

# View run logs
gh run view 123456789 --log

# View failed logs only
gh run view 123456789 --log-failed

# Watch run in real-time
gh run watch 123456789
```

5️⃣ **Download Artifacts**
```bash
# List artifacts for a run
gh run view 123456789 --json artifacts

# Download all artifacts
gh run download 123456789

# Download specific artifact
gh run download 123456789 --name coverage-report

# Download to specific directory
gh run download 123456789 --dir ./artifacts
```

6️⃣ **Re-run Workflows**
```bash
# Re-run failed jobs
gh run rerun 123456789 --failed

# Re-run entire workflow
gh run rerun 123456789

# Cancel a run
gh run cancel 123456789

# Delete a run
gh run delete 123456789
```

7️⃣ **Workflow Monitoring Script**
```bash
#!/bin/bash
# watch-ci.sh - Monitor CI status

WORKFLOW="ci.yml"

echo "🔍 Monitoring $WORKFLOW..."

while true; do
  clear
  echo "=== Latest 5 Runs ==="
  gh run list --workflow $WORKFLOW --limit 5
  
  # Check if any in progress
  IN_PROGRESS=$(gh run list --workflow $WORKFLOW --status in_progress --json databaseId --jq 'length')
  
  if [ "$IN_PROGRESS" -gt 0 ]; then
    echo "\n⏳ Runs in progress: $IN_PROGRESS"
  fi
  
  sleep 10
done
```

**✅ CI/CD Exercise**:
```bash
# 1. List all workflows
gh workflow list

# 2. View CI workflow
gh workflow view ci.yml

# 3. Check recent runs
gh run list --workflow ci.yml --limit 5

# 4. View latest run details
gh run view --workflow ci.yml

# 5. Watch a running workflow
LATEST_RUN=$(gh run list --workflow ci.yml --json databaseId --jq '.[0].databaseId')
gh run watch $LATEST_RUN

# 6. Download artifacts if available
gh run download $LATEST_RUN

# 7. Re-run if failed
gh run rerun $LATEST_RUN --failed
```

---

### Lab 6: Release Management

**Objective**: Master release creation and management

#### Tasks:

1️⃣ **List Releases**
```bash
# List all releases
gh release list

# Limit results
gh release list --limit 10
```

**Expected Output**:
```
TITLE            TYPE     TAG NAME  PUBLISHED
Release 1.2.0    Latest   v1.2.0    about 2 days ago
Release 1.1.0             v1.1.0    about 1 week ago
Release 1.0.0             v1.0.0    about 2 weeks ago
Beta 1.0.0-rc1   Pre-release v1.0.0-rc1  about 3 weeks ago

# Exclude drafts and pre-releases
gh release list --exclude-drafts
gh release list --exclude-pre-releases

# JSON output
gh release list --json tagName,name,publishedAt,isPrerelease
```

2️⃣ **View Release**
```bash
# View latest release
gh release view

# View specific release
gh release view v1.0.0

# View in browser
gh release view v1.0.0 --web

# Get JSON data
gh release view v1.0.0 --json tagName,name,body,assets
```

3️⃣ **Create Release**
```bash
# Interactive creation
gh release create v1.0.0

# With title and notes
gh release create v1.0.0 \
  --title "Version 1.0.0" \
  --notes "First stable release"

# From notes file
gh release create v1.0.0 \
  --title "Version 1.0.0" \
  --notes-file CHANGELOG.md

# Auto-generate notes from commits
gh release create v1.0.0 \
  --title "Version 1.0.0" \
  --generate-notes

# With assets
gh release create v1.0.0 \
  --title "Version 1.0.0" \
  --notes "Release notes" \
  dist/*.tar.gz \
  dist/*.zip

# Draft release
gh release create v1.0.0 \
  --draft \
  --title "Version 1.0.0" \
  --notes "Draft release for review"

# Pre-release
gh release create v1.0.0-beta.1 \
  --prerelease \
  --title "Beta 1" \
  --notes "Beta release for testing"

# Set as latest
gh release create v1.1.0 \
  --title "Version 1.1.0" \
  --notes "New features" \
  --latest

# Don't set as latest
gh release create v1.0.1 \
  --title "Patch 1.0.1" \
  --notes "Bug fixes" \
  --latest=false

# With target commitish
gh release create v1.0.0 \
  --target develop \
  --title "Version 1.0.0"
```

4️⃣ **Upload Assets**
```bash
# Upload single file
gh release upload v1.0.0 dist/app.tar.gz

# Upload multiple files
gh release upload v1.0.0 dist/*.tar.gz

# Upload with pattern
gh release upload v1.0.0 build/release-*

# Replace existing asset
gh release upload v1.0.0 app.tar.gz --clobber
```

5️⃣ **Download Release Assets**
```bash
# Download all assets from latest release
gh release download

# Download from specific release
gh release download v1.0.0

# Download specific asset
gh release download v1.0.0 --pattern "*.tar.gz"

# Download to specific directory
gh release download v1.0.0 --dir ./downloads

# Skip existing files
gh release download v1.0.0 --skip-existing
```

6️⃣ **Edit Release**
```bash
# Edit release
gh release edit v1.0.0 --title "New title"
gh release edit v1.0.0 --notes "Updated notes"

# Convert draft to full release
gh release edit v1.0.0 --draft=false

# Mark as pre-release
gh release edit v1.0.0 --prerelease

# Update notes from file
gh release edit v1.0.0 --notes-file CHANGELOG.md
```

7️⃣ **Delete Release**
```bash
# Delete release
gh release delete v1.0.0

# Delete with confirmation
gh release delete v1.0.0 --yes

# Cleanup tag too
gh release delete v1.0.0 --cleanup-tag
```

**✅ Complete Release Workflow**:
```bash
#!/bin/bash
# release.sh - Automated release script

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: ./release.sh <version>"
  exit 1
fi

echo "🚀 Creating release $VERSION..."

# 1. Create git tag
git tag -a "$VERSION" -m "Release $VERSION"
git push origin "$VERSION"

# 2. Build artifacts
echo "📦 Building artifacts..."
npm run build  # or your build command

# 3. Create release with auto-generated notes
echo "📝 Creating GitHub release..."
gh release create "$VERSION" \
  --title "Release $VERSION" \
  --generate-notes \
  dist/*.tar.gz \
  dist/*.zip

# 4. Verify release
echo "✅ Release created successfully!"
gh release view "$VERSION"

# 5. Announce
echo "📢 Release $VERSION is now available!"
```

---

### Lab 7: Advanced Automation

**Objective**: Build automation scripts using GitHub CLI

#### Tasks:

1️⃣ **Automated PR Management**
```bash
#!/bin/bash
# auto-merge.sh - Auto-merge approved PRs

echo "🔍 Checking for approved PRs..."

# Get all open PRs
gh pr list --state open --json number,title,reviews | jq -c '.[]' | while read pr; do
  PR_NUMBER=$(echo $pr | jq -r '.number')
  TITLE=$(echo $pr | jq -r '.title')
  APPROVED=$(echo $pr | jq -r '.reviews[] | select(.state == "APPROVED") | .state' | wc -l)
  
  if [ "$APPROVED" -ge 1 ]; then
    echo "✅ PR #$PR_NUMBER: $TITLE is approved"
    
    # Check if CI passes
    CHECKS=$(gh pr checks $PR_NUMBER --json state,conclusion)
    FAILED=$(echo $CHECKS | jq '[.[] | select(.state == "COMPLETED" and .conclusion != "SUCCESS")] | length')
    
    if [ "$FAILED" -eq 0 ]; then
      echo "🚀 All checks passed. Merging..."
      gh pr merge $PR_NUMBER --squash --delete-branch
    else
      echo "⏳ Waiting for checks to pass..."
    fi
  fi
done
```

2️⃣ **Issue Triage Automation**
```bash
#!/bin/bash
# triage-issues.sh - Auto-label and assign issues

gh issue list --state open --limit 50 --json number,title,body | jq -c '.[]' | while read issue; do
  NUMBER=$(echo $issue | jq -r '.number')
  TITLE=$(echo $issue | jq -r '.title')
  BODY=$(echo $issue | jq -r '.body')
  
  # Auto-label based on keywords
  if echo "$TITLE $BODY" | grep -qi "bug\|error\|crash\|fail"; then
    echo "🐛 Labeling #$NUMBER as bug"
    gh issue edit $NUMBER --add-label bug
  fi
  
  if echo "$TITLE $BODY" | grep -qi "feature\|enhancement\|add"; then
    echo "✨ Labeling #$NUMBER as enhancement"
    gh issue edit $NUMBER --add-label enhancement
  fi
  
  if echo "$TITLE $BODY" | grep -qi "documentation\|docs\|readme"; then
    echo "📚 Labeling #$NUMBER as documentation"
    gh issue edit $NUMBER --add-label documentation
  fi
  
  # Auto-assign based on area
  if echo "$TITLE $BODY" | grep -qi "ci\|cd\|pipeline"; then
    echo "👤 Assigning to devops team"
    gh issue edit $NUMBER --add-assignee devops-user
  fi
done
```

3️⃣ **Release Notes Generator**
```bash
#!/bin/bash
# generate-release-notes.sh - Generate release notes from commits

PREVIOUS_TAG=$(git describe --tags --abbrev=0 HEAD~1)
CURRENT_TAG=$(git describe --tags --abbrev=0)

echo "# Release Notes: $CURRENT_TAG"
echo
echo "**Released:** $(date '+%Y-%m-%d')"
echo

# Features
echo "## 🚀 Features"
git log $PREVIOUS_TAG..$CURRENT_TAG --pretty=format:"- %s" --grep="^feat"
echo

# Bug Fixes
echo "## 🐛 Bug Fixes"
git log $PREVIOUS_TAG..$CURRENT_TAG --pretty=format:"- %s" --grep="^fix"
echo

# Changes
echo "## 📝 Changes"
git log $PREVIOUS_TAG..$CURRENT_TAG --oneline | wc -l | xargs echo "- Total commits:"
echo

# Contributors
echo "## 👥 Contributors"
git log $PREVIOUS_TAG..$CURRENT_TAG --format='%aN' | sort -u | sed 's/^/- @/'
```

4️⃣ **Stale PR Cleanup**
```bash
#!/bin/bash
# cleanup-stale-prs.sh - Close stale PRs

DAYS=30

gh pr list --state open --json number,title,createdAt | jq -c '.[]' | while read pr; do
  NUMBER=$(echo $pr | jq -r '.number')
  TITLE=$(echo $pr | jq -r '.title')
  CREATED=$(echo $pr | jq -r '.createdAt')
  
  CREATED_TIMESTAMP=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$CREATED" "+%s")
  NOW=$(date +%s)
  AGE=$(( ($NOW - $CREATED_TIMESTAMP) / 86400 ))
  
  if [ "$AGE" -gt "$DAYS" ]; then
    echo "🗑️  PR #$NUMBER is $AGE days old. Closing..."
    gh pr close $NUMBER --comment "Closing due to inactivity after $DAYS days. Please reopen if still relevant."
  fi
done
```

5️⃣ **Workflow Status Dashboard**
```bash
#!/bin/bash
# ci-dashboard.sh - Real-time CI dashboard

while true; do
  clear
  echo "==================================="
  echo "    CI/CD Dashboard"
  echo "==================================="
  echo
  
  # Workflows
  echo "📊 Workflow Status:"
  gh run list --limit 10 --json workflowName,status,conclusion,startedAt \
    --template '{{range .}}{{.workflowName}}: {{.status}} {{if eq .status "completed"}}({{.conclusion}}){{end}}
{{end}}'
  
  echo
  echo "📝 Recent PRs:"
  gh pr list --limit 5 --json number,title,state \
    --template '{{range .}}#{{.number}}: {{.title}} ({{.state}})
{{end}}'
  
  echo
  echo "🐛 Open Issues: $(gh issue list --state open --json number | jq 'length')"
  echo "✅ Closed Today: $(gh issue list --state closed --search "closed:>=$(date -I)" --json number | jq 'length')"
  
  echo
  echo "Press Ctrl+C to exit..."
  sleep 30
done
```

**✅ Automation Exercise**:
Create a complete DevOps automation script:

```bash
#!/bin/bash
# devops-workflow.sh - Complete DevOps automation

set -e

# Configuration
REPO="owner/repo"
VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: ./devops-workflow.sh <version>"
  exit 1
fi

echo "🚀 Starting DevOps workflow for $VERSION..."

# 1. Create release branch
echo "📝 Creating release branch..."
git checkout -b "release/$VERSION"

# 2. Update version files
echo "🔄 Updating version..."
sed -i '' "s/version = \".*\"/version = \"$VERSION\"/" pyproject.toml
git add pyproject.toml
git commit -m "chore: bump version to $VERSION"
git push -u origin "release/$VERSION"

# 3. Create PR
echo "📋 Creating release PR..."
PR_URL=$(gh pr create \
  --title "Release $VERSION" \
  --body "Automated release PR for version $VERSION" \
  --base main \
  --head "release/$VERSION" \
  --label release)

echo "✅ PR created: $PR_URL"

# 4. Wait for CI
echo "⏳ Waiting for CI to complete..."
PR_NUMBER=$(echo $PR_URL | grep -o '[0-9]*$')
gh pr checks $PR_NUMBER --watch

# 5. Auto-merge if approved
echo "🔍 Checking approval status..."
APPROVED=$(gh pr view $PR_NUMBER --json reviews --jq '[.reviews[] | select(.state == "APPROVED")] | length')

if [ "$APPROVED" -ge 1 ]; then
  echo "✅ PR approved. Merging..."
  gh pr merge $PR_NUMBER --squash --delete-branch
else
  echo "⏳ Waiting for approval. Run again after approval."
  exit 0
fi

# 6. Create release
echo "📦 Creating GitHub release..."
gh release create "v$VERSION" \
  --title "Release $VERSION" \
  --generate-notes

echo "🎉 Release $VERSION completed successfully!"
```

---

### Lab 8: Extensions & Customization

**Objective**: Extend GitHub CLI with custom commands

#### Tasks:

1️⃣ **Install Extensions**
```bash
# Browse extensions
gh extension browse

# Search for extension
gh extension search

# Install extension
gh extension install owner/gh-extension-name

# Popular extensions:
gh extension install dlvhdr/gh-dash        # Dashboard
gh extension install github/gh-copilot     # Copilot CLI
gh extension install mislav/gh-branch      # Branch utilities
gh extension install vilmibm/gh-screensaver  # Fun screensaver
```

2️⃣ **Manage Extensions**
```bash
# List installed extensions
gh extension list

# Upgrade extension
gh extension upgrade extension-name

# Upgrade all extensions
gh extension upgrade --all

# Remove extension
gh extension remove extension-name
```

3️⃣ **Create Custom Extension**
```bash
# Create extension scaffold
gh extension create gh-hello

# Extension structure:
gh-hello/
├── gh-hello           # Main executable script
└── README.md

# Example extension (gh-hello):
cat > gh-hello << 'EOF'
#!/bin/bash
set -e

name=${1:-World}
echo "Hello, $name! 👋"
echo "Repository: $(gh repo view --json nameWithOwner -q .nameWithOwner)"
EOF

chmod +x gh-hello

# Install local extension
gh extension install .

# Use extension
gh hello
gh hello "GitHub CLI"
```

4️⃣ **Advanced Custom Extension**
```bash
# Create a PR stats extension
gh extension create gh-pr-stats

cat > gh-pr-stats << 'EOF'
#!/bin/bash
# gh-pr-stats - Show PR statistics

set -e

REPO=${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}

echo "📊 PR Statistics for $REPO"
echo "======================================"

# Total PRs
TOTAL=$(gh pr list --repo $REPO --state all --limit 1000 --json number | jq 'length')
echo "Total PRs: $TOTAL"

# Open PRs
OPEN=$(gh pr list --repo $REPO --state open --json number | jq 'length')
echo "Open PRs: $OPEN"

# Merged PRs
MERGED=$(gh pr list --repo $REPO --state merged --limit 1000 --json number | jq 'length')
echo "Merged PRs: $MERGED"

# Closed (not merged)
CLOSED=$(gh pr list --repo $REPO --state closed --limit 1000 --json number | jq 'length')
echo "Closed PRs: $CLOSED"

# Average time to merge (last 10 merged PRs)
echo ""
echo "⏱️  Average Time to Merge (last 10):"
gh pr list --repo $REPO --state merged --limit 10 \
  --json number,createdAt,mergedAt | \
  jq -r '.[] | "\(.number),\(.createdAt),\(.mergedAt)"' | \
  while IFS=, read num created merged; do
    created_ts=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$created" "+%s")
    merged_ts=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$merged" "+%s")
    hours=$(( ($merged_ts - $created_ts) / 3600 ))
    echo "  PR #$num: $hours hours"
  done

EOF

chmod +x gh-pr-stats
gh extension install .

# Use it
gh pr-stats
gh pr-stats owner/repo
```

5️⃣ **Extension with Configuration**
```bash
# Create configurable extension
gh extension create gh-deploy

cat > gh-deploy << 'EOF'
#!/bin/bash
# gh-deploy - Simplified deployment helper

set -e

CONFIG_FILE="$HOME/.gh-deploy.conf"

# Load config
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

ENVIRONMENT=${1:-staging}
WORKFLOW=${GH_DEPLOY_WORKFLOW:-deploy.yml}

echo "🚀 Deploying to $ENVIRONMENT..."

# Trigger deployment workflow
gh workflow run "$WORKFLOW" \
  --field environment="$ENVIRONMENT" \
  --field ref="$(git branch --show-current)"

echo "✅ Deployment triggered!"
echo "📊 Monitor progress:"
echo "   gh run list --workflow $WORKFLOW --limit 1"

# Watch the deployment
LATEST_RUN=$(gh run list --workflow "$WORKFLOW" --limit 1 --json databaseId -q '.[0].databaseId')
gh run watch "$LATEST_RUN"
EOF

chmod +x gh-deploy

# Create config
cat > ~/.gh-deploy.conf << 'EOF'
# GitHub Deployment Configuration
GH_DEPLOY_WORKFLOW=cd.yml
EOF

gh extension install .

# Use it
gh deploy staging
gh deploy production
```

**✅ Extension Exercise**:
Create a useful extension for your workflow:

```bash
# Create your custom extension
gh extension create gh-my-workflow

# Add your custom logic
# Examples:
# - Team-specific shortcuts
# - Project management helpers
# - Custom reporting tools
# - Integration with other tools

# Share with team
git push origin main

# Team members install
gh extension install your-org/gh-my-workflow
```

---

## 🌍 Real-World Integration

### Integration with This Project

#### 1. **Automated Release Workflow**
```bash
# scripts/gh-release.sh
#!/bin/bash
set -e

VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Usage: ./scripts/gh-release.sh <version>"
  exit 1
fi

echo "🚀 Creating release $VERSION for DevOps-Demo-Project..."

# Update version
sed -i '' "s/^VERSION = .*/VERSION = \"$VERSION\"/" app/main.py

# Create release branch
git checkout -b "release/$VERSION"
git add app/main.py
git commit -m "chore: bump version to $VERSION"
git push -u origin "release/$VERSION"

# Create PR
gh pr create \
  --title "Release $VERSION" \
  --body "Automated release for version $VERSION" \
  --base main \
  --label release \
  --reviewer @me

echo "✅ Release PR created. Review and merge to trigger CD pipeline."
```

#### 2. **PR Creation Helper**
```bash
# scripts/gh-pr.sh
#!/bin/bash

BRANCH=$(git branch --show-current)
TYPE=$(echo $BRANCH | cut -d'/' -f1)
SCOPE=$(echo $BRANCH | cut -d'/' -f2-)

# Generate PR title
case $TYPE in
  feature) PREFIX="feat" ;;
  bugfix) PREFIX="fix" ;;
  hotfix) PREFIX="fix" ;;
  *) PREFIX="chore" ;;
esac

gh pr create \
  --title "$PREFIX: $SCOPE" \
  --body "$(git log --format=%B -n 1)" \
  --label $TYPE \
  --web
```

#### 3. **CI Status Monitor**
```bash
# scripts/gh-ci-status.sh
#!/bin/bash

echo "📊 CI/CD Status for DevOps-Demo-Project"
echo "========================================"

# Latest workflow runs
echo "\n🏃 Recent Workflow Runs:"
gh run list --limit 5 --json workflowName,status,conclusion,startedAt \
  --template '{{range .}}{{.workflowName}}: {{.status}} {{if eq .status "completed"}}({{.conclusion}}){{end}}
{{end}}'

# PR status
echo "\n📝 Open Pull Requests:"
gh pr list --json number,title,statusCheckRollup \
  --template '{{range .}}#{{.number}}: {{.title}}
  Status: {{.statusCheckRollup}}
{{end}}'

# Check ArgoCD sync (via API)
echo "\n🔄 ArgoCD Sync Status:"
gh api repos/:owner/:repo/deployments/latest \
  --jq '.[] | "Environment: \(.environment) | Status: \(.state)"'
```

#### 4. **Issue Creation from Logs**
```bash
# scripts/gh-error-report.sh
#!/bin/bash

LOG_FILE=$1
ERROR=$(grep -i "error\|exception" $LOG_FILE | head -1)

if [ -n "$ERROR" ]; then
  gh issue create \
    --title "Error detected: $ERROR" \
    --body "Automated error report from logs:

\`\`\`
$(tail -20 $LOG_FILE)
\`\`\`
    
Timestamp: $(date)
Host: $(hostname)" \
    --label bug,automated
fi
```

---

## 📚 Best Practices

### 1. **Scripting & Automation**

✅ **Always check for errors**
```bash
set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure
```

✅ **Use JSON output for scripting**
```bash
# Good: Parse JSON
gh pr list --json number,title | jq '.[] | select(.title | contains("bug"))'

# Bad: Parse human-readable output
gh pr list | grep bug
```

✅ **Handle pagination properly**
```bash
# Get all results
gh api --paginate repos/:owner/:repo/issues
```

### 2. **Security**

🔒 **Use environment variables for tokens**
```bash
export GH_TOKEN="your-token"
# Never: gh auth login --with-token < token.txt (tracked in history)
```

🔒 **Scope tokens appropriately**
- Use fine-grained tokens
- Minimum required permissions
- Rotate regularly

🔒 **Don't commit credentials**
```bash
# .gitignore
.gh-token
.env
```

### 3. **Performance**

⚡ **Limit API calls**
```bash
# Use --limit to reduce API calls
gh issue list --limit 10

# Cache results when possible
ISSUES=$(gh issue list --json number,title)
echo $ISSUES | jq '.[] | select(.title | contains("bug"))'
```

⚡ **Use GraphQL for complex queries**
```bash
gh api graphql -f query='
  query {
    repository(owner: "owner", name: "repo") {
      issues(first: 10) {
        nodes {
          title
          state
        }
      }
    }
  }
'
```

### 4. **Team Collaboration**

👥 **Standardize scripts**
- Keep scripts in `scripts/` directory
- Document with comments
- Use consistent naming

👥 **Share extensions**
```bash
# Organization extensions
gh extension install yourorg/gh-team-workflow
```

---

## 🐛 Troubleshooting

### Common Issues

#### Authentication Failed
```bash
# Check status
gh auth status

# Re-authenticate
gh auth login

# Check token permissions
gh auth token
```

#### API Rate Limit
```bash
# Check rate limit
gh api rate_limit

# Wait or use authenticated requests (higher limit)
gh auth login
```

#### Command Not Found
```bash
# Verify installation
which gh
gh --version

# Re-install
brew reinstall gh
```

#### Permission Denied
```bash
# Check repo permissions
gh repo view --json permissions

# Ensure correct scope for token
gh auth refresh -s repo,workflow
```

---

## 📖 Cheat Sheet

### Quick Reference

```bash
# Repository
gh repo view                      # View current repo
gh repo create                    # Create repo
gh repo clone owner/repo          # Clone repo
gh repo fork                      # Fork repo

# Issues
gh issue list                     # List issues
gh issue create                   # Create issue
gh issue view 123                 # View issue #123
gh issue close 123                # Close issue

# Pull Requests
gh pr list                        # List PRs
gh pr create                      # Create PR
gh pr checkout 123                # Checkout PR #123
gh pr review 123 --approve        # Approve PR
gh pr merge 123 --squash          # Squash and merge

# Actions
gh workflow list                  # List workflows
gh run list                       # List runs
gh run view                       # View run details
gh run watch                      # Watch run

# Releases
gh release list                   # List releases
gh release create v1.0.0          # Create release
gh release download v1.0.0        # Download release

# API
gh api repos/:owner/:repo         # Call API endpoint
gh api graphql -f query='...'     # GraphQL query

# Configuration
gh config set editor vim          # Set editor
gh config list                    # List config
gh alias set                      # Create alias
```

### Useful Aliases

```bash
# Add to ~/.config/gh/config.yml
aliases:
  pv: pr view
  pc: pr create --web
  pm: pr merge --squash --delete-branch
  ic: issue create
  rv: repo view --web
  co: pr checkout
```

---

## 📚 Resources

### Official Documentation
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [GitHub CLI GitHub Repo](https://github.com/cli/cli)
- [GitHub REST API](https://docs.github.com/en/rest)
- [GitHub GraphQL API](https://docs.github.com/en/graphql)

### Extensions
- [gh extensions](https://github.com/topics/gh-extension)
- [Awesome gh extensions](https://github.com/vilmibm/awesome-gh-extensions)

### Community
- [GitHub CLI Discussions](https://github.com/cli/cli/discussions)
- [GitHub Community](https://github.community)

---

## 🎓 Conclusion

You've now mastered GitHub CLI! You can:

✅ Authenticate and configure gh  
✅ Manage repositories efficiently  
✅ Automate issue tracking  
✅ Streamline PR workflows  
✅ Monitor CI/CD pipelines  
✅ Create and manage releases  
✅ Build custom automation  
✅ Extend with custom extensions

### Next Steps

1. **Practice Daily**: Use gh for your regular workflow
2. **Automate**: Replace manual tasks with gh scripts
3. **Share**: Teach teammates and share scripts
4. **Extend**: Build custom extensions for your needs
5. **Integrate**: Add gh to your CI/CD pipelines

### Integration Checklist

- [ ] Install gh CLI
- [ ] Authenticate with GitHub
- [ ] Configure aliases and defaults
- [ ] Create PR automation scripts
- [ ] Set up release workflows
- [ ] Build CI/CD monitoring
- [ ] Create custom extensions
- [ ] Document team workflows

---

**Happy Automating! 🚀**

For questions or contributions, open an issue or PR in this repository.
