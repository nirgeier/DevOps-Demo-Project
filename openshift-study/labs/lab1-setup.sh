#!/bin/bash
# Lab 1: OpenShift CLI Setup & Authentication
# This script guides you through initial setup and cluster connection

set -e

echo "🎓 Lab 1: OpenShift CLI Setup & Authentication"
echo "==============================================="
echo

# Progress tracking
TOTAL_STEPS=6
CURRENT_STEP=0

progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📍 Step $CURRENT_STEP of $TOTAL_STEPS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
}

# Check if oc is installed
progress
echo "✅ Step 1: Check OpenShift CLI Installation"
echo "============================================"

if ! command -v oc &> /dev/null; then
    echo "❌ OpenShift CLI is not installed!"
    echo
    echo "📦 Installing via Homebrew (macOS)..."
    if command -v brew &> /dev/null; then
        brew install openshift-cli
    else
        echo "Please install OpenShift CLI manually:"
        echo "  macOS: brew install openshift-cli"
        echo "  Linux: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/"
        exit 1
    fi
else
    echo "✅ OpenShift CLI is already installed"
    oc version --client
fi

echo
read -p "Press Enter to continue..."

progress
echo "🔐 Step 2: Authentication"
echo "========================="
echo
echo "To authenticate with OpenShift:"
echo "  1. Open your OpenShift web console"
echo "  2. Click your username (top right corner)"
echo "  3. Click 'Copy login command'"
echo "  4. Click 'Display Token'"
echo "  5. Copy the 'oc login' command"
echo
echo "Example command format:"
echo "  oc login --token=sha256~xxxxx --server=https://api.cluster.example.com:6443"
echo
read -p "Do you have access to an OpenShift cluster? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo "Great! Please paste your login command below:"
    echo "(or press Ctrl+C to skip and login manually later)"
    echo
    read -p "oc login command: " LOGIN_CMD
    
    if [ -n "$LOGIN_CMD" ]; then
        eval $LOGIN_CMD
        echo
        echo "✅ Login successful!"
    fi
else
    echo
    echo "ℹ️  No problem! You can run this lab later when you have cluster access."
    echo "   For now, we'll show you what the commands look like."
    echo
fi

echo
read -p "Press Enter to continue..."

progress
echo "✅ Step 3: Verify Authentication"
echo "================================="

if oc whoami &> /dev/null; then
    echo "Current user:"
    oc whoami
    echo
    echo "Current server:"
    oc whoami --show-server
    echo
    echo "Current context:"
    oc whoami --show-context
else
    echo "ℹ️  Not currently logged in to a cluster."
    echo "   Example output when logged in:"
    echo "     User: developer"
    echo "     Server: https://api.cluster.example.com:6443"
    echo "     Context: default/api-cluster-example-com:6443/developer"
fi

echo
read -p "Press Enter to continue..."

progress
echo "📊 Step 4: Explore Cluster (if connected)"
echo "=========================================="

if oc whoami &> /dev/null; then
    echo "Available projects:"
    oc projects || echo "No projects available"
    
    echo
    echo "Current project:"
    oc project || echo "No project selected"
    
    echo
    echo "Cluster info:"
    oc cluster-info || echo "Unable to get cluster info"
else
    echo "ℹ️  Not connected to a cluster."
    echo
    echo "   When connected, you can use:"
    echo "     oc projects           # List all projects"
    echo "     oc project            # Show current project"
    echo "     oc cluster-info       # Cluster information"
fi

echo
read -p "Press Enter to continue..."

progress
echo "🔧 Step 5: Configure CLI"
echo "========================"
echo
echo "Setting up environment variables..."

# Set default editor
export KUBE_EDITOR="${EDITOR:-vim}"
echo "Default editor: $KUBE_EDITOR"

# Enable completion
echo
echo "Enable shell completion:"
if [ -n "$ZSH_VERSION" ]; then
    echo "Detected: Zsh"
    echo
    echo "Add this to your ~/.zshrc:"
    echo "  source <(oc completion zsh)"
    echo "  compdef _oc oc"
    echo
    read -p "Install completion now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p ~/.zsh/completion
        oc completion zsh > ~/.zsh/completion/_oc 2>/dev/null || echo "Completion setup (will work after login)"
        echo "✅ Completion files created"
        echo "   Add to ~/.zshrc: fpath=(~/.zsh/completion \$fpath)"
        echo "   Then run: compinit"
    fi
elif [ -n "$BASH_VERSION" ]; then
    echo "Detected: Bash"
    echo
    echo "Add this to your ~/.bashrc:"
    echo "  source <(oc completion bash)"
    echo
    read -p "Install completion now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -d /usr/local/etc/bash_completion.d ]; then
            oc completion bash > /usr/local/etc/bash_completion.d/oc 2>/dev/null || echo "Completion setup (will work after login)"
            echo "✅ Completion installed!"
        else
            echo "Install manually: oc completion bash > /usr/local/etc/bash_completion.d/oc"
        fi
    fi
fi

echo
read -p "Press Enter to continue..."

progress
echo "🎓 Step 6: Test Basic Commands"
echo "==============================="
echo
echo "Here are some essential commands to try:"
echo

cat << 'EOF'
# Get help
oc --help
oc <command> --help

# Check version
oc version

# View current context
oc whoami
oc whoami --show-server
oc whoami --show-context

# List projects
oc projects

# Switch project
oc project <project-name>

# View project status
oc status

# Get all resources
oc get all

# View configuration
oc config view
oc config current-context
oc config get-contexts
EOF

if oc whoami &> /dev/null; then
    echo
    echo "Let's try a few commands:"
    echo
    echo "Your projects:"
    oc projects 2>/dev/null || echo "  (No projects yet)"
    
    echo
    echo "Your authentication:"
    echo "  User: $(oc whoami)"
    echo "  Server: $(oc whoami --show-server)"
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Lab 1 Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "📝 Summary:"
echo "  ✅ OpenShift CLI installed"
if oc whoami &> /dev/null; then
    echo "  ✅ Authenticated to cluster"
    echo "  ✅ Verified connection"
else
    echo "  ⏳ Ready to authenticate when cluster available"
fi
echo "  ✅ Learned basic commands"
echo
echo "🎓 Key Commands Learned:"
echo "========================"
echo "  oc version                    # Check version"
echo "  oc login <server>             # Connect to cluster"
echo "  oc whoami                     # Current user"
echo "  oc projects                   # List projects"
echo "  oc project <name>             # Switch project"
echo "  oc status                     # Project status"
echo "  oc cluster-info               # Cluster information"
echo
echo "📚 Next Steps:"
echo "=============="
if oc whoami &> /dev/null; then
    echo "  ✅ You're connected! Ready for Lab 2"
    echo "  Run: ./lab2-projects.sh"
else
    echo "  1. Get access to an OpenShift cluster"
    echo "  2. Run: oc login --token=<token> --server=<server>"
    echo "  3. Then run: ./lab2-projects.sh"
fi
echo
echo "💡 Tip: Keep your login token secure and don't share it!"
echo
