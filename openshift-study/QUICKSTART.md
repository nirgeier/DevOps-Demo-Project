# OpenShift CLI (oc) - Quick Start Guide

> **Fast-track guide to get started with OpenShift CLI in this project**

## 📦 Installation

```bash
# Install OpenShift CLI
./scripts/install-openshift.sh

# Connect to cluster (get command from web console)
oc login --token=<token> --server=<server-url>

# Verify setup
oc whoami
./scripts/doctor.sh oc
```

## 🎓 Learning Resources

### Interactive Labs
Complete hands-on labs in order:

```bash
cd openshift-study/labs

./lab1-setup.sh             # Setup & Authentication
./lab2-projects.sh          # Project & Application Management
./lab3-deployments.sh       # Deployment & Pod Management
./lab4-networking.sh        # Service & Route Configuration
./lab5-builds.sh            # Build & ImageStream Operations
./lab6-monitoring.sh        # Monitoring & Troubleshooting
```

### Comprehensive Guide
📚 See [openshift-study/README.md](README.md) for complete documentation including:
- All commands with examples
- Detailed lab instructions
- Real-world integration examples
- Best practices
- Troubleshooting guide
- Complete cheat sheet

## 🚀 Quick Start

### Connect to Cluster
```bash
# Get login command from OpenShift web console
# Click your username → Copy login command → Display Token

# Login
oc login --token=sha256~xxxxx --server=https://api.cluster.example.com:6443

# Verify
oc whoami
oc projects
```

### Deploy Application
```bash
# Create project
oc new-project my-app

# Deploy from Git
oc new-app https://github.com/myorg/myapp --name=myapp

# Expose service
oc expose svc/myapp

# Get URL
oc get route myapp
```

## 📋 Common Commands

### Project Management
```bash
oc new-project <name>          # Create project
oc project <name>              # Switch project
oc projects                    # List projects
oc delete project <name>       # Delete project
```

### Application Deployment
```bash
oc new-app <image>             # Deploy from image
oc new-app <git-url>           # Deploy from Git (S2I)
oc get all                     # List all resources
oc delete all -l app=<name>    # Delete application
```

### Pod Management
```bash
oc get pods                    # List pods
oc logs <pod>                  # View logs
oc logs -f <pod>               # Follow logs
oc rsh <pod>                   # Shell into pod
oc exec <pod> -- <command>     # Execute command
oc debug pod/<pod>             # Debug pod
```

### Deployment Operations
```bash
oc scale deployment/<name> --replicas=3
oc rollout status deployment/<name>
oc rollout restart deployment/<name>
oc rollout undo deployment/<name>
oc rollout history deployment/<name>
```

### Services & Networking
```bash
oc get svc                     # List services
oc expose svc/<name>           # Create route
oc get routes                  # List routes
oc port-forward svc/<name> 8080:8080
```

### Builds & Images
```bash
oc new-build <git-url>         # Create build
oc start-build <name>          # Trigger build
oc logs -f bc/<name>           # Follow build logs
oc get builds                  # List builds
oc get imagestreams            # List image streams
oc import-image <name>         # Import external image
```

### Monitoring & Debugging
```bash
oc status                      # Project status
oc describe <resource> <name>  # Detailed info
oc get events                  # View events
oc adm top pods                # Resource usage
oc adm top nodes               # Node usage (admin)
```

## 🔄 Workflow Examples

### Daily Development Workflow
```bash
# 1. Login to cluster
oc login --token=$TOKEN --server=$SERVER

# 2. Create/switch to project
oc project my-project

# 3. Deploy application
oc new-app python:3.9~https://github.com/myorg/myapp --name=myapp

# 4. Watch deployment
oc logs -f bc/myapp

# 5. Expose service
oc expose svc/myapp

# 6. Get URL and test
ROUTE=$(oc get route myapp -o jsonpath='{.spec.host}')
curl http://$ROUTE

# 7. Scale if needed
oc scale deployment/myapp --replicas=3

# 8. Monitor
oc status
oc get pods
```

### Update Deployment
```bash
# 1. Trigger new build
oc start-build myapp

# 2. Watch build
oc logs -f bc/myapp

# 3. Monitor rollout
oc rollout status deployment/myapp

# 4. Verify
oc get pods
curl http://$(oc get route myapp -o jsonpath='{.spec.host}')
```

### Troubleshooting Workflow
```bash
# 1. Check status
oc status
oc get pods

# 2. View events
oc get events --sort-by='.lastTimestamp'

# 3. Check specific pod
POD=$(oc get pods -l app=myapp -o jsonpath='{.items[0].metadata.name}')
oc describe pod $POD
oc logs $POD

# 4. Debug if needed
oc debug pod/$POD

# 5. Check resources
oc adm top pods

# 6. Restart if necessary
oc rollout restart deployment/myapp
```

## 🎯 Integration with This Project

### Deploy DevOps Demo Project
```bash
# 1. Login to OpenShift
oc login --token=$OC_TOKEN --server=$OC_SERVER

# 2. Create project
oc new-project devops-demo

# 3. Deploy Flask application
oc new-app python:3.9~https://github.com/nirgeier/DevOps-Demo-Project \
  --context-dir=app \
  --name=flask-app

# 4. Wait for build
oc logs -f bc/flask-app

# 5. Expose service
oc expose svc/flask-app

# 6. Get application URL
echo "Application URL: http://$(oc get route flask-app -o jsonpath='{.spec.host}')"

# 7. Scale application
oc scale deployment/flask-app --replicas=3

# 8. Monitor
oc status
```

### CI/CD Integration
```bash
# Create service account for CI/CD
oc create serviceaccount cicd-bot

# Grant permissions
oc policy add-role-to-user edit system:serviceaccount:devops-demo:cicd-bot

# Get token for CI/CD
TOKEN=$(oc serviceaccounts get-token cicd-bot)
echo "Use this token in your CI/CD pipeline: $TOKEN"
```

### Health Monitoring
```bash
# Check application health
ROUTE=$(oc get route flask-app -o jsonpath='{.spec.host}')
curl -f http://$ROUTE/health || echo "Application is down!"

# Check pod status
oc get pods -l app=flask-app -o jsonpath='{.items[*].status.phase}'

# Resource usage
oc adm top pods -l app=flask-app
```

## 💡 Tips & Best Practices

### 1. **Use Labels for Organization**
```bash
oc label deployment flask-app environment=production version=v1.0
oc get all -l environment=production
```

### 2. **Set Resource Limits**
```bash
oc set resources deployment flask-app \
  --limits=cpu=500m,memory=512Mi \
  --requests=cpu=250m,memory=256Mi
```

### 3. **Configure Health Checks**
```bash
oc set probe deployment/flask-app \
  --liveness --get-url=http://:8080/health \
  --initial-delay-seconds=30 \
  --timeout-seconds=3

oc set probe deployment/flask-app \
  --readiness --get-url=http://:8080/ready \
  --initial-delay-seconds=5 \
  --timeout-seconds=3
```

### 4. **Use Environment Variables**
```bash
oc set env deployment/flask-app \
  DATABASE_HOST=postgres \
  DATABASE_PORT=5432 \
  ENV=production
```

### 5. **Enable Auto-scaling**
```bash
oc autoscale deployment/flask-app \
  --min=2 --max=10 --cpu-percent=80
```

### 6. **Use Secrets for Sensitive Data**
```bash
oc create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=secret

oc set env deployment/flask-app --from=secret/db-credentials
```

### 7. **Export Resources for Backup**
```bash
oc get all -o yaml > backup.yaml
oc get secrets -o yaml > secrets-backup.yaml
```

## 🆘 Troubleshooting

### Pod Won't Start
```bash
# 1. Check pod status
oc get pods

# 2. Describe pod
oc describe pod <pod-name>

# 3. Check events
oc get events --sort-by='.lastTimestamp'

# 4. View logs
oc logs <pod-name>

# 5. Debug
oc debug pod/<pod-name>
```

### Build Fails
```bash
# 1. Check build logs
oc logs -f bc/<build-name>

# 2. View build status
oc describe bc/<build-name>

# 3. Check build events
oc get events | grep -i build

# 4. Retry build
oc start-build <build-name>
```

### Cannot Access Application
```bash
# 1. Check pod is running
oc get pods -l app=myapp

# 2. Check service
oc get svc myapp
oc describe svc myapp

# 3. Check endpoints
oc get endpoints myapp

# 4. Check route
oc get route myapp
oc describe route myapp

# 5. Test directly (bypass route)
oc port-forward svc/myapp 8080:8080
curl localhost:8080
```

### Permission Issues
```bash
# Check Security Context Constraints
oc describe pod <pod-name> | grep scc

# Grant SCC permissions
oc adm policy add-scc-to-user anyuid -z default
```

## 📊 Quick Reference Table

| Task | Command |
|------|---------|
| **Login** | `oc login <server> --token=<token>` |
| **Create Project** | `oc new-project <name>` |
| **Deploy App** | `oc new-app <image>` |
| **Scale** | `oc scale deployment/<name> --replicas=N` |
| **Expose** | `oc expose svc/<name>` |
| **Logs** | `oc logs <pod>` |
| **Shell** | `oc rsh <pod>` |
| **Status** | `oc status` |
| **Delete** | `oc delete all -l app=<name>` |
| **Rollback** | `oc rollout undo deployment/<name>` |

## 📚 Additional Resources

- **Main Guide**: [openshift-study/README.md](README.md)
- **Official Docs**: https://docs.openshift.com/
- **Learning Portal**: https://learn.openshift.com/
- **Project README**: [../README.md](../README.md)

## 🎓 Next Steps

1. Complete all labs in `openshift-study/labs/`
2. Read the comprehensive guide in `openshift-study/README.md`
3. Deploy your application to OpenShift
4. Set up CI/CD integration
5. Configure monitoring and alerts
6. Implement auto-scaling
7. Apply security best practices

---

**Questions?** Open an issue or check the [complete documentation](README.md).
