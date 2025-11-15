#!/bin/bash
# Lab 6: Monitoring & Troubleshooting
# Learn debugging, monitoring, and problem-solving

set -e

echo "🎓 Lab 6: Monitoring & Troubleshooting"
echo "======================================="
echo

# Check authentication
if ! oc whoami &> /dev/null; then
    echo "❌ Not authenticated! Please login first"
    exit 1
fi

echo "✅ Authenticated as: $(oc whoami)"
echo

# Create project
PROJECT_NAME="lab6-demo-$(date +%s)"
echo "Creating project: $PROJECT_NAME"
oc new-project $PROJECT_NAME --display-name="Lab 6 Monitoring" || oc project $PROJECT_NAME

# Progress tracking
TOTAL_STEPS=8
CURRENT_STEP=0

progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📍 Step $CURRENT_STEP of $TOTAL_STEPS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
}

# Deploy test application
echo "Deploying test application..."
oc new-app nginx:latest --name=test-app
sleep 3

progress
echo "✅ Step 1: Project Status Overview"
echo "==================================="
echo
echo "Project status:"
oc status

echo
echo "All resources:"
oc get all

echo
echo "Resource summary:"
echo "  Deployments: $(oc get deployments --no-headers | wc -l)"
echo "  Pods: $(oc get pods --no-headers | wc -l)"
echo "  Services: $(oc get services --no-headers | wc -l)"

echo
read -p "Press Enter to continue..."

progress
echo "📋 Step 2: View Events"
echo "======================"
echo
echo "Recent events:"
oc get events --sort-by='.lastTimestamp' | tail -20

echo
echo "Watch events (Ctrl+C to stop):"
read -p "Start watching? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    timeout 30s oc get events --watch || true
fi

echo
echo "Filter events by type:"
echo "  oc get events --field-selector type=Warning"
echo "  oc get events --field-selector type=Normal"

echo
read -p "Press Enter to continue..."

progress
echo "🐛 Step 3: Pod Troubleshooting"
echo "==============================="
echo
POD_NAME=$(oc get pods -l app=test-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$POD_NAME" ]; then
    echo "Investigating pod: $POD_NAME"
    echo
    echo "1. Pod status:"
    oc get pod $POD_NAME -o jsonpath='{.status.phase}'
    echo
    
    echo
    echo "2. Pod conditions:"
    oc get pod $POD_NAME -o jsonpath='{.status.conditions[*].type}'
    echo
    
    echo
    echo "3. Container status:"
    oc get pod $POD_NAME -o jsonpath='{.status.containerStatuses[0].state}'
    echo
    
    echo
    echo "4. Pod events:"
    oc describe pod $POD_NAME | grep -A 10 "Events:"
    
    echo
    echo "Common issues to check:"
    cat << 'EOF'
- ImagePullBackOff: Check image name and registry access
- CrashLoopBackOff: Check logs for application errors
- Pending: Check resource availability and node selectors
- OOMKilled: Check memory limits
- Error: Check pod description and events
EOF
else
    echo "No pods available for troubleshooting demo"
fi

echo
read -p "Press Enter to continue..."

progress
echo "🔍 Step 4: Debug Containers"
echo "==========================="
echo

if [ -n "$POD_NAME" ]; then
    echo "Debug options for pod: $POD_NAME"
    echo
    echo "1. View logs:"
    oc logs $POD_NAME --tail=20
    
    echo
    echo "2. Create debug copy:"
    echo "   oc debug pod/$POD_NAME"
    echo
    echo "3. Debug with different image:"
    echo "   oc debug pod/$POD_NAME --image=busybox"
    echo
    echo "4. Debug with root access:"
    echo "   oc debug pod/$POD_NAME --as-root"
    
    echo
    read -p "Create a debug session? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Creating debug pod (type 'exit' to return)..."
        oc debug pod/$POD_NAME || true
    fi
else
    echo "Debug commands demo (no pod available)"
fi

echo
read -p "Press Enter to continue..."

progress
echo "📊 Step 5: Resource Monitoring"
echo "==============================="
echo
echo "Resource usage:"

# Try to get metrics
if oc adm top pods &> /dev/null; then
    echo "Pod resource usage:"
    oc adm top pods
    
    echo
    echo "Sort by CPU:"
    oc adm top pods --sort-by=cpu
    
    echo
    echo "Sort by memory:"
    oc adm top pods --sort-by=memory
else
    echo "ℹ️  Metrics not available (requires metrics-server)"
    echo "   When available, use:"
    echo "     oc adm top pods"
    echo "     oc adm top nodes"
fi

echo
echo "Check pod resource limits:"
if [ -n "$POD_NAME" ]; then
    oc describe pod $POD_NAME | grep -A 5 "Limits\|Requests"
fi

echo
read -p "Press Enter to continue..."

progress
echo "📝 Step 6: Logs Analysis"
echo "========================"
echo

if [ -n "$POD_NAME" ]; then
    echo "Log commands for pod: $POD_NAME"
    echo
    echo "1. Tail logs:"
    oc logs $POD_NAME --tail=10
    
    echo
    echo "2. Logs with timestamps:"
    oc logs $POD_NAME --timestamps --tail=5
    
    echo
    echo "3. Follow logs (Ctrl+C to stop):"
    read -p "Follow logs? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        timeout 20s oc logs -f $POD_NAME || true
    fi
    
    echo
    echo "Other log options:"
    cat << 'EOF'
# Previous container logs (if crashed)
oc logs $POD_NAME --previous

# All containers in pod
oc logs $POD_NAME --all-containers

# Specific container
oc logs $POD_NAME -c container-name

# Since time
oc logs $POD_NAME --since=1h

# Export logs
oc logs $POD_NAME > pod-logs.txt
EOF
fi

echo
read -p "Press Enter to continue..."

progress
echo "🔬 Step 7: Advanced Diagnostics"
echo "================================"
echo
echo "Must-gather (cluster diagnostic collection):"
echo "  oc adm must-gather"
echo "  (Requires admin access, collects extensive cluster data)"

echo
echo "Inspect resources:"
echo "  oc adm inspect deployment/test-app"
echo "  oc adm inspect ns/$PROJECT_NAME"

echo
echo "Network debugging:"
cat << 'EOF'
# Create debug pod with network tools
oc run netdebug --image=nicolaka/netshoot --rm -it -- bash

# DNS testing
oc run dnstest --image=busybox --rm -it -- nslookup test-app

# Connectivity testing
oc run curl --image=curlimages/curl --rm -it -- \
  curl http://test-app:8080
EOF

echo
echo "Check endpoints:"
oc get endpoints

echo
read -p "Press Enter to continue..."

progress
echo "🎯 Step 8: Troubleshooting Scenarios"
echo "====================================="
echo
echo "Common scenarios and solutions:"
echo

cat << 'EOF'
Scenario 1: Pod Won't Start
────────────────────────────
1. oc get pods                      # Check status
2. oc describe pod <name>           # Read events
3. oc logs <name>                   # Check logs
4. oc debug pod/<name>              # Debug

Scenario 2: Application Not Accessible
───────────────────────────────────────
1. oc get pods                      # Pods running?
2. oc get svc <name>                # Service exists?
3. oc get endpoints <name>          # Has endpoints?
4. oc get route <name>              # Route configured?
5. curl <route-url>                 # Test access

Scenario 3: High Memory/CPU Usage
──────────────────────────────────
1. oc adm top pods                  # Check usage
2. oc describe pod <name>           # Check limits
3. oc logs <name>                   # Check for leaks
4. oc set resources deployment/<name> # Update limits

Scenario 4: Build Failures
───────────────────────────
1. oc get builds                    # Check status
2. oc logs -f build/<name>          # Watch logs
3. oc describe bc/<name>            # Check config
4. oc start-build <name>            # Retry

Scenario 5: Permission Errors
──────────────────────────────
1. oc describe pod <name> | grep scc   # Check SCC
2. oc get rolebindings                  # Check RBAC
3. oc adm policy add-scc-to-user anyuid -z default
EOF

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Lab 6 Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "📝 Summary:"
echo "  ✅ Monitored project status"
echo "  ✅ Analyzed events"
echo "  ✅ Troubleshot pods"
echo "  ✅ Used debug containers"
echo "  ✅ Monitored resources"
echo "  ✅ Analyzed logs"
echo "  ✅ Learned diagnostic commands"
echo
echo "🎓 Key Commands Learned:"
echo "========================"
echo "  oc status                         # Project overview"
echo "  oc get events                     # View events"
echo "  oc describe pod <name>            # Pod details"
echo "  oc logs <pod>                     # View logs"
echo "  oc logs -f <pod>                  # Follow logs"
echo "  oc debug pod/<name>               # Debug pod"
echo "  oc adm top pods                   # Resource usage"
echo "  oc adm inspect <resource>         # Collect diagnostics"
echo
echo "💡 Troubleshooting Tips:"
echo "========================"
echo "  1. Always check 'oc status' first"
echo "  2. Use 'oc describe' for detailed info"
echo "  3. Check events for recent issues"
echo "  4. Logs are your friend"
echo "  5. Use debug pods for deep inspection"
echo "  6. Monitor resource usage regularly"
echo
echo "🔧 Cleanup:"
echo "==========="
echo
read -p "Delete the test project? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting project $PROJECT_NAME..."
    oc delete project $PROJECT_NAME
    echo "✅ Cleaned up!"
else
    echo "ℹ️  Project kept: $PROJECT_NAME"
    echo "   Delete with: oc delete project $PROJECT_NAME"
fi

echo
echo "🎓 Congratulations!"
echo "==================="
echo "You've completed all 6 OpenShift CLI labs!"
echo
echo "📚 What's Next?"
echo "==============="
echo "  1. Review the comprehensive guide: ../README.md"
echo "  2. Check the quick reference: ../QUICKSTART.md"
echo "  3. Deploy your own applications"
echo "  4. Set up CI/CD pipelines"
echo "  5. Explore advanced OpenShift features"
echo
echo "💪 You're now ready to:"
echo "  ✅ Deploy applications to OpenShift"
echo "  ✅ Manage projects and resources"
echo "  ✅ Configure networking and routing"
echo "  ✅ Build container images"
echo "  ✅ Monitor and troubleshoot issues"
echo
echo "Keep practicing and exploring! 🚀"
echo
