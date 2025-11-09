# Deployment Guide

Complete guide for deploying the DevOps Demo Application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
- [Docker Deployment](#docker-deployment)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Production Deployment](#production-deployment)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

1. **Docker** (v20.10+)
2. **kubectl** (v1.28+)
3. **Helm** (v3.12+)
4. **ArgoCD CLI** (optional)

### Install Tools

```bash
# Run automated installation
./scripts/init.sh

# Or install individually
./scripts/install-kubectl.sh
./scripts/install-helm.sh
./scripts/install-k9s.sh
```

## Local Development

### Python Virtual Environment

```bash
# Create and activate virtual environment
uv venv
source .venv/bin/activate

# Install dependencies
uv pip install -e ".[dev]"

# Run application
python app/main.py
```

### Access Application

```
http://localhost:8080
```

### Run Tests

```bash
pytest tests/ -v --cov=app
```

## Docker Deployment

### Build Image

```bash
# Build locally
docker build -f docker/Dockerfile -t ghcr.io/nirgeier/devops-demo-project:latest .

# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 \
  -f docker/Dockerfile \
  -t ghcr.io/nirgeier/devops-demo-project:latest .
```

### Run Container

```bash
# Simple run
docker run -p 8080:8080 ghcr.io/nirgeier/devops-demo-project:latest

# With environment variables
docker run -p 8080:8080 \
  -e APP_VERSION=1.0.0 \
  -e ENVIRONMENT=production \
  ghcr.io/nirgeier/devops-demo-project:latest

# With docker-compose
docker-compose -f docker/docker-compose.yml up -d
```

### Verify Container

```bash
# Check health
curl http://localhost:8080/health

# View logs
docker logs -f <container-id>

# Stop container
docker-compose -f docker/docker-compose.yml down
```

## Kubernetes Deployment

### Using Helm

#### 1. Install

```bash
# Create namespace
kubectl create namespace devops-demo

# Install with Helm
helm install devops-demo helm/devops-demo \
  --namespace devops-demo \
  --values helm/devops-demo/values.yaml
```

#### 2. Verify

```bash
# Check pods
kubectl get pods -n devops-demo

# Check services
kubectl get svc -n devops-demo

# Check deployment
kubectl get deployment -n devops-demo
```

#### 3. Access Application

```bash
# Port forward
kubectl port-forward -n devops-demo svc/devops-demo 8080:80

# Or use ingress (if enabled)
# Update helm/devops-demo/values.yaml:
# ingress:
#   enabled: true
#   hosts:
#     - host: devops-demo.example.com
```

#### 4. Upgrade

```bash
# Update values.yaml and upgrade
helm upgrade devops-demo helm/devops-demo \
  --namespace devops-demo \
  --values helm/devops-demo/values.yaml
```

#### 5. Rollback

```bash
# List releases
helm history devops-demo -n devops-demo

# Rollback to previous version
helm rollback devops-demo -n devops-demo
```

#### 6. Uninstall

```bash
helm uninstall devops-demo -n devops-demo
kubectl delete namespace devops-demo
```

### Using kubectl

```bash
# Generate manifests from Helm
helm template devops-demo helm/devops-demo > manifests.yaml

# Apply manifests
kubectl apply -f manifests.yaml

# Delete
kubectl delete -f manifests.yaml
```

## Production Deployment

### Using ArgoCD (GitOps)

#### 1. Install ArgoCD

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
```

#### 2. Access ArgoCD UI

```bash
# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Login at: https://localhost:8080
# Username: admin
# Password: (from above command)
```

#### 3. Deploy Application

```bash
# Apply namespace
kubectl apply -f argocd/namespace.yaml

# Apply ArgoCD application
kubectl apply -f argocd/application.yaml

# Check sync status
kubectl get application -n argocd
```

#### 4. Using ArgoCD CLI

```bash
# Login
argocd login localhost:8080

# List applications
argocd app list

# Get application status
argocd app get devops-demo

# Sync application
argocd app sync devops-demo

# View application details
argocd app get devops-demo --refresh
```

### GitHub Container Registry

#### 1. Authenticate

```bash
# Create GitHub Personal Access Token with packages:read permission
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

#### 2. Pull Image

```bash
docker pull ghcr.io/nirgeier/devops-demo-project:latest
```

#### 3. Configure Kubernetes

```bash
# Create image pull secret
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=USERNAME \
  --docker-password=$GITHUB_TOKEN \
  --docker-email=EMAIL \
  -n devops-demo

# Update values.yaml
# imagePullSecrets:
#   - name: ghcr-secret
```

## Monitoring

### Health Checks

```bash
# Liveness probe
curl http://localhost:8080/health

# Readiness probe
curl http://localhost:8080/ready
```

### Logs

```bash
# Docker
docker logs -f <container-name>

# Kubernetes
kubectl logs -f deployment/devops-demo -n devops-demo

# All pods
kubectl logs -f -l app.kubernetes.io/name=devops-demo -n devops-demo

# Previous container (if crashed)
kubectl logs --previous deployment/devops-demo -n devops-demo
```

### Metrics

```bash
# Get pod metrics
kubectl top pods -n devops-demo

# Get node metrics
kubectl top nodes

# HPA status
kubectl get hpa -n devops-demo
```

### k9s (Interactive)

```bash
# Launch k9s
k9s -n devops-demo

# Common commands in k9s:
# :pods        - View pods
# :svc         - View services
# :deploy      - View deployments
# :logs        - View logs
# d            - Describe resource
# l            - View logs
# s            - Shell into pod
```

## Troubleshooting

### Pod Not Starting

```bash
# Describe pod
kubectl describe pod <pod-name> -n devops-demo

# Check events
kubectl get events -n devops-demo --sort-by='.lastTimestamp'

# Check logs
kubectl logs <pod-name> -n devops-demo
```

### Image Pull Errors

```bash
# Verify image exists
docker pull ghcr.io/nirgeier/devops-demo-project:latest

# Check image pull secret
kubectl get secret ghcr-secret -n devops-demo

# Recreate secret
kubectl delete secret ghcr-secret -n devops-demo
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=USERNAME \
  --docker-password=$GITHUB_TOKEN \
  -n devops-demo
```

### Service Not Accessible

```bash
# Check service
kubectl get svc -n devops-demo

# Check endpoints
kubectl get endpoints -n devops-demo

# Port forward for testing
kubectl port-forward svc/devops-demo 8080:80 -n devops-demo
```

### High Memory/CPU Usage

```bash
# Check resource usage
kubectl top pods -n devops-demo

# Update resource limits in values.yaml
# resources:
#   limits:
#     cpu: 1000m
#     memory: 1Gi

# Apply changes
helm upgrade devops-demo helm/devops-demo -n devops-demo
```

### ArgoCD Sync Issues

```bash
# Check application status
argocd app get devops-demo

# View sync status
kubectl describe application devops-demo -n argocd

# Force sync
argocd app sync devops-demo --force

# Refresh application
argocd app get devops-demo --refresh
```

## Scaling

### Manual Scaling

```bash
# Scale deployment
kubectl scale deployment devops-demo --replicas=5 -n devops-demo

# Update Helm values
# replicaCount: 5
helm upgrade devops-demo helm/devops-demo -n devops-demo
```

### Auto Scaling (HPA)

```bash
# Check HPA
kubectl get hpa -n devops-demo

# Describe HPA
kubectl describe hpa devops-demo -n devops-demo

# Update HPA settings in values.yaml
# autoscaling:
#   enabled: true
#   minReplicas: 2
#   maxReplicas: 10
```

## Security

### Security Context

The application runs as non-root user (UID 1000) with:
- Read-only root filesystem
- No privilege escalation
- Dropped capabilities

### Network Policies

```bash
# Apply network policy (example)
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: devops-demo-netpol
  namespace: devops-demo
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: devops-demo
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector: {}
    ports:
    - protocol: TCP
      port: 8080
EOF
```

## Backup and Recovery

### Backup Helm Release

```bash
# Get current values
helm get values devops-demo -n devops-demo > backup-values.yaml

# Get all resources
helm get manifest devops-demo -n devops-demo > backup-manifest.yaml
```

### Disaster Recovery

```bash
# Restore from backup
helm install devops-demo helm/devops-demo \
  --namespace devops-demo \
  --values backup-values.yaml

# Or apply manifests
kubectl apply -f backup-manifest.yaml
```

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Docker Documentation](https://docs.docker.com/)

---

For more information, see the [main README](../README.md).
