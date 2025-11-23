# Lab 3: Issue Management with GitHub CLI

## 📚 Overview

This lab covers comprehensive issue management using GitHub CLI. You'll learn to create, track, manage, and automate issues - the cornerstone of project collaboration and bug tracking on GitHub.

## 🎯 Learning Objectives

By the end of this lab, you will be able to:

- ✅ List and filter issues efficiently
- ✅ Create detailed issues with templates
- ✅ Add comments and reactions to issues
- ✅ Update issue metadata (labels, assignees, milestones)
- ✅ Close and reopen issues
- ✅ Pin and lock issues
- ✅ Automate issue workflows
- ✅ Export and analyze issue data

## 🔧 Prerequisites

- ✅ Completed [Lab 1: Setup & Authentication](./LAB1-SETUP.md)
- ✅ Completed [Lab 2: Repository Management](./LAB2-REPOSITORY.md)
- ✅ A repository with issues enabled
- ✅ Understanding of GitHub issue concepts

## 📋 Lab Steps

### Step 1: List and Filter Issues

View issues with various filters:

```bash
# List all open issues in current repository
gh issue list

# List all issues (including closed)
gh issue list --state all

# List only closed issues
gh issue list --state closed

# Limit results
gh issue list --limit 20
```

**Filter by properties:**

```bash
# Issues assigned to you
gh issue list --assignee @me

# Issues created by you
gh issue list --author @me

# Issues mentioning you
gh issue list --mention @me

# Issues by specific user
gh issue list --assignee username
gh issue list --author username
```

**Filter by labels:**

```bash
# Single label
gh issue list --label bug
gh issue list --label enhancement

# Multiple labels (AND)
gh issue list --label "bug,high-priority"

# Exclude labels
gh issue list --label "!wontfix"
```

**Advanced filters:**

```bash
# Filter by milestone
gh issue list --milestone "v1.0"

# Filter by search query
gh issue list --search "error in:title"
gh issue list --search "is:open is:issue author:@me"

# Combine filters
gh issue list \
    --assignee @me \
    --label bug \
    --state open \
    --limit 10
```

**Expected Output:**
```
Showing 5 of 5 open issues in owner/repo

#42  Bug: Application crashes on startup       bug,critical  about 2 hours ago
#41  Feature: Add dark mode support             enhancement   yesterday
#38  Documentation needs updating               docs          3 days ago
```

### Step 2: View Issue Details

Get comprehensive issue information:

```bash
# View specific issue
gh issue view 42

# View in browser
gh issue view 42 --web

# Include comments
gh issue view 42 --comments

# JSON output for scripting
gh issue view 42 --json number,title,body,state,labels,assignees

# Pretty print JSON
gh issue view 42 --json number,title,state,labels,createdAt | jq '.'
```

**Expected JSON Output:**
```json
{
  "number": 42,
  "title": "Bug: Application crashes on startup",
  "state": "OPEN",
  "labels": [
    {
      "name": "bug",
      "color": "d73a4a"
    }
  ],
  "createdAt": "2024-11-15T10:30:00Z"
}
```

### Step 3: Create Issues

Create comprehensive issues:

**Basic issue:**

```bash
# Simple issue
gh issue create --title "Bug: Login form not working"

# With body
gh issue create \
    --title "Feature: Add export functionality" \
    --body "We need to add CSV export for reports"
```

**Detailed issue with metadata:**

```bash
gh issue create \
    --title "Bug: Memory leak in data processor" \
    --body "## Description
The data processor shows memory leak after processing 1000+ records.

## Steps to Reproduce
1. Start the application
2. Process large dataset (>1000 records)
3. Monitor memory usage
4. Observe continuous memory growth

## Expected Behavior
Memory should stabilize after processing

## Actual Behavior
Memory keeps growing indefinitely

## Environment
- Version: 2.1.0
- OS: Ubuntu 22.04
- Node: 18.17.0

## Additional Context
See attached memory profiling report." \
    --label "bug,high-priority" \
    --assignee username \
    --milestone "v2.2" \
    --project "Backend Development"
```

**Interactive creation:**

```bash
# Opens editor for detailed input
gh issue create --title "Issue title" --body-file ISSUE_TEMPLATE.md

# Fully interactive
gh issue create
```

**From template:**

```bash
# Use issue template from repository
gh issue create --template bug_report.md

# Fill template interactively
gh issue create --web
```

**Programmatic creation:**

```bash
#!/bin/bash
# Create issue from script

ISSUE_BODY=$(cat <<EOF
## Summary
Automated issue creation from deployment script

## Details
Deployment ID: ${DEPLOYMENT_ID}
Timestamp: $(date)
Status: Failed

## Action Required
Review deployment logs and retry
EOF
)

gh issue create \
    --title "Deployment Failed: ${DEPLOYMENT_ID}" \
    --body "$ISSUE_BODY" \
    --label "deployment,urgent" \
    --assignee @me
```

### Step 4: Add Comments

Engage in issue discussions:

```bash
# Add simple comment
gh issue comment 42 --body "I can reproduce this issue"

# Add detailed comment
gh issue comment 42 --body "## Investigation Results

I've identified the root cause:
- Issue is in the authentication module
- Occurs only with OAuth2 providers
- Workaround: Use local auth temporarily

PR incoming with fix."

# Comment from file
gh issue comment 42 --body-file comment.md

# Edit comment (opens editor)
gh issue comment 42 --edit
```

**Add reactions:**

```bash
# React to issue
gh api repos/:owner/:repo/issues/42/reactions \
    -f content="+1"

# Available reactions: +1, -1, laugh, confused, heart, hooray, rocket, eyes
```

### Step 5: Update Issues

Modify issue metadata and properties:

**Edit issue content:**

```bash
# Update title
gh issue edit 42 --title "Bug: Login form fails with OAuth"

# Update body
gh issue edit 42 --body "Updated description with more details"

# Edit interactively (opens editor)
gh issue edit 42
```

**Manage labels:**

```bash
# Add labels
gh issue edit 42 --add-label "bug"
gh issue edit 42 --add-label "bug,critical,needs-triage"

# Remove labels
gh issue edit 42 --remove-label "needs-triage"

# Replace all labels
gh issue edit 42 --label "bug,in-progress"
```

**Manage assignees:**

```bash
# Assign to user
gh issue edit 42 --add-assignee username

# Assign to multiple users
gh issue edit 42 --add-assignee user1,user2,user3

# Assign to yourself
gh issue edit 42 --add-assignee @me

# Remove assignee
gh issue edit 42 --remove-assignee username

# Clear all assignees
gh issue edit 42 --assignee ""
```

**Set milestone:**

```bash
# Assign to milestone
gh issue edit 42 --milestone "v1.0"

# Remove from milestone
gh issue edit 42 --milestone ""
```

**Add to project:**

```bash
# Add to project board
gh issue edit 42 --add-project "Development"

# Remove from project
gh issue edit 42 --remove-project "Development"
```

### Step 6: Close and Reopen Issues

Manage issue lifecycle:

**Close issues:**

```bash
# Close with comment
gh issue close 42 --comment "Fixed in PR #45"

# Close as completed
gh issue close 42 --reason completed

# Close as not planned
gh issue close 42 --reason "not planned"

# Close multiple issues
gh issue close 42 43 44 --comment "Batch closing resolved issues"
```

**Reopen issues:**

```bash
# Reopen issue
gh issue reopen 42 --comment "Issue persists, reopening"

# Reopen multiple
gh issue reopen 42 43 44
```

### Step 7: Advanced Issue Operations

**Pin issue:**

```bash
# Pin important issue (requires GraphQL API)
gh api graphql -f query='
mutation {
  pinIssue(input: {issueId: "ISSUE_NODE_ID"}) {
    issue {
      title
    }
  }
}'
```

**Lock conversation:**

```bash
# Lock issue to prevent further comments
gh api -X PUT repos/:owner/:repo/issues/42/lock \
    -f lock_reason="resolved"

# Unlock issue
gh api -X DELETE repos/:owner/:repo/issues/42/lock
```

**Transfer issue:**

```bash
# Transfer to another repository
gh api --method POST \
    repos/:owner/:repo/issues/42/transfer \
    -f repository_id=123456789
```

### Step 8: Automate Issue Workflows

Create powerful automation scripts:

**Example 1: Daily Issue Report**

```bash
#!/bin/bash
# generate-issue-report.sh

echo "📊 Daily Issue Report - $(date +%Y-%m-%d)"
echo "=========================================="
echo

echo "🆕 New Issues (Last 24 hours):"
gh issue list --search "created:>$(date -v-1d +%Y-%m-%d)" --json number,title \
    | jq -r '.[] | "#\(.number) \(.title)"'

echo
echo "🔴 Critical Issues:"
gh issue list --label critical --json number,title \
    | jq -r '.[] | "#\(.number) \(.title)"'

echo
echo "📈 Statistics:"
OPEN=$(gh issue list --state open --json number | jq length)
CLOSED_TODAY=$(gh issue list --state closed --search "closed:>$(date -v-1d +%Y-%m-%d)" --json number | jq length)
echo "  Open issues: $OPEN"
echo "  Closed today: $CLOSED_TODAY"
```

**Example 2: Stale Issue Reminder**

```bash
#!/bin/bash
# stale-issue-check.sh

STALE_DAYS=30
STALE_DATE=$(date -v-${STALE_DAYS}d +%Y-%m-%d)

echo "Checking for stale issues (inactive for $STALE_DAYS days)..."

gh issue list --state open --search "updated:<$STALE_DATE" --json number,title,url | \
jq -r '.[] | "\(.number)|\(.title)|\(.url)"' | \
while IFS='|' read -r number title url; do
    echo "Issue #$number: $title"
    gh issue comment $number --body "⚠️ This issue has been inactive for $STALE_DAYS days. 
    
Please provide an update or this issue will be closed in 7 days."
    gh issue edit $number --add-label "stale"
done
```

**Example 3: Auto-Label by Title**

```bash
#!/bin/bash
# auto-label-issues.sh

# Get recent unlabeled issues
gh issue list --label "!bug,!feature,!docs" --limit 10 --json number,title | \
jq -r '.[] | "\(.number)|\(.title)"' | \
while IFS='|' read -r number title; do
    echo "Processing #$number: $title"
    
    # Auto-label based on keywords
    if echo "$title" | grep -qi "bug\|error\|crash\|fail"; then
        gh issue edit $number --add-label "bug"
        echo "  Added label: bug"
    fi
    
    if echo "$title" | grep -qi "feature\|enhancement\|add"; then
        gh issue edit $number --add-label "enhancement"
        echo "  Added label: enhancement"
    fi
    
    if echo "$title" | grep -qi "doc\|documentation\|readme"; then
        gh issue edit $number --add-label "documentation"
        echo "  Added label: documentation"
    fi
done
```

## 🎓 Key Commands Reference

| Command | Description |
|---------|-------------|
| `gh issue list` | List issues with filters |
| `gh issue view <number>` | View issue details |
| `gh issue create` | Create new issue |
| `gh issue comment <number>` | Add comment to issue |
| `gh issue edit <number>` | Update issue metadata |
| `gh issue close <number>` | Close issue |
| `gh issue reopen <number>` | Reopen closed issue |
| `gh issue status` | Show your issue status |

## 💡 Pro Tips

### 1. Issue Templates

Create reusable templates:

```bash
# Create .github/ISSUE_TEMPLATE/bug_report.md
mkdir -p .github/ISSUE_TEMPLATE
cat > .github/ISSUE_TEMPLATE/bug_report.md <<'EOF'
---
name: Bug Report
about: Report a bug to help us improve
labels: bug
assignees: ''
---

## Bug Description
A clear description of the bug

## Steps to Reproduce
1. Step one
2. Step two
3. See error

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- Version:
- OS:
- Browser:
EOF
```

### 2. Quick Issue Creation Alias

```bash
# Add to ~/.zshrc or ~/.bashrc
alias ghi='gh issue create'
alias ghil='gh issue list'
alias ghic='gh issue close'
```

### 3. Issue Search Power

```bash
# Complex searches
gh issue list --search "is:open author:@me label:bug sort:updated-desc"
gh issue list --search "is:issue is:closed closed:>2024-01-01"
gh issue list --search "linked:pr is:open"
```

### 4. Export Issues to CSV

```bash
gh issue list --state all --limit 1000 --json number,title,state,labels,assignees,createdAt | \
jq -r '.[] | [.number,.title,.state,(.labels | map(.name) | join(";")),(.assignees | map(.login) | join(";")),. createdAt] | @csv' > issues.csv
```

## 🔍 Practical Examples

### Example: Weekly Sprint Planning

```bash
#!/bin/bash
MILESTONE="Sprint 24"

echo "📋 Sprint Planning - $MILESTONE"
echo "================================"

# Create milestone if needed
gh api repos/:owner/:repo/milestones -f title="$MILESTONE"

# Assign sprint issues
cat sprint-issues.txt | while read issue; do
    gh issue edit $issue --milestone "$MILESTONE"
done

# Generate sprint report
gh issue list --milestone "$MILESTONE" --json number,title,assignees | \
jq -r '.[] | "- [ ] #\(.number): \(.title) (@\(.assignees[0].login))"'
```

## ✅ Lab Exercise

Complete this practical exercise:

1. **Create a bug report:**
```bash
gh issue create \
    --title "Lab 3 Exercise: Sample Bug" \
    --body "This is a practice issue for Lab 3" \
    --label "bug,lab-exercise"
```

2. **Add comment:**
```bash
# Get issue number from previous command, then:
gh issue comment <NUMBER> --body "Adding investigation notes..."
```

3. **Update metadata:**
```bash
gh issue edit <NUMBER> \
    --add-label "in-progress" \
    --add-assignee @me
```

4. **Close with resolution:**
```bash
gh issue close <NUMBER> --comment "Lab exercise completed! ✅"
```

## 📚 Additional Resources

- [gh issue documentation](https://cli.github.com/manual/gh_issue)
- [GitHub Issues guide](https://docs.github.com/en/issues)
- [Issue templates](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests)
- [GitHub Search syntax](https://docs.github.com/en/search-github/searching-on-github/searching-issues-and-pull-requests)

## 🚀 Next Steps

**[Lab 4: Pull Request Workflows →](./LAB4-PULL-REQUESTS.md)**

Master pull request creation, review, and merge workflows.

---

**Lab Duration:** 40-50 minutes  
**Difficulty:** Intermediate  
**Prerequisites:** Labs 1-2 completed
