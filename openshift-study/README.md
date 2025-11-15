# OpenShift CLI Study Guide

Complete guide to mastering OpenShift CLI for enterprise container orchestration.

## Overview

This study guide provides hands-on labs and comprehensive documentation for learning OpenShift CLI (`oc`) in the context of enterprise Kubernetes deployments.

## Labs

The labs directory contains 6 hands-on exercises:

1. **Lab 1: Setup & Authentication** (`lab1-setup.sh`)
   - Install and configure OpenShift CLI
   - Authenticate with clusters
   - Basic navigation

2. **Lab 2: Project & Application Management** (`lab2-projects.sh`)
   - Create and manage projects
   - Deploy applications
   - Resource management

3. **Lab 3: Deployment & Pod Management** (`lab3-deployments.sh`)
   - Create deployments
   - Scale applications
   - Rolling updates

4. **Lab 4: Service & Route Configuration** (`lab4-networking.sh`)
   - Configure services
   - Expose applications
   - Route management

5. **Lab 5: Build & ImageStream Operations** (`lab5-builds.sh`)
   - Source-to-Image (S2I) builds
   - ImageStream management
   - Build configurations

6. **Lab 6: Monitoring & Troubleshooting** (`lab6-monitoring.sh`)
   - View logs and events
   - Debug pods
   - Performance monitoring

## Running Labs

```bash
cd openshift-study/labs
./lab1-setup.sh       # Start with lab 1
./lab2-projects.sh    # Then lab 2, etc.
```

## Quick Reference

### Authentication
```bash
oc login <cluster-url>  # Login to cluster
oc whoami               # Show current user
oc logout               # Logout
```

### Projects
```bash
oc new-project <name>   # Create project
oc projects             # List projects
oc project <name>       # Switch project
```

### Applications
```bash
oc new-app <image>      # Deploy from image
oc new-app python~<url> # Deploy from source
oc get all              # View all resources
```

### Routes
```bash
oc expose svc/<name>    # Create route
oc get routes           # List routes
```

## Documentation

For detailed command documentation, run:
```bash
oc --help
oc <command> --help
```

Or visit: https://docs.openshift.com/

## Integration with Project

This project uses OpenShift CLI in several automation scripts:
- `scripts/openshift-doctor.sh` - Comprehensive diagnostics
- `scripts/install-openshift.sh` - Installation automation

## OpenShift vs Kubernetes

OpenShift extends Kubernetes with:
- **Projects** - Multi-tenant isolation
- **Routes** - Simplified external access
- **S2I** - Build from source code
- **Integrated Registry** - Built-in container registry
- **Enhanced Security** - Security Context Constraints
