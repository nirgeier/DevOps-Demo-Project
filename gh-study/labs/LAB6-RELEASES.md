# Lab 6: Release Management with GitHub CLI

## 📚 Overview

Master GitHub releases from the command line. Learn to create, manage, and automate software releases including version tagging, release notes generation, and asset management.

## 🎯 Learning Objectives

- ✅ List and view releases
- ✅ Create releases with tags
- ✅ Generate automated release notes
- ✅ Upload and download release assets
- ✅ Manage pre-releases
- ✅ Edit and delete releases
- ✅ Automate release workflows

## 🔧 Prerequisites

- Completed Labs 1-5
- Git tag knowledge
- Semantic versioning understanding
- Repository with releases enabled

## 📋 Key Commands

### List Releases

```bash
# All releases
gh release list

# Limit results
gh release list --limit 10

# Exclude pre-releases and drafts
gh release list --exclude-pre-releases
gh release list --exclude-drafts
```

### View Release Details

```bash
# Latest release
gh release view

# Specific release
gh release view v1.0.0

# View in browser
gh release view v1.0.0 --web

# JSON output
gh release view v1.0.0 --json tagName,name,assets,publishedAt
```

### Create Releases

```bash
# Basic release
gh release create v1.0.0 --title "Version 1.0.0"

# With release notes
gh release create v1.0.0 \
    --title "v1.0.0 - Major Release" \
    --notes "## What's New
    
- Feature A
- Feature B
- Bug fixes

## Breaking Changes
- API endpoint changes"

# Auto-generate release notes
gh release create v1.0.0 --generate-notes

# Create pre-release
gh release create v2.0.0-beta \
    --title "Beta Release" \
    --prerelease \
    --generate-notes

# Create draft
gh release create v1.1.0 --draft --generate-notes
```

### Upload Assets

```bash
# Upload files
gh release upload v1.0.0 dist/app.zip

# Multiple files
gh release upload v1.0.0 \
    dist/app.zip \
    dist/checksums.txt \
    dist/CHANGELOG.md

# With glob pattern
gh release upload v1.0.0 dist/*.tar.gz
```

### Download Assets

```bash
# Download all assets
gh release download v1.0.0

# Download to specific directory
gh release download v1.0.0 --dir ./downloads

# Download specific asset
gh release download v1.0.0 --pattern "*.zip"

# Skip existing files
gh release download v1.0.0 --skip-existing
```

### Edit Releases

```bash
# Edit title and notes
gh release edit v1.0.0 \
    --title "Version 1.0.0 (Updated)" \
    --notes "Updated release notes..."

# Mark as latest
gh release edit v1.0.0 --latest

# Convert to non-prerelease
gh release edit v2.0.0-beta --prerelease=false

# Publish draft
gh release edit v1.1.0 --draft=false
```

### Delete Releases

```bash
# Delete release and tag
gh release delete v1.0.0 --yes

# Keep the tag
gh release delete v1.0.0 --yes --cleanup-tag=false
```

## 💡 Practical Examples

### Example 1: Complete Release Script

```bash
#!/bin/bash
# release.sh - Complete release automation

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.2.0"
    exit 1
fi

TAG="v$VERSION"

echo "🚀 Creating release $TAG"

# 1. Verify working directory is clean
if [[ -n $(git status -s) ]]; then
    echo "❌ Working directory not clean!"
    exit 1
fi

# 2. Create and push tag
echo "📝 Creating tag $TAG..."
git tag -a $TAG -m "Release $VERSION"
git push origin $TAG

# 3. Build artifacts
echo "📦 Building artifacts..."
npm run build  # or your build command
tar -czf "app-$VERSION.tar.gz" dist/
sha256sum "app-$VERSION.tar.gz" > "app-$VERSION.sha256"

# 4. Create release
echo "🎉 Creating GitHub release..."
gh release create $TAG \
    --title "Release $VERSION" \
    --generate-notes \
    "app-$VERSION.tar.gz" \
    "app-$VERSION.sha256"

echo "✅ Release $TAG created successfully!"
gh release view $TAG --web
```

### Example 2: Release Notes Generator

```bash
#!/bin/bash
# generate-release-notes.sh

CURRENT_TAG=$(git describe --tags --abbrev=0)
PREVIOUS_TAG=$(git describe --tags --abbrev=0 $CURRENT_TAG^)

echo "# Release Notes: $CURRENT_TAG"
echo
echo "## Changes since $PREVIOUS_TAG"
echo

# Features
echo "### ✨ Features"
git log $PREVIOUS_TAG..$CURRENT_TAG --oneline | grep "feat:" | sed 's/^/- /'
echo

# Bug Fixes
echo "### 🐛 Bug Fixes"
git log $PREVIOUS_TAG..$CURRENT_TAG --oneline | grep "fix:" | sed 's/^/- /'
echo

# Contributors
echo "### 👥 Contributors"
git log $PREVIOUS_TAG..$CURRENT_TAG --format='- @%an' | sort -u
echo

# Full Changelog
echo "### 📋 Full Changelog"
echo "**Full Changelog**: https://github.com/owner/repo/compare/$PREVIOUS_TAG...$CURRENT_TAG"
```

### Example 3: Release Dashboard

```bash
#!/bin/bash
# release-dashboard.sh

echo "══════════════════════════════════════"
echo "       Release Dashboard"
echo "══════════════════════════════════════"

echo
echo "📦 Latest Releases:"
gh release list --limit 5

echo
echo "📊 Release Statistics:"
TOTAL=$(gh release list --limit 1000 --json tagName | jq length)
PRERELEASE=$(gh release list --limit 1000 --json isPrerelease | jq '[.[] | select(.isPrerelease)] | length')
DRAFT=$(gh release list --limit 1000 --json isDraft | jq '[.[] | select(.isDraft)] | length')

echo "  Total: $TOTAL"
echo "  Pre-releases: $PRERELEASE"
echo "  Drafts: $DRAFT"

echo
echo "📈 Download Stats (Latest Release):"
gh api repos/:owner/:repo/releases/latest | \
    jq -r '.assets[] | "  \(.name): \(.download_count) downloads"'
```

### Example 4: Semantic Release Automation

```bash
#!/bin/bash
# semantic-release.sh - Bump version based on commits

# Get current version
CURRENT=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
CURRENT=${CURRENT#v}

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

# Check commits since last tag
COMMITS=$(git log $CURRENT..HEAD --oneline)

# Determine version bump
if echo "$COMMITS" | grep -q "BREAKING CHANGE\|!:"; then
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    BUMP="major"
elif echo "$COMMITS" | grep -q "feat:"; then
    MINOR=$((MINOR + 1))
    PATCH=0
    BUMP="minor"
elif echo "$COMMITS" | grep -q "fix:"; then
    PATCH=$((PATCH + 1))
    BUMP="patch"
else
    echo "No releasable changes found"
    exit 0
fi

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "Bumping version: $CURRENT → $NEW_VERSION ($BUMP)"

# Create release
./release.sh $NEW_VERSION
```

## 🎓 Release Workflow Template

```bash
#!/bin/bash
# complete-release-workflow.sh

VERSION=$1
NOTES_FILE="RELEASE_NOTES.md"

# 1. Validate version
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Invalid version format. Use: X.Y.Z"
    exit 1
fi

TAG="v$VERSION"

# 2. Update version in files
echo "Updating version in project files..."
sed -i "" "s/\"version\": \".*\"/\"version\": \"$VERSION\"/" package.json

# 3. Commit version bump
git add package.json
git commit -m "chore: bump version to $VERSION"

# 4. Create tag
git tag -a $TAG -m "Release $VERSION"

# 5. Generate release notes
echo "# Release $VERSION" > $NOTES_FILE
echo "" >> $NOTES_FILE
git log --oneline --no-merges $(git describe --tags --abbrev=0 HEAD^)..HEAD >> $NOTES_FILE

# 6. Build and package
npm run build
zip -r "release-$VERSION.zip" dist/

# 7. Push tag
git push origin $TAG

# 8. Create GitHub release
gh release create $TAG \
    --title "Release $VERSION" \
    --notes-file $NOTES_FILE \
    "release-$VERSION.zip"

# 9. Cleanup
rm $NOTES_FILE "release-$VERSION.zip"

echo "✅ Release $TAG published successfully!"
```

## ✅ Lab Exercise

1. **Create a test tag:**
```bash
git tag -a v0.1.0 -m "Lab 6 exercise"
git push origin v0.1.0
```

2. **Create release:**
```bash
gh release create v0.1.0 \
    --title "Lab 6 Exercise Release" \
    --generate-notes
```

3. **Create assets:**
```bash
echo "Test artifact" > test.txt
tar -czf test-v0.1.0.tar.gz test.txt
```

4. **Upload assets:**
```bash
gh release upload v0.1.0 test-v0.1.0.tar.gz
```

5. **View release:**
```bash
gh release view v0.1.0
```

6. **Download assets:**
```bash
gh release download v0.1.0
```

7. **Cleanup:**
```bash
gh release delete v0.1.0 --yes
git push origin :v0.1.0  # Delete remote tag
git tag -d v0.1.0  # Delete local tag
```

## 📚 Additional Resources

- [gh release documentation](https://cli.github.com/manual/gh_release)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Releases guide](https://docs.github.com/en/repositories/releasing-projects-on-github)

## 🎉 Congratulations!

You've completed all GitHub CLI labs! You now have the skills to:

- ✅ Manage repositories efficiently
- ✅ Handle issues and pull requests
- ✅ Monitor CI/CD workflows
- ✅ Create and manage releases
- ✅ Automate GitHub operations

---

**Lab Duration:** 45-60 minutes  
**Difficulty:** Intermediate to Advanced  
**Prerequisites:** Labs 1-5, version control knowledge
