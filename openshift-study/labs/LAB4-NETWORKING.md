# Lab 4: Service & Route Configuration

## 📚 Overview

Master OpenShift networking, including services, routes, and external access configuration for your applications.

## 🎯 Learning Objectives

- ✅ Understand OpenShift networking
- ✅ Create and manage services
- ✅ Expose applications with routes
- ✅ Configure TLS/SSL termination
- ✅ Manage load balancing
- ✅ Use port forwarding

## 📋 Key Commands

### Service Management

```bash
# List services
oc get services
oc get svc

# Describe service
oc describe svc myapp

# View endpoints
oc get endpoints myapp

# Create service manually
oc create service clusterip myapp --tcp=8080:8080
```

### Route Management

```bash
# Expose service
oc expose svc/myapp

# List routes
oc get routes

# Get route URL
oc get route myapp -o jsonpath='{.spec.host}'

# Delete route
oc delete route myapp
```

### Secure Routes (TLS)

```bash
# Edge termination (TLS terminates at router)
oc create route edge myapp-secure \
    --service=myapp \
    --hostname=myapp.example.com

# Passthrough termination (TLS passes through to pod)
oc create route passthrough myapp-passthrough \
    --service=myapp \
    --hostname=secure.example.com

# Re-encrypt termination (TLS terminates and re-encrypts)
oc create route reencrypt myapp-reencrypt \
    --service=myapp \
    --dest-ca-cert=ca.crt
```

### Load Balancing

```bash
# Create route with weight-based routing
oc set route-backends myapp-route \
    myapp-v1=80 \
    myapp-v2=20

# View backend weights
oc get route myapp-route -o yaml | grep -A5 backends
```

### Port Forwarding

```bash
# Forward local port to pod
oc port-forward pod/myapp-abc123 8080:8080

# Forward to service
oc port-forward svc/myapp 8080:8080

# Background process
oc port-forward svc/myapp 8080:8080 &
```

## 💡 Practical Examples

### Example 1: Complete Service Exposure

```bash
#!/bin/bash
# expose-app.sh

APP=myapp
HOSTNAME="myapp.apps.cluster.example.com"

# Create service if not exists
if ! oc get svc $APP > /dev/null 2>&1; then
    oc expose deployment $APP --port=8080
fi

# Create route
oc create route edge $APP-secure \
    --service=$APP \
    --hostname=$HOSTNAME \
    --insecure-policy=Redirect

# Get URL
URL=$(oc get route $APP-secure -o jsonpath='{.spec.host}')
echo "✅ Application available at: https://$URL"

# Test
curl -k https://$URL
```

### Example 2: Blue-Green Deployment

```bash
#!/bin/bash
# blue-green-deployment.sh

# Deploy blue version
oc new-app nginx:1.20 --name=app-blue
oc expose svc/app-blue

# Deploy green version
oc new-app nginx:1.21 --name=app-green

# Create route pointing to blue
oc expose svc/app-blue --name=app-route

# Switch to green (zero downtime)
oc patch route app-route -p '{"spec":{"to":{"name":"app-green"}}}'

# Verify
oc get route app-route
```

### Example 3: A/B Testing Setup

```bash
#!/bin/bash
# ab-testing-setup.sh

# Deploy version A and B
oc new-app myapp:v1 --name=myapp-v1
oc new-app myapp:v2 --name=myapp-v2

# Expose services
oc expose svc/myapp-v1
oc expose svc/myapp-v2

# Create weighted route (80% v1, 20% v2)
oc create route edge myapp-ab --service=myapp-v1
oc set route-backends myapp-ab myapp-v1=80 myapp-v2=20

# Verify traffic split
oc get route myapp-ab -o yaml
```

### Example 4: Network Policy

```bash
# Create network policy to restrict traffic
cat <<EOF | oc apply -f -
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: allow-frontend-only
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
EOF

# View network policies
oc get networkpolicy
oc describe networkpolicy allow-frontend-only
```

## 🎓 Complete Networking Example

```bash
#!/bin/bash
# complete-networking-setup.sh

PROJECT=networking-demo
APP=web-app

# Create project
oc new-project $PROJECT

# Deploy application
oc new-app nginx:latest --name=$APP

# Wait for deployment
oc rollout status deployment/$APP

# Expose service
oc expose svc/$APP

# Get HTTP route
HTTP_ROUTE=$(oc get route $APP -o jsonpath='{.spec.host}')
echo "HTTP URL: http://$HTTP_ROUTE"

# Create secure route
oc create route edge $APP-secure \
    --service=$APP \
    --insecure-policy=Redirect

# Get HTTPS route
HTTPS_ROUTE=$(oc get route $APP-secure -o jsonpath='{.spec.host}')
echo "HTTPS URL: https://$HTTPS_ROUTE"

# Test endpoints
echo "Testing HTTP (should redirect)..."
curl -I http://$HTTP_ROUTE

echo "Testing HTTPS..."
curl -k -I https://$HTTPS_ROUTE
```

## 🎓 Service Types

### ClusterIP (Default)
```bash
# Internal cluster access only
oc create service clusterip myapp --tcp=8080:8080
```

### NodePort
```bash
# Expose on each node's IP at a static port
oc create service nodeport myapp --tcp=8080:8080
```

### LoadBalancer
```bash
# External load balancer (cloud providers)
oc create service loadbalancer myapp --tcp=8080:8080
```

### ExternalName
```bash
# Map service to external DNS name
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Service
metadata:
  name: external-db
spec:
  type: ExternalName
  externalName: database.example.com
EOF
```

## ✅ Lab Exercise

1. Deploy nginx application
2. Create internal service
3. Expose with HTTP route
4. Create secure HTTPS route
5. Test both endpoints
6. Configure port forwarding
7. Cleanup resources

```bash
# Quick exercise
oc new-project lab4-exercise
oc new-app nginx --name=webserver
oc expose svc/webserver
oc create route edge webserver-secure --service=webserver
oc get routes
curl http://$(oc get route webserver -o jsonpath='{.spec.host}')
oc delete project lab4-exercise
```

## 📚 Additional Resources

- [Networking](https://docs.openshift.com/container-platform/latest/networking/understanding-networking.html)
- [Routes](https://docs.openshift.com/container-platform/latest/networking/routes/route-configuration.html)
- [Network Policy](https://docs.openshift.com/container-platform/latest/networking/network_policy/about-network-policy.html)

## 🚀 Next Steps

**[Lab 5: Build & ImageStream Operations →](./LAB5-BUILDS.md)**

---

**Lab Duration:** 40-50 minutes  
**Difficulty:** Intermediate
