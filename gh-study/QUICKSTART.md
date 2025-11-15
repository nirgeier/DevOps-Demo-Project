# GitHub CLI (gh) - Quick Start Guide

> **Fast-track guide to get started with GitHub CLI in this project**

## 📦 Installation

```bash
# Install GitHub CLI
./scripts/install-gh.sh

# Authenticate
gh auth login

# Verify setup
gh auth status
./scripts/doctor.sh gh
```

## 🎓 Learning Resources

### Interactive Labs
Complete hands-on labs in order:

```bash
cd gh-study/labs

./lab1-setup.sh          # Setup & Authentication
./lab2-repository.sh     # Repository Management
./lab3-issues.sh         # Issue Management
./lab4-pull-requests.sh  # Pull Request Workflows
./lab5-actions.sh        # GitHub Actions Management
./lab6-releases.sh       # Release Management
```

### Comprehensive Guide
📚 See [gh-study/README.md](README.md) for complete documentation including:
- All commands with examples
- Lab 7: Advanced Automation
- Lab 8: Extensions & Customization
- Real-world integration examples
- Best practices
- Troubleshooting guide
- Complete cheat sheet

## 🚀 Quick Start Scripts

### Create Pull Request
```bash
# From any feature branch
./scripts/gh-create-pr.sh

# Features:
# - Auto-detects PR type (feature/bugfix/hotfix)
# - Pre-filled PR template
# - Automatic labeling
# - Request reviewers
# - Monitor CI status
```

### Create Release
```bash
# Automated release workflow
./scripts/gh-release.sh 1.0.0

# This will:
# 1. Create release branch
# 2. Update versions in all files
# 3. Generate changelog from commits
# 4. Create PR to main
# 5. Enable auto-merge when approved
# 6. Tag and deploy automatically
```

### Helper Functions
```bash
# Source helper functions in your scripts
source scripts/gh-helpers.sh

# Available functions:
check_gh_auth                      # Verify authentication
create_devops_pr "title" "body"    # Create PR
check_ci_status                    # Check CI for current branch
wait_for_ci                        # Wait for CI to complete
create_release "1.0.0"             # Create release
list_open_prs                      # List all open PRs
pr_status 123                      # Check PR status
auto_merge_approved                # Auto-merge approved PRs
create_issue_from_error "title" "msg"  # Create issue
trigger_workflow "workflow.yml"    # Trigger workflow
get_latest_release                 # Get latest release tag
download_release_artifacts "v1.0.0"  # Download release
```

## 📋 Common Commands

### Repository Operations
```bash
gh repo view                    # View current repo
gh repo list                    # List your repos
gh repo clone owner/repo        # Clone repository
gh repo fork owner/repo         # Fork repository
```

### Issue Management
```bash
gh issue list                   # List all issues
gh issue list --assignee @me    # Your issues
gh issue create                 # Create new issue
gh issue view 123               # View issue
gh issue close 123              # Close issue
```

### Pull Requests
```bash
gh pr list                      # List all PRs
gh pr list --author @me         # Your PRs
gh pr create                    # Create new PR
gh pr view 123                  # View PR
gh pr checkout 123              # Checkout PR locally
gh pr review 123 --approve      # Approve PR
gh pr merge 123 --squash        # Squash and merge
gh pr checks 123 --watch        # Watch CI checks
```

### GitHub Actions
```bash
gh workflow list                # List workflows
gh workflow run ci.yml          # Trigger workflow
gh run list                     # List workflow runs
gh run view                     # View latest run
gh run watch                    # Watch run in real-time
gh run download                 # Download artifacts
```

### Releases
```bash
gh release list                 # List releases
gh release view                 # View latest release
gh release create v1.0.0        # Create release
gh release download v1.0.0      # Download release
```

## 🔄 Workflow Examples

### Daily Development
```bash
# 1. Create feature branch
git checkout -b feature/new-feature

# 2. Make changes and commit
git add .
git commit -m "feat: add new feature"
git push -u origin feature/new-feature

# 3. Create PR
./scripts/gh-create-pr.sh

# 4. Monitor CI
gh pr checks --watch

# 5. Merge when approved
gh pr merge --squash --delete-branch
```

### Release Process
```bash
# 1. Create release
./scripts/gh-release.sh 1.1.0

# 2. Monitor PR
gh pr view --web

# 3. Approve and merge
# (Auto-merge is enabled, or merge manually)

# 4. Verify deployment
gh run list --workflow cd.yml
gh run watch
```

### CI/CD Monitoring
```bash
# View recent runs
gh run list --limit 10

# Watch specific run
gh run watch <run-id>

# Download artifacts
gh run download <run-id>

# Check PR status
gh pr checks <pr-number>
```

## 🎯 Integration Points

The GitHub CLI is integrated into this project at multiple levels:

1. **Automation Scripts**
   - `gh-create-pr.sh` - Streamlined PR creation
   - `gh-release.sh` - Automated release workflow
   - `gh-helpers.sh` - Reusable functions library

2. **Workflows**
   - Release management
   - PR automation
   - Issue tracking
   - CI/CD monitoring

3. **Development Process**
   - GitFlow workflow support
   - Branch management
   - Code review process
   - Release management

## 💡 Tips & Best Practices

1. **Always authenticate first**
   ```bash
   gh auth status  # Check auth
   gh auth login   # Login if needed
   ```

2. **Use JSON output for scripting**
   ```bash
   gh pr list --json number,title | jq '.[] | select(.title | contains("bug"))'
   ```

3. **Combine with git commands**
   ```bash
   git push && gh pr create --fill
   ```

4. **Set up aliases**
   ```bash
   gh alias set pv 'pr view'
   gh alias set pm 'pr merge --squash --delete-branch'
   ```

5. **Use watch for CI**
   ```bash
   gh pr checks --watch  # Live updates
   ```

## 🆘 Troubleshooting

### Authentication Issues
```bash
gh auth status        # Check status
gh auth login         # Re-authenticate
gh auth refresh       # Refresh token
```

### API Rate Limits
```bash
gh api rate_limit     # Check limits
```

### Permission Errors
```bash
gh auth refresh -s repo,workflow  # Request additional scopes
```

## 📚 Additional Resources

- **Main Guide**: [gh-study/README.md](README.md)
- **Official Docs**: https://cli.github.com/manual/
- **GitHub API**: https://docs.github.com/en/rest
- **Project README**: [../README.md](../README.md)

## 🎓 Next Steps

1. Complete all labs in `gh-study/labs/`
2. Read the comprehensive guide in `gh-study/README.md`
3. Integrate gh commands into your daily workflow
4. Create custom automation scripts
5. Build GitHub CLI extensions for team needs

---

**Questions?** Open an issue or check the [complete documentation](README.md).
