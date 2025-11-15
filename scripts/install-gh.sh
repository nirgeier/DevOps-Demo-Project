#!/bin/bash
# Install GitHub CLI (gh)
# Supports macOS, Linux (Debian/Ubuntu), and detects OS automatically

set -e

echo "🔧 GitHub CLI Installation Script"
echo "=================================="
echo

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    echo "❌ Unsupported operating system: $OSTYPE"
    exit 1
fi

echo "Detected OS: $OS"
echo

# Check if already installed
if command -v gh &> /dev/null; then
    CURRENT_VERSION=$(gh --version | head -1)
    echo "✅ GitHub CLI is already installed: $CURRENT_VERSION"
    echo
    read -p "Reinstall/upgrade? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Install based on OS
case $OS in
    macos)
        echo "📦 Installing GitHub CLI via Homebrew..."
        if ! command -v brew &> /dev/null; then
            echo "❌ Homebrew is not installed!"
            echo "📥 Install Homebrew first: https://brew.sh"
            echo "   Or run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
        brew install gh
        ;;
        
    linux)
        echo "📦 Installing GitHub CLI for Linux..."
        
        # Check for Debian/Ubuntu
        if command -v apt &> /dev/null; then
            echo "Installing via apt..."
            type -p curl >/dev/null || sudo apt install curl -y
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update
            sudo apt install gh -y
        # Check for Fedora/RHEL
        elif command -v dnf &> /dev/null; then
            echo "Installing via dnf..."
            sudo dnf install 'dnf-command(config-manager)' -y
            sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
            sudo dnf install gh -y
        # Check for Arch
        elif command -v pacman &> /dev/null; then
            echo "Installing via pacman..."
            sudo pacman -S github-cli
        else
            echo "❌ Unsupported Linux distribution"
            echo "📥 Visit https://github.com/cli/cli#installation for manual installation"
            exit 1
        fi
        ;;
esac

echo
echo "✅ Installation complete!"
echo

# Verify installation
if command -v gh &> /dev/null; then
    VERSION=$(gh --version | head -1)
    echo "Installed version: $VERSION"
    echo
    
    # Setup instructions
    echo "📝 Next Steps:"
    echo "=============="
    echo
    echo "1. Authenticate with GitHub:"
    echo "   gh auth login"
    echo
    echo "2. Set up shell completion:"
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo "   # For Zsh, add to ~/.zshrc:"
        echo "   eval \"\$(gh completion -s zsh)\""
    elif [[ "$SHELL" == *"bash"* ]]; then
        echo "   # For Bash, add to ~/.bashrc:"
        echo "   eval \"\$(gh completion -s bash)\""
    fi
    echo
    echo "3. Configure defaults:"
    echo "   gh config set editor vim"
    echo "   gh config set git_protocol https"
    echo
    echo "4. Test your installation:"
    echo "   gh --help"
    echo "   gh repo list"
    echo
    echo "📚 For more information:"
    echo "   https://cli.github.com/manual/"
    echo
    echo "🎓 Start with the labs:"
    echo "   cd gh-study/labs"
    echo "   ./lab1-setup.sh"
    echo
    
    echo "✨ GitHub CLI is ready to use!"
else
    echo "❌ Installation failed. GitHub CLI command not found."
    exit 1
fi
