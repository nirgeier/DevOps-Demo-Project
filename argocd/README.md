# ArgoCD Configuration

This directory contains ArgoCD application manifests for GitOps deployment.

## Files

- `application.yaml` - Main ArgoCD Application definition
- `namespace.yaml` - Kubernetes namespace for the application

## Deployment

### Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Access ArgoCD UI

```bash
# Port forward ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Deploy Application

```bash
# Apply namespace
kubectl apply -f namespace.yaml

# Apply ArgoCD application
kubectl apply -f application.yaml
```

## Configuration

The application is configured with:

- **Auto-sync**: Enabled
- **Self-heal**: Enabled
- **Prune**: Enabled (removes resources not in Git)
- **Namespace**: Auto-created if not exists

## Monitoring

```bash
# Check application status
kubectl get applications -n argocd

# View application details
kubectl describe application devops-demo -n argocd

# Use ArgoCD CLI
argocd app get devops-demo
argocd app sync devops-demo
```

## GitOps Workflow

1. Make changes to Helm charts or values in `helm/devops-demo/`
2. Commit and push to Git
3. ArgoCD automatically detects changes
4. ArgoCD syncs the application to match Git state
5. Monitor deployment in ArgoCD UI

## Sync Policies

- **Automated sync**: Changes in Git are automatically deployed
- **Self-heal**: If manual changes are made to the cluster, they are reverted
- **Prune**: Resources deleted from Git are removed from the cluster
