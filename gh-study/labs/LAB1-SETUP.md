# Lab 1: GitHub CLI Setup & Authentication

## 📚 Overview

This lab guides you through installing, configuring, and authenticating the GitHub CLI (`gh`). You'll learn how to set up your development environment for seamless GitHub integration from the command line.

## 🎯 Learning Objectives

By the end of this lab, you will be able to:

- ✅ Install the GitHub CLI on your system
- ✅ Authenticate with GitHub using web browser
- ✅ Configure default settings for optimal workflow
- ✅ Enable shell completion for faster command entry
- ✅ Verify your setup and test basic commands

## 🔧 Prerequisites

- macOS, Linux, or Windows with WSL
- A GitHub account
- Terminal/shell access
- Homebrew (for macOS) or appropriate package manager

## 📋 Lab Steps

### Step 1: Check Installation

First, verify if GitHub CLI is already installed:

```bash
gh --version
```

**Expected Output:**
```
gh version 2.x.x (2024-xx-xx)
```

### Step 2: Install GitHub CLI

If not installed, use your package manager:

**macOS:**
```bash
brew install gh
```

**Linux (Debian/Ubuntu):**
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

**Windows:**
```powershell
winget install --id GitHub.cli
```

### Step 3: Authentication

Authenticate with GitHub using the interactive login:

```bash
gh auth login
```

**Follow these prompts:**

1. **What account do you want to log into?**
   - Select: `GitHub.com`

2. **What is your preferred protocol for Git operations?**
   - Select: `HTTPS` (recommended)

3. **Authenticate GitHub CLI**
   - Select: `Login with a web browser`

4. **Copy the one-time code** and press Enter
   - The browser will open automatically
   - Paste the code when prompted
   - Click "Authorize GitHub CLI"

### Step 4: Verify Authentication

Confirm your authentication status:

```bash
gh auth status
```

**Expected Output:**
```
github.com
  ✓ Logged in to github.com as YOUR_USERNAME (oauth_token)
  ✓ Git operations for github.com configured to use https protocol.
  ✓ Token: *******************
```

Check your user information:

```bash
gh api user --jq '.login'
```

This should display your GitHub username.

### Step 5: Configure Defaults

Set up your preferences for a better experience:

```bash
# Set default editor (choose one)
gh config set editor vim
gh config set editor "code --wait"  # VS Code
gh config set editor nano

# Set git protocol
gh config set git_protocol https

# Set preferred browser (optional)
gh config set browser firefox
```

View all configuration:

```bash
gh config list
```

**Expected Output:**
```
git_protocol=https
editor=vim
prompt=enabled
```

### Step 6: Enable Shell Completion

Shell completion makes command entry faster and prevents typos.

**For Zsh:**

```bash
# Create completion directory
mkdir -p ~/.zsh/completion

# Generate completion script
gh completion -s zsh > ~/.zsh/completion/_gh

# Add to ~/.zshrc
echo 'fpath=(~/.zsh/completion $fpath)' >> ~/.zshrc
echo 'autoload -Uz compinit && compinit' >> ~/.zshrc

# Reload shell
source ~/.zshrc
```

**For Bash:**

```bash
# macOS (with Homebrew)
gh completion -s bash > /usr/local/etc/bash_completion.d/gh

# Linux
gh completion -s bash | sudo tee /usr/share/bash-completion/completions/gh > /dev/null

# Reload shell
source ~/.bashrc
```

**For Fish:**

```bash
gh completion -s fish > ~/.config/fish/completions/gh.fish
```

### Step 7: Test Your Setup

Try these basic commands to verify everything works:

```bash
# View your repositories
gh repo list --limit 5

# View your authentication status
gh auth status

# Get help
gh --help

# View API rate limits
gh api rate_limit
```

## 🎓 Key Commands Reference

| Command | Description |
|---------|-------------|
| `gh auth login` | Authenticate with GitHub |
| `gh auth status` | Check authentication status |
| `gh auth logout` | Log out from GitHub |
| `gh auth refresh` | Refresh authentication token |
| `gh config set <key> <value>` | Set configuration value |
| `gh config list` | List all configuration |
| `gh completion -s <shell>` | Generate completion script |
| `gh --version` | Show version information |
| `gh --help` | Display help information |

## 💡 Pro Tips

### 1. Multiple Accounts

You can authenticate with multiple GitHub accounts:

```bash
# Add another account
gh auth login --hostname github.com --web

# Switch between accounts
gh auth switch
```

### 2. SSH vs HTTPS

While HTTPS is recommended for beginners, SSH can be more convenient:

```bash
# Switch to SSH
gh config set git_protocol ssh

# Ensure SSH keys are configured
gh ssh-key list
gh ssh-key add ~/.ssh/id_ed25519.pub
```

### 3. Token Scopes

Check your token permissions:

```bash
gh auth status --show-token
```

If you need additional scopes, refresh with:

```bash
gh auth refresh -s read:org,repo,workflow
```

### 4. Environment Variables

You can also configure via environment variables:

```bash
export GH_EDITOR=vim
export GH_PAGER=less
export GH_BROWSER=firefox
```

## 🔍 Troubleshooting

### Issue: "gh: command not found"

**Solution:**
- Ensure the installation completed successfully
- Restart your terminal
- Check PATH: `echo $PATH | grep gh`
- Reinstall if necessary

### Issue: "authentication failed"

**Solution:**
```bash
# Clear authentication
gh auth logout

# Try again with token
gh auth login --with-token < token.txt

# Or use device flow
gh auth login --web
```

### Issue: "API rate limit exceeded"

**Solution:**
- Authenticate (increases rate limit from 60 to 5000/hour)
- Check remaining requests: `gh api rate_limit`
- Wait for rate limit reset

### Issue: Completion not working

**Solution:**
```bash
# Verify completion installed
ls -la ~/.zsh/completion/_gh  # Zsh
ls -la /usr/local/etc/bash_completion.d/gh  # Bash

# Reload shell configuration
source ~/.zshrc  # Zsh
source ~/.bashrc  # Bash
```

## 📊 Configuration File Locations

- **Config:** `~/.config/gh/config.yml`
- **Hosts:** `~/.config/gh/hosts.yml`
- **Cache:** `~/.cache/gh/`

View configuration manually:

```bash
cat ~/.config/gh/config.yml
```

## ✅ Validation Checklist

Before moving to the next lab, ensure:

- [ ] GitHub CLI is installed and shows version
- [ ] Successfully authenticated via web browser
- [ ] `gh auth status` shows active login
- [ ] Configuration is set (editor, protocol)
- [ ] Shell completion is enabled
- [ ] Test commands work (`gh repo list`)
- [ ] Understanding of basic commands

## 🎉 Success Indicators

You've successfully completed Lab 1 when:

1. ✅ `gh --version` displays version information
2. ✅ `gh auth status` shows you're logged in
3. ✅ `gh repo list` displays your repositories
4. ✅ Tab completion works in your shell
5. ✅ You can access `gh --help` documentation

## 📚 Additional Resources

- [GitHub CLI Manual](https://cli.github.com/manual/)
- [GitHub CLI Repository](https://github.com/cli/cli)
- [Authentication Documentation](https://cli.github.com/manual/gh_auth_login)
- [Configuration Guide](https://cli.github.com/manual/gh_config)

## 🚀 Next Steps

Now that you have GitHub CLI set up, proceed to:

**[Lab 2: Repository Management →](./LAB2-REPOSITORY.md)**

Learn to create, clone, and manage repositories from the command line.

---

**Lab Duration:** 15-20 minutes  
**Difficulty:** Beginner  
**Prerequisites:** Terminal access, GitHub account
