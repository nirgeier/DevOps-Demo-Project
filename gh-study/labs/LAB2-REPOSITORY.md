# Lab 2: Repository Management with GitHub CLI

## 📚 Overview

This lab teaches you how to create, clone, view, and manage GitHub repositories entirely from the command line. You'll master the essential repository operations that form the foundation of GitHub workflows.

## 🎯 Learning Objectives

By the end of this lab, you will be able to:

- ✅ List and search your repositories
- ✅ View repository details and statistics
- ✅ Create new repositories with various options
- ✅ Clone repositories efficiently
- ✅ Fork repositories
- ✅ Archive and delete repositories
- ✅ Work with repository metadata

## 🔧 Prerequisites

- ✅ Completed [Lab 1: Setup & Authentication](./LAB1-SETUP.md)
- ✅ Authenticated GitHub CLI (`gh auth status`)
- ✅ Git installed and configured
- ✅ Basic command line knowledge

## 📋 Lab Steps

### Step 1: List Your Repositories

View all repositories you have access to:

```bash
# List your repositories (default: 30)
gh repo list

# Limit results
gh repo list --limit 10

# Include additional details
gh repo list --limit 5 --source
```

**Filter repositories:**

```bash
# Only public repositories
gh repo list --visibility public

# Only private repositories
gh repo list --visibility private

# Filter by language
gh repo list --language python
gh repo list --language javascript

# Include archived repositories
gh repo list --archived
```

**Expected Output:**
```
owner/repo-name    Description here    public    about 2 hours ago
owner/another-repo Another description private   2 days ago
```

### Step 2: View Repository Details

Get comprehensive information about a repository:

```bash
# View current repository (if in a git directory)
gh repo view

# View specific repository
gh repo view owner/repo-name

# View in browser
gh repo view --web
gh repo view owner/repo-name --web
```

**Get specific information:**

```bash
# View README
gh repo view owner/repo-name --readme

# Get JSON output for scripting
gh repo view owner/repo-name --json name,description,url
gh repo view --json stargazerCount,forkCount,openIssues

# Pretty print JSON
gh repo view --json name,owner,description,stargazerCount | jq '.'
```

**Expected JSON Output:**
```json
{
  "name": "awesome-project",
  "description": "An amazing project",
  "stargazerCount": 42,
  "forkCount": 7,
  "openIssues": 3
}
```

### Step 3: Create a New Repository

Create repositories with various configurations:

**Basic repository:**

```bash
# Create public repository
gh repo create my-new-project --public

# Create private repository
gh repo create my-private-project --private

# Create with description
gh repo create my-project \
    --public \
    --description "My awesome project"
```

**Advanced creation options:**

```bash
# Create with README and .gitignore
gh repo create awesome-app \
    --public \
    --description "A full-featured application" \
    --add-readme \
    --gitignore Node \
    --license MIT

# Create and clone immediately
gh repo create my-app \
    --public \
    --clone \
    --add-readme

# Create from template
gh repo create my-new-project \
    --template owner/template-repo \
    --public
```

**Interactive creation:**

```bash
# Interactive prompts
gh repo create

# You'll be asked:
# - Repository name?
# - Description?
# - Visibility (public/private/internal)?
# - Initialize with README?
# - Add .gitignore?
# - Add license?
# - Clone locally?
```

**Organization repositories:**

```bash
# Create in organization
gh repo create my-org/new-repo \
    --public \
    --description "Organization project"
```

### Step 4: Clone Repositories

Clone repositories efficiently:

```bash
# Clone your repository
gh repo clone owner/repo-name

# Clone to specific directory
gh repo clone owner/repo-name /path/to/directory

# Clone with custom protocol
gh repo clone owner/repo-name -- --depth 1  # Shallow clone
```

**Clone shortcuts:**

```bash
# If currently in org context
gh repo clone repo-name  # Clones from your default org

# Clone and cd into directory
gh repo clone owner/repo && cd repo
```

### Step 5: Fork Repositories

Create and manage forks:

```bash
# Fork a repository
gh repo fork owner/repo-name

# Fork and clone
gh repo fork owner/repo-name --clone

# Fork to organization
gh repo fork owner/repo-name --org my-organization

# Fork without remote setup
gh repo fork owner/repo-name --remote=false
```

**Working with forks:**

```bash
# Check if repository is a fork
gh repo view --json isFork

# View parent repository
gh repo view --json parent

# Sync fork with upstream
git fetch upstream
git merge upstream/main
```

### Step 6: Repository Metadata

Update repository information:

```bash
# Edit repository settings
gh repo edit owner/repo-name

# Update description
gh repo edit --description "Updated description"

# Change default branch
gh repo edit --default-branch main

# Enable/disable features
gh repo edit --enable-issues
gh repo edit --enable-wiki
gh repo edit --enable-projects

# Update visibility
gh repo edit --visibility private
```

**Add topics:**

```bash
# Add topics (tags)
gh repo edit --add-topic javascript
gh repo edit --add-topic nodejs,typescript,react

# Remove topics
gh repo edit --remove-topic old-tag
```

### Step 7: Archive and Delete

Manage repository lifecycle:

**Archive repository:**

```bash
# Archive (make read-only)
gh repo archive owner/repo-name

# Unarchive
gh repo unarchive owner/repo-name
```

**Delete repository:**

```bash
# Delete repository (requires confirmation)
gh repo delete owner/repo-name

# Delete without confirmation (use carefully!)
gh repo delete owner/repo-name --yes
```

⚠️ **Warning:** Deletion is permanent and cannot be undone!

### Step 8: Advanced Operations

**Search repositories:**

```bash
# Search GitHub for repositories
gh search repos "machine learning" --language python

# Filter by stars
gh search repos "kubernetes" --stars ">1000"

# Filter by date
gh search repos "docker" --created ">2024-01-01"

# Combine filters
gh search repos "react" \
    --language typescript \
    --stars ">500" \
    --sort stars \
    --order desc \
    --limit 10
```

**Repository statistics:**

```bash
# Get comprehensive stats
gh api repos/owner/repo-name | jq '{
  stars: .stargazers_count,
  forks: .forks_count,
  watchers: .watchers_count,
  size: .size,
  language: .language,
  open_issues: .open_issues_count
}'
```

**Sync fork:**

```bash
# Sync fork with upstream
gh repo sync owner/repo-name

# Sync specific branch
gh repo sync --branch main
```

## 🎓 Key Commands Reference

| Command | Description |
|---------|-------------|
| `gh repo list` | List repositories |
| `gh repo view [repo]` | View repository details |
| `gh repo create <name>` | Create new repository |
| `gh repo clone <repo>` | Clone repository |
| `gh repo fork <repo>` | Fork repository |
| `gh repo edit` | Edit repository settings |
| `gh repo archive <repo>` | Archive repository |
| `gh repo delete <repo>` | Delete repository |
| `gh repo sync` | Sync fork with upstream |

## 💡 Pro Tips

### 1. Default Repository

Set a default repository for your session:

```bash
# Set default repo
gh repo set-default owner/repo-name

# Now these commands work without specifying repo
gh issue list
gh pr list
```

### 2. Repository Rename

Rename a repository:

```bash
gh api -X PATCH repos/owner/old-name \
    -f name="new-name"
```

### 3. Transfer Repository

Transfer to another owner:

```bash
gh api -X POST repos/owner/repo/transfer \
    -f new_owner="target-owner"
```

### 4. Batch Operations

Create multiple repositories from a list:

```bash
# From file
cat repos.txt | while read repo; do
    gh repo create "$repo" --public --add-readme
done

# From array
for repo in app-backend app-frontend app-docs; do
    gh repo create "myorg/$repo" --private
done
```

### 5. Clone All User Repositories

```bash
# Clone all your repositories
gh repo list --limit 1000 --json name --jq '.[].name' | \
    xargs -I {} gh repo clone {}
```

## 🔍 Practical Examples

### Example 1: Create Full-Featured Project

```bash
#!/bin/bash
PROJECT_NAME="awesome-web-app"
ORG="my-company"

# Create repository
gh repo create "$ORG/$PROJECT_NAME" \
    --private \
    --description "Production web application" \
    --add-readme \
    --gitignore Node \
    --license MIT \
    --clone

# Navigate and configure
cd "$PROJECT_NAME"

# Enable features
gh repo edit --enable-issues --enable-wiki --enable-projects

# Add topics
gh repo edit --add-topic nodejs,express,mongodb,react

echo "✅ Repository created and configured!"
```

### Example 2: Repository Information Dashboard

```bash
#!/bin/bash
REPO="$1"

echo "📊 Repository Statistics for $REPO"
echo "=================================="

gh api "repos/$REPO" | jq '{
    name: .name,
    description: .description,
    language: .language,
    stars: .stargazers_count,
    forks: .forks_count,
    watchers: .watchers_count,
    open_issues: .open_issues_count,
    size_kb: .size,
    created: .created_at,
    updated: .updated_at,
    homepage: .homepage,
    topics: .topics
}'
```

### Example 3: Bulk Repository Update

```bash
#!/bin/bash
# Update description for multiple repositories

REPOS=("repo1" "repo2" "repo3")
NEW_DESC="Updated project description"

for repo in "${REPOS[@]}"; do
    echo "Updating $repo..."
    gh repo edit "owner/$repo" --description "$NEW_DESC"
done
```

## 🔍 Troubleshooting

### Issue: Permission denied

**Solution:**
```bash
# Check authentication
gh auth status

# Refresh token with required scopes
gh auth refresh -s repo,delete_repo

# Verify permissions
gh api user/repos
```

### Issue: Repository already exists

**Solution:**
```bash
# Check if repository exists
gh repo view owner/repo-name

# Use different name or delete existing
gh repo delete owner/repo-name --yes
```

### Issue: Clone fails with SSH

**Solution:**
```bash
# Switch to HTTPS
gh config set git_protocol https

# Or add SSH key
gh ssh-key add ~/.ssh/id_ed25519.pub
```

## ✅ Lab Exercise

Create a complete project setup:

1. **Create repository with all features:**
```bash
gh repo create lab2-exercise \
    --public \
    --add-readme \
    --gitignore Python \
    --license Apache-2.0 \
    --clone
```

2. **Configure repository:**
```bash
cd lab2-exercise
gh repo edit --description "Lab 2 practice repository" \
    --enable-issues \
    --enable-wiki \
    --add-topic github-cli,learning,devops
```

3. **Add content:**
```bash
echo "# Lab 2 Exercise" >> README.md
echo "This repository was created for practice!" >> README.md
git add README.md
git commit -m "docs: update README"
git push
```

4. **Verify:**
```bash
gh repo view
```

5. **Cleanup (optional):**
```bash
cd ..
gh repo delete lab2-exercise --yes
```

## ✅ Validation Checklist

Before proceeding to Lab 3, ensure you can:

- [ ] List your repositories with filters
- [ ] View repository details in various formats
- [ ] Create repositories with different options
- [ ] Clone repositories
- [ ] Fork repositories
- [ ] Edit repository settings
- [ ] Archive/delete repositories
- [ ] Search for repositories
- [ ] Work with repository metadata

## 🎉 Success Indicators

You've mastered Lab 2 when you can:

1. ✅ Create a repository with all features enabled
2. ✅ View repository statistics in JSON format
3. ✅ Clone and fork repositories efficiently
4. ✅ Update repository settings programmatically
5. ✅ Search and filter repositories effectively

## 📚 Additional Resources

- [gh repo documentation](https://cli.github.com/manual/gh_repo)
- [Repository API reference](https://docs.github.com/en/rest/repos)
- [Repository best practices](https://docs.github.com/en/repositories)
- [GitHub topics guide](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/classifying-your-repository-with-topics)

## 🚀 Next Steps

Continue your GitHub CLI journey with:

**[Lab 3: Issue Management →](./LAB3-ISSUES.md)**

Learn to create, manage, and automate GitHub Issues from the command line.

---

**Lab Duration:** 30-40 minutes  
**Difficulty:** Beginner to Intermediate  
**Prerequisites:** Lab 1 completed, Git basics
