# OpenShift CLI (oc) Mastery Guide 🚀

> **Complete hands-on guide to becoming an OpenShift CLI expert with practical labs and real-world DevOps integration**

![OpenShift](https://img.shields.io/badge/OpenShift-4.20-red?logo=redhat)
![Shell](https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh-green)
![DevOps](https://img.shields.io/badge/DevOps-Ready-orange)

## 📋 Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Authentication](#authentication)
- [Core Concepts](#core-concepts)
- [Command Structure](#command-structure)
- [Lab Exercises](#lab-exercises)
  - [Lab 1: Basic Setup & Authentication](#lab-1-basic-setup--authentication)
  - [Lab 2: Project & Application Management](#lab-2-project--application-management)
  - [Lab 3: Deployment & Pod Management](#lab-3-deployment--pod-management)
  - [Lab 4: Service & Route Configuration](#lab-4-service--route-configuration)
  - [Lab 5: Build & ImageStream Operations](#lab-5-build--imagestream-operations)
  - [Lab 6: Monitoring & Troubleshooting](#lab-6-monitoring--troubleshooting)
- [Real-World Integration](#real-world-integration)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Cheat Sheet](#cheat-sheet)
- [Resources](#resources)

---

## 🎯 Introduction

OpenShift CLI (`oc`) is a powerful command-line tool that extends Kubernetes functionality with additional features for enterprise container orchestration. It's essential for:

- **Enterprise DevOps**: Full-featured container platform management
- **Developer Productivity**: Streamlined application deployment workflows
- **CI/CD Integration**: Automate builds, deployments, and releases
- **Platform Operations**: Manage clusters, nodes, and infrastructure
- **Multi-tenancy**: Project isolation and resource management

### Why OpenShift CLI?

✅ **Kubernetes compatible** - All kubectl commands work  
✅ **Enhanced features** - Additional enterprise capabilities  
✅ **Developer-focused** - Source-to-Image (S2I) builds  
✅ **Enterprise ready** - Built-in security and governance  
✅ **Cloud native** - Perfect for hybrid and multi-cloud

### OpenShift vs Kubernetes

| Feature | Kubernetes (kubectl) | OpenShift (oc) |
|---------|---------------------|----------------|
| **Base Commands** | ✅ Yes | ✅ Yes (all kubectl) |
| **Projects** | ❌ Namespaces only | ✅ Multi-tenant projects |
| **Routes** | ❌ Ingress | ✅ Simplified routing |
| **Builds** | ❌ External tools | ✅ Built-in S2I |
| **Image Registry** | ❌ External | ✅ Integrated registry |
| **Security** | ✅ Basic | ✅ Enhanced SCCs |
| **Web Console** | ✅ Basic | ✅ Advanced Developer Console |

---

## 📦 Installation

### macOS (Homebrew)
```bash
# Install OpenShift CLI
brew install openshift-cli

# Verify installation
oc version
```

### Linux (Red Hat)
```bash
# Download latest oc client
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz

# Extract
tar -xzf openshift-client-linux.tar.gz

# Move to PATH
sudo mv oc /usr/local/bin/
sudo chmod +x /usr/local/bin/oc

# Verify
oc version
```

### Linux (Debian/Ubuntu)
```bash
# Download and install
curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz | tar -xz

sudo mv oc /usr/local/bin/
sudo chmod +x /usr/local/bin/oc
```

### Windows (Chocolatey)
```powershell
choco install openshift-cli
```

### Windows (Manual)
```powershell
# Download from: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/
# Extract and add to PATH
```

### Verify Installation
```bash
oc version
# Client Version: 4.20.x
# Kustomize Version: v5.x.x

# Check kubectl compatibility
kubectl version --client
```

---

## 🔐 Authentication

### Login to OpenShift Cluster
```bash
# Interactive login via web console
oc login https://api.cluster-name.example.com:6443

# Login with username/password
oc login https://api.cluster-name.example.com:6443 \
  --username=developer \
  --password=secret

# Login with token (recommended for CI/CD)
oc login https://api.cluster-name.example.com:6443 \
  --token=sha256~xxxxxxxxxxxxx

# Login and skip certificate verification (development only)
oc login https://api.cluster-name.example.com:6443 \
  --insecure-skip-tls-verify=true
```

### Get Login Token
```bash
# From web console:
# 1. Click your username (top right)
# 2. Click "Copy login command"
# 3. Click "Display Token"
# 4. Copy the oc login command

# Check current login status
oc whoami
# Output: developer

# Get current server
oc whoami --show-server
# Output: https://api.cluster-name.example.com:6443

# Get current token
oc whoami --show-token

# Get current context
oc whoami --show-context
```

### Multiple Clusters
```bash
# Login to different clusters
oc login cluster1.example.com --token=token1
oc login cluster2.example.com --token=token2

# List all contexts
oc config get-contexts

# Switch between contexts
oc config use-context cluster1-context
oc config use-context cluster2-context

# View current context
oc config current-context
```

### Service Accounts (for CI/CD)
```bash
# Create service account
oc create serviceaccount cicd-bot

# Grant permissions
oc policy add-role-to-user edit system:serviceaccount:myproject:cicd-bot

# Get service account token
oc serviceaccounts get-token cicd-bot

# Login with service account token
oc login --token=$(oc serviceaccounts get-token cicd-bot)
```

---

## 🧩 Core Concepts

### OpenShift Architecture

```
┌─────────────────────────────────────────┐
│         OpenShift Container Platform    │
├─────────────────────────────────────────┤
│  Projects (Multi-tenant Namespaces)    │
│  ├── Applications                        │
│  │   ├── Deployments / DeploymentConfigs│
│  │   ├── Pods                           │
│  │   ├── Services                       │
│  │   └── Routes (Ingress)               │
│  ├── Builds                             │
│  │   ├── BuildConfigs                   │
│  │   ├── ImageStreams                   │
│  │   └── S2I (Source-to-Image)          │
│  └── Storage                            │
│      ├── PersistentVolumes              │
│      └── PersistentVolumeClaims         │
├─────────────────────────────────────────┤
│         Kubernetes Layer                │
│  (All kubectl functionality)            │
└─────────────────────────────────────────┘
```

### Command Categories

```
oc <command> <subcommand> [flags]
```

| Category | Commands | Purpose |
|----------|----------|---------|
| **Basic Commands** | `login`, `status`, `project` | Authentication and context |
| **Build & Deploy** | `new-app`, `new-build`, `start-build` | Application creation |
| **Application Management** | `get`, `describe`, `logs`, `exec` | Resource inspection |
| **Deployment Operations** | `rollout`, `scale`, `autoscale` | Manage deployments |
| **Network** | `expose`, `create route` | Services and routing |
| **Advanced** | `adm`, `policy`, `secrets` | Admin and security |
| **Troubleshooting** | `debug`, `logs`, `events` | Problem solving |

### Resource Types

```bash
# Projects (unique to OpenShift)
oc get projects                    # List all projects
oc project myproject              # Switch project
oc new-project myproject          # Create project

# Applications
oc get all                        # All resources in project
oc get pods                       # Running containers
oc get deployments                # Deployments
oc get dc                         # DeploymentConfigs (OpenShift)
oc get svc                        # Services
oc get routes                     # Routes (OpenShift Ingress)

# Builds (OpenShift-specific)
oc get builds                     # Build instances
oc get bc                         # BuildConfigs
oc get is                         # ImageStreams

# Storage
oc get pv                         # PersistentVolumes
oc get pvc                        # PersistentVolumeClaims
```

### Output Formats

```bash
# Human-readable (default)
oc get pods

# Wide output (more columns)
oc get pods -o wide

# YAML output
oc get pod mypod -o yaml

# JSON output (scriptable)
oc get pods -o json

# JSONPath (extract specific fields)
oc get pods -o jsonpath='{.items[*].metadata.name}'

# Custom columns
oc get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

# Watch for changes
oc get pods --watch
```

---

## 🔬 Lab Exercises

### Lab 1: Basic Setup & Authentication

**Objective**: Install, authenticate, and configure OpenShift CLI

#### Tasks:

1️⃣ **Install OpenShift CLI**
```bash
# macOS
brew install openshift-cli

# Verify
oc version
```

**Expected Output**:
```
Client Version: 4.20.0
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
```

2️⃣ **Login to OpenShift Cluster**
```bash
# Get login command from web console
# User menu → Copy login command → Display Token

# Login with token
oc login --token=sha256~xxxxx --server=https://api.cluster.example.com:6443

# Check authentication
oc whoami
```

**Expected Output**:
```
✓ Logged in as "developer" at "https://api.cluster.example.com:6443"
developer
```

3️⃣ **Explore Current Context**
```bash
# Who am I?
oc whoami

# What server?
oc whoami --show-server

# Current project
oc project

# List all projects
oc projects
```

**Expected Output**:
```
developer
https://api.cluster.example.com:6443
Using project "default" on server "https://api.cluster.example.com:6443".
You have access to the following projects:
  * default
    myproject
    test-project
```

4️⃣ **Configure CLI**
```bash
# Set default editor
export KUBE_EDITOR=vim

# Enable bash completion
oc completion bash > /usr/local/etc/bash_completion.d/oc

# Enable zsh completion
oc completion zsh > /usr/local/share/zsh/site-functions/_oc

# Add to ~/.zshrc or ~/.bashrc
source <(oc completion zsh)  # or bash
```

5️⃣ **Test Basic Commands**
```bash
# Get cluster info
oc cluster-info

# Check cluster version
oc version

# Get cluster nodes (if you have admin access)
oc get nodes

# View current configuration
oc config view
```

**✅ Verification**:
```bash
oc status
oc whoami --show-context
oc projects
```

---

### Lab 2: Project & Application Management

**Objective**: Master project creation and application deployment

#### Tasks:

1️⃣ **Create a New Project**
```bash
# Create project
oc new-project demo-app \
  --display-name="Demo Application" \
  --description="Lab 2 demonstration project"

# Verify
oc project
oc status
```

**Expected Output**:
```
Now using project "demo-app" on server "https://api.cluster.example.com:6443".

You can add applications to this project with the 'new-app' command.
```

2️⃣ **Deploy Application from Git**
```bash
# Deploy from GitHub repository
oc new-app https://github.com/sclorg/nodejs-ex \
  --name=nodejs-app

# Watch deployment
oc logs -f bc/nodejs-app
```

**Expected Output**:
```
--> Found Docker image abc123 (2 weeks old)
    * An image stream tag will be created as "nodejs-app:latest"
    * A source build using source code from https://github.com/sclorg/nodejs-ex will be created
    * The resulting image will be pushed to image stream tag "nodejs-app:latest"
    * This image will be deployed in deployment config "nodejs-app"
--> Creating resources ...
    imagestream.image.openshift.io "nodejs-app" created
    buildconfig.build.openshift.io "nodejs-app" created
    deployment.apps "nodejs-app" created
    service "nodejs-app" created
--> Success
```

3️⃣ **Deploy from Docker Image**
```bash
# Deploy from Docker Hub
oc new-app nginx:latest --name=nginx-demo

# Deploy from specific registry
oc new-app quay.io/myorg/myapp:v1.0 --name=myapp
```

4️⃣ **View Application Resources**
```bash
# All resources in project
oc get all

# Specific resources
oc get pods
oc get services
oc get deployments
oc get routes

# Detailed view
oc describe deployment nodejs-app
```

**Expected Output**:
```
NAME                              READY   STATUS      AGE
pod/nodejs-app-1-build            0/1     Completed   5m
pod/nodejs-app-6d4f8b7c9d-x7k2l   1/1     Running     3m

NAME                 TYPE        CLUSTER-IP      PORT(S)
service/nodejs-app   ClusterIP   172.30.123.45   8080/TCP

NAME                         READY   UP-TO-DATE   AVAILABLE
deployment.apps/nodejs-app   1/1     1            1

NAME                        TYPE     FROM   LATEST
buildconfig.build/nodejs-app   Source   Git    1

NAME                                IMAGE
imagestream.image/nodejs-app         nodejs-app:latest
```

5️⃣ **Manage Projects**
```bash
# List all projects
oc projects

# Switch project
oc project default

# Delete project (careful!)
oc delete project demo-app
```

6️⃣ **Project Labels and Annotations**
```bash
# Add labels
oc label project demo-app environment=dev

# Add annotations
oc annotate project demo-app description="Development environment"

# View project details
oc describe project demo-app
```

**✅ Practice Exercise**:
```bash
# Create a project
oc new-project lab2-exercise

# Deploy sample app
oc new-app httpd:2.4 --name=web-server

# Check status
oc status
oc get all

# Clean up
oc delete project lab2-exercise
```

---

### Lab 3: Deployment & Pod Management

**Objective**: Master pod and deployment operations

#### Tasks:

1️⃣ **View Pods**
```bash
# List pods
oc get pods

# Wide output (shows node, IP)
oc get pods -o wide

# Watch pods
oc get pods --watch

# Get pods with labels
oc get pods --show-labels
oc get pods -l app=nodejs-app
```

**Expected Output**:
```
NAME                          READY   STATUS    RESTARTS   AGE
nodejs-app-6d4f8b7c9d-x7k2l   1/1     Running   0          10m
```

2️⃣ **Pod Details and Logs**
```bash
# Describe pod
oc describe pod nodejs-app-6d4f8b7c9d-x7k2l

# View logs
oc logs nodejs-app-6d4f8b7c9d-x7k2l

# Follow logs (live)
oc logs -f nodejs-app-6d4f8b7c9d-x7k2l

# Previous logs (if crashed)
oc logs --previous nodejs-app-6d4f8b7c9d-x7k2l

# Logs with timestamps
oc logs nodejs-app-6d4f8b7c9d-x7k2l --timestamps

# Last N lines
oc logs nodejs-app-6d4f8b7c9d-x7k2l --tail=50
```

3️⃣ **Execute Commands in Pods**
```bash
# Interactive shell
oc rsh nodejs-app-6d4f8b7c9d-x7k2l

# Single command
oc exec nodejs-app-6d4f8b7c9d-x7k2l -- ls -la

# With specific container (multi-container pod)
oc exec nodejs-app-6d4f8b7c9d-x7k2l -c container-name -- env
```

4️⃣ **Scale Deployments**
```bash
# Scale up
oc scale deployment nodejs-app --replicas=3

# Scale down
oc scale deployment nodejs-app --replicas=1

# Auto-scale
oc autoscale deployment nodejs-app \
  --min=2 --max=10 --cpu-percent=80
```

**Expected Output**:
```
deployment.apps/nodejs-app scaled

NAME         READY   UP-TO-DATE   AVAILABLE   AGE
nodejs-app   3/3     3            3           15m
```

5️⃣ **Manage Deployments**
```bash
# Rollout status
oc rollout status deployment/nodejs-app

# Rollout history
oc rollout history deployment/nodejs-app

# Rollback deployment
oc rollout undo deployment/nodejs-app

# Rollback to specific revision
oc rollout undo deployment/nodejs-app --to-revision=2

# Pause/Resume rollout
oc rollout pause deployment/nodejs-app
oc rollout resume deployment/nodejs-app

# Restart deployment
oc rollout restart deployment/nodejs-app
```

6️⃣ **Update Deployment**
```bash
# Update image
oc set image deployment/nodejs-app nodejs-app=myimage:v2

# Set environment variables
oc set env deployment/nodejs-app \
  DATABASE_HOST=postgres \
  DATABASE_PORT=5432

# Update resources
oc set resources deployment nodejs-app \
  --limits=cpu=500m,memory=512Mi \
  --requests=cpu=250m,memory=256Mi
```

7️⃣ **Pod Operations**
```bash
# Copy files to/from pod
oc cp /local/file pod-name:/remote/path
oc cp pod-name:/remote/file /local/path

# Port forwarding
oc port-forward pod/nodejs-app-xxx 8080:8080

# Debug pod
oc debug pod/nodejs-app-xxx

# Create debug pod from deployment
oc debug deployment/nodejs-app
```

**✅ Complete Exercise**:
```bash
# 1. Deploy app
oc new-app nginx:latest --name=nginx-test

# 2. Wait for deployment
oc rollout status deployment/nginx-test

# 3. View pods
oc get pods

# 4. Check logs
oc logs deployment/nginx-test

# 5. Scale up
oc scale deployment nginx-test --replicas=3

# 6. Execute command
oc exec deployment/nginx-test -- nginx -v

# 7. Port forward and test
oc port-forward deployment/nginx-test 8080:80
# In browser: http://localhost:8080

# 8. Clean up
oc delete all -l app=nginx-test
```

---

### Lab 4: Service & Route Configuration

**Objective**: Master networking, services, and external access

#### Tasks:

1️⃣ **Create and View Services**
```bash
# List services
oc get services
oc get svc

# Describe service
oc describe svc nodejs-app

# View service endpoints
oc get endpoints nodejs-app
```

**Expected Output**:
```
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
nodejs-app   ClusterIP   172.30.123.45   <none>        8080/TCP   20m
```

2️⃣ **Expose Service with Route**
```bash
# Create route (HTTP)
oc expose service nodejs-app

# View routes
oc get routes

# Describe route
oc describe route nodejs-app

# Get route URL
oc get route nodejs-app -o jsonpath='{.spec.host}'
```

**Expected Output**:
```
NAME         HOST/PORT                                    PATH   SERVICES     PORT
nodejs-app   nodejs-app-demo-app.apps.cluster.example.com        nodejs-app   8080-tcp

Route exposed on: nodejs-app-demo-app.apps.cluster.example.com
```

3️⃣ **Create Route with Custom Hostname**
```bash
# Custom hostname
oc expose service nodejs-app \
  --hostname=myapp.example.com \
  --name=custom-route

# Edge-terminated TLS route
oc create route edge nodejs-app-secure \
  --service=nodejs-app \
  --hostname=secure.example.com

# Passthrough TLS route
oc create route passthrough nodejs-app-passthrough \
  --service=nodejs-app \
  --hostname=passthrough.example.com

# Re-encrypt TLS route
oc create route reencrypt nodejs-app-reencrypt \
  --service=nodejs-app \
  --hostname=reencrypt.example.com
```

4️⃣ **Test Service Access**
```bash
# From within cluster
oc run test-pod --image=curlimages/curl --rm -it --restart=Never \
  -- curl http://nodejs-app:8080

# Port forward for local testing
oc port-forward svc/nodejs-app 8080:8080

# Test from local machine
curl http://localhost:8080

# Test route
ROUTE_URL=$(oc get route nodejs-app -o jsonpath='{.spec.host}')
curl http://$ROUTE_URL
```

5️⃣ **Service Types**
```bash
# ClusterIP (internal only - default)
oc expose deployment nodejs-app --port=8080 --type=ClusterIP

# NodePort (exposes on node IP)
oc expose deployment nodejs-app --port=8080 --type=NodePort

# LoadBalancer (cloud provider)
oc expose deployment nodejs-app --port=8080 --type=LoadBalancer

# View service
oc get svc nodejs-app
```

6️⃣ **Advanced Routing**
```bash
# Blue-Green deployment routes
oc expose svc blue-app --name=app --hostname=app.example.com
oc patch route app -p '{"spec":{"to":{"name":"green-app"}}}'

# A/B Testing (split traffic)
oc set route-backends app blue-app=90 green-app=10

# Path-based routing
oc expose service api --path=/api
oc expose service web --path=/

# Route with annotations
oc annotate route nodejs-app \
  haproxy.router.openshift.io/timeout=60s
```

7️⃣ **Network Policies**
```bash
# Allow traffic from specific namespace
cat <<EOF | oc apply -f -
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: allow-from-namespace
spec:
  podSelector:
    matchLabels:
      app: nodejs-app
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: allowed-namespace
EOF

# View network policies
oc get networkpolicies
```

**✅ Complete Exercise**:
```bash
# 1. Deploy two versions
oc new-app nginx:1.20 --name=nginx-v1
oc new-app nginx:1.21 --name=nginx-v2

# 2. Wait for deployments
oc rollout status deployment/nginx-v1
oc rollout status deployment/nginx-v2

# 3. Create route for v1
oc expose svc nginx-v1 --name=nginx-route

# 4. Test route
ROUTE=$(oc get route nginx-route -o jsonpath='{.spec.host}')
curl http://$ROUTE

# 5. Switch to v2
oc patch route nginx-route -p '{"spec":{"to":{"name":"nginx-v2"}}}'

# 6. Test again
curl http://$ROUTE

# 7. A/B test (50/50)
oc set route-backends nginx-route nginx-v1=50 nginx-v2=50

# 8. Clean up
oc delete all -l app=nginx-v1
oc delete all -l app=nginx-v2
oc delete route nginx-route
```

---

### Lab 5: Build & ImageStream Operations

**Objective**: Master OpenShift's build system and image management

#### Tasks:

1️⃣ **Source-to-Image (S2I) Build**
```bash
# Create app with S2I
oc new-app python:3.9~https://github.com/sclorg/django-ex \
  --name=django-app

# View build config
oc get buildconfig django-app
oc describe bc django-app

# Trigger build
oc start-build django-app

# Follow build logs
oc logs -f bc/django-app

# View builds
oc get builds
```

**Expected Output**:
```
NAME             TYPE     FROM   STATUS     STARTED          DURATION
django-app-1     Source   Git    Running    5 seconds ago

Cloning "https://github.com/sclorg/django-ex" ...
Commit: abc123def456 (Initial commit)
Author: Developer <dev@example.com>
...
Pushing image to registry...
Push successful
```

2️⃣ **Docker Build**
```bash
# Create build from Dockerfile
oc new-build https://github.com/myorg/myapp \
  --strategy=docker \
  --name=myapp

# Binary build (local Dockerfile)
oc new-build --name=local-app \
  --binary \
  --strategy=docker

# Upload local source
oc start-build local-app --from-dir=. --follow
```

3️⃣ **ImageStreams**
```bash
# List image streams
oc get imagestreams
oc get is

# Describe image stream
oc describe is django-app

# Import external image
oc import-image myapp:latest \
  --from=docker.io/myorg/myapp:latest \
  --confirm

# Tag image
oc tag django-app:latest django-app:v1.0
oc tag django-app:latest django-app:stable

# View image stream tags
oc get istag
```

**Expected Output**:
```
NAME         IMAGE REPOSITORY                                           TAGS
django-app   image-registry.openshift-image-registry.svc:5000/demo/django-app   latest,v1.0,stable
```

4️⃣ **Build Triggers**
```bash
# Add GitHub webhook
oc set triggers bc/django-app --from-github

# Get webhook URL
oc describe bc django-app | grep -A 2 "Webhook GitHub"

# Add image change trigger
oc set triggers bc/django-app \
  --from-image=python:3.9

# Add config change trigger
oc set triggers bc/django-app --from-config

# View triggers
oc describe bc django-app | grep -A 10 Triggers
```

5️⃣ **Build Secrets**
```bash
# Create Git auth secret
oc create secret generic git-secret \
  --from-literal=username=myuser \
  --from-literal=password=mytoken \
  --type=kubernetes.io/basic-auth

# Link secret to build
oc set build-secret --source bc/myapp git-secret

# Create Docker registry secret
oc create secret docker-registry my-registry-secret \
  --docker-server=quay.io \
  --docker-username=myuser \
  --docker-password=mytoken

# Link to service account
oc secrets link builder my-registry-secret
```

6️⃣ **Build Configuration**
```bash
# Update build source
oc patch bc/django-app -p \
  '{"spec":{"source":{"git":{"uri":"https://github.com/neworg/newapp"}}}}'

# Set build resources
oc patch bc/django-app -p \
  '{"spec":{"resources":{"limits":{"cpu":"1","memory":"1Gi"}}}}'

# Set environment in build
oc set env bc/django-app \
  NPM_MIRROR=https://registry.npmjs.org

# Cancel build
oc cancel-build django-app-2

# Delete build
oc delete build django-app-2
```

7️⃣ **Advanced Build Patterns**
```bash
# Multi-stage build
cat <<EOF | oc apply -f -
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: multi-stage-build
spec:
  source:
    type: Git
    git:
      uri: https://github.com/myorg/myapp
  strategy:
    type: Docker
    dockerStrategy:
      dockerfilePath: Dockerfile.multistage
  output:
    to:
      kind: ImageStreamTag
      name: myapp:latest
EOF

# Pipeline build (deprecated in 4.x, use Tekton)
# See Tekton Pipelines instead

# Custom builder image
oc new-build https://github.com/myorg/myapp \
  --image-stream=my-custom-builder:latest \
  --name=custom-build
```

**✅ Complete Exercise**:
```bash
# 1. Create S2I build from source
oc new-app python:3.9~https://github.com/sclorg/django-ex \
  --name=django-lab

# 2. Watch build
oc logs -f bc/django-lab

# 3. View image stream
oc get is django-lab

# 4. Tag image
oc tag django-lab:latest django-lab:v1.0

# 5. Trigger new build
oc start-build django-lab

# 6. View all builds
oc get builds

# 7. Export build config
oc get bc django-lab -o yaml > django-build.yaml

# 8. Clean up
oc delete all -l app=django-lab
oc delete is django-lab
```

---

### Lab 6: Monitoring & Troubleshooting

**Objective**: Master debugging, monitoring, and problem-solving techniques

#### Tasks:

1️⃣ **Check Cluster Status**
```bash
# Project status
oc status

# Cluster info
oc cluster-info

# Node status (admin required)
oc get nodes
oc describe node node-name

# Component health
oc get clusteroperators
```

**Expected Output**:
```
In project demo-app on server https://api.cluster.example.com:6443

svc/nodejs-app - 172.30.123.45:8080
  deployment/nodejs-app deploys istag/nodejs-app:latest
    deployment #1 running for 30 minutes - 3 pods

3 infos identified, use 'oc status --suggest' for details.
```

2️⃣ **View Events**
```bash
# All events
oc get events

# Sort by time
oc get events --sort-by='.lastTimestamp'

# Watch events
oc get events --watch

# Events for specific resource
oc describe pod nodejs-app-xxx | grep -A 10 Events

# Filter by type
oc get events --field-selector type=Warning
```

3️⃣ **Pod Troubleshooting**
```bash
# Check pod status
oc get pods
oc describe pod pod-name

# Common issues:
# - ImagePullBackOff
oc describe pod pod-name | grep -A 5 "Failed to pull image"

# - CrashLoopBackOff
oc logs pod-name --previous

# - Pending
oc describe pod pod-name | grep -A 10 Events

# - OOMKilled
oc describe pod pod-name | grep -i "oom"
```

4️⃣ **Debug Containers**
```bash
# Debug running pod
oc debug pod/nodejs-app-xxx

# Debug with different image
oc debug pod/nodejs-app-xxx --image=busybox

# Debug deployment
oc debug deployment/nodejs-app

# Debug with root access
oc debug pod/nodejs-app-xxx --as-root

# Keep pod after exit
oc debug pod/nodejs-app-xxx --keep-init-container
```

5️⃣ **Resource Monitoring**
```bash
# Top nodes (admin required)
oc adm top nodes

# Top pods
oc adm top pods

# Top pods with containers
oc adm top pods --containers

# Specific namespace
oc adm top pods -n myproject

# Sort by CPU/memory
oc adm top pods --sort-by=cpu
oc adm top pods --sort-by=memory
```

**Expected Output**:
```
NAME                          CPU(cores)   MEMORY(bytes)
nodejs-app-6d4f8b7c9d-x7k2l   5m          128Mi
nginx-app-7d9f8c6b5a-k3n2p    2m          64Mi
```

6️⃣ **Logs and Debugging**
```bash
# Application logs
oc logs pod-name

# All containers in pod
oc logs pod-name --all-containers

# Specific container
oc logs pod-name -c container-name

# Previous instance
oc logs pod-name --previous

# Deployment logs
oc logs deployment/nodejs-app

# Stream logs from multiple pods
oc logs -f -l app=nodejs-app

# Export logs
oc logs pod-name > pod-logs.txt
```

7️⃣ **Advanced Debugging**
```bash
# Must-gather (collect diagnostic data)
oc adm must-gather

# Inspect resource
oc adm inspect deployment/nodejs-app

# Inspect namespace
oc adm inspect ns/demo-app

# Network debugging
oc run netdebug --image=nicolaka/netshoot --rm -it -- bash

# DNS debugging
oc run dnstest --image=busybox --rm -it -- nslookup nodejs-app
```

8️⃣ **Quota and Limits**
```bash
# View resource quotas
oc get resourcequota
oc describe resourcequota

# View limit ranges
oc get limitrange
oc describe limitrange

# Check project resource usage
oc describe project demo-app

# View pod resource usage
oc describe pod pod-name | grep -A 10 "Requests\|Limits"
```

9️⃣ **Security Context Constraints**
```bash
# View SCCs
oc get scc

# Check which SCC a pod uses
oc describe pod pod-name | grep "scc"

# Test SCC permissions
oc adm policy scc-subject-review -f pod.yaml
```

🔟 **Performance Analysis**
```bash
# Explain resource
oc explain pod.spec.containers.resources

# Analyze pod scheduling
oc describe pod pod-name | grep -A 10 "Node-Selectors\|Tolerations"

# View pod security policies
oc get podsecuritypolicies

# Check service endpoints
oc get endpoints service-name -o yaml
```

**✅ Troubleshooting Scenarios**:

**Scenario 1: Pod Not Starting**
```bash
# 1. Check pod status
oc get pods

# 2. Describe pod
oc describe pod failing-pod

# 3. Check events
oc get events --sort-by='.lastTimestamp' | grep failing-pod

# 4. Check logs
oc logs failing-pod

# 5. Debug
oc debug pod/failing-pod
```

**Scenario 2: Application Not Accessible**
```bash
# 1. Check pod
oc get pods -l app=myapp

# 2. Check service
oc get svc myapp
oc describe svc myapp

# 3. Check endpoints
oc get endpoints myapp

# 4. Check route
oc get route myapp
curl -v http://$(oc get route myapp -o jsonpath='{.spec.host}')

# 5. Port forward test
oc port-forward svc/myapp 8080:8080
curl localhost:8080
```

**Scenario 3: High Memory Usage**
```bash
# 1. Check resource usage
oc adm top pods

# 2. Identify high-memory pod
oc adm top pods --sort-by=memory

# 3. Check limits
oc describe pod high-memory-pod | grep -A 5 Limits

# 4. Update limits
oc set resources deployment myapp \
  --limits=memory=1Gi \
  --requests=memory=512Mi

# 5. Monitor
oc adm top pods --watch
```

---

## 🌍 Real-World Integration

### Integration with This Project

#### 1. **Deploy to OpenShift**
```bash
# scripts/deploy-openshift.sh
#!/bin/bash
set -e

PROJECT_NAME="devops-demo"
APP_NAME="flask-app"
GIT_REPO="https://github.com/nirgeier/DevOps-Demo-Project"

echo "🚀 Deploying to OpenShift..."

# Login
oc login --token=$OC_TOKEN --server=$OC_SERVER

# Create/use project
oc new-project $PROJECT_NAME || oc project $PROJECT_NAME

# Deploy application
oc new-app python:3.9~$GIT_REPO \
  --name=$APP_NAME \
  --context-dir=app

# Expose service
oc expose svc/$APP_NAME

# Get route
ROUTE=$(oc get route $APP_NAME -o jsonpath='{.spec.host}')
echo "✅ Application deployed: http://$ROUTE"
```

#### 2. **CI/CD Integration**
```yaml
# .github/workflows/deploy-openshift.yml
name: Deploy to OpenShift

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install OpenShift CLI
        run: |
          curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz | tar -xz
          sudo mv oc /usr/local/bin/
      
      - name: Login to OpenShift
        run: |
          oc login --token=${{ secrets.OC_TOKEN }} --server=${{ secrets.OC_SERVER }}
      
      - name: Deploy
        run: |
          oc project devops-demo
          oc start-build flask-app --follow
          oc rollout status deployment/flask-app
```

#### 3. **Health Monitoring**
```bash
# scripts/health-check.sh
#!/bin/bash

APP_NAME="flask-app"
PROJECT="devops-demo"

echo "🏥 Health Check for $APP_NAME"

# Check pod health
POD_STATUS=$(oc get pods -l app=$APP_NAME -n $PROJECT -o jsonpath='{.items[0].status.phase}')
echo "Pod Status: $POD_STATUS"

# Check endpoint
ROUTE=$(oc get route $APP_NAME -n $PROJECT -o jsonpath='{.spec.host}')
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$ROUTE/health)
echo "HTTP Status: $HTTP_CODE"

if [ "$POD_STATUS" == "Running" ] && [ "$HTTP_CODE" == "200" ]; then
  echo "✅ Application is healthy"
  exit 0
else
  echo "❌ Application is unhealthy"
  exit 1
fi
```

---

## 📚 Best Practices

### 1. **Resource Management**

✅ **Always set resource limits**
```bash
oc set resources deployment myapp \
  --limits=cpu=500m,memory=512Mi \
  --requests=cpu=250m,memory=256Mi
```

✅ **Use resource quotas**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: project-quota
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
```

### 2. **Security**

🔒 **Use service accounts**
```bash
oc create serviceaccount myapp-sa
oc adm policy add-scc-to-user anyuid -z myapp-sa
oc set serviceaccount deployment myapp myapp-sa
```

🔒 **Manage secrets properly**
```bash
# Create secret
oc create secret generic db-secret \
  --from-literal=password=secretpassword

# Use in deployment
oc set env deployment/myapp --from=secret/db-secret
```

### 3. **Labels and Annotations**

🏷️ **Use consistent labels**
```bash
oc label deployment myapp \
  app=myapp \
  version=v1.0 \
  environment=production
```

### 4. **Health Checks**

💚 **Always configure probes**
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

---

## 🐛 Troubleshooting

### Common Issues

#### ImagePullBackOff
```bash
# Check image name
oc describe pod pod-name | grep Image

# Check image stream
oc describe is image-name

# Force pull
oc import-image image-name:latest --confirm
```

#### CrashLoopBackOff
```bash
# Check logs
oc logs pod-name --previous

# Debug with shell
oc debug pod/pod-name
```

#### Insufficient Permissions
```bash
# Check SCC
oc describe pod pod-name | grep scc

# Grant permissions
oc adm policy add-scc-to-user anyuid -z default
```

---

## 📖 Cheat Sheet

### Quick Reference

```bash
# Authentication
oc login <server>                 # Login to cluster
oc whoami                         # Current user
oc logout                         # Logout

# Projects
oc new-project <name>             # Create project
oc project <name>                 # Switch project
oc projects                       # List projects

# Applications
oc new-app <image>                # Create app
oc get all                        # List all resources
oc delete all -l app=<name>       # Delete app

# Pods
oc get pods                       # List pods
oc logs <pod>                     # View logs
oc rsh <pod>                      # Shell into pod
oc debug pod/<pod>                # Debug pod

# Deployments
oc scale deployment/<name> --replicas=3
oc rollout status deployment/<name>
oc rollout undo deployment/<name>

# Services & Routes
oc expose svc/<name>              # Create route
oc get routes                     # List routes

# Builds
oc start-build <name>             # Trigger build
oc logs -f bc/<name>              # Follow build logs

# Troubleshooting
oc status                         # Project status
oc get events                     # View events
oc adm top pods                   # Resource usage
```

---

## 📚 Resources

### Official Documentation
- [OpenShift Documentation](https://docs.openshift.com/)
- [OpenShift CLI Reference](https://docs.openshift.com/container-platform/4.20/cli_reference/openshift_cli/getting-started-cli.html)
- [OpenShift Learning Portal](https://learn.openshift.com/)

### Community
- [OpenShift Commons](https://commons.openshift.org/)
- [OpenShift Blog](https://www.openshift.com/blog)
- [Red Hat Developer](https://developers.redhat.com/products/openshift)

---

## 🎓 Conclusion

You've now mastered OpenShift CLI! You can:

✅ Deploy and manage applications  
✅ Configure networking and routing  
✅ Use Source-to-Image builds  
✅ Monitor and troubleshoot  
✅ Implement CI/CD workflows  
✅ Apply security best practices

### Next Steps

1. **Practice**: Complete all lab exercises
2. **Deploy**: Try deploying your applications
3. **Automate**: Build CI/CD pipelines
4. **Learn More**: Explore operators and advanced features
5. **Contribute**: Share knowledge with your team

---

**Happy Container Orchestrating! 🚀**

For questions or contributions, open an issue or PR in this repository.
