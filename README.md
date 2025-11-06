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

- **Python 3.11+**
- **Docker** (for containerization)
- **kubectl** (for Kubernetes)
- **Helm** (for Kubernetes package management)
- **uv** (Python package manager)
- **k9s** (optional, for Kubernetes cluster management)

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
./scripts/install-argocd.sh  # Optional
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
source .venv/bin/activate

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
├── app/                      # Python application
│   ├── __init__.py
│   └── main.py              # Flask application
├── tests/                    # Test suite
│   ├── __init__.py
│   └── test_main.py         # Unit tests
├── docker/                   # Docker configuration
│   ├── Dockerfile           # Multi-stage build
│   ├── .dockerignore
│   └── docker-compose.yml
├── helm/                     # Helm charts
│   └── devops-demo/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/       # Kubernetes manifests
├── argocd/                   # ArgoCD configuration
│   ├── application.yaml
│   ├── namespace.yaml
│   └── README.md
├── scripts/                  # Installation scripts
│   ├── init.sh              # Project initialization
│   ├── install-uv.sh
│   ├── install-kubectl.sh
│   ├── install-helm.sh
│   └── install-k9s.sh
├── .github/                  # GitHub Actions
│   └── workflows/
│       ├── ci.yml           # Continuous Integration
│       ├── cd.yml           # Continuous Deployment
│       ├── release.yml      # Release management
│       └── gitflow.yml      # GitFlow validation
├── docs/                     # Documentation
├── pyproject.toml           # Python dependencies
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
# Create virtual environment
uv venv

# Activate environment
source .venv/bin/activate

# Install dependencies
uv pip install -e ".[dev]"

# Run development server
python app/main.py
```

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
