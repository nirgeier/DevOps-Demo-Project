#!/bin/bash
# Lab 6: Release Management with GitHub CLI
# Learn to create, manage, and automate releases

set -e

echo "🎓 Lab 6: Release Management"
echo "============================"
echo

# Check if in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository!"
    exit 1
fi

echo "✅ Step 1: List Existing Releases"
echo "=================================="
echo
gh release list

echo
echo "Latest release details:"
if gh release view > /dev/null 2>&1; then
    gh release view
else
    echo "No releases found in this repository"
fi

echo
read -p "Press Enter to continue..."

echo
echo "🏷️ Step 2: Create a Git Tag"
echo "==========================="
echo
TAG_NAME="v0.0.1-lab6-$(date +%s)"
echo "Creating tag: $TAG_NAME"

git tag -a $TAG_NAME -m "Lab 6: Test release tag"
git push origin $TAG_NAME

echo "✅ Tag created and pushed: $TAG_NAME"

echo
read -p "Press Enter to continue..."

echo
echo "📦 Step 3: Create a Simple Release"
echo "==================================="
echo
gh release create $TAG_NAME \
    --title "Lab 6 Test Release" \
    --notes "This is a test release created during GitHub CLI Lab 6.

## What's Changed
- Testing release creation via GitHub CLI
- Demonstrating release workflow

## Type
🧪 Test Release

This release can be safely deleted after the lab." \
    --prerelease

echo "✅ Release created!"
gh release view $TAG_NAME

echo
read -p "Press Enter to continue..."

echo
echo "📝 Step 4: Generate Release Notes"
echo "=================================="
echo
NOTES_TAG="v0.0.2-lab6-$(date +%s)"
git tag -a $NOTES_TAG -m "Lab 6: Auto-generated notes test"
git push origin $NOTES_TAG

echo "Creating release with auto-generated notes..."
gh release create $NOTES_TAG \
    --title "Lab 6 Auto-Generated Notes" \
    --generate-notes \
    --prerelease

echo "✅ Release created with auto-generated notes!"
gh release view $NOTES_TAG

echo
read -p "Press Enter to continue..."

echo
echo "📎 Step 5: Add Release Assets"
echo "=============================="
echo
# Create sample assets
ASSET_DIR="/tmp/gh-lab6-assets"
mkdir -p $ASSET_DIR

echo "Creating sample assets..."
echo "# Lab 6 Assets" > $ASSET_DIR/README.txt
echo "Build number: $(date +%s)" > $ASSET_DIR/build-info.txt
tar -czf $ASSET_DIR/lab6-package.tar.gz -C $ASSET_DIR README.txt build-info.txt

echo "Uploading assets to release..."
gh release upload $TAG_NAME \
    $ASSET_DIR/lab6-package.tar.gz \
    $ASSET_DIR/README.txt

echo "✅ Assets uploaded!"
gh release view $TAG_NAME

echo
read -p "Press Enter to continue..."

echo
echo "📥 Step 6: Download Release Assets"
echo "==================================="
echo
DOWNLOAD_DIR="/tmp/gh-lab6-downloads"
mkdir -p $DOWNLOAD_DIR

echo "Downloading assets from $TAG_NAME..."
gh release download $TAG_NAME --dir $DOWNLOAD_DIR

echo "✅ Assets downloaded to: $DOWNLOAD_DIR"
ls -lh $DOWNLOAD_DIR

echo
read -p "Press Enter to continue..."

echo
echo "✏️ Step 7: Edit a Release"
echo "========================="
echo
echo "Updating release notes..."
gh release edit $TAG_NAME \
    --notes "# Lab 6 Test Release (Updated)

This release has been updated during the lab.

## Features
- ✅ Release creation
- ✅ Asset management
- ✅ Release editing

## Assets
- lab6-package.tar.gz
- README.txt

## Cleanup
This release will be cleaned up after the lab."

echo "Converting to full release..."
gh release edit $TAG_NAME --prerelease=false

echo "✅ Release updated!"
gh release view $TAG_NAME

echo
read -p "Press Enter to continue..."

echo
echo "🔍 Step 8: View Release in JSON"
echo "================================"
echo
gh release view $TAG_NAME --json tagName,name,body,assets,publishedAt | jq '.'

echo
read -p "Press Enter to continue..."

echo
echo "📊 Step 9: Create Release Automation Script"
echo "============================================"
echo
RELEASE_SCRIPT="/tmp/gh-release-automation.sh"
cat > $RELEASE_SCRIPT << 'EOFSCRIPT'
#!/bin/bash
# Automated Release Script

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.0"
    exit 1
fi

TAG="v$VERSION"

echo "🚀 Creating release $TAG..."

# 1. Check if tag exists
if git rev-parse $TAG >/dev/null 2>&1; then
    echo "❌ Tag $TAG already exists!"
    exit 1
fi

# 2. Create and push tag
echo "📝 Creating tag..."
git tag -a $TAG -m "Release $VERSION"
git push origin $TAG

# 3. Build artifacts (example)
echo "📦 Building artifacts..."
BUILD_DIR="/tmp/release-$VERSION"
mkdir -p $BUILD_DIR
echo "Version: $VERSION" > $BUILD_DIR/VERSION.txt
echo "Build date: $(date)" >> $BUILD_DIR/VERSION.txt
tar -czf $BUILD_DIR/release-$VERSION.tar.gz -C $BUILD_DIR VERSION.txt

# 4. Create release
echo "🎉 Creating GitHub release..."
gh release create $TAG \
    --title "Release $VERSION" \
    --generate-notes \
    $BUILD_DIR/release-$VERSION.tar.gz \
    $BUILD_DIR/VERSION.txt

echo "✅ Release $TAG created successfully!"
gh release view $TAG --web
EOFSCRIPT

chmod +x $RELEASE_SCRIPT

echo "✅ Release automation script created: $RELEASE_SCRIPT"
echo
echo "Example usage:"
echo "  $RELEASE_SCRIPT 1.0.0"

echo
read -p "Press Enter to continue..."

echo
echo "🧹 Step 10: Cleanup Test Releases"
echo "=================================="
echo
echo "Test releases created during this lab:"
echo "  - $TAG_NAME"
echo "  - $NOTES_TAG"
echo
read -p "Delete these test releases? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting releases..."
    gh release delete $TAG_NAME --yes --cleanup-tag
    gh release delete $NOTES_TAG --yes --cleanup-tag
    echo "✅ Test releases deleted"
    
    # Cleanup directories
    rm -rf $ASSET_DIR $DOWNLOAD_DIR
    echo "✅ Temporary files cleaned up"
else
    echo "ℹ️  Test releases kept. Delete manually with:"
    echo "  gh release delete $TAG_NAME --yes --cleanup-tag"
    echo "  gh release delete $NOTES_TAG --yes --cleanup-tag"
fi

echo
echo "🎓 Key Commands Learned:"
echo "========================"
echo "  gh release list           # List all releases"
echo "  gh release view <tag>     # View release details"
echo "  gh release create <tag>   # Create new release"
echo "  gh release create <tag> --generate-notes  # Auto-generate notes"
echo "  gh release upload <tag> <files>  # Upload assets"
echo "  gh release download <tag>  # Download assets"
echo "  gh release edit <tag>     # Edit release"
echo "  gh release delete <tag>   # Delete release"
echo
echo "💡 Release Options:"
echo "==================="
echo "  --title \"Release Title\""
echo "  --notes \"Release notes\""
echo "  --notes-file CHANGELOG.md"
echo "  --generate-notes          # Auto-generate from commits"
echo "  --draft                   # Create draft release"
echo "  --prerelease              # Mark as pre-release"
echo "  --latest                  # Set as latest release"
echo "  --target <branch>         # Target branch/commit"
echo
echo "🎉 Lab 6 Complete!"
echo "=================="
echo
echo "Next: Run lab7-automation.sh for advanced automation"
