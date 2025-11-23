# Lab 5: Build & ImageStream Operations

## 📚 Overview

Master OpenShift's build system, Source-to-Image (S2I), BuildConfigs, and ImageStream management for automated container image creation.

## 🎯 Learning Objectives

- ✅ Understand build strategies
- ✅ Create and manage BuildConfigs
- ✅ Work with ImageStreams
- ✅ Configure build triggers
- ✅ Manage build secrets
- ✅ Tag and version images

## 📋 Key Commands

### BuildConfig Management

```bash
# List build configurations
oc get buildconfig
oc get bc

# Describe build config
oc describe bc myapp

# Edit build config
oc edit bc myapp

# Delete build config
oc delete bc myapp
```

### Build Operations

```bash
# List builds
oc get builds

# Start new build
oc start-build myapp

# Start build and follow logs
oc start-build myapp --follow

# Build from local directory
oc start-build myapp --from-dir=.

# Build from Git
oc start-build myapp --from-repo=https://github.com/user/repo

# Cancel build
oc cancel-build myapp-1
```

### ImageStream Management

```bash
# List image streams
oc get imagestreams
oc get is

# Describe image stream
oc describe is myapp

# Import external image
oc import-image nginx:latest \
    --from=docker.io/library/nginx:latest \
    --confirm

# Tag image
oc tag myapp:latest myapp:v1.0
oc tag myapp:latest myapp:stable

# Delete tag
oc tag myapp:v1.0 -d
```

### Build Logs

```bash
# View build logs
oc logs build/myapp-1

# Follow build logs
oc logs -f bc/myapp

# Get logs from specific build
oc logs build/myapp-2 --tail=50
```

## 💡 Build Strategies

### 1. Source Strategy (S2I)

```bash
# Deploy with S2I
oc new-app python:3.9~https://github.com/sclorg/django-ex

# View build config
oc get bc django-ex -o yaml
```

### 2. Docker Strategy

```bash
# Create from Dockerfile
cat <<EOF | oc apply -f -
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: myapp-docker
spec:
  source:
    git:
      uri: https://github.com/user/repo
    type: Git
  strategy:
    dockerStrategy:
      dockerfilePath: Dockerfile
    type: Docker
  output:
    to:
      kind: ImageStreamTag
      name: myapp:latest
EOF
```

### 3. Pipeline Strategy

```bash
# Jenkinsfile-based builds
cat <<EOF | oc apply -f -
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: myapp-pipeline
spec:
  strategy:
    jenkinsPipelineStrategy:
      jenkinsfilePath: Jenkinsfile
    type: JenkinsPipeline
EOF
```

## 💡 Practical Examples

### Example 1: Complete S2I Build

```bash
#!/bin/bash
# s2i-build.sh

PROJECT=build-demo
APP=python-app
GIT_REPO=https://github.com/sclorg/django-ex

echo "🏗️ Setting up S2I build..."

# Create project
oc new-project $PROJECT

# Create application with S2I
oc new-app python:3.9~$GIT_REPO --name=$APP

# Watch build
echo "Building application..."
oc logs -f bc/$APP

# Tag successful build
oc tag $APP:latest $APP:v1.0

echo "✅ Build complete!"
oc get builds
oc get is $APP
```

### Example 2: Build with Secrets

```bash
#!/bin/bash
# secure-build.sh

# Create secret for private Git repo
oc create secret generic git-credentials \
    --from-literal=username=myuser \
    --from-literal=password=mytoken \
    --type=kubernetes.io/basic-auth

# Link secret to builder service account
oc secrets link builder git-credentials

# Create secret for Docker registry
oc create secret docker-registry registry-credentials \
    --docker-server=quay.io \
    --docker-username=myuser \
    --docker-password=mypassword

# Link to builder
oc secrets link builder registry-credentials --for=pull,mount

# Set build secret
oc set build-secret --source bc/myapp git-credentials

echo "✅ Secrets configured!"
```

### Example 3: Multi-stage Build

```bash
#!/bin/bash
# multi-stage-build.sh

# Create BuildConfig with webhook
cat <<EOF | oc apply -f -
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: myapp-multistage
spec:
  source:
    git:
      uri: https://github.com/user/repo
    type: Git
  strategy:
    dockerStrategy:
      dockerfilePath: Dockerfile
    type: Docker
  output:
    to:
      kind: ImageStreamTag
      name: myapp:latest
  triggers:
  - type: ConfigChange
  - type: ImageChange
  - type: GitHub
    github:
      secret: mysecret
EOF

# Get webhook URL
oc describe bc myapp-multistage | grep -A5 "Webhook"
```

### Example 4: Image Stream Mirroring

```bash
#!/bin/bash
# mirror-images.sh

# Create image stream
oc create imagestream myapp

# Import from external registry
oc import-image myapp:v1 \
    --from=docker.io/myorg/myapp:v1 \
    --confirm \
    --scheduled

# Tag for different environments
oc tag myapp:v1 myapp:dev
oc tag myapp:v1 myapp:test
oc tag myapp:v1 myapp:prod

# Verify
oc get istag
```

## 🎓 Build Triggers

### Configure Webhook Triggers

```bash
# GitHub webhook
oc set triggers bc/myapp --from-github

# Generic webhook
oc set triggers bc/myapp --from-webhook

# Get webhook URL
oc describe bc myapp | grep -A2 "Webhook GitHub"

# Remove trigger
oc set triggers bc/myapp --from-github --remove
```

### Configure Image Change Triggers

```bash
# Add image change trigger
oc set triggers bc/myapp --from-image=python:3.9

# Remove trigger
oc set triggers bc/myapp --from-image=python:3.9 --remove

# Manual trigger only
oc set triggers bc/myapp --manual
```

## 🎓 Complete Build Pipeline

```bash
#!/bin/bash
# complete-build-pipeline.sh

PROJECT=cicd-demo
APP=webapp

# Setup
oc new-project $PROJECT

# Create app with S2I
oc new-app nodejs:16~https://github.com/sclorg/nodejs-ex --name=$APP

# Configure build
oc set resources bc/$APP \
    --limits=cpu=1,memory=1Gi \
    --requests=cpu=500m,memory=512Mi

# Add build hook
oc set build-hook bc/$APP \
    --post-commit \
    --command -- /bin/bash -c "npm test"

# Watch first build
oc logs -f bc/$APP

# After successful build, tag
oc tag $APP:latest $APP:v1.0.0
oc tag $APP:latest $APP:stable

# Configure auto-triggering
oc set triggers bc/$APP --from-github

# Get webhook
WEBHOOK=$(oc describe bc/$APP | grep "Webhook GitHub" | awk '{print $NF}')
echo "GitHub webhook URL: $WEBHOOK"

# Deploy from image stream
oc new-app --image-stream=$APP:stable --name=$APP-prod

echo "✅ Complete build pipeline configured!"
```

## ✅ Lab Exercise

1. Create S2I build from Git
2. Watch build process
3. Tag successful build
4. Configure webhook trigger
5. Test rebuild process
6. Manage image versions

```bash
# Quick exercise
oc new-project lab5-exercise
oc new-app python:3.9~https://github.com/sclorg/django-ex
oc logs -f bc/django-ex
oc tag django-ex:latest django-ex:v1
oc get is django-ex
oc delete project lab5-exercise
```

## 📚 Additional Resources

- [Builds](https://docs.openshift.com/container-platform/latest/cicd/builds/understanding-image-builds.html)
- [Source-to-Image](https://docs.openshift.com/container-platform/latest/openshift_images/using_images/using-s21-images.html)
- [Image Streams](https://docs.openshift.com/container-platform/latest/openshift_images/image-streams-manage.html)

## 🚀 Next Steps

**[Lab 6: Monitoring & Troubleshooting →](./LAB6-MONITORING.md)**

---

**Lab Duration:** 50-60 minutes  
**Difficulty:** Intermediate to Advanced
