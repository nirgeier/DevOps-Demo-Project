#!/bin/bash
# Lab 2: Project & Application Management
# Learn to create projects and deploy applications

set -e

echo "🎓 Lab 2: Project & Application Management"
echo "==========================================="
echo

# Check authentication
if ! oc whoami &> /dev/null; then
    echo "❌ Not authenticated! Please run lab1-setup.sh first"
    echo "   Or login with: oc login --token=<token> --server=<server>"
    exit 1
fi

echo "✅ Authenticated as: $(oc whoami)"
echo "🌐 Server: $(oc whoami --show-server)"
echo

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
echo "✅ Step 1: List Existing Projects"
echo "=================================="
echo
echo "Your accessible projects:"
oc projects

echo
read -p "Press Enter to continue..."

progress
echo "🆕 Step 2: Create a New Project"
echo "================================"
echo
PROJECT_NAME="lab2-demo-$(date +%s)"
echo "Creating project: $PROJECT_NAME"
echo

oc new-project $PROJECT_NAME \
    --display-name="Lab 2 Demo Project" \
    --description="Interactive lab for learning OpenShift CLI"

echo
echo "✅ Project created successfully!"
echo
echo "Current project:"
oc project

echo
read -p "Press Enter to continue..."

progress
echo "📦 Step 3: Deploy Application from Git"
echo "======================================="
echo
echo "Deploying a Node.js application using Source-to-Image (S2I)..."
echo "Repository: https://github.com/sclorg/nodejs-ex"
echo

oc new-app https://github.com/sclorg/nodejs-ex \
    --name=nodejs-app

echo
echo "✅ Application deployment initiated!"
echo
echo "The following resources were created:"
oc get all -l app=nodejs-app

echo
read -p "Press Enter to continue..."

progress
echo "🔨 Step 4: Watch the Build"
echo "=========================="
echo
echo "Watching the build process..."
echo "Press Ctrl+C to stop watching (build will continue)"
echo
sleep 2

# Follow build logs with timeout
timeout 120s oc logs -f bc/nodejs-app || true

echo
echo "Build status:"
oc get builds

echo
read -p "Press Enter to continue..."

progress
echo "📊 Step 5: View Application Resources"
echo "======================================"
echo
echo "All resources in project:"
oc get all

echo
echo "Detailed pod information:"
oc get pods -o wide

echo
echo "Service details:"
oc get svc nodejs-app

echo
echo "Build configuration:"
oc get bc nodejs-app

echo
echo "Image stream:"
oc get is nodejs-app

echo
read -p "Press Enter to continue..."

progress
echo "🔍 Step 6: Inspect Resources"
echo "============================="
echo
echo "Let's examine the deployment in detail..."
echo

# Get pod name
POD_NAME=$(oc get pods -l app=nodejs-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -n "$POD_NAME" ] && [ "$POD_NAME" != "null" ]; then
    echo "Pod Name: $POD_NAME"
    echo
    echo "Pod Description:"
    oc describe pod $POD_NAME | head -30
    
    echo
    echo "Pod Status:"
    oc get pod $POD_NAME -o jsonpath='{.status.phase}'
    echo
    
    if [ "$(oc get pod $POD_NAME -o jsonpath='{.status.phase}')" == "Running" ]; then
        echo
        echo "✅ Pod is running!"
        echo
        read -p "View application logs? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Application logs:"
            oc logs $POD_NAME --tail=20
        fi
    else
        echo "⏳ Pod is still starting up..."
    fi
else
    echo "ℹ️  Pod not yet created or still building"
fi

echo
read -p "Press Enter to continue..."

progress
echo "🧹 Step 7: Project Management"
echo "=============================="
echo
echo "Project operations you can perform:"
echo

cat << 'EOF'
# List all projects
oc projects

# Switch to a project
oc project <project-name>

# Get current project
oc project

# View project details
oc describe project <project-name>

# Label a project
oc label project <project-name> environment=dev

# Annotate a project
oc annotate project <project-name> description="My description"

# Delete a project
oc delete project <project-name>
EOF

echo
echo "Current project details:"
oc describe project $PROJECT_NAME | head -20

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Lab 2 Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "📝 Summary:"
echo "  ✅ Created project: $PROJECT_NAME"
echo "  ✅ Deployed Node.js app from Git"
echo "  ✅ Watched S2I build process"
echo "  ✅ Explored application resources"
echo "  ✅ Learned project management"
echo
echo "🎓 Key Commands Learned:"
echo "========================"
echo "  oc new-project <name>             # Create project"
echo "  oc project <name>                 # Switch project"
echo "  oc projects                       # List projects"
echo "  oc new-app <source>               # Deploy application"
echo "  oc get all                        # List all resources"
echo "  oc logs -f bc/<name>              # Follow build logs"
echo "  oc describe <resource> <name>     # Resource details"
echo
echo "🔧 Cleanup Options:"
echo "==================="
echo
read -p "Delete the test project and all resources? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo "Deleting project $PROJECT_NAME..."
    oc delete project $PROJECT_NAME
    echo "✅ Project deleted!"
else
    echo
    echo "ℹ️  Project kept: $PROJECT_NAME"
    echo "   Delete later with: oc delete project $PROJECT_NAME"
    echo "   Or in web console: Administration → Projects → Delete"
fi

echo
echo "📚 Next Steps:"
echo "=============="
echo "  Run: ./lab3-deployments.sh"
echo "  Topic: Deployment & Pod Management"
echo
echo "💡 Tip: Use 'oc get all' frequently to see all your resources!"
echo
