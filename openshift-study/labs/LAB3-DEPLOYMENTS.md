# Lab 3: Deployment & Pod Management

## 📚 Overview

Master pod lifecycle management, deployment scaling, resource management, and troubleshooting in OpenShift.

## 🎯 Learning Objectives

- ✅ Manage pod lifecycle
- ✅ Execute commands in containers
- ✅ Scale deployments
- ✅ Manage rollouts and rollbacks
- ✅ Set resource limits
- ✅ Debug pods effectively

## 📋 Key Commands

### Pod Management

```bash
# List pods
oc get pods
oc get pods -o wide
oc get pods --show-labels
oc get pods -l app=myapp

# Describe pod
oc describe pod <pod-name>

# Pod status
oc get pod <pod-name> -o jsonpath='{.status.phase}'
```

### Execute in Pods

```bash
# Run command
oc exec <pod> -- ls /app

# Interactive shell
oc rsh <pod>

# Copy files
oc cp <pod>:/path/file ./local-file
oc cp ./local-file <pod>:/path/
```

### Deployment Scaling

```bash
# Scale replicas
oc scale deployment/myapp --replicas=3

# View deployment
oc get deployment myapp

# Horizontal Pod Autoscaler
oc autoscale deployment myapp --min=2 --max=10 --cpu-percent=80
```

### Rollout Management

```bash
# Rollout status
oc rollout status deployment/myapp

# Rollout history
oc rollout history deployment/myapp

# Rollback
oc rollout undo deployment/myapp

# Rollback to specific revision
oc rollout undo deployment/myapp --to-revision=2

# Pause/Resume rollout
oc rollout pause deployment/myapp
oc rollout resume deployment/myapp
```

### Resource Management

```bash
# Set resource limits
oc set resources deployment myapp \
    --limits=cpu=500m,memory=512Mi \
    --requests=cpu=200m,memory=256Mi

# View resource usage (requires metrics)
oc adm top pods
oc adm top nodes
```

### Debug Pods

```bash
# Create debug pod
oc debug pod/<pod-name>

# Debug with different image
oc debug pod/<pod-name> --image=busybox

# Debug as root
oc debug pod/<pod-name> --as-root

# Debug node
oc debug node/<node-name>
```

## 💡 Practical Examples

### Example 1: Rolling Update

```bash
#!/bin/bash
# Update application image

APP=myapp
NEW_IMAGE=myapp:v2

echo "Starting rolling update..."
oc set image deployment/$APP $APP=$NEW_IMAGE

echo "Watching rollout..."
oc rollout status deployment/$APP

echo "✅ Update complete!"
oc get pods -l app=$APP
```

### Example 2: Resource Monitoring

```bash
#!/bin/bash
# Monitor pod resources

while true; do
    clear
    echo "Pod Resource Usage - $(date)"
    echo "================================"
    oc adm top pods --sort-by=memory
    echo
    echo "Deployment Status:"
    oc get deployments
    sleep 10
done
```

### Example 3: Health Check Script

```bash
#!/bin/bash
# Check pod health

for pod in $(oc get pods -o name); do
    NAME=$(echo $pod | cut -d'/' -f2)
    STATUS=$(oc get $pod -o jsonpath='{.status.phase}')
    READY=$(oc get $pod -o jsonpath='{.status.containerStatuses[0].ready}')
    
    echo "Pod: $NAME"
    echo "  Status: $STATUS"
    echo "  Ready: $READY"
    echo
done
```

## 🎓 Complete Example

```bash
#!/bin/bash
# Complete deployment lifecycle

PROJECT=myapp-demo
APP=nginx-app

# Create project
oc new-project $PROJECT

# Deploy nginx
oc new-app nginx:latest --name=$APP

# Wait for deployment
oc rollout status deployment/$APP

# Scale to 3 replicas
oc scale deployment/$APP --replicas=3

# Set resource limits
oc set resources deployment/$APP \
    --limits=cpu=200m,memory=256Mi \
    --requests=cpu=100m,memory=128Mi

# Update environment
oc set env deployment/$APP TEST_VAR=production

# Watch rollout
oc rollout status deployment/$APP

# Verify
oc get pods -l app=$APP
```

## ✅ Lab Exercise

1. Deploy application
2. Scale to 3 replicas
3. Execute commands in pod
4. Set resource limits
5. Perform rolling update
6. Rollback deployment

## 📚 Resources

- [Pod Configuration](https://docs.openshift.com/container-platform/latest/nodes/pods/nodes-pods-configuring.html)
- [Deployments](https://docs.openshift.com/container-platform/latest/applications/deployments/what-deployments-are.html)

## 🚀 Next Steps

**[Lab 4: Networking & Routes →](./LAB4-NETWORKING.md)**

---

**Lab Duration:** 45-60 minutes  
**Difficulty:** Intermediate
