#!/bin/bash
# Lab 1: GitHub CLI Setup & Authentication
# This script guides you through initial setup

set -e

echo "🎓 Lab 1: GitHub CLI Setup & Authentication"
echo "==========================================="
echo

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI is not installed!"
    echo "📦 Installing via Homebrew..."
    brew install gh
else
    echo "✅ GitHub CLI is already installed"
    gh --version
fi

echo
echo "🔐 Step 1: Authentication"
echo "========================="
echo "Run: gh auth login"
echo
echo "Choose the following options:"
echo "  1. GitHub.com"
echo "  2. HTTPS"
echo "  3. Login with a web browser"
echo "  4. Press Enter to open browser"
echo
read -p "Press Enter to continue with authentication..."
gh auth login

echo
echo "✅ Step 2: Verify Authentication"
echo "================================="
gh auth status

echo
echo "👤 Your GitHub user:"
gh api user --jq '.login'

echo
echo "📊 Step 3: Configure Defaults"
echo "=============================="

# Set default editor
echo "Setting default editor to vim..."
gh config set editor vim

# Set git protocol
echo "Setting git protocol to https..."
gh config set git_protocol https

# Show all config
echo
echo "Current configuration:"
gh config list

echo
echo "🔧 Step 4: Enable Shell Completion"
echo "==================================="

# Check shell type
if [ -n "$ZSH_VERSION" ]; then
    echo "Detected: Zsh"
    mkdir -p ~/.zsh/completion
    gh completion -s zsh > ~/.zsh/completion/_gh
    echo "Add this to your ~/.zshrc:"
    echo "  fpath=(~/.zsh/completion \$fpath)"
    echo "  autoload -Uz compinit && compinit"
elif [ -n "$BASH_VERSION" ]; then
    echo "Detected: Bash"
    gh completion -s bash > /usr/local/etc/bash_completion.d/gh
    echo "Completion installed!"
fi

echo
echo "✅ Step 5: Test Your Setup"
echo "=========================="
echo
echo "Try these commands:"
echo "  gh repo list              # List your repositories"
echo "  gh issue list             # List issues (in a repo)"
echo "  gh pr list                # List pull requests"
echo "  gh --help                 # Show help"
echo
echo "🎉 Lab 1 Complete!"
echo "=================="
echo
echo "Next: Run lab2-repository.sh to learn repository management"
