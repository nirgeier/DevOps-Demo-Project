#!/bin/bash
# Lab 4: Service & Route Configuration
# Learn networking, services, and external access

set -e

echo "🎓 Lab 4: Service & Route Configuration"
echo "========================================"
echo

# Check authentication
if ! oc whoami &> /dev/null; then
    echo "❌ Not authenticated! Please login first"
    exit 1
fi

echo "✅ Authenticated as: $(oc whoami)"
echo

# Create project
PROJECT_NAME="lab4-demo-$(date +%s)"
echo "Creating project: $PROJECT_NAME"
oc new-project $PROJECT_NAME --display-name="Lab 4 Networking" || oc project $PROJECT_NAME

# Progress tracking
TOTAL_STEPS=7
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
echo "✅ Step 1: Deploy Application"
echo "=============================="
echo
echo "Deploying nginx application..."

oc new-app nginx:latest --name=web-app
sleep 3

echo "Application deployed:"
oc get all -l app=web-app

echo
read -p "Press Enter to continue..."

progress
echo "🌐 Step 2: View Services"
echo "========================"
echo
echo "List all services:"
oc get services

echo
echo "Service details:"
oc describe svc web-app

echo
echo "Service endpoints:"
oc get endpoints web-app

echo
echo "The service provides internal cluster access to the pods."
echo "ClusterIP: $(oc get svc web-app -o jsonpath='{.spec.clusterIP}')"
echo "Port: $(oc get svc web-app -o jsonpath='{.spec.ports[0].port}')"

echo
read -p "Press Enter to continue..."

progress
echo "🔀 Step 3: Create Route (External Access)"
echo "=========================================="
echo
echo "Exposing service with a route..."

oc expose svc web-app

echo "✅ Route created!"
echo
echo "Available routes:"
oc get routes

echo
ROUTE_HOST=$(oc get route web-app -o jsonpath='{.spec.host}' 2>/dev/null)
if [ -n "$ROUTE_HOST" ]; then
    echo "Your application is accessible at:"
    echo "  http://$ROUTE_HOST"
    echo
    read -p "Test the route? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Testing route..."
        curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" "http://$ROUTE_HOST" || echo "Connection failed"
    fi
fi

echo
read -p "Press Enter to continue..."

progress
echo "🔒 Step 4: Secure Route (HTTPS)"
echo "================================"
echo
echo "Creating edge-terminated TLS route..."

oc create route edge web-app-secure \
    --service=web-app \
    --hostname="secure-$PROJECT_NAME.apps.example.com" 2>/dev/null || echo "Route creation (may need admin access)"

echo
echo "All routes:"
oc get routes

echo
read -p "Press Enter to continue..."

progress
echo "⚖️  Step 5: Load Balancing & Traffic Management"
echo "==============================================="
echo
echo "Let's deploy a second version for A/B testing..."

oc new-app nginx:1.20 --name=web-v1
oc new-app nginx:1.21 --name=web-v2

echo "Waiting for deployments..."
sleep 5

echo
echo "Both versions deployed:"
oc get deployments

echo
echo "Creating routes for A/B testing..."

# Create route for v1
oc expose svc web-v1 --name=web-split 2>/dev/null || true

# Set traffic split (if supported)
echo
echo "Traffic can be split between services:"
echo "  oc set route-backends web-split web-v1=80 web-v2=20"
echo "  (80% traffic to v1, 20% to v2)"

echo
read -p "Press Enter to continue..."

progress
echo "🧪 Step 6: Service Types"
echo "========================"
echo
echo "OpenShift supports different service types:"
echo

cat << 'EOF'
1. ClusterIP (default)
   - Internal cluster access only
   - Service IP accessible from within cluster

2. NodePort
   - Exposes service on each node's IP
   - Accessible via <NodeIP>:<NodePort>

3. LoadBalancer
   - Creates external load balancer (cloud providers)
   - Gets external IP for access

4. ExternalName
   - Maps service to external DNS name
EOF

echo
echo "Current services and their types:"
oc get svc -o custom-columns=NAME:.metadata.name,TYPE:.spec.type,CLUSTER-IP:.spec.clusterIP

echo
read -p "Press Enter to continue..."

progress
echo "🔍 Step 7: Port Forwarding"
echo "=========================="
echo
echo "Port forwarding allows local access to services..."
echo
POD_NAME=$(oc get pods -l app=web-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$POD_NAME" ] && [ "$POD_NAME" != "null" ]; then
    echo "Available pod: $POD_NAME"
    echo
    echo "To forward local port 8080 to pod port 80:"
    echo "  oc port-forward pod/$POD_NAME 8080:80"
    echo
    echo "To forward to service:"
    echo "  oc port-forward svc/web-app 8080:80"
    echo
    read -p "Try port forwarding now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Starting port forward (Ctrl+C to stop)..."
        echo "Test with: curl http://localhost:8080"
        echo
        timeout 30s oc port-forward svc/web-app 8080:80 || true
    fi
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Lab 4 Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "📝 Summary:"
echo "  ✅ Created and managed services"
echo "  ✅ Exposed applications with routes"
echo "  ✅ Created secure HTTPS routes"
echo "  ✅ Learned load balancing concepts"
echo "  ✅ Explored service types"
echo "  ✅ Used port forwarding"
echo
echo "🎓 Key Commands Learned:"
echo "========================"
echo "  oc get svc                        # List services"
echo "  oc describe svc <name>            # Service details"
echo "  oc get endpoints <name>           # Service endpoints"
echo "  oc expose svc <name>              # Create route"
echo "  oc get routes                     # List routes"
echo "  oc create route edge <name> --service=<svc>"
echo "  oc port-forward svc/<name> <local>:<remote>"
echo
echo "💡 Advanced Networking:"
echo "======================="
echo "  oc set route-backends <route> <svc1>=<weight> <svc2>=<weight>"
echo "  oc create route passthrough <name> --service=<svc>"
echo "  oc create route reencrypt <name> --service=<svc>"
echo "  oc annotate route <name> haproxy.router.openshift.io/timeout=60s"
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
echo "  Run: ./lab5-builds.sh"
echo "  Topic: Build & ImageStream Operations"
echo
