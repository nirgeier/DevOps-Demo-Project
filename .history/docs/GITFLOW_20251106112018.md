# GitFlow Branching Strategy

This document describes the GitFlow branching model used in this project.

## Overview

GitFlow is a branching model designed around project releases. It provides a robust framework for managing larger projects and enables parallel development.

## Branch Types

### Main Branches

#### `main`
- **Purpose**: Production-ready code
- **Lifetime**: Permanent
- **Protected**: Yes
- **Deployment**: Automatically deployed to production
- **Merges from**: `release/*`, `hotfix/*`
- **Merges to**: Never merged to other branches directly

#### `develop`
- **Purpose**: Integration branch for features
- **Lifetime**: Permanent
- **Protected**: Yes
- **Deployment**: Can be deployed to staging/development environments
- **Merges from**: `feature/*`, `bugfix/*`, `release/*`, `hotfix/*`
- **Merges to**: `release/*`

### Supporting Branches

#### `feature/*`
- **Purpose**: New feature development
- **Naming**: `feature/feature-name` (e.g., `feature/user-authentication`)
- **Branch from**: `develop`
- **Merge to**: `develop`
- **Lifetime**: Temporary (deleted after merge)
- **Example**:
  ```bash
  git checkout develop
  git pull origin develop
  git checkout -b feature/new-api-endpoint
  # ... develop feature ...
  git push origin feature/new-api-endpoint
  # Create PR to develop
  ```

#### `bugfix/*`
- **Purpose**: Fix bugs in develop branch
- **Naming**: `bugfix/bug-description` (e.g., `bugfix/fix-login-error`)
- **Branch from**: `develop`
- **Merge to**: `develop`
- **Lifetime**: Temporary (deleted after merge)
- **Example**:
  ```bash
  git checkout develop
  git checkout -b bugfix/fix-health-endpoint
  # ... fix bug ...
  git push origin bugfix/fix-health-endpoint
  # Create PR to develop
  ```

#### `release/*`
- **Purpose**: Prepare for production release
- **Naming**: `release/version` (e.g., `release/1.2.0`)
- **Branch from**: `develop`
- **Merge to**: `main` AND `develop`
- **Lifetime**: Temporary (deleted after release)
- **Activities**: Version bumps, documentation updates, minor fixes
- **Example**:
  ```bash
  git checkout develop
  git checkout -b release/1.2.0
  # Update version numbers
  # Update CHANGELOG
  git push origin release/1.2.0
  # Create PR to main
  # After merge to main, tag is automatically created
  ```

#### `hotfix/*`
- **Purpose**: Critical production bug fixes
- **Naming**: `hotfix/issue-description` (e.g., `hotfix/security-patch`)
- **Branch from**: `main`
- **Merge to**: `main` AND `develop`
- **Lifetime**: Temporary (deleted after merge)
- **Example**:
  ```bash
  git checkout main
  git checkout -b hotfix/critical-security-fix
  # ... fix critical issue ...
  git push origin hotfix/critical-security-fix
  # Create PR to main
  ```

## Workflow Diagrams

### Feature Development

```
develop
  |
  |---> feature/my-feature
  |         |
  |         | (development work)
  |         |
  |<--------| (PR merge)
  |
```

### Release Process

```
develop
  |
  |---> release/1.0.0
  |         |
  |         | (version bump, docs)
  |         |
  |         |-------> main (tagged v1.0.0)
  |         |
  |<--------| (merge back)
  |
```

### Hotfix Process

```
main
  |
  |---> hotfix/critical-fix
  |         |
  |         | (emergency fix)
  |         |
  |<--------| (merge)
  |
develop
  |
  |<------- (merge hotfix)
  |
```

## Automation

### GitHub Actions Workflows

#### 1. GitFlow Validation (`gitflow.yml`)

Validates branch naming and merge targets:
- Enforces GitFlow naming conventions
- Validates PR target branches
- Runs on every PR

#### 2. Release Management (`release.yml`)

Automates release process:
- Creates release PRs
- Tags releases automatically
- Merges back to develop after release

#### 3. CI/CD Integration

- **CI**: Runs on all branches
- **CD**: Runs on `main` and tags
- **Staging**: Deploys from `develop`

## Best Practices

### Commit Messages

Follow conventional commits format:

```
type(scope): subject

body (optional)

footer (optional)
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Build process or auxiliary tool changes

Examples:
```
feat(api): add user authentication endpoint
fix(health): correct health check status code
docs(readme): update deployment instructions
chore(deps): upgrade flask to 3.0.0
```

### Pull Requests

#### PR Title Format
```
[Type] Brief description
```

Examples:
- `[Feature] Add JWT authentication`
- `[Bugfix] Fix memory leak in health check`
- `[Release] Version 1.2.0`
- `[Hotfix] Security patch for CVE-2024-XXXX`

#### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Feature
- [ ] Bugfix
- [ ] Hotfix
- [ ] Release
- [ ] Documentation

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests added/updated
```

### Branch Protection Rules

#### `main` branch:
- ✅ Require pull request reviews (1+ approvals)
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ✅ Include administrators
- ✅ Restrict force pushes
- ✅ Restrict deletions

#### `develop` branch:
- ✅ Require pull request reviews (1+ approvals)
- ✅ Require status checks to pass
- ✅ Restrict force pushes

### Version Numbering

Follow Semantic Versioning (SemVer):

```
MAJOR.MINOR.PATCH

Example: 1.2.3
```

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Process

1. **Create Release Branch**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b release/1.2.0
   ```

2. **Update Version**
   - Update `pyproject.toml`
   - Update `app/__init__.py`
   - Update `helm/devops-demo/Chart.yaml`

3. **Update CHANGELOG**
   ```markdown
   ## [1.2.0] - 2025-11-06
   
   ### Added
   - New feature X
   
   ### Changed
   - Updated dependency Y
   
   ### Fixed
   - Bug Z
   ```

4. **Create PR to main**
   - Title: `[Release] Version 1.2.0`
   - Review and merge

5. **Automatic Actions**
   - Tag created: `v1.2.0`
   - GitHub release created
   - Docker image built and pushed
   - Merge back to develop

### Hotfix Process

1. **Create Hotfix Branch**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b hotfix/critical-issue
   ```

2. **Fix Issue**
   - Make minimal changes
   - Add tests
   - Update version (patch bump)

3. **Create PR to main**
   - Title: `[Hotfix] Fix critical issue`
   - Fast-track review

4. **Automatic Actions**
   - Merge to main
   - Create tag
   - Merge to develop
   - Deploy to production

## Common Commands

### Start New Feature
```bash
git checkout develop
git pull origin develop
git checkout -b feature/my-feature
```

### Update Feature Branch
```bash
git checkout feature/my-feature
git fetch origin
git rebase origin/develop
```

### Finish Feature
```bash
git checkout feature/my-feature
git push origin feature/my-feature
# Create PR to develop via GitHub UI
```

### Start Release
```bash
git checkout develop
git pull origin develop
git checkout -b release/1.2.0
# Update versions and changelog
git push origin release/1.2.0
# Create PR to main via GitHub UI
```

### Emergency Hotfix
```bash
git checkout main
git pull origin main
git checkout -b hotfix/critical-fix
# Fix issue
git push origin hotfix/critical-fix
# Create PR to main via GitHub UI
```

## Troubleshooting

### Merge Conflicts

```bash
# On your feature branch
git checkout feature/my-feature
git fetch origin
git rebase origin/develop

# Resolve conflicts
git add .
git rebase --continue

# Force push (only on feature branches!)
git push --force-with-lease origin feature/my-feature
```

### Wrong Base Branch

```bash
# If you branched from wrong base
git checkout feature/my-feature
git rebase --onto develop main feature/my-feature
```

### Forgot to Branch

```bash
# If you committed to develop directly
git checkout develop
git reset --soft HEAD~1
git checkout -b feature/my-feature
git commit -m "Your commit message"
```

## Resources

- [GitFlow Original Post](https://nvie.com/posts/a-successful-git-branching-model/)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

For questions about the GitFlow process, open an issue on GitHub.
