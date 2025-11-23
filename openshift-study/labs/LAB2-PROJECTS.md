# Lab 2: Project & Application Management

## 📚 Overview

Learn to create and manage OpenShift projects, deploy applications using Source-to-Image (S2I), and understand the application deployment lifecycle.

## 🎯 Learning Objectives

- ✅ Create and manage projects
- ✅ Deploy applications from Git
- ✅ Use Source-to-Image (S2I) builds
- ✅ Monitor build progress
- ✅ View application resources
- ✅ Understand deployment strategies

## 🔧 Prerequisites

- Completed [Lab 1: Setup & Authentication](./LAB1-SETUP.md)
- Authenticated to OpenShift cluster
- Understanding of containerization basics

## 📋 Lab Steps

### Step 1: List Existing Projects

```bash
# View all accessible projects
oc projects

# Get detailed list
oc get projects

# Filter by label
oc get projects -l environment=dev
```

### Step 2: Create a New Project

```bash
# Basic project creation
oc new-project myapp-dev

# With metadata
oc new-project myapp-prod \
    --display-name="My Application - Production" \
    --description="Production environment for my application"

# Verify creation
oc project
oc status
```

### Step 3: Deploy Application from Git

**Deploy Node.js Application:**

```bash
# Create app from Git repository
oc new-app https://github.com/sclorg/nodejs-ex --name=nodejs-app

# Deploy with specific version
oc new-app nodejs:16~https://github.com/sclorg/nodejs-ex

# Deploy from specific branch
oc new-app https://github.com/user/repo#branch-name

# With environment variables
oc new-app https://github.com/sclorg/nodejs-ex \
    -e NODE_ENV=production \
    -e PORT=8080
```

**Deploy Python Application:**

```bash
oc new-app python:3.9~https://github.com/sclorg/django-ex --name=django-app
```

**Deploy from Private Repository:**

```bash
# Create secret for Git authentication
oc create secret generic git-secret \
    --from-literal=username=myuser \
    --from-literal=password=mytoken \
    --type=kubernetes.io/basic-auth

# Link secret to builder
oc set build-secret --source bc/myapp git-secret

# Deploy
oc new-app https://github.com/private/repo --name=myapp
```

### Step 4: Watch Build Process

```bash
# List builds
oc get builds

# Watch build logs
oc logs -f bc/nodejs-app

# Follow specific build
oc logs -f build/nodejs-app-1

# Get build status
oc get build nodejs-app-1

# Cancel build
oc cancel-build nodejs-app-1
```

### Step 5: View Application Resources

```bash
# All resources in project
oc get all

# Specific resource types
oc get pods
oc get deployments
oc get services
oc get routes

# Wide output with more details
oc get pods -o wide

# Watch resources in real-time
oc get pods --watch
```

**Detailed Resource Information:**

```bash
# Describe pod
oc describe pod nodejs-app-1-abc123

# Describe deployment
oc describe deployment nodejs-app

# Describe service
oc describe svc nodejs-app
```

### Step 6: Access Application Logs

```bash
# View logs
oc logs nodejs-app-1-abc123

# Follow logs
oc logs -f nodejs-app-1-abc123

# Previous container logs (if crashed)
oc logs --previous nodejs-app-1-abc123

# Logs from all containers in pod
oc logs nodejs-app-1-abc123 --all-containers

# Last 100 lines
oc logs nodejs-app-1-abc123 --tail=100

# Since timestamp
oc logs nodejs-app-1-abc123 --since=1h
```

### Step 7: Expose Application

```bash
# Create route to expose service
oc expose svc nodejs-app

# View routes
oc get routes

# Get application URL
oc get route nodejs-app -o jsonpath='{.spec.host}'

# Test application
curl http://$(oc get route nodejs-app -o jsonpath='{.spec.host}')
```

### Step 8: Scale Application

```bash
# Scale to 3 replicas
oc scale deployment nodejs-app --replicas=3

# Verify scaling
oc get pods -l app=nodejs-app

# Auto-scaling (HPA)
oc autoscale deployment nodejs-app \
    --min=2 \
    --max=10 \
    --cpu-percent=80
```

## 💡 Advanced Operations

### Label and Annotate Resources

```bash
# Add labels
oc label deployment nodejs-app environment=dev tier=frontend

# Add annotation
oc annotate deployment nodejs-app description="Node.js application"

# Filter by label
oc get pods -l environment=dev
```

### Update Deployment

```bash
# Set environment variable
oc set env deployment/nodejs-app NODE_ENV=production

# Update image
oc set image deployment/nodejs-app nodejs-app=nodejs:18

# Set resource limits
oc set resources deployment nodejs-app \
    --limits=cpu=500m,memory=512Mi \
    --requests=cpu=200m,memory=256Mi
```

### Project Administration

```bash
# Set project resource quotas
oc create quota dev-quota \
    --hard=pods=10,services=5,cpu=2,memory=2Gi

# Set limit ranges
oc create limitrange dev-limits \
    --max=cpu=1,memory=1Gi \
    --min=cpu=50m,memory=64Mi

# View quotas
oc get quota
oc describe quota dev-quota
```

## 🎓 Practical Example: Complete Deployment

```bash
#!/bin/bash
# deploy-app.sh

PROJECT_NAME="myapp-demo"
APP_NAME="web-app"
GIT_REPO="https://github.com/sclorg/nodejs-ex"

echo "🚀 Deploying application..."

# 1. Create project
echo "Creating project: $PROJECT_NAME"
oc new-project $PROJECT_NAME

# 2. Deploy application
echo "Deploying from Git: $GIT_REPO"
oc new-app nodejs:16~$GIT_REPO --name=$APP_NAME

# 3. Wait for build
echo "Waiting for build to complete..."
oc logs -f bc/$APP_NAME

# 4. Expose service
echo "Exposing application..."
oc expose svc/$APP_NAME

# 5. Get URL
APP_URL=$(oc get route $APP_NAME -o jsonpath='{.spec.host}')
echo "✅ Application deployed!"
echo "   URL: http://$APP_URL"

# 6. Test application
echo "Testing application..."
curl -s http://$APP_URL | grep -q "Welcome" && echo "✅ App is responding!" || echo "❌ App test failed"
```

## 🎓 Key Commands Reference

| Command | Description |
|---------|-------------|
| `oc new-project <name>` | Create new project |
| `oc project <name>` | Switch to project |
| `oc projects` | List all projects |
| `oc new-app <source>` | Deploy application |
| `oc get all` | View all resources |
| `oc logs -f <pod>` | Follow logs |
| `oc expose svc/<name>` | Create route |
| `oc scale deployment/<name>` | Scale application |
| `oc delete project <name>` | Delete project |

## ✅ Lab Exercise

Deploy a complete application:

1. **Create project:**
```bash
oc new-project lab2-exercise
```

2. **Deploy application:**
```bash
oc new-app python:3.9~https://github.com/sclorg/django-ex
```

3. **Watch build:**
```bash
oc logs -f bc/django-ex
```

4. **Expose service:**
```bash
oc expose svc/django-ex
```

5. **Get URL and test:**
```bash
oc get route
curl http://$(oc get route django-ex -o jsonpath='{.spec.host}')
```

6. **Cleanup:**
```bash
oc delete project lab2-exercise
```

## 📚 Additional Resources

- [OpenShift Applications](https://docs.openshift.com/container-platform/latest/applications/index.html)
- [Source-to-Image (S2I)](https://docs.openshift.com/container-platform/latest/openshift_images/create-images.html)
- [Application Tutorials](https://docs.openshift.com/container-platform/latest/getting_started/index.html)

## 🚀 Next Steps

**[Lab 3: Deployment & Pod Management →](./LAB3-DEPLOYMENTS.md)**

---

**Lab Duration:** 40-50 minutes  
**Difficulty:** Beginner to Intermediate  
**Prerequisites:** Lab 1 completed
