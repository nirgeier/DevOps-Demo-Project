# Lab 4: Pull Request Workflows with GitHub CLI

## 📚 Overview

Master the complete pull request lifecycle using GitHub CLI. Learn to create, review, manage, and merge pull requests efficiently from the command line, streamlining your code review workflow.

## 🎯 Learning Objectives

By the end of this lab, you will be able to:

- ✅ Create pull requests with detailed descriptions
- ✅ List and filter pull requests effectively
- ✅ Review pull requests and provide feedback
- ✅ Manage PR metadata (labels, reviewers, milestones)
- ✅ Check PR status and CI/CD results
- ✅ Merge pull requests with different strategies
- ✅ Handle draft PRs and mark them ready
- ✅ Automate PR workflows

## 🔧 Prerequisites

- ✅ Completed [Lab 1-3](./LAB1-SETUP.md)
- ✅ Git installed and configured
- ✅ Understanding of Git branches
- ✅ Repository with PRs enabled
- ✅ Familiarity with code review concepts

## 📋 Lab Steps

### Step 1: List Pull Requests

View and filter pull requests:

```bash
# List all open PRs
gh pr list

# List all PRs (including closed/merged)
gh pr list --state all

# Limit results
gh pr list --limit 20
```

**Filter by author and assignee:**

```bash
# Your PRs
gh pr list --author @me

# PRs assigned to you
gh pr list --assignee @me

# PRs by specific user
gh pr list --author username

# PRs requesting your review
gh pr list --search "review-requested:@me"
```

**Filter by labels and status:**

```bash
# Filter by label
gh pr list --label "bug"
gh pr list --label "enhancement,high-priority"

# Filter by base branch
gh pr list --base main
gh pr list --base develop

# Draft PRs only
gh pr list --draft

# Search query
gh pr list --search "is:open is:pr author:@me"
```

**Expected Output:**
```
Showing 3 of 3 open pull requests in owner/repo

#45  feat: Add user authentication     feature     about 2 hours ago
#44  fix: Resolve memory leak          bug-fix     yesterday
#43  docs: Update API documentation    docs        3 days ago
```

### Step 2: Create Pull Requests

Create PRs with various configurations:

**Basic PR creation:**

```bash
# Create PR (interactive)
gh pr create

# With title and body
gh pr create \
    --title "feat: Add dark mode support" \
    --body "Implements dark mode toggle for better UX"

# Quick PR (uses branch name as title)
gh pr create --fill
```

**Detailed PR with metadata:**

```bash
gh pr create \
    --title "feat: Implement user authentication" \
    --body "## Overview
This PR adds JWT-based authentication system

## Changes
- Add JWT token generation and validation
- Implement login/logout endpoints
- Add authentication middleware
- Create user session management

## Testing
- ✅ Unit tests passing
- ✅ Integration tests passing
- ✅ Manual testing completed

## Breaking Changes
None

## Related Issues
Closes #42
Fixes #38" \
    --label "feature,backend" \
    --assignee @me \
    --reviewer user1,user2 \
    --milestone "v2.0" \
    --base main \
    --head feature/auth
```

**Draft PR:**

```bash
# Create as draft
gh pr create \
    --title "WIP: Refactor database layer" \
    --body "Work in progress, not ready for review" \
    --draft
```

**PR from template:**

```bash
# Use body from file
gh pr create --body-file .github/PULL_REQUEST_TEMPLATE.md

# Open in browser for creation
gh pr create --web
```

**Create PR from existing branch:**

```bash
# From current branch
gh pr create --fill

# From specific branch
gh pr create --head feature-branch --base main --fill
```

### Step 3: View Pull Request Details

Get comprehensive PR information:

```bash
# View specific PR
gh pr view 45

# View in browser
gh pr view 45 --web

# View with comments
gh pr view 45 --comments

# View diff
gh pr diff 45

# JSON output
gh pr view 45 --json number,title,body,state,reviews,statusCheckRollup

# Formatted JSON
gh pr view 45 --json number,title,author,createdAt,mergeable | jq '.'
```

**Expected JSON Output:**
```json
{
  "number": 45,
  "title": "feat: Add user authentication",
  "author": {
    "login": "developer"
  },
  "createdAt": "2024-11-15T10:30:00Z",
  "mergeable": "MERGEABLE"
}
```

### Step 4: Review Pull Requests

Provide comprehensive code reviews:

**Approve PR:**

```bash
# Simple approval
gh pr review 45 --approve

# Approval with comment
gh pr review 45 --approve --body "LGTM! Great implementation. ✅

Code is clean and well-tested. Ready to merge."
```

**Request changes:**

```bash
gh pr review 45 --request-changes --body "Please address these issues:

1. Add error handling in line 45
2. Update tests to cover edge cases
3. Fix linting errors

Otherwise looks good!"
```

**Comment only:**

```bash
gh pr review 45 --comment --body "Some thoughts on this implementation:

- Consider caching the results
- Maybe extract the logic into a separate function
- Documentation could be more detailed

Not blocking, just suggestions. 💭"
```

**Add inline comments:**

```bash
# Comment on specific file/line (uses API)
gh api repos/:owner/:repo/pulls/45/comments \
    -f body="Consider using async/await here" \
    -f path="src/auth.js" \
    -f line=42 \
    -f side="RIGHT"
```

### Step 5: Manage PR Metadata

Update PR properties:

**Edit PR details:**

```bash
# Update title
gh pr edit 45 --title "feat: Add OAuth2 authentication"

# Update body
gh pr edit 45 --body "Updated description..."

# Interactive edit
gh pr edit 45
```

**Manage labels:**

```bash
# Add labels
gh pr edit 45 --add-label "ready-for-review"
gh pr edit 45 --add-label "feature,backend,breaking-change"

# Remove labels
gh pr edit 45 --remove-label "wip"
```

**Manage reviewers:**

```bash
# Request review
gh pr edit 45 --add-reviewer user1,user2,team-reviewers

# Remove reviewer
gh pr edit 45 --remove-reviewer user1
```

**Manage assignees:**

```bash
# Add assignee
gh pr edit 45 --add-assignee @me

# Remove assignee
gh pr edit 45 --remove-assignee user1
```

**Set milestone and project:**

```bash
# Set milestone
gh pr edit 45 --milestone "v2.0"

# Add to project
gh pr edit 45 --add-project "Backend Development"
```

### Step 6: PR Status and Checks

Monitor PR health and CI/CD:

**Check status:**

```bash
# View PR status
gh pr status

# Detailed status for specific PR
gh pr view 45 --json statusCheckRollup | jq '.'
```

**View CI checks:**

```bash
# List all checks
gh pr checks 45

# Watch checks in real-time
gh pr checks 45 --watch

# Filter by specific check
gh pr checks 45 | grep "CI"
```

**Expected Output:**
```
Some checks were not successful
X  CI / lint       — The command "npm run lint" exited with 1.
✓  CI / test       — Your tests passed!
✓  CI / build      — Build completed successfully
✓  CodeQL          — All queries passed
○  Deploy Preview  — In progress...
```

**Check if PR is ready to merge:**

```bash
# Check mergability
gh pr view 45 --json mergeable,mergeStateStatus

# Full status check
gh pr view 45 --json reviewDecision,statusCheckRollup,mergeable | jq '{
    mergeable: .mergeable,
    reviewDecision: .reviewDecision,
    checksPass: (.statusCheckRollup[].conclusion == "SUCCESS")
}'
```

### Step 7: Merge Pull Requests

Merge with different strategies:

**Merge commit (default):**

```bash
# Standard merge
gh pr merge 45

# With commit message
gh pr merge 45 --merge --body "Merge authentication feature"

# Delete branch after merge
gh pr merge 45 --merge --delete-branch

# Auto-merge when checks pass
gh pr merge 45 --merge --auto
```

**Squash merge:**

```bash
# Squash all commits
gh pr merge 45 --squash

# With custom message
gh pr merge 45 --squash --subject "feat: implement user authentication"

# Squash with detailed body
gh pr merge 45 --squash \
    --subject "feat: add OAuth2" \
    --body "Implements OAuth2 authentication with Google and GitHub providers"
```

**Rebase merge:**

```bash
# Rebase and merge
gh pr merge 45 --rebase

# Rebase with branch deletion
gh pr merge 45 --rebase --delete-branch
```

**Admin merge (override protections):**

```bash
# Force merge (requires admin)
gh pr merge 45 --admin
```

### Step 8: Draft PRs and State Management

Work with draft pull requests:

**Mark as ready:**

```bash
# Convert draft to ready
gh pr ready 45

# Create ready PR from draft
gh pr ready 45 --undo-draft
```

**Convert to draft:**

```bash
# Mark as draft (requires API)
gh api graphql -f query='
mutation {
  convertPullRequestToDraft(input: {pullRequestId: "PR_NODE_ID"}) {
    pullRequest {
      isDraft
    }
  }
}'
```

**Close and reopen:**

```bash
# Close PR without merging
gh pr close 45 --comment "Closing due to alternative approach in #46"

# Reopen PR
gh pr reopen 45 --comment "Reopening after discussion"
```

### Step 9: Local PR Operations

Work with PRs locally:

**Checkout PR:**

```bash
# Checkout PR branch
gh pr checkout 45

# By branch name
gh pr checkout feature/auth

# View changes locally
git log HEAD~3..HEAD
git diff main...HEAD
```

**Update PR:**

```bash
# After checking out
git add .
git commit -m "Address review comments"
git push

# Force push (if rebased)
git push --force-with-lease
```

**Sync with base branch:**

```bash
# Update from main
git fetch origin main
git merge origin/main
git push
```

### Step 10: Advanced PR Workflows

**Example 1: Auto-approve dependabot PRs:**

```bash
#!/bin/bash
# auto-approve-dependabot.sh

gh pr list --author "app/dependabot" --json number,title | \
jq -r '.[] | "\(.number)|\(.title)"' | \
while IFS='|' read -r number title; do
    if gh pr checks $number | grep -q "All checks have passed"; then
        echo "Auto-approving #$number: $title"
        gh pr review $number --approve --body "✅ Dependabot PR auto-approved"
        gh pr merge $number --auto --squash --delete-branch
    fi
done
```

**Example 2: PR Dashboard:**

```bash
#!/bin/bash
# pr-dashboard.sh

clear
echo "═══════════════════════════════════════"
echo "  Pull Request Dashboard"
echo "═══════════════════════════════════════"
echo

echo "📊 Your PRs Awaiting Review:"
gh pr list --author @me --json number,title,reviews \
    | jq -r '.[] | select(.reviews | length == 0) | "#\(.number) \(.title)"'

echo
echo "👀 PRs You Need to Review:"
gh pr list --search "review-requested:@me" --json number,title \
    | jq -r '.[] | "#\(.number) \(.title)"'

echo
echo "✅ Recently Merged (Last 7 days):"
gh pr list --state merged --search "merged:>$(date -v-7d +%Y-%m-%d)" --limit 5 \
    --json number,title,mergedAt | jq -r '.[] | "#\(.number) \(.title) (\(.mergedAt))"'

echo
echo "📈 Statistics:"
OPEN=$(gh pr list --state open --json number | jq length)
DRAFT=$(gh pr list --draft --json number | jq length)
echo "  Open: $OPEN (Draft: $DRAFT)"
```

**Example 3: Enforce PR standards:**

```bash
#!/bin/bash
# check-pr-standards.sh

PR_NUMBER=$1

echo "Checking PR #$PR_NUMBER for standards compliance..."

# Check title format
TITLE=$(gh pr view $PR_NUMBER --json title -q .title)
if [[ ! $TITLE =~ ^(feat|fix|docs|style|refactor|test|chore): ]]; then
    gh pr comment $PR_NUMBER --body "⚠️ PR title doesn't follow convention:
    
    Expected format: \`type: description\`
    
    Valid types: feat, fix, docs, style, refactor, test, chore"
    gh pr edit $PR_NUMBER --add-label "needs-update"
fi

# Check description length
BODY_LENGTH=$(gh pr view $PR_NUMBER --json body -q '.body | length')
if [ $BODY_LENGTH -lt 50 ]; then
    gh pr comment $PR_NUMBER --body "⚠️ Please add a more detailed description (minimum 50 characters)"
    gh pr edit $PR_NUMBER --add-label "needs-description"
fi

# Check for tests
if ! gh pr diff $PR_NUMBER | grep -q "test"; then
    gh pr comment $PR_NUMBER --body "💡 Consider adding tests for this change"
    gh pr edit $PR_NUMBER --add-label "needs-tests"
fi

echo "✅ Standards check complete!"
```

## 🎓 Key Commands Reference

| Command | Description |
|---------|-------------|
| `gh pr list` | List pull requests |
| `gh pr view <number>` | View PR details |
| `gh pr create` | Create new PR |
| `gh pr review <number>` | Review PR |
| `gh pr edit <number>` | Update PR metadata |
| `gh pr merge <number>` | Merge PR |
| `gh pr checkout <number>` | Checkout PR locally |
| `gh pr status` | Show PR status |
| `gh pr checks <number>` | View CI checks |
| `gh pr diff <number>` | View PR diff |
| `gh pr ready <number>` | Mark draft as ready |
| `gh pr close <number>` | Close PR |

## 💡 Pro Tips

### 1. PR Templates

Create `.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings generated
```

### 2. Quick Aliases

```bash
# Add to ~/.zshrc
alias ghp='gh pr'
alias ghpc='gh pr create --fill'
alias ghpm='gh pr merge --squash --delete-branch'
alias ghpv='gh pr view --web'
```

### 3. Auto-merge When Ready

```bash
gh pr merge 45 --auto --squash --delete-branch
```

## ✅ Lab Exercise

Complete this PR workflow:

1. **Create feature branch:**
```bash
git checkout -b lab4/feature-demo
echo "# New Feature" > FEATURE.md
git add FEATURE.md
git commit -m "feat: add new feature"
git push -u origin lab4/feature-demo
```

2. **Create PR:**
```bash
gh pr create --title "feat: Add new feature demo" \
    --body "Demo PR for Lab 4" \
    --label "lab-exercise"
```

3. **Add review:**
```bash
gh pr review <NUMBER> --approve --body "Looks good!"
```

4. **Merge:**
```bash
gh pr merge <NUMBER> --squash --delete-branch
```

## 📚 Additional Resources

- [gh pr documentation](https://cli.github.com/manual/gh_pr)
- [GitHub PR guide](https://docs.github.com/en/pull-requests)
- [Code review best practices](https://google.github.io/eng-practices/review/)

## 🚀 Next Steps

**[Lab 5: GitHub Actions & CI/CD →](./LAB5-ACTIONS.md)**

Learn to manage workflows, monitor runs, and work with GitHub Actions.

---

**Lab Duration:** 45-60 minutes  
**Difficulty:** Intermediate to Advanced  
**Prerequisites:** Labs 1-3, Git branch knowledge
