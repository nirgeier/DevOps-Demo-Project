#!/bin/bash
# Lab 5: GitHub Actions & CI/CD Management
# Learn to manage workflows, runs, and artifacts

set -e

echo "🎓 Lab 5: GitHub Actions Management"
echo "===================================="
echo

# Check if in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository!"
    exit 1
fi

echo "✅ Step 1: List All Workflows"
echo "=============================="
echo
gh workflow list

echo
echo "Detailed view of CI workflow:"
if gh workflow view ci.yml > /dev/null 2>&1; then
    gh workflow view ci.yml
else
    echo "ℹ️  No ci.yml workflow found in this repository"
fi

echo
read -p "Press Enter to continue..."

echo
echo "📊 Step 2: View Recent Workflow Runs"
echo "====================================="
echo
echo "Last 10 workflow runs:"
gh run list --limit 10

echo
echo "Only successful runs:"
gh run list --status success --limit 5

echo
echo "Only failed runs:"
gh run list --status failure --limit 5

echo
echo "Runs in progress:"
gh run list --status in_progress

echo
read -p "Press Enter to continue..."

echo
echo "🔍 Step 3: View Run Details"
echo "==========================="
echo
LATEST_RUN=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')

if [ -n "$LATEST_RUN" ]; then
    echo "Latest run ID: $LATEST_RUN"
    echo
    gh run view $LATEST_RUN
    
    echo
    echo "Run in JSON format:"
    gh run view $LATEST_RUN --json number,status,conclusion,workflowName,headBranch | jq '.'
else
    echo "No workflow runs found in this repository"
fi

echo
read -p "Press Enter to continue..."

echo
echo "📋 Step 4: View Run Logs"
echo "========================"
echo
if [ -n "$LATEST_RUN" ]; then
    echo "Fetching logs for run $LATEST_RUN..."
    echo "Note: This may produce a lot of output"
    echo
    read -p "Display logs? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gh run view $LATEST_RUN --log | head -100
        echo
        echo "... (truncated, showing first 100 lines)"
    fi
else
    echo "No runs available to view logs"
fi

echo
read -p "Press Enter to continue..."

echo
echo "📦 Step 5: List Artifacts"
echo "========================="
echo
if [ -n "$LATEST_RUN" ]; then
    echo "Artifacts for run $LATEST_RUN:"
    ARTIFACTS=$(gh run view $LATEST_RUN --json artifacts --jq '.artifacts')
    
    if [ "$ARTIFACTS" != "[]" ]; then
        echo "$ARTIFACTS" | jq '.'
        
        echo
        read -p "Download artifacts? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            DOWNLOAD_DIR="/tmp/gh-lab5-artifacts"
            mkdir -p $DOWNLOAD_DIR
            gh run download $LATEST_RUN --dir $DOWNLOAD_DIR
            echo "✅ Artifacts downloaded to: $DOWNLOAD_DIR"
            ls -lh $DOWNLOAD_DIR
        fi
    else
        echo "No artifacts found for this run"
    fi
else
    echo "No runs available"
fi

echo
read -p "Press Enter to continue..."

echo
echo "🔄 Step 6: Trigger a Workflow (if manual trigger enabled)"
echo "=========================================================="
echo
echo "Available workflows:"
gh workflow list

echo
echo "To manually trigger a workflow:"
echo "  gh workflow run <workflow-name>"
echo "  gh workflow run ci.yml"
echo "  gh workflow run release.yml --field version=1.0.0"
echo
read -p "Trigger a workflow? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter workflow filename (e.g., ci.yml): " WORKFLOW_NAME
    if [ -n "$WORKFLOW_NAME" ]; then
        gh workflow run $WORKFLOW_NAME && echo "✅ Workflow triggered!"
        echo
        echo "Watch the run with:"
        echo "  gh run watch"
    fi
fi

echo
read -p "Press Enter to continue..."

echo
echo "👀 Step 7: Watch a Running Workflow"
echo "===================================="
echo
IN_PROGRESS=$(gh run list --status in_progress --limit 1 --json databaseId --jq '.[0].databaseId')

if [ -n "$IN_PROGRESS" ]; then
    echo "Found run in progress: $IN_PROGRESS"
    echo
    read -p "Watch this run? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gh run watch $IN_PROGRESS
    fi
else
    echo "No runs currently in progress"
    echo
    echo "To watch a run when available:"
    echo "  gh run watch <run-id>"
    echo "  gh run watch  # watches latest run"
fi

echo
read -p "Press Enter to continue..."

echo
echo "🔁 Step 8: Re-run Workflows"
echo "==========================="
echo
if [ -n "$LATEST_RUN" ]; then
    RUN_STATUS=$(gh run view $LATEST_RUN --json status,conclusion --jq '.status + " " + (.conclusion // "")')
    echo "Latest run status: $RUN_STATUS"
    echo
    echo "Re-run options:"
    echo "  gh run rerun $LATEST_RUN              # Re-run all jobs"
    echo "  gh run rerun $LATEST_RUN --failed     # Re-run only failed jobs"
    echo
    read -p "Re-run this workflow? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gh run rerun $LATEST_RUN && echo "✅ Workflow re-run triggered!"
    fi
else
    echo "No runs available to re-run"
fi

echo
read -p "Press Enter to continue..."

echo
echo "📊 Step 9: Create a Monitoring Script"
echo "======================================"
echo
MONITOR_SCRIPT="/tmp/gh-monitor.sh"
cat > $MONITOR_SCRIPT << 'EOFSCRIPT'
#!/bin/bash
# GitHub Actions Monitoring Dashboard

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

while true; do
    clear
    echo "================================================"
    echo "  GitHub Actions Dashboard - $REPO"
    echo "================================================"
    echo
    
    echo "📊 Workflow Status (Last 5 runs):"
    echo "-----------------------------------"
    gh run list --limit 5 --json workflowName,status,conclusion,createdAt \
        --template '{{range .}}{{.workflowName}}: {{.status}} {{if eq .status "completed"}}({{.conclusion}}){{end}}
{{end}}'
    
    echo
    echo "⏳ In Progress:"
    IN_PROGRESS=$(gh run list --status in_progress --json databaseId | jq 'length')
    echo "   $IN_PROGRESS runs"
    
    echo
    echo "✅ Success Today:"
    SUCCESS=$(gh run list --status success --created $(date -I) --json databaseId | jq 'length')
    echo "   $SUCCESS runs"
    
    echo
    echo "❌ Failed Today:"
    FAILED=$(gh run list --status failure --created $(date -I) --json databaseId | jq 'length')
    echo "   $FAILED runs"
    
    echo
    echo "================================================"
    echo "Press Ctrl+C to exit. Refreshing in 30s..."
    echo "================================================"
    
    sleep 30
done
EOFSCRIPT

chmod +x $MONITOR_SCRIPT

echo "✅ Monitoring script created: $MONITOR_SCRIPT"
echo
read -p "Run the monitoring dashboard? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    $MONITOR_SCRIPT
fi

echo
echo "🎓 Key Commands Learned:"
echo "========================"
echo "  gh workflow list          # List workflows"
echo "  gh workflow view ci.yml   # View workflow details"
echo "  gh workflow run ci.yml    # Trigger workflow"
echo "  gh run list               # List workflow runs"
echo "  gh run view <id>          # View run details"
echo "  gh run view <id> --log    # View run logs"
echo "  gh run watch <id>         # Watch run in real-time"
echo "  gh run download <id>      # Download artifacts"
echo "  gh run rerun <id>         # Re-run workflow"
echo "  gh run cancel <id>        # Cancel running workflow"
echo
echo "💡 Useful Filters:"
echo "=================="
echo "  --status success|failure|in_progress"
echo "  --workflow <name>"
echo "  --branch <branch>"
echo "  --created <date>"
echo "  --json <fields>"
echo
echo "🎉 Lab 5 Complete!"
echo "=================="
echo
echo "Next: Run lab6-releases.sh to learn release management"
