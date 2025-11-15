#!/bin/bash
# Lab 5: Build & ImageStream Operations
# Learn Source-to-Image builds and image management

set -e

echo "🎓 Lab 5: Build & ImageStream Operations"
echo "========================================="
echo

# Check authentication
if ! oc whoami &> /dev/null; then
    echo "❌ Not authenticated! Please login first"
    exit 1
fi

echo "✅ Authenticated as: $(oc whoami)"
echo

# Create project
PROJECT_NAME="lab5-demo-$(date +%s)"
echo "Creating project: $PROJECT_NAME"
oc new-project $PROJECT_NAME --display-name="Lab 5 Builds" || oc project $PROJECT_NAME

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
echo "✅ Step 1: Source-to-Image (S2I) Build"
echo "======================================="
echo
echo "Deploying a Python app with S2I..."
echo "Repository: https://github.com/sclorg/django-ex"
echo

oc new-app python:3.9~https://github.com/sclorg/django-ex \
    --name=django-app

echo
echo "✅ Build initiated!"
echo
echo "Resources created:"
oc get all -l app=django-app

echo
read -p "Press Enter to continue..."

progress
echo "🔨 Step 2: Watch Build Process"
echo "==============================="
echo
echo "Build configurations:"
oc get buildconfig

echo
echo "Current builds:"
oc get builds

echo
echo "Following build logs (Ctrl+C to stop watching)..."
sleep 2

BUILD_NAME=$(oc get builds -l app=django-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$BUILD_NAME" ]; then
    timeout 120s oc logs -f build/$BUILD_NAME || echo "Build timeout or completed"
else
    echo "Build not started yet"
fi

echo
echo "Final build status:"
oc get builds

echo
read -p "Press Enter to continue..."

progress
echo "🖼️  Step 3: ImageStream Management"
echo "==================================="
echo
echo "List image streams:"
oc get imagestreams

echo
echo "Django app image stream:"
oc describe is django-app | head -30

echo
echo "Image stream tags:"
oc get imagestreamtag

echo
echo "Import external image..."
oc import-image nginx:latest \
    --from=docker.io/library/nginx:latest \
    --confirm \
    --scheduled 2>/dev/null || echo "Image import (may need permissions)"

echo
read -p "Press Enter to continue..."

progress
echo "🏷️  Step 4: Image Tagging"
echo "========================="
echo
echo "Tag the built image..."

# Tag latest as v1.0
oc tag django-app:latest django-app:v1.0

# Tag as stable
oc tag django-app:latest django-app:stable

echo "✅ Tags created!"
echo
echo "All image stream tags:"
oc get istag | grep django-app

echo
echo "Image stream with tags:"
oc describe is django-app | grep -A 5 "Tags:"

echo
read -p "Press Enter to continue..."

progress
echo "🔄 Step 5: Build Triggers"
echo "========================="
echo
echo "Build configuration with triggers:"
oc describe bc django-app | grep -A 15 "Triggered by:"

echo
echo "Available trigger types:"
cat << 'EOF'
1. Webhook Triggers (GitHub, GitLab, Bitbucket)
   - Trigger builds automatically on git push
   - Get webhook URL: oc describe bc <name>

2. Image Change Triggers
   - Rebuild when base image changes
   - Example: python:3.9 updates

3. Config Change Triggers
   - Rebuild when BuildConfig changes
EOF

echo
echo "To manually trigger a build:"
echo "  oc start-build django-app"
echo "  oc start-build django-app --follow"

echo
read -p "Trigger a manual build? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting new build..."
    oc start-build django-app --follow
fi

echo
read -p "Press Enter to continue..."

progress
echo "🔐 Step 6: Build Secrets and Authentication"
echo "============================================"
echo
echo "Creating a sample Git auth secret..."

oc create secret generic git-auth \
    --from-literal=username=demo-user \
    --from-literal=password=demo-pass \
    --type=kubernetes.io/basic-auth \
    2>/dev/null || echo "Secret may already exist"

echo "✅ Secret created!"
echo
echo "Secrets in project:"
oc get secrets | grep -v "token\|dockercfg"

echo
echo "To use secret in build:"
echo "  oc set build-secret --source bc/django-app git-auth"

echo
echo "For Docker registry authentication:"
cat << 'EOF'
oc create secret docker-registry my-registry \
  --docker-server=quay.io \
  --docker-username=user \
  --docker-password=pass

oc secrets link builder my-registry
EOF

echo
read -p "Press Enter to continue..."

progress
echo "⚙️  Step 7: Advanced Build Operations"
echo "======================================"
echo
echo "Build configuration details:"
oc get bc django-app -o yaml | head -30

echo
echo "Update build resources:"
cat << 'EOF'
# Set build resource limits
oc patch bc/django-app -p '
{
  "spec": {
    "resources": {
      "limits": {
        "cpu": "1",
        "memory": "1Gi"
      }
    }
  }
}'

# Set environment variable in build
oc set env bc/django-app BUILD_ENV=production

# Update build source
oc patch bc/django-app -p '
{
  "spec": {
    "source": {
      "git": {
        "uri": "https://github.com/new-org/new-repo"
      }
    }
  }
}'
EOF

echo
echo "Cancel running build:"
echo "  oc cancel-build <build-name>"

echo
echo "Delete old builds:"
echo "  oc delete build <build-name>"

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Lab 5 Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "📝 Summary:"
echo "  ✅ Created S2I builds"
echo "  ✅ Monitored build process"
echo "  ✅ Managed image streams"
echo "  ✅ Tagged images"
echo "  ✅ Configured build triggers"
echo "  ✅ Used build secrets"
echo
echo "🎓 Key Commands Learned:"
echo "========================"
echo "  oc new-app <builder>~<git-url>    # S2I build"
echo "  oc get buildconfig                # List build configs"
echo "  oc get builds                     # List builds"
echo "  oc start-build <name>             # Trigger build"
echo "  oc logs -f build/<name>           # Follow build logs"
echo "  oc get imagestreams               # List images"
echo "  oc describe is <name>             # Image details"
echo "  oc tag <source> <dest>            # Tag image"
echo "  oc import-image <name>            # Import external image"
echo
echo "💡 Build Types:"
echo "==============="
echo "  Source Strategy (S2I)  - Source code + builder image"
echo "  Docker Strategy        - From Dockerfile"
echo "  Pipeline Strategy      - Jenkins/Tekton pipelines"
echo "  Custom Strategy        - Custom build process"
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
echo "  Run: ./lab6-monitoring.sh"
echo "  Topic: Monitoring & Troubleshooting"
echo
