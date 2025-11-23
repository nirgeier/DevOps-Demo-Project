# Lab 6: Monitoring & Troubleshooting

## 📚 Overview

Master OpenShift monitoring, logging, debugging, and troubleshooting techniques to maintain healthy applications and resolve issues effectively.

## 🎯 Learning Objectives

- ✅ Monitor cluster and application health
- ✅ View and analyze logs
- ✅ Debug pods and containers
- ✅ Troubleshoot common issues
- ✅ Use diagnostic tools
- ✅ Monitor resource usage

## 📋 Key Commands

### Project Status

```bash
# Project overview
oc status

# Detailed status
oc status --suggest

# All resources
oc get all

# Resource counts
oc get all --no-headers | wc -l
```

### Events

```bash
# View events
oc get events

# Sort by timestamp
oc get events --sort-by='.lastTimestamp'

# Watch events
oc get events --watch

# Filter by type
oc get events --field-selector type=Warning
oc get events --field-selector type=Normal

# Events for specific resource
oc get events --field-selector involvedObject.name=mypod
```

### Logs

```bash
# Pod logs
oc logs mypod

# Follow logs
oc logs -f mypod

# Previous container logs
oc logs --previous mypod

# All containers in pod
oc logs mypod --all-containers

# Timestamps
oc logs mypod --timestamps

# Since time
oc logs mypod --since=1h
oc logs mypod --since=2024-11-15T10:00:00Z

# Tail last N lines
oc logs mypod --tail=100

# Container specific logs (multi-container pod)
oc logs mypod -c container-name
```

### Debugging

```bash
# Debug pod
oc debug pod/mypod

# Debug with different image
oc debug pod/mypod --image=busybox

# Debug as root
oc debug pod/mypod --as-root

# Debug node
oc debug node/worker-01

# Create debug deployment
oc debug deployment/myapp
```

### Resource Monitoring

```bash
# Pod resource usage (requires metrics server)
oc adm top pods

# Sort by CPU
oc adm top pods --sort-by=cpu

# Sort by memory
oc adm top pods --sort-by=memory

# Node resource usage
oc adm top nodes

# Specific namespace
oc adm top pods -n myproject
```

## 💡 Troubleshooting Scenarios

### Scenario 1: Pod Won't Start

```bash
#!/bin/bash
# diagnose-pod.sh

POD=$1

echo "🔍 Diagnosing pod: $POD"
echo

# Check pod status
echo "Pod Status:"
oc get pod $POD
echo

# Check events
echo "Recent Events:"
oc describe pod $POD | grep -A10 "Events:"
echo

# Check logs
echo "Container Logs:"
oc logs $POD --tail=20
echo

# Check previous logs (if crashed)
echo "Previous Logs (if any):"
oc logs $POD --previous 2>/dev/null || echo "No previous logs"
echo

# Check pod definition
echo "Pod Issues:"
oc describe pod $POD | grep -i "error\|warning\|failed"
```

### Scenario 2: Application Not Accessible

```bash
#!/bin/bash
# check-connectivity.sh

APP=$1

echo "🌐 Checking connectivity for: $APP"
echo

# Check pods
echo "1. Pod Status:"
oc get pods -l app=$APP
echo

# Check service
echo "2. Service:"
oc get svc $APP
echo

# Check endpoints
echo "3. Endpoints:"
oc get endpoints $APP
echo

# Check route
echo "4. Route:"
oc get route $APP
echo

# Test endpoint
ROUTE=$(oc get route $APP -o jsonpath='{.spec.host}' 2>/dev/null)
if [ -n "$ROUTE" ]; then
    echo "5. Testing route: http://$ROUTE"
    curl -I -s "http://$ROUTE" | head -5
fi
```

### Scenario 3: High Resource Usage

```bash
#!/bin/bash
# resource-check.sh

echo "📊 Resource Usage Report"
echo "======================="
echo

# Top pods by memory
echo "Top 5 Memory Consumers:"
oc adm top pods --sort-by=memory | head -6
echo

# Top pods by CPU
echo "Top 5 CPU Consumers:"
oc adm top pods --sort-by=cpu | head -6
echo

# Check limits
echo "Resource Limits:"
oc describe quota 2>/dev/null || echo "No quotas set"
echo

# Check node usage
echo "Node Usage:"
oc adm top nodes 2>/dev/null || echo "Metrics not available"
```

### Scenario 4: Build Failures

```bash
#!/bin/bash
# diagnose-build.sh

BC=$1

echo "🏗️ Diagnosing build: $BC"
echo

# Check build config
echo "Build Config:"
oc get bc $BC
echo

# Recent builds
echo "Recent Builds:"
oc get builds -l buildconfig=$BC
echo

# Latest build logs
LATEST_BUILD=$(oc get builds -l buildconfig=$BC -o name | tail -1)
if [ -n "$LATEST_BUILD" ]; then
    echo "Latest Build Logs:"
    oc logs $LATEST_BUILD | tail -50
fi
echo

# Check source
echo "Build Source:"
oc describe bc $BC | grep -A5 "Source:"
```

## 🎓 Monitoring Dashboard

```bash
#!/bin/bash
# monitoring-dashboard.sh

PROJECT=${1:-$(oc project -q)}

while true; do
    clear
    echo "═══════════════════════════════════════════"
    echo "  OpenShift Monitoring Dashboard"
    echo "  Project: $PROJECT"
    echo "  Time: $(date)"
    echo "═══════════════════════════════════════════"
    echo
    
    # Project status
    echo "📊 Project Status:"
    PODS=$(oc get pods --no-headers | wc -l)
    RUNNING=$(oc get pods --field-selector=status.phase=Running --no-headers | wc -l)
    PENDING=$(oc get pods --field-selector=status.phase=Pending --no-headers | wc -l)
    FAILED=$(oc get pods --field-selector=status.phase=Failed --no-headers | wc -l)
    
    echo "  Total Pods: $PODS"
    echo "  Running: $RUNNING"
    echo "  Pending: $PENDING"
    echo "  Failed: $FAILED"
    echo
    
    # Recent events
    echo "📋 Recent Events:"
    oc get events --sort-by='.lastTimestamp' | tail -5
    echo
    
    # Resource usage
    echo "💻 Resource Usage:"
    oc adm top pods --sort-by=memory 2>/dev/null | head -6 || echo "  Metrics not available"
    echo
    
    # Recent warnings
    WARNINGS=$(oc get events --field-selector type=Warning --no-headers | wc -l)
    echo "⚠️  Active Warnings: $WARNINGS"
    
    echo
    echo "Press Ctrl+C to exit. Refreshing in 30s..."
    sleep 30
done
```

## 🎓 Complete Troubleshooting Script

```bash
#!/bin/bash
# openshift-doctor.sh

PROJECT=$1

echo "🏥 OpenShift Project Health Check"
echo "=================================="
echo "Project: ${PROJECT:-current}"
echo "Time: $(date)"
echo

[ -n "$PROJECT" ] && oc project $PROJECT

# 1. Check authentication
echo "1️⃣ Authentication"
oc whoami && echo "✅ Authenticated" || echo "❌ Not authenticated"
echo

# 2. Check pods
echo "2️⃣ Pod Health"
TOTAL_PODS=$(oc get pods --no-headers 2>/dev/null | wc -l)
HEALTHY_PODS=$(oc get pods --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
echo "Total: $TOTAL_PODS | Healthy: $HEALTHY_PODS"

if [ "$TOTAL_PODS" -ne "$HEALTHY_PODS" ]; then
    echo "⚠️  Unhealthy pods detected:"
    oc get pods | grep -v "Running\|Completed"
fi
echo

# 3. Check deployments
echo "3️⃣ Deployments"
oc get deployments --no-headers | while read name desired current updated available age; do
    if [ "$desired" != "$available" ]; then
        echo "⚠️  $name: $available/$desired available"
    else
        echo "✅ $name: OK"
    fi
done
echo

# 4. Check services
echo "4️⃣ Services"
SVC_COUNT=$(oc get svc --no-headers | wc -l)
echo "Services: $SVC_COUNT"
oc get svc --no-headers | while read name type cluster_ip external port age; do
    ENDPOINTS=$(oc get endpoints $name -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null | wc -w)
    if [ "$ENDPOINTS" -eq 0 ]; then
        echo "⚠️  $name: No endpoints"
    fi
done
echo

# 5. Check routes
echo "5️⃣ Routes"
ROUTE_COUNT=$(oc get routes --no-headers 2>/dev/null | wc -l)
echo "Routes: $ROUTE_COUNT"
oc get routes --no-headers 2>/dev/null | while read name host path services port term age; do
    echo "  $name → $host"
done
echo

# 6. Check events
echo "6️⃣ Recent Issues"
WARNINGS=$(oc get events --field-selector type=Warning --no-headers 2>/dev/null | wc -l)
if [ "$WARNINGS" -gt 0 ]; then
    echo "⚠️  $WARNINGS warnings found:"
    oc get events --field-selector type=Warning --no-headers | tail -3
else
    echo "✅ No warnings"
fi
echo

# 7. Resource usage
echo "7️⃣ Resource Usage"
oc adm top pods --sort-by=memory 2>/dev/null | head -5 || echo "Metrics not available"
echo

echo "=================================="
echo "Health check complete!"
```

## ✅ Lab Exercise

1. Deploy application with intentional issues
2. Use diagnostic commands
3. Analyze logs and events
4. Debug pod issues
5. Fix problems
6. Verify health

## 📚 Common Issues & Solutions

### ImagePullBackOff
```bash
# Check image name
oc describe pod <pod> | grep -i image

# Check image stream
oc get is

# Check pull secrets
oc get secrets
```

### CrashLoopBackOff
```bash
# Check logs
oc logs <pod> --previous

# Check resource limits
oc describe pod <pod> | grep -A5 Limits

# Debug interactively
oc debug pod/<pod>
```

### OOMKilled
```bash
# Check memory limits
oc describe pod <pod> | grep -i memory

# Increase limits
oc set resources deployment/<name> --limits=memory=1Gi
```

## 📚 Resources

- [Monitoring](https://docs.openshift.com/container-platform/latest/monitoring/monitoring-overview.html)
- [Logging](https://docs.openshift.com/container-platform/latest/logging/cluster-logging.html)
- [Troubleshooting](https://docs.openshift.com/container-platform/latest/support/troubleshooting/index.html)

## 🎉 Congratulations!

You've completed all OpenShift CLI labs! You now can:

- ✅ Deploy and manage applications
- ✅ Configure networking and routing
- ✅ Build container images
- ✅ Monitor and troubleshoot effectively
- ✅ Automate OpenShift operations

---

**Lab Duration:** 50-60 minutes  
**Difficulty:** Intermediate to Advanced  
**Prerequisites:** Labs 1-5 completed
