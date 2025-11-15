# DevOps Demo Project 🚀

A complete DevOps CI/CD pipeline demonstration project featuring Python Flask application, Docker containerization, Kubernetes deployment with Helm, ArgoCD GitOps, and automated GitHub Actions workflows.

![DevOps Pipeline](https://img.shields.io/badge/DevOps-Pipeline-blue)
![Python](https://img.shields.io/badge/Python-3.11-green)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Development](#development)
- [Deployment](#deployment)
- [GitFlow Workflow](#gitflow-workflow)
- [CI/CD Pipeline](#cicd-pipeline)
- [GitHub CLI Integration](#github-cli-integration)
- [Documentation](#documentation)

## 🎯 Overview

This project demonstrates a modern DevOps workflow implementing:

- **Python Flask Application**: RESTful API with health checks
- **Container Orchestration**: Docker multi-stage builds
- **Kubernetes Deployment**: Helm charts with best practices
- **GitOps**: ArgoCD for automated deployments
- **CI/CD**: GitHub Actions for build, test, and deploy
- **GitFlow**: Branch-based development workflow
- **Automated Testing**: Unit tests with pytest and coverage
- **GitHub CLI**: Powerful automation and workflow management

## 🏗️ Architecture

```
┌─────────────┐
│   Git Repo  │
│  (GitHub)   │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ GitHub Actions  │  ← CI/CD Pipeline
│  - Build        │
│  - Test         │
│  - Push Image   │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ GitHub Registry │  ← Container Storage
│     (GHCR)      │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│    ArgoCD       │  ← GitOps Controller
│ (Kubernetes)    │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│   Kubernetes    │  ← Production Environment
│   with Helm     │
└─────────────────┘
```

## ✨ Features

### Application Features
- ✅ RESTful API endpoints
- ✅ Health and readiness probes
- ✅ Structured logging
- ✅ Error handling
- ✅ Environment-based configuration

### DevOps Features
- ✅ Multi-stage Docker builds
- ✅ Kubernetes-ready Helm charts
- ✅ Horizontal Pod Autoscaling (HPA)
- ✅ ArgoCD GitOps deployment
- ✅ Automated CI/CD with GitHub Actions
- ✅ GitFlow workflow enforcement
- ✅ Automated testing and code coverage
- ✅ Container image signing and attestation

## 📦 Prerequisites

### Required Tools
- **Python 3.11+** - Application runtime
- **Docker** - Containerization
- **kubectl** - Kubernetes CLI
- **Helm** - Kubernetes package manager
- **uv** - Fast Python package manager
- **Git** - Version control

### DevOps CLI Tools
- **GitHub CLI (gh)** - GitHub automation & workflows
- **OpenShift CLI (oc)** - Enterprise container platform (optional)

### Optional Tools
- **k9s** - Terminal UI for Kubernetes
- **ArgoCD CLI** - GitOps tool CLI

### Automated Installation

Run the init script to install all required tools:

```bash
chmod +x scripts/init.sh
./scripts/init.sh
```

Or install tools individually:

```bash
chmod +x scripts/*.sh
./scripts/install-uv.sh
./scripts/install-docker.sh
./scripts/install-kubectl.sh
./scripts/install-helm.sh
./scripts/install-k9s.sh
./scripts/install-gh.sh        # GitHub CLI
./scripts/install-openshift.sh # OpenShift CLI (optional)
./scripts/install-argocd.sh    # ArgoCD CLI (optional)
```

### Health Check

Verify your setup with the unified diagnostics tool:

```bash
# Check all tools
./scripts/doctor.sh

# Check specific tool
./scripts/doctor.sh gh          # GitHub CLI
./scripts/doctor.sh oc          # OpenShift CLI
./scripts/doctor.sh docker      # Docker
./scripts/doctor.sh python      # Python environment
./scripts/doctor.sh quick       # Quick essential check

# Detailed diagnostics
./scripts/gh-doctor.sh          # GitHub CLI (detailed)
./scripts/openshift-doctor.sh   # OpenShift CLI (detailed)
./scripts/verify-setup.sh       # Full project verification
```

## 🚀 Quick Start

### 1. Clone and Initialize

```bash
git clone https://github.com/nirgeier/DevOps-Demo-Project.git
cd DevOps-Demo-Project
./scripts/init.sh
```

### 2. Run Locally

```bash
# Activate virtual environment
# On Unix/macOS/Linux:
source .venv/bin/activate
# On Windows (Git Bash):
source .venv/Scripts/activate
# On Windows (PowerShell):
.venv\Scripts\Activate.ps1

# Run the application
python app/main.py

# Or with gunicorn (production-like)
gunicorn --bind 0.0.0.0:8080 app.main:app
```

Visit: http://localhost:8080

### 3. Run with Docker

```bash
# Build the image
docker build -f docker/Dockerfile -t devops-demo:latest .

# Run the container
docker run -p 8080:8080 devops-demo:latest

# Or use docker-compose
docker-compose -f docker/docker-compose.yml up
```

### 4. Deploy to Kubernetes

```bash
# Install with Helm
helm install devops-demo helm/devops-demo

# Or use ArgoCD
kubectl apply -f argocd/namespace.yaml
kubectl apply -f argocd/application.yaml
```

## 📁 Project Structure

```
DevOps-Demo-Project/
├── app/                          # Python application
│   ├── __init__.py
│   └── main.py                  # Flask application
├── tests/                        # Test suite
│   ├── __init__.py
│   └── test_main.py             # Unit tests
├── docker/                       # Docker configuration
│   ├── Dockerfile               # Multi-stage build
│   ├── .dockerignore
│   └── docker-compose.yml
├── helm/                         # Helm charts
│   └── devops-demo/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/           # Kubernetes manifests
├── argocd/                       # ArgoCD configuration
│   ├── application.yaml
│   ├── namespace.yaml
│   └── README.md
├── scripts/                      # Automation & installation
│   ├── init.sh                  # Complete project setup
│   ├── doctor.sh                # Health check all tools
│   ├── verify-setup.sh          # Comprehensive verification
│   ├── install-*.sh             # Tool installation scripts
│   ├── gh-*.sh                  # GitHub CLI automation
│   ├── gh-doctor.sh             # GitHub CLI diagnostics
│   ├── openshift-doctor.sh      # OpenShift CLI diagnostics
│   └── build-multiplatform.sh   # Multi-arch Docker builds
├── gh-study/                     # GitHub CLI learning
│   ├── README.md                # Complete guide
│   ├── QUICKSTART.md            # Quick reference
│   └── labs/                    # 6 hands-on labs
├── openshift-study/              # OpenShift CLI learning
│   ├── README.md                # Complete guide
│   ├── QUICKSTART.md            # Quick reference
│   └── labs/                    # 6 hands-on labs
├── .github/                      # GitHub Actions
│   └── workflows/
│       ├── ci.yml               # Continuous Integration
│       ├── cd.yml               # Continuous Deployment
│       ├── release.yml          # Release management
│       └── gitflow.yml          # GitFlow validation
├── docs/                         # Documentation
├── pyproject.toml               # Python dependencies
├── PROJECT_IMPROVEMENTS.md      # Detailed improvements log
├── .gitignore
└── README.md
```

## 💻 Development

### Running Tests

```bash
# Run all tests
pytest tests/ -v

# With coverage report
pytest tests/ -v --cov=app --cov-report=html

# View coverage report
open htmlcov/index.html
```

### Code Quality

```bash
# Linting
flake8 app/ tests/

# Formatting
black app/ tests/
```

### Local Development

```bash
# Create virtual environment (with uv - recommended)
uv venv

# OR create with standard Python venv
python -m venv .venv

# Activate environment
# On Unix/macOS/Linux:
source .venv/bin/activate
# On Windows (Git Bash):
source .venv/Scripts/activate
# On Windows (PowerShell):
.venv\Scripts\Activate.ps1

# Install dependencies (with uv - faster)
uv pip install -e ".[dev]"

# OR install with pip (standard)
python -m pip install -e ".[dev]"

# Run development server
python app/main.py
```

## 🛠️ Scripts Reference

The `scripts/` directory contains comprehensive automation tools:

### 🏥 Health & Diagnostics

```bash
# Unified health check for all tools
./scripts/doctor.sh              # Check all DevOps tools
./scripts/doctor.sh gh           # Check GitHub CLI only
./scripts/doctor.sh oc           # Check OpenShift CLI only
./scripts/doctor.sh quick        # Quick essential check

# Detailed diagnostics
./scripts/gh-doctor.sh           # GitHub CLI comprehensive check
./scripts/openshift-doctor.sh    # OpenShift CLI comprehensive check
./scripts/verify-setup.sh        # Full project verification
```

### 📥 Installation Scripts

```bash
# One-command setup
./scripts/init.sh                # Install & configure everything

# Individual tool installation
./scripts/install-uv.sh          # Python package manager
./scripts/install-docker.sh      # Docker
./scripts/install-kubectl.sh     # Kubernetes CLI
./scripts/install-helm.sh        # Helm package manager
./scripts/install-k9s.sh         # Kubernetes terminal UI
./scripts/install-gh.sh          # GitHub CLI
./scripts/install-openshift.sh   # OpenShift CLI
./scripts/install-argocd.sh      # ArgoCD CLI
```

### 🚀 GitHub Automation

```bash
# Pull Request workflow
./scripts/gh-create-pr.sh        # Create PR from current branch
                                 # - Auto-detects PR type
                                 # - Applies labels
                                 # - Requests reviewers

# Release workflow
./scripts/gh-release.sh 1.0.0    # Automated release process
                                 # - Creates release branch
                                 # - Updates versions
                                 # - Generates changelog
                                 # - Creates PR to main

# Helper functions
source scripts/gh-helpers.sh     # Library of reusable functions
                                 # - check_gh_auth
                                 # - create_devops_pr
                                 # - check_ci_status
                                 # - wait_for_ci
                                 # - create_release
                                 # - and more...
```

### 🏗️ Build & Deploy

```bash
# Multi-platform Docker builds
./scripts/build-multiplatform.sh # Build for amd64 & arm64
```

### 📊 Quick Command Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `init.sh` | Complete project setup | `./scripts/init.sh` |
| `doctor.sh` | Health check all tools | `./scripts/doctor.sh [tool]` |
| `verify-setup.sh` | Comprehensive verification | `./scripts/verify-setup.sh` |
| `gh-create-pr.sh` | Create pull request | `./scripts/gh-create-pr.sh` |
| `gh-release.sh` | Automated release | `./scripts/gh-release.sh <version>` |
| `gh-doctor.sh` | GitHub CLI diagnostics | `./scripts/gh-doctor.sh` |
| `openshift-doctor.sh` | OpenShift diagnostics | `./scripts/openshift-doctor.sh` |

See [PROJECT_IMPROVEMENTS.md](PROJECT_IMPROVEMENTS.md) for detailed documentation of all scripts and improvements.

## 🚢 Deployment

### Docker Deployment

```bash
# Build multi-platform image
docker buildx build --platform linux/amd64,linux/arm64 \
  -f docker/Dockerfile \
  -t ghcr.io/nirgeier/devops-demo-project:latest \
  --push .
```

### Kubernetes Deployment

```bash
# Using Helm
helm upgrade --install devops-demo helm/devops-demo \
  --namespace devops-demo \
  --create-namespace \
  --values helm/devops-demo/values.yaml

# Check deployment
kubectl get pods -n devops-demo
kubectl get svc -n devops-demo

# Port forward for local access
kubectl port-forward -n devops-demo svc/devops-demo 8080:80
```

### ArgoCD Deployment

```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Deploy application
kubectl apply -f argocd/namespace.yaml
kubectl apply -f argocd/application.yaml

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## 🔄 GitFlow Workflow

This project follows the GitFlow branching model:

### Branch Structure

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - New features (branch from develop)
- `release/*` - Release preparation (branch from develop)
- `hotfix/*` - Production fixes (branch from main)

### Workflow

1. **Feature Development**
   ```bash
   git checkout develop
   git checkout -b feature/new-feature
   # ... make changes ...
   git push origin feature/new-feature
   # Create PR to develop
   ```

2. **Release Process**
   ```bash
   git checkout develop
   git checkout -b release/1.0.0
   # ... update version, changelog ...
   git push origin release/1.0.0
   # Create PR to main
   ```

3. **Hotfix**
   ```bash
   git checkout main
   git checkout -b hotfix/critical-fix
   # ... fix issue ...
   git push origin hotfix/critical-fix
   # Create PR to main
   ```

## 🔧 CI/CD Pipeline

### Continuous Integration (CI)

Triggered on: Push to any branch, Pull Requests

Steps:
1. ✅ Code checkout
2. ✅ Python setup with uv
3. ✅ Install dependencies
4. ✅ Run linting (flake8)
5. ✅ Run tests with coverage
6. ✅ Build Docker image
7. ✅ Test Docker image

### Continuous Deployment (CD)

Triggered on: Push to main, Version tags

Steps:
1. ✅ Build multi-platform Docker image
2. ✅ Push to GitHub Container Registry
3. ✅ Generate image attestation
4. ✅ Create GitHub release (for tags)
5. ✅ Update GitOps repository

### Release Management

Automated release workflow:
1. Create release branch
2. Automatic PR to main
3. On merge: Create version tag
4. Trigger CD pipeline
5. Merge back to develop

## 🔧 GitHub CLI Integration

This project includes comprehensive GitHub CLI (`gh`) integration for workflow automation and productivity.

### Quick Setup

```bash
# Install GitHub CLI
./scripts/install-gh.sh

# Authenticate
gh auth login

# Verify installation
gh --version
gh auth status

# Run diagnostics
./scripts/gh-doctor.sh
```

### 🎓 GitHub CLI Labs

Complete hands-on labs to master GitHub CLI:

```bash
cd gh-study/labs

# Lab 1: Setup & Authentication
./lab1-setup.sh

# Lab 2: Repository Management  
./lab2-repository.sh

# Lab 3: Issue Management
./lab3-issues.sh

# Lab 4: Pull Request Workflows
./lab4-pull-requests.sh

# Lab 5: GitHub Actions Management
./lab5-actions.sh

# Lab 6: Release Management
./lab6-releases.sh
```

📚 **[Complete GitHub CLI Study Guide](gh-study/README.md)** - Comprehensive guide with 8 labs covering everything from basics to advanced automation.

### Automation Scripts

The project includes ready-to-use automation scripts:

#### Create Pull Request
```bash
# From a feature branch
./scripts/gh-create-pr.sh

# Interactive PR creation with:
# - Auto-detection of PR type (feature/bugfix/hotfix)
# - Pre-filled PR template
# - Automatic labeling
# - CI status monitoring
```

#### Automated Release
```bash
# Create a new release
./scripts/gh-release.sh 1.0.0

# This will:
# 1. Create release branch
# 2. Update version in all files
# 3. Generate changelog
# 4. Create PR to main
# 5. Enable auto-merge when approved
```

#### Helper Functions
```bash
# Source helper functions
source scripts/gh-helpers.sh

# Use helper functions
check_ci_status              # Check CI for current branch
wait_for_ci                  # Wait for CI to complete
create_devops_pr "title" "body"  # Create PR with template
create_release "1.0.0"       # Create release with tag
list_open_prs                # List all open PRs
pr_status 123                # Check PR status
auto_merge_approved          # Auto-merge approved PRs
```

### Common Workflows

#### Daily Development
```bash
# Start feature
git checkout -b feature/my-feature
# ... make changes ...
git add .
git commit -m "feat: add new feature"
git push -u origin feature/my-feature

# Create PR
./scripts/gh-create-pr.sh

# Check CI status
gh pr checks --watch

# Merge when ready
gh pr merge --squash --delete-branch
```

#### Release Process
```bash
# Initiate release
./scripts/gh-release.sh 1.1.0

# Monitor PR
gh pr view --web

# Check CI
gh pr checks --watch

# After approval, merge happens automatically
# or manually: gh pr merge <number> --squash
```

#### CI/CD Monitoring
```bash
# View recent workflow runs
gh run list --limit 10

# Watch specific run
gh run watch

# View logs
gh run view --log

# Download artifacts
gh run download
```

#### Issue Management
```bash
# Create issue
gh issue create --title "Bug: Fix login" --label bug

# List your issues
gh issue list --assignee @me

# View issue
gh issue view 123

# Close with comment
gh issue close 123 --comment "Fixed in PR #124"
```

### Integration with CI/CD

The GitHub CLI is integrated into the CI/CD workflows:

1. **Release Management** - Automated PR creation and tagging
2. **PR Automation** - Auto-merge approved PRs with passing CI
3. **Issue Tracking** - Auto-create issues from errors
4. **Workflow Triggers** - Programmatically trigger workflows
5. **Artifact Management** - Download and upload artifacts

See [gh-study/README.md](gh-study/README.md) for complete documentation and advanced usage.

## 🚀 OpenShift Integration

This project includes comprehensive OpenShift CLI (`oc`) integration for enterprise container orchestration.

### Quick Setup

```bash
# Install OpenShift CLI
./scripts/install-openshift.sh

# Authenticate with your cluster
oc login https://api.your-cluster.example.com:6443

# Verify installation
oc version
oc whoami

# Run diagnostics
./scripts/openshift-doctor.sh
```

### 🎓 OpenShift CLI Labs

Complete hands-on labs to master OpenShift CLI:

```bash
cd openshift-study/labs

# Lab 1: Setup & Authentication
./lab1-setup.sh

# Lab 2: Project & Application Management
./lab2-projects.sh

# Lab 3: Deployment & Pod Management
./lab3-deployments.sh

# Lab 4: Service & Route Configuration
./lab4-networking.sh

# Lab 5: Build & ImageStream Operations
./lab5-builds.sh

# Lab 6: Monitoring & Troubleshooting
./lab6-monitoring.sh
```

📚 **[Complete OpenShift CLI Study Guide](openshift-study/README.md)** - Comprehensive guide with 6 labs covering everything from basics to advanced operations.

### Deploy to OpenShift

```bash
# Create project
oc new-project devops-demo

# Deploy this application
oc new-app python:3.9~https://github.com/nirgeier/DevOps-Demo-Project \
  --name=flask-app \
  --context-dir=app

# Expose service
oc expose svc/flask-app

# Get route URL
oc get route flask-app -o jsonpath='{.spec.host}'
```

### OpenShift Commands

```bash
# View all resources
oc get all

# Check pod logs
oc logs deployment/flask-app

# Scale application
oc scale deployment flask-app --replicas=3

# Debug pod
oc debug deployment/flask-app

# Port forward for testing
oc port-forward deployment/flask-app 8080:8080
```

### OpenShift vs Kubernetes

OpenShift extends Kubernetes with:
- **Projects** - Multi-tenant isolation (vs namespaces)
- **Routes** - Simplified external access (vs Ingress)
- **Source-to-Image (S2I)** - Build from source code
- **Integrated Registry** - Built-in container registry
- **Enhanced Security** - Security Context Constraints (SCCs)
- **Developer Console** - Advanced web UI

See [openshift-study/README.md](openshift-study/README.md) for complete documentation and advanced usage.

## 🎯 Complete Workflow & Architecture

This section provides a detailed walkthrough of how everything connects and flows through the entire DevOps pipeline.

### 📊 End-to-End Pipeline Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          COMPLETE DEVOPS WORKFLOW                           │
└─────────────────────────────────────────────────────────────────────────────┘

STEP 1: DEVELOPER CREATES CODE
┌──────────────────────────────────────────────────────────────────────────┐
│ Developer Branch:  feature/new-feature                                   │
│   ├── Writes Python code (app/main.py)                                   │
│   ├── Writes unit tests (tests/test_main.py)                             │
│   ├── Commits: git commit -m "feat: new feature"                         │
│   └── Pushes: git push origin feature/new-feature                        │
└──────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
STEP 2: GITHUB ACTIONS - CI PIPELINE TRIGGERS
┌──────────────────────────────────────────────────────────────────────────┐
│ Trigger: Push to feature/* branch                                        │
│ Workflow: .github/workflows/ci.yml                                       │
│                                                                           │
│ 🔍 LINT & TEST STAGE:                                                    │
│   ├── 📝 Setup Python 3.11 with uv                                       │
│   ├── 📦 Install dependencies (Flask, pytest, etc.)                      │
│   ├── 🔍 Run flake8 linting                                              │
│   ├── ✅ Run pytest with coverage                                        │
│   └── 📊 Upload coverage to Codecov                                      │
│                                                                           │
│ 🐳 BUILD STAGE:                                                          │
│   ├── 🔨 Build Docker image (amd64 platform)                             │
│   ├── 🏗️  Multi-stage build: builder → final                             │
│   ├── 📦 Dependencies cached in layer 1                                  │
│   └── ✅ Health check: curl /health endpoint                             │
│                                                                           │
│ Result: ✅ CI Passed → Ready to merge                                    │
└──────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
STEP 3: CREATE PULL REQUEST & CODE REVIEW
┌──────────────────────────────────────────────────────────────────────────┐
│ GitHub PR Created: feature/new-feature → develop                         │
│   ├── CI checks run automatically (branch protection)                    │
│   ├── Code review required (GitHub rules)                                │
│   ├── Approvals needed (at least 1)                                      │
│   └── All CI checks must pass                                            │
└──────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
STEP 4: MERGE TO DEVELOP
┌──────────────────────────────────────────────────────────────────────────┐
│ Action: PR merged to develop branch                                      │
│ Trigger: Merge commit detected                                           │
│ CI Pipeline: Runs again on develop branch                                │
│ Result: Code now in integration branch, ready for release planning       │
└──────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
STEP 5: CREATE RELEASE BRANCH
┌──────────────────────────────────────────────────────────────────────────┐
│ When ready for release:                                                  │
│   ├── git checkout develop                                               │
│   ├── git checkout -b release/1.0.0                                      │
│   ├── Update CHANGELOG.md                                                │
│   ├── Update version in pyproject.toml                                   │
│   ├── git commit -m "chore: bump version to 1.0.0"                       │
│   └── git push origin release/1.0.0                                      │
└──────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
STEP 6: GITHUB ACTIONS - RELEASE WORKFLOW
┌──────────────────────────────────────────────────────────────────────────┐
│ Trigger: Push to release/* branch                                        │
│ Workflow: .github/workflows/release.yml                                  │
│                                                                           │
│ 📋 Automatic PR Creation:                                                │
│   ├── Create PR: release/1.0.0 → main                                    │
│   ├── Add checklist for release validation                               │
│   ├── Tag with "release" label                                           │
│   └── Description includes version and changes                           │
└──────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
STEP 7: MERGE RELEASE TO MAIN
┌──────────────────────────────────────────────────────────────────────────┐
│ Action: Release PR reviewed and merged to main                           │
│ Branch: release/1.0.0 → main                                             │
│ Trigger: Merge to main detected                                          │
│ Action: GitHub Actions auto-tags with v1.0.0                            │
└──────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
STEP 8: GITHUB ACTIONS - CD PIPELINE TRIGGERS
┌──────────────────────────────────────────────────────────────────────────┐
│ Trigger: Push to main branch + Git tag v1.0.0 pushed                     │
│ Workflow: .github/workflows/cd.yml                                       │
│                                                                           │
│ 🐳 DOCKER BUILD STAGE:                                                   │
│   ├── 🔨 Build multi-platform image (amd64, arm64)                       │
│   ├── 📝 Extract metadata (version, tags, labels)                        │
│   ├── 🔐 Login to GitHub Container Registry (GHCR)                       │
│   └── 🚀 Push to: ghcr.io/nirgeier/devops-demo-project:v1.0.0            │
│                                                                           │
│ 🔐 SECURITY STAGE:                                                       │
│   └── 📜 Generate artifact attestation (provenance)                      │
│                                                                           │
│ 📦 RELEASE STAGE:                                                        │
│   ├── 🏷️  Create GitHub Release v1.0.0                                   │
│   ├── 📝 Generate release notes from commits                             │
│   └── 📋 Include Docker pull commands in release                         │
│                                                                           │
│ 🔄 GITOPS UPDATE STAGE:                                                  │
│   ├── 🔍 Extract image tag from build output                             │
│   ├── ✏️  Update helm/devops-demo/values.yaml                            │
│   ├── 🔄 Commit: chore: update image tag to v1.0.0                       │
│   └── 🚀 Push to main branch (triggers ArgoCD)                           │
│                                                                           │
│ Result: 📦 Container in GHCR | 📝 Release created | 🔄 GitOps updated  │
└──────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
STEP 9: ARGOCD DETECTS CHANGES
┌──────────────────────────────────────────────────────────────────────────┐
│ ArgoCD Watches: GitHub Repository (helm/devops-demo/values.yaml)         │
│                                                                           │
│ Change Detection:                                                        │
│   ├── ✅ New image tag in values.yaml detected                           │
│   ├── 🔍 Compares desired vs current state                               │
│   ├── 📊 Status: OutOfSync                                               │
│   └── 🔄 Auto-sync enabled (syncs immediately)                           │
└──────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
STEP 10: ARGOCD DEPLOYMENT TO KUBERNETES
┌──────────────────────────────────────────────────────────────────────────┐
│ ArgoCD Application: devops-demo                                          │
│ Source: helm/devops-demo/ chart                                          │
│                                                                           │
│ 📋 DEPLOYMENT PROCESS:                                                   │
│   ├── 🎯 Generate Kubernetes manifests from Helm chart                   │
│   ├── 📝 Apply values.yaml (2 replicas, image: v1.0.0)                   │
│   ├── 🔐 Create namespace: devops-demo (if not exists)                   │
│   ├── 📦 Create/Update Kubernetes resources:                             │
│   │   ├── 🔳 Deployment (2 replicas)                                     │
│   │   ├── 🔗 Service (ClusterIP port 80 → 8080)                          │
│   │   ├── 👤 ServiceAccount                                              │
│   │   ├── 📊 HorizontalPodAutoscaler (2-10 pods, 80% CPU/Mem)            │
│   │   ├── 🌍 Ingress (NGINX, optional)                                   │
│   │   └── 🛡️  Pod Anti-Affinity rules                                    │
│   │                                                                       │
│   └── ✅ Sync Status: Synced (all resources deployed)                    │
└──────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
STEP 11: KUBERNETES ROLLING UPDATE
┌──────────────────────────────────────────────────────────────────────────┐
│ Resource: Deployment/devops-demo                                         │
│ Action: Rolling update to new image tag                                  │
│                                                                           │
│ 📋 ROLLOUT PROCESS:                                                      │
│   ├── 1️⃣  New ReplicaSet created with v1.0.0 image                       │
│   ├── 2️⃣  Pod 1 starts: image pull → create → health check               │
│   ├── 3️⃣  Readiness probe passes → route traffic to Pod 1                │
│   ├── 4️⃣  Pod 2 starts: same process                                     │
│   ├── 5️⃣  Old ReplicaSet pods terminated (graceful shutdown)             │
│   ├── 6️⃣  Service endpoints updated: Pod 1, Pod 2 (v1.0.0)               │
│   │                                                                       │
│   └── ✅ Deployment Ready: 2/2 pods running                              │
└──────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
STEP 12: APPLICATION RUNNING IN KUBERNETES
┌──────────────────────────────────────────────────────────────────────────┐
│ 🎯 PRODUCTION ENVIRONMENT:                                               │
│                                                                           │
│ 🔳 DEPLOYMENT (devops-demo):                                             │
│   ├── Pod 1: devops-demo-abc123                                          │
│   │   ├── Container: devops-demo:v1.0.0                                  │
│   │   ├── CPU: 250m request / 500m limit                                 │
│   │   ├── Memory: 256Mi request / 512Mi limit                            │
│   │   ├── Status: Running ✅                                             │
│   │   ├── Probes:                                                        │
│   │   │   ├── Liveness: GET /health (every 10s)                          │
│   │   │   └── Readiness: GET /ready (every 5s)                           │
│   │   └── Logs: Available via kubectl logs                               │
│   │                                                                       │
│   └── Pod 2: devops-demo-def456                                          │
│       ├── Container: devops-demo:v1.0.0                                  │
│       ├── Running on different node (pod anti-affinity)                  │
│       └── Status: Running ✅                                             │
│                                                                           │
│ 🔗 SERVICE (devops-demo):                                                │
│   ├── Type: ClusterIP                                                    │
│   ├── Internal IP: 10.x.x.x                                              │
│   ├── Port: 80 → 8080                                                    │
│   ├── Endpoints: 2 Pods                                                  │
│   └── DNS: devops-demo.devops-demo.svc.cluster.local                     │
│                                                                           │
│ 📊 AUTOSCALING:                                                          │
│   ├── HPA: enabled                                                       │
│   ├── Replicas: 2 (current) / 2-10 (target range)                        │
│   ├── CPU threshold: 80%                                                 │
│   ├── Memory threshold: 80%                                              │
│   └── Action: Scale up if exceeded                                       │
│                                                                           │
│ ✅ HEALTH STATUS:                                                        │
│   ├── All replicas ready and running                                     │
│   ├── Service endpoints healthy                                          │
│   ├── ArgoCD sync status: Synced                                         │
│   └── Application accessible via Service                                 │
└──────────────────────────────────────────────────────────────────────────┘
```

### 🔌 Component Connections & Data Flow

```
LOCAL DEVELOPMENT
├─ Developer
│  ├── app/main.py (Flask app)
│  ├── tests/test_main.py (Unit tests)
│  ├── docker/Dockerfile (Container def)
│  ├── docker-compose.yml (Local compose)
│  ├── helm/devops-demo/ (Deployment config)
│  └── pyproject.toml (Dependencies)
│
└─ Version Control
   └─ Git Repository (GitHub)
      ├── main branch
      ├── develop branch
      ├── feature/* branches
      ├── release/* branches
      └── Automated Tags (v1.0.0)

CI/CD AUTOMATION
├─ GitHub Actions
│  ├── ci.yml workflow
│  │   ├─ Triggered: Push to any branch
│  │   ├─ Runs: Lint, Test, Build Docker
│  │   └─ Artifacts: Coverage reports
│  │
│  ├─ cd.yml workflow
│  │   ├─ Triggered: Push to main + tags
│  │   ├─ Builds: Multi-platform images
│  │   ├─ Pushes: GHCR registry
│  │   ├─ Signs: Container attestation
│  │   ├─ Creates: GitHub release
│  │   └─ Updates: Helm values.yaml
│  │
│  ├─ release.yml workflow
│  │   ├─ Triggered: Release branch
│  │   ├─ Creates: PR to main
│  │   ├─ Tags: Version tags (v1.0.0)
│  │   └─ Merges: Back to develop
│  │
│  └─ gitflow.yml workflow
│      ├─ Validates: Branch naming
│      ├─ Enforces: PR requirements
│      └─ Checks: Commit conventions

CONTAINER REGISTRY
├─ GitHub Container Registry (GHCR)
│  ├─ Repository: ghcr.io/nirgeier/devops-demo-project
│  ├─ Tags: v1.0.0, latest, sha-abc123, etc.
│  ├─ Multi-platform: linux/amd64, linux/arm64
│  ├─ Attestation: Provenance signed
│  └─ Metadata: Labels, digests

GITOPS ORCHESTRATION
├─ ArgoCD
│  ├─ Watches: GitHub repository (polling)
│  ├─ Detects: Changes in helm/ directory
│  ├─ Compares: Desired vs Actual state
│  ├─ Syncs: On change detection
│  ├─ Auto-heals: Drift correction
│  └─ Status: Dashboard + metrics

KUBERNETES CLUSTER
├─ Namespace: devops-demo
│  ├─ Deployment: devops-demo
│  │  ├─ Replicas: 2
│  │  ├─ Image: ghcr.io/nirgeier/devops-demo-project:v1.0.0
│  │  ├─ Containers: 1 (devops-demo)
│  │  ├─ Probes: Liveness + Readiness
│  │  ├─ Resources: Limits + Requests
│  │  └─ Updates: Rolling (0 downtime)
│  │
│  ├─ Service: devops-demo
│  │  ├─ Type: ClusterIP
│  │  ├─ Ports: 80 → 8080
│  │  ├─ Selector: app=devops-demo
│  │  └─ DNS: devops-demo.devops-demo.svc.cluster.local
│  │
│  ├─ HorizontalPodAutoscaler: devops-demo
│  │  ├─ Min: 2 replicas
│  │  ├─ Max: 10 replicas
│  │  ├─ CPU: 80% threshold
│  │  ├─ Memory: 80% threshold
│  │  └─ Scales: Based on metrics
│  │
│  ├─ ServiceAccount: devops-demo
│  │  └─ RBAC: Pod-level permissions
│  │
│  └─ Pods: Running instances
│     ├─ Pod 1: devops-demo-abc123 (Running ✅)
│     └─ Pod 2: devops-demo-def456 (Running ✅)
```

### 🔄 Data Flow Through Pipeline

```
CHANGE FLOW:
1. Developer writes code → Local testing
2. Push to GitHub → CI pipeline starts
3. All tests pass → Ready to merge
4. Merge to develop → Integration verification
5. Create release/* branch → Release workflow
6. Merge to main → Version tag created + CD pipeline
7. CD pipeline → Build & push image to GHCR
8. CD pipeline → Update Helm values.yaml
9. ArgoCD detects change → Syncs to Kubernetes
10. Kubernetes rolling update → New version live
11. Service routes traffic → Old pods terminated
12. Monitoring → Health checks pass ✅

IMAGE PROMOTION:
- Build: ghcr.io/nirgeier/devops-demo-project:branch-sha123def
- Test: ghcr.io/nirgeier/devops-demo-project:latest (on develop)
- Stage: ghcr.io/nirgeier/devops-demo-project:v1.0.0-rc1 (release)
- Prod: ghcr.io/nirgeier/devops-demo-project:v1.0.0 (main + tag)

CONFIGURATION FLOW:
1. Default values → helm/devops-demo/values.yaml
2. CD pipeline → Updates image.tag field
3. Git commit → Changes tracked in GitHub
4. ArgoCD watches → Detects new values
5. Helm template → Generates Kubernetes YAML
6. kubectl apply → Resources created/updated
7. Kubernetes → Reconciles to desired state
```

### 🏗️ Architecture Layers

```
Layer 1: APPLICATION LAYER
┌─────────────────────────────────────────────────────────────┐
│ app/main.py - Flask REST API                                │
│  ├─ GET /         → Welcome message                         │
│  ├─ GET /health   → Kubernetes liveness probe               │
│  ├─ GET /ready    → Kubernetes readiness probe              │
│  ├─ GET /api/info → App information                         │
│  └─ POST /api/echo → Echo service                           │
└─────────────────────────────────────────────────────────────┘

Layer 2: CONTAINERIZATION
┌─────────────────────────────────────────────────────────────┐
│ docker/Dockerfile - Multi-stage build                       │
│  ├─ Stage 1: Builder (dependencies cached)                  │
│  └─ Stage 2: Final (minimal image size)                     │
│     └─ Run as non-root user (uid 1000)                      │
│     └─ Health check configured                              │
│     └─ Exposed port: 8080                                   │
└─────────────────────────────────────────────────────────────┘

Layer 3: ORCHESTRATION & DEPLOYMENT
┌─────────────────────────────────────────────────────────────┐
│ helm/devops-demo/ - Kubernetes package                      │
│  ├─ Chart.yaml - Chart metadata                             │
│  ├─ values.yaml - Configuration values                      │
│  └─ templates/ - Kubernetes resource templates              │
│     ├─ deployment.yaml - Pod management                     │
│     ├─ service.yaml - Network exposure                      │
│     ├─ hpa.yaml - Auto-scaling rules                        │
│     ├─ ingress.yaml - External routing                      │
│     ├─ serviceaccount.yaml - RBAC permissions               │
│     └─ _helpers.tpl - Template helpers                      │
└─────────────────────────────────────────────────────────────┘

Layer 4: CONTINUOUS INTEGRATION
┌─────────────────────────────────────────────────────────────┐
│ .github/workflows/ci.yml - Build & Test                     │
│  ├─ Test: Python lint + unit tests                          │
│  ├─ Build: Docker image creation                            │
│  └─ Verify: Container health checks                         │
└─────────────────────────────────────────────────────────────┘

Layer 5: CONTINUOUS DEPLOYMENT
┌─────────────────────────────────────────────────────────────┐
│ .github/workflows/cd.yml - Release & Deploy                 │
│  ├─ Build: Multi-platform images (amd64, arm64)             │
│  ├─ Push: GitHub Container Registry                         │
│  ├─ Sign: Container attestation                             │
│  ├─ Release: GitHub release with notes                      │
│  └─ Update: Helm values with new image tag                  │
└─────────────────────────────────────────────────────────────┘

Layer 6: GITOPS ORCHESTRATION
┌─────────────────────────────────────────────────────────────┐
│ ArgoCD Application - GitOps Controller                       │
│  ├─ Source: GitHub repository (helm/ directory)             │
│  ├─ Destination: Kubernetes cluster                         │
│  ├─ Policy: Auto-sync + Self-heal                           │
│  └─ Action: Deploy/update on Git changes                    │
└─────────────────────────────────────────────────────────────┘

Layer 7: RUNTIME ENVIRONMENT
┌─────────────────────────────────────────────────────────────┐
│ Kubernetes Cluster - Production Environment                 │
│  ├─ Namespace: devops-demo                                  │
│  ├─ Deployment: 2 replicas (auto-scales 2-10)               │
│  ├─ Service: ClusterIP load balancer                        │
│  ├─ Monitoring: Probes + metrics                            │
│  └─ Status: Self-healing with drift correction              │
└─────────────────────────────────────────────────────────────┘
```

### 📡 Network & Traffic Flow

```
EXTERNAL TRAFFIC:
Internet Client
    │
    └──→ Kubernetes Ingress (nginx)
         │ (optional, disabled by default)
         │ │ Host: devops-demo.example.com
         │ │ Path: /
         │
         └──→ Kubernetes Service (ClusterIP)
              │ DevOps-demo service
              │ Port 80 → Pod 8080
              │
              ├──→ Pod 1 (devops-demo-abc123)
              │    └──→ Container port 8080
              │        └──→ Flask app receiving request
              │
              └──→ Pod 2 (devops-demo-def456)
                   └──→ Container port 8080
                       └──→ Flask app receiving request

INTERNAL TRAFFIC (Kubernetes):
DNS Query: devops-demo.devops-demo.svc.cluster.local
    │
    └──→ Kubernetes DNS (CoreDNS)
         │
         └──→ Service ClusterIP: 10.x.x.x
              │
              └──→ Round-robin load balancing
                   ├──→ Pod 1 (iptables rule)
                   └──→ Pod 2 (iptables rule)

GITOPS TRAFFIC:
ArgoCD Controller (in argocd namespace)
    │
    ├──→ GitHub API (polling every 3 minutes)
    │    └──→ Check: helm/devops-demo/values.yaml
    │        └──→ Get: Current image tag
    │
    └──→ Kubernetes API (reconciliation loop)
         ├──→ GET: Current state (Deployment, Pods, etc.)
         ├──→ COMPARE: Desired vs Actual
         └──→ APPLY: kubectl apply -f (manifests)
              └──→ Kubernetes reconciliation
                   └──→ Updates Deployment
                       └──→ Creates new ReplicaSet
                           └──→ Launches new Pods
                               └──→ Terminates old Pods
```

### 🔐 Security & Best Practices

```
CONTAINERIZATION SECURITY:
✅ Non-root user (uid 1000) - No privilege escalation
✅ Read-only root filesystem - No container modification
✅ Drop all capabilities - No system-level access
✅ No privilege escalation - runAsNonRoot: true
✅ Resource limits - CPU 500m, Memory 512Mi
✅ Health checks - Automatic pod restart on failure
✅ Minimal base image - python:3.11-slim (90MB+)

KUBERNETES SECURITY:
✅ Pod security context - runAsNonRoot, fsGroup
✅ Resource quotas - Per pod limits and requests
✅ Pod anti-affinity - Spread replicas across nodes
✅ Readiness probes - Traffic only to ready pods
✅ Liveness probes - Auto-restart failed containers
✅ Service account - RBAC permissions per pod
✅ Network policies - (can be configured)

CI/CD SECURITY:
✅ Container attestation - Signed provenance
✅ GitHub OIDC - Keyless authentication
✅ Secrets management - GITHUB_TOKEN auto-rotated
✅ Branch protection - Required reviews & checks
✅ Commit signing - (can be configured)
✅ Supply chain - SLSA level 2 compliance

GITOPS SECURITY:
✅ Read-only replicas - ArgoCD has no write access
✅ Git source of truth - All changes via Git
✅ Audit logs - Git commit history
✅ RBAC - ArgoCD service account permissions
✅ Network policies - ArgoCD to K8s communication
```

### 🎯 What Connects to What

| Component | Connects To | How | Purpose |
|-----------|------------|-----|---------|
| Developer | GitHub | Push code | Trigger CI/CD |
| GitHub | GitHub Actions | Webhook | Run workflows |
| GitHub Actions | GHCR | Push image | Store container |
| GitHub Actions | GitHub | Commit/tag/release | Track changes |
| GHCR | Kubernetes | Image pull | Deploy app |
| Git repo (helm/) | ArgoCD | Poll / webhook | Detect changes |
| ArgoCD | Kubernetes API | kubectl apply | Deploy resources |
| Service | Pod | iptables rules | Route traffic |
| HPA | Metrics server | Query metrics | Scale pods |
| Pod | GitHub | Not directly | (logs can be sent) |
| Ingress | Service | DNS name | Route external traffic |
| Liveness probe | Pod | HTTP GET /health | Check if alive |
| Readiness probe | Pod | HTTP GET /ready | Check if ready |

### 🚀 Complete Example: From Code to Production

```
SCENARIO: Deploying a new feature v1.1.0

❶ Developer creates feature
   $ git checkout develop
   $ git checkout -b feature/add-metrics
   # Edit app/main.py to add /metrics endpoint
   # Edit tests/test_main.py with new tests
   $ pytest tests/ -v  # ✅ Pass locally
   $ git add .
   $ git commit -m "feat: add metrics endpoint"
   $ git push origin feature/add-metrics

❷ GitHub detects push
   📌 Trigger: Push to feature/* branch
   ▶️  CI Workflow starts (.github/workflows/ci.yml)

❸ CI Pipeline runs
   • Setup Python 3.11 with uv
   • Install dependencies
   • Run flake8 linting (✅ Pass)
   • Run pytest (✅ 8/8 tests pass)
   • Build Docker image (linux/amd64)
   • Test Docker image
   ✅ ALL CHECKS PASSED

❹ Create Pull Request
   $ gh pr create --title "feat: add metrics" --body "..."
   📌 PR target: develop branch
   ✅ All CI checks pass
   ✅ Code review approved
   ✅ Ready to merge

❺ Merge to develop
   $ gh pr merge --squash  # or merge via GitHub UI
   📌 Trigger: Merge commit to develop
   ▶️  CI workflow runs again (quick check)

❻ Create release branch
   $ git checkout develop && git pull
   $ git checkout -b release/1.1.0
   # Update CHANGELOG.md
   # Update pyproject.toml: version = "1.1.0"
   $ git commit -m "chore: bump version to 1.1.0"
   $ git push origin release/1.1.0

❼ Release workflow auto-creates PR
   📌 Trigger: Push to release/* branch
   ▶️  Release workflow (.github/workflows/release.yml)
   ✅ PR created: release/1.1.0 → main
   ✅ Title: "Release 1.1.0"
   ✅ Checklist added for validation

❽ Merge release to main
   $ gh pr merge <PR_NUMBER>  # via GitHub UI
   📌 Trigger: Merge commit to main
   ▶️  Release workflow detects merge

❾ Automatic tagging
   🏷️  Git tag created: v1.1.0
   📌 Trigger: Tag push to GitHub
   ▶️  CD Workflow starts (.github/workflows/cd.yml)

❿ CD Pipeline builds & deploys
   🏗️  Build multi-platform Docker image (amd64, arm64)
   🔐 Login to GHCR
   🚀 Push image: ghcr.io/nirgeier/devops-demo-project:v1.1.0
   🚀 Push image: ghcr.io/nirgeier/devops-demo-project:latest
   📜 Generate and push attestation
   📦 Create GitHub Release v1.1.0 with notes
   ✏️  Update helm/devops-demo/values.yaml
       - image.tag: "v1.1.0"
   💾 Commit & push: "chore: update image tag to v1.1.0"

⓫ ArgoCD detects Git change
   👀 ArgoCD polling detects values.yaml update
   ⚠️  Status changes: "Synced" → "OutOfSync"
   🔄 Auto-sync enabled (immediate action)

⓬ Deployment to Kubernetes
   🎯 Generate manifests: helm template with v1.1.0
   📋 kubectl apply -f manifests.yaml
   
   ✨ Deployment spec updated:
      - image: ghcr.io/nirgeier/devops-demo-project:v1.1.0
      - 2 replicas
   
   🔄 Rolling update begins:
      - New ReplicaSet created (v1.1.0)
      - Pod 1 starts: image pull → startup → ready
      - Service routes new traffic to Pod 1
      - Pod 2 starts: image pull → startup → ready
      - Service routes new traffic to Pod 2
      - Old Pods (v1.0.0) terminated gracefully
   
   ✅ Deployment complete (0 downtime)

⓭ Verify in production
   $ kubectl get pods -n devops-demo
   devops-demo-abc789  1/1  Running  (v1.1.0)
   devops-demo-def012  1/1  Running  (v1.1.0)
   
   $ kubectl get deployment -n devops-demo
   devops-demo  2/2  2/2  Updated ✅
   
   $ curl https://devops-demo.example.com/metrics
   { "requests": 1243, "errors": 0, ... } ✅

⓮ Auto-merge back to develop
   🔄 Release workflow merges main → develop
   📝 Merge commit: "Merge release v1.1.0 into develop"
   ✅ Both branches now in sync

✨ SUCCESS: v1.1.0 is now live in production!
```

## 📚 Documentation

- [ArgoCD Setup](argocd/README.md)
- [Helm Charts](helm/devops-demo/README.md)
- [API Documentation](docs/API.md)
- [Deployment Guide](docs/DEPLOYMENT.md)

## 🔗 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Welcome message |
| `/health` | GET | Health check |
| `/ready` | GET | Readiness probe |
| `/api/info` | GET | Application information |
| `/api/echo` | POST | Echo endpoint |

## 🛠️ Tools Used

- **Python/Flask** - Application framework
- **uv** - Fast Python package manager
- **Docker** - Containerization
- **Kubernetes** - Container orchestration
- **Helm** - Kubernetes package manager
- **ArgoCD** - GitOps continuous delivery
- **GitHub Actions** - CI/CD automation
- **GitHub CLI (gh)** - Workflow automation and management
- **OpenShift CLI (oc)** - Enterprise container platform (optional)
- **pytest** - Testing framework
- **k9s** - Kubernetes CLI manager

## 📄 License

MIT License - see LICENSE file for details

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

**Made with ❤️ for DevOps Engineers**
DevOps-Demo-Project
