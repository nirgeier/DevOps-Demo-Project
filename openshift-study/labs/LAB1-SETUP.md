# Lab 1: OpenShift CLI Setup & Authentication

## 📚 Overview

This lab guides you through installing, configuring, and authenticating the OpenShift CLI (`oc`). You'll learn how to connect to an OpenShift cluster and prepare your environment for container platform management.

## 🎯 Learning Objectives

- ✅ Install OpenShift CLI (`oc`)
- ✅ Authenticate with OpenShift cluster
- ✅ Configure CLI settings
- ✅ Verify cluster connectivity
- ✅ Enable shell completion
- ✅ Understand oc command structure

## 🔧 Prerequisites

- macOS, Linux, or Windows with WSL
- Terminal/shell access
- Access to an OpenShift cluster (or CodeReady Containers for local testing)
- Network access to cluster API endpoint

## 📋 Installation

### macOS

```bash
# Using Homebrew
brew install openshift-cli

# Or download directly
curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-mac.tar.gz
tar xvzf openshift-client-mac.tar.gz
sudo mv oc kubectl /usr/local/bin/
```

### Linux

```bash
# Download latest
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz

# Extract
tar xvzf openshift-client-linux.tar.gz

# Move to PATH
sudo mv oc kubectl /usr/local/bin/

# Verify
oc version --client
```

### Windows

```powershell
# Using Chocolatey
choco install openshift-cli

# Or download from: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/
```

## 🔐 Authentication

### Method 1: Web Console Login (Recommended)

1. **Open OpenShift Web Console**
2. **Click your username** (top right)
3. **Select "Copy login command"**
4. **Click "Display Token"**
5. **Copy the `oc login` command**
6. **Paste in terminal:**

```bash
oc login --token=sha256~xxxxx --server=https://api.cluster.example.com:6443
```

### Method 2: Username/Password

```bash
oc login https://api.cluster.example.com:6443 -u username -p password
```

### Method 3: Service Account Token

```bash
oc login --token=<service-account-token> --server=<api-url>
```

## ✅ Verify Authentication

```bash
# Check current user
oc whoami

# Check server
oc whoami --show-server

# Check context
oc whoami --show-context

# Full authentication status
oc whoami --show-console
```

**Expected Output:**
```
developer
https://api.cluster.example.com:6443
default/api-cluster-example-com:6443/developer
```

## ⚙️ Configuration

### Set Default Editor

```bash
# Set editor
export KUBE_EDITOR=vim
# Or
export KUBE_EDITOR=nano
export KUBE_EDITOR="code --wait"
```

### Shell Completion

**Zsh:**
```bash
# Generate completion
mkdir -p ~/.zsh/completion
oc completion zsh > ~/.zsh/completion/_oc

# Add to ~/.zshrc
echo 'fpath=(~/.zsh/completion $fpath)' >> ~/.zshrc
echo 'autoload -Uz compinit && compinit' >> ~/.zshrc

# Reload
source ~/.zshrc
```

**Bash:**
```bash
# Install completion
oc completion bash | sudo tee /etc/bash_completion.d/oc > /dev/null

# Reload
source ~/.bashrc
```

## 📊 Essential Commands

### Cluster Information

```bash
# Cluster version
oc version

# Cluster info
oc cluster-info

# API resources
oc api-resources

# Get nodes (if you have permissions)
oc get nodes
```

### Project Management

```bash
# List projects
oc projects

# Current project
oc project

# Switch project
oc project my-project

# Create project
oc new-project demo-project
```

### Get Help

```bash
# General help
oc --help

# Command help
oc get --help
oc create --help

# Explain resources
oc explain pod
oc explain deployment.spec
```

## 🔍 Configuration Files

OpenShift CLI stores configuration in:

- **Config:** `~/.kube/config`
- **Cache:** `~/.kube/cache/`

View configuration:

```bash
# View full config
oc config view

# Current context
oc config current-context

# All contexts
oc config get-contexts

# Switch context
oc config use-context <context-name>
```

## 💡 Pro Tips

### 1. Aliases

```bash
# Add to ~/.zshrc or ~/.bashrc
alias k='oc'
alias kgp='oc get pods'
alias kgs='oc get svc'
alias kdp='oc describe pod'
alias kl='oc logs'
```

### 2. Quick Resource Access

```bash
# Short names
oc get po      # pods
oc get svc     # services
oc get deploy  # deployments
oc get bc      # buildconfigs
oc get is      # imagestreams
oc get route   # routes
```

### 3. Multiple Clusters

```bash
# Add new cluster
oc login https://another-cluster.example.com:6443

# Switch between clusters
oc config get-contexts
oc config use-context <context-name>
```

## 🔍 Troubleshooting

### Issue: "oc: command not found"

**Solution:**
```bash
# Verify installation
which oc

# Check PATH
echo $PATH

# Reinstall if needed
```

### Issue: "Unable to connect to server"

**Solution:**
```bash
# Check server URL
oc whoami --show-server

# Test connectivity
curl -k https://api.cluster.example.com:6443/healthz

# Verify token hasn't expired
oc whoami
```

### Issue: "Forbidden" errors

**Solution:**
```bash
# Check permissions
oc auth can-i create pods

# View your role bindings
oc describe rolebinding

# Request access from cluster admin
```

## ✅ Validation Checklist

Before proceeding:

- [ ] `oc version` shows client and server versions
- [ ] `oc whoami` displays your username
- [ ] `oc projects` lists accessible projects
- [ ] `oc get all` works in a project
- [ ] Shell completion is enabled
- [ ] Configuration is saved

## 🎓 Key Commands Reference

| Command | Description |
|---------|-------------|
| `oc login <url>` | Authenticate to cluster |
| `oc whoami` | Show current user |
| `oc version` | Show version info |
| `oc projects` | List projects |
| `oc project <name>` | Switch project |
| `oc status` | Project status |
| `oc cluster-info` | Cluster information |
| `oc config view` | View configuration |

## 📚 Additional Resources

- [OpenShift CLI Tools](https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html)
- [OC Command Reference](https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/developer-cli-commands.html)
- [Authentication Methods](https://docs.openshift.com/container-platform/latest/authentication/understanding-authentication.html)

## 🚀 Next Steps

**[Lab 2: Project & Application Management →](./LAB2-PROJECTS.md)**

Learn to create projects and deploy your first applications.

---

**Lab Duration:** 20-30 minutes  
**Difficulty:** Beginner  
**Prerequisites:** Terminal access, OpenShift cluster
