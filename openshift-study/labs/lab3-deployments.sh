#!/bin/bash
# Lab 3: Deployment & Pod Management
# Learn to manage pods, deployments, and scaling

set -e

echo "🎓 Lab 3: Deployment & Pod Management"
echo "======================================"
echo

# Check authentication
if ! oc whoami &> /dev/null; then
    echo "❌ Not authenticated! Please login first"
    exit 1
fi

echo "✅ Authenticated as: $(oc whoami)"
echo

# Create or use existing project
PROJECT_NAME="lab3-demo-$(date +%s)"
echo "Creating project: $PROJECT_NAME"
oc new-project $PROJECT_NAME --display-name="Lab 3 Demo" || oc project $PROJECT_NAME

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

progress
echo "✅ Step 1: Deploy a Simple Application"
echo "======================================="
echo
echo "Deploying nginx web server..."

oc new-app nginx:latest --name=nginx-demo

echo
echo "Waiting for deployment..."
sleep 5

echo "Current status:"
oc get all -l app=nginx-demo

echo
read -p "Press Enter to continue..."

progress
echo "📋 Step 2: View and Monitor Pods"
echo "================================="
echo
echo "List all pods:"
oc get pods

echo
echo "Detailed pod view (wide output):"
oc get pods -o wide

echo
echo "Pods with labels:"
oc get pods --show-labels

echo
echo "Filter by label:"
oc get pods -l app=nginx-demo

echo
read -p "Press Enter to continue..."

progress
echo "🔍 Step 3: Inspect Pod Details"
echo "==============================="
echo

POD_NAME=$(oc get pods -l app=nginx-demo -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$POD_NAME" ]; then
    echo "Selected pod: $POD_NAME"
    echo
    echo "Pod description (first 40 lines):"
    oc describe pod $POD_NAME | head -40
    
    echo
    echo "Pod status:"
    oc get pod $POD_NAME -o jsonpath='{.status.phase}'
    echo
    
    echo
    read -p "View pod logs? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Pod logs:"
        oc logs $POD_NAME --tail=20
    fi
else
    echo "⏳ Pod not ready yet"
fi

echo
read -p "Press Enter to continue..."

progress
echo "🔧 Step 4: Execute Commands in Pod"
echo "==================================="
echo

if [ -n "$POD_NAME" ] && [ "$(oc get pod $POD_NAME -o jsonpath='{.status.phase}')" == "Running" ]; then
    echo "Executing commands in pod: $POD_NAME"
    echo
    
    echo "1. Check nginx version:"
    oc exec $POD_NAME -- nginx -v
    
    echo
    echo "2. List files in /usr/share/nginx/html:"
    oc exec $POD_NAME -- ls -la /usr/share/nginx/html
    
    echo
    echo "3. Check environment variables:"
    oc exec $POD_NAME -- env | grep -E "KUBERNETES|OPENSHIFT" | head -5
    
    echo
    read -p "Open interactive shell in pod? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Opening shell (type 'exit' to return)..."
        oc rsh $POD_NAME
    fi
else
    echo "⏳ Pod not ready for command execution"
fi

echo
read -p "Press Enter to continue..."

progress
echo "📈 Step 5: Scale Deployment"
echo "==========================="
echo
echo "Current deployment:"
oc get deployment nginx-demo

echo
echo "Scaling up to 3 replicas..."
oc scale deployment nginx-demo --replicas=3

echo
echo "Waiting for pods to be ready..."
sleep 5

echo "New pod count:"
oc get pods -l app=nginx-demo

echo
echo "Deployment status:"
oc get deployment nginx-demo

echo
read -p "Press Enter to continue..."

progress
echo "🔄 Step 6: Rollout Management"
echo "=============================="
echo
echo "Rollout status:"
oc rollout status deployment/nginx-demo

echo
echo "Rollout history:"
oc rollout history deployment/nginx-demo

echo
echo "Let's update the deployment..."
oc set env deployment/nginx-demo DEMO_VAR=lab3

echo
echo "Watch the rollout..."
oc rollout status deployment/nginx-demo

echo
echo "Updated deployment:"
oc get deployment nginx-demo

echo
read -p "Press Enter to continue..."

progress
echo "↩️  Step 7: Rollback and Updates"
echo "================================="
echo
echo "Current revision:"
oc rollout history deployment/nginx-demo

echo
read -p "Perform a rollback? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Rolling back to previous revision..."
    oc rollout undo deployment/nginx-demo
    
    echo
    echo "Rollout status:"
    oc rollout status deployment/nginx-demo
    
    echo
    echo "Verify rollback:"
    oc rollout history deployment/nginx-demo
fi

echo
read -p "Press Enter to continue..."

progress
echo "🔍 Step 8: Resource Management"
echo "==============================="
echo
echo "Setting resource limits..."

oc set resources deployment nginx-demo \
    --limits=cpu=200m,memory=256Mi \
    --requests=cpu=100m,memory=128Mi

echo "✅ Resources updated!"
echo
echo "Verify resources:"
oc describe deployment nginx-demo | grep -A 10 "Limits\|Requests"

echo
echo "Pod resource usage:"
if command -v oc &> /dev/null; then
    oc adm top pods -l app=nginx-demo 2>/dev/null || echo "  (Metrics not available)"
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Lab 3 Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "📝 Summary:"
echo "  ✅ Deployed and managed pods"
echo "  ✅ Executed commands in pods"
echo "  ✅ Scaled deployments"
echo "  ✅ Managed rollouts and rollbacks"
echo "  ✅ Set resource limits"
echo
echo "🎓 Key Commands Learned:"
echo "========================"
echo "  oc get pods                       # List pods"
echo "  oc get pods -o wide               # Detailed view"
echo "  oc describe pod <name>            # Pod details"
echo "  oc logs <pod>                     # View logs"
echo "  oc exec <pod> -- <cmd>            # Execute command"
echo "  oc rsh <pod>                      # Interactive shell"
echo "  oc scale deployment/<name> --replicas=N"
echo "  oc rollout status deployment/<name>"
echo "  oc rollout undo deployment/<name>"
echo "  oc set resources deployment/<name> --limits=..."
echo
echo "💡 Advanced Operations:"
echo "======================="
echo "  oc debug pod/<name>               # Debug pod"
echo "  oc port-forward pod/<name> 8080:80"
echo "  oc cp <pod>:/path /local/path     # Copy files"
echo "  oc logs -f <pod>                  # Follow logs"
echo "  oc logs --previous <pod>          # Previous logs"
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
echo "📚 Next Steps:"
echo "=============="
echo "  Run: ./lab4-networking.sh"
echo "  Topic: Service & Route Configuration"
echo
