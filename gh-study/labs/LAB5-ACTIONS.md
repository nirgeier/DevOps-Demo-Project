# Lab 5: GitHub Actions & CI/CD Management

## 📚 Overview

Master GitHub Actions management from the command line. Learn to monitor workflows, debug runs, download artifacts, and automate CI/CD operations using GitHub CLI.

## 🎯 Learning Objectives

- ✅ List and view workflows
- ✅ Monitor workflow runs and logs
- ✅ Trigger manual workflows
- ✅ Download and manage artifacts
- ✅ Re-run failed workflows
- ✅ Cancel running workflows
- ✅ Create monitoring dashboards
- ✅ Automate workflow operations

## 🔧 Prerequisites

- Completed Labs 1-4
- Repository with GitHub Actions enabled
- Understanding of CI/CD concepts
- Workflows configured in `.github/workflows/`

## 📋 Key Commands

### List Workflows

```bash
# All workflows
gh workflow list

# Detailed workflow view
gh workflow view ci.yml
gh workflow view --web

# JSON output
gh workflow list --json name,state,path
```

### View Workflow Runs

```bash
# Recent runs
gh run list --limit 20

# Filter by status
gh run list --status success
gh run list --status failure
gh run list --status in_progress

# Filter by workflow
gh run list --workflow ci.yml

# Filter by branch
gh run list --branch main

# Filter by date
gh run list --created ">2024-11-01"
```

### Watch Run Progress

```bash
# View specific run
gh run view 123456789

# Watch in real-time
gh run watch 123456789

# View logs
gh run view 123456789 --log

# JSON output
gh run view 123456789 --json status,conclusion,workflowName
```

### Trigger Workflows

```bash
# Trigger workflow
gh workflow run ci.yml

# With inputs
gh workflow run deploy.yml \
    --field environment=production \
    --field version=1.2.3

# On specific branch
gh workflow run ci.yml --ref feature-branch
```

### Manage Artifacts

```bash
# List artifacts for run
gh run view 123456789 --json artifacts

# Download artifacts
gh run download 123456789

# Download to specific directory
gh run download 123456789 --dir ./artifacts

# Download specific artifact
gh run download 123456789 --name test-results
```

### Re-run Workflows

```bash
# Re-run entire workflow
gh run rerun 123456789

# Re-run only failed jobs
gh run rerun 123456789 --failed

# Debug run
gh run rerun 123456789 --debug
```

### Cancel Runs

```bash
# Cancel specific run
gh run cancel 123456789

# Cancel all runs for workflow
gh run list --workflow ci.yml --status in_progress --json databaseId \
    | jq -r '.[].databaseId' \
    | xargs -I {} gh run cancel {}
```

## 💡 Practical Examples

### Example 1: CI/CD Dashboard

```bash
#!/bin/bash
# ci-dashboard.sh

echo "╔═══════════════════════════════════════╗"
echo "║      GitHub Actions Dashboard         ║"
echo "╚═══════════════════════════════════════╝"

echo
echo "⏳ In Progress:"
gh run list --status in_progress --limit 5

echo
echo "✅ Recent Successes:"
gh run list --status success --limit 5

echo
echo "❌ Recent Failures:"
gh run list --status failure --limit 5

echo
echo "📊 Today's Statistics:"
SUCCESS=$(gh run list --status success --created "$(date +%Y-%m-%d)" --json databaseId | jq length)
FAILED=$(gh run list --status failure --created "$(date +%Y-%m-%d)" --json databaseId | jq length)
echo "  Success: $SUCCESS | Failed: $FAILED"
```

### Example 2: Auto-retry Failed Workflows

```bash
#!/bin/bash
# retry-failed.sh

gh run list --status failure --limit 10 --json databaseId,workflowName | \
jq -r '.[] | "\(.databaseId)|\(.workflowName)"' | \
while IFS='|' read -r id workflow; do
    echo "Retrying $workflow (Run: $id)"
    gh run rerun $id --failed
    sleep 2
done
```

### Example 3: Deployment Automation

```bash
#!/bin/bash
# deploy.sh

VERSION=$1
ENV=${2:-production}

echo "🚀 Deploying v$VERSION to $ENV"

# Trigger deployment workflow
RUN_ID=$(gh workflow run deploy.yml \
    --field version=$VERSION \
    --field environment=$ENV \
    --json databaseId -q .databaseId)

echo "Workflow triggered: Run #$RUN_ID"
echo "Watching deployment..."

# Watch progress
gh run watch $RUN_ID

# Check result
STATUS=$(gh run view $RUN_ID --json conclusion -q .conclusion)

if [ "$STATUS" = "SUCCESS" ]; then
    echo "✅ Deployment successful!"
else
    echo "❌ Deployment failed!"
    gh run view $RUN_ID --log
    exit 1
fi
```

## 🎓 Complete Example: Monitoring Script

```bash
#!/bin/bash
# monitor-workflows.sh

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

while true; do
    clear
    echo "════════════════════════════════════════"
    echo "  Workflow Monitor - $REPO"
    echo "  $(date)"
    echo "════════════════════════════════════════"
    
    echo
    echo "📊 Active Workflows:"
    gh run list --status in_progress --limit 5 \
        --json workflowName,startedAt,displayTitle \
        | jq -r '.[] | "  • \(.workflowName): \(.displayTitle)"'
    
    echo
    echo "✅ Last 5 Successful:"
    gh run list --status success --limit 5 \
        --json workflowName,conclusion,createdAt \
        | jq -r '.[] | "  • \(.workflowName) - \(.createdAt)"'
    
    echo
    echo "❌ Recent Failures:"
    FAILURES=$(gh run list --status failure --limit 3 --json databaseId | jq length)
    echo "  Count: $FAILURES"
    
    echo
    echo "Press Ctrl+C to exit. Refreshing in 30s..."
    sleep 30
done
```

## ✅ Lab Exercise

1. **List your workflows:**
```bash
gh workflow list
```

2. **View recent runs:**
```bash
gh run list --limit 10
```

3. **Trigger a workflow (if you have one):**
```bash
gh workflow run ci.yml
```

4. **Watch the run:**
```bash
gh run watch
```

5. **Download artifacts:**
```bash
gh run download <run-id>
```

## 📚 Additional Resources

- [gh workflow docs](https://cli.github.com/manual/gh_workflow)
- [gh run docs](https://cli.github.com/manual/gh_run)
- [GitHub Actions documentation](https://docs.github.com/en/actions)
- [Workflow syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)

## 🚀 Next Steps

**[Lab 6: Release Management →](./LAB6-RELEASES.md)**

---

**Lab Duration:** 40-50 minutes  
**Difficulty:** Intermediate  
**Prerequisites:** Labs 1-4, GitHub Actions knowledge
