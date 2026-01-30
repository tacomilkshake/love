#!/bin/bash
#
# ci_post_clone.sh - Xcode Cloud post-clone script for Elevate iOS
#

set -ex  # Exit on error, print commands

echo "=== Elevate iOS: Post-Clone Setup ==="
echo "Current directory: $(pwd)"
echo "Repository path: $CI_PRIMARY_REPOSITORY_PATH"

REPO_ROOT="$CI_PRIMARY_REPOSITORY_PATH"
XCODE_DIR="$REPO_ROOT/platform/xcode"
DEPS_DIR="$REPO_ROOT/love-apple-dependencies"
ELEVATE_DIR="$REPO_ROOT/elevate-game"

# 0. Initialize submodules
echo "[0/4] Initializing submodules..."
cd "$REPO_ROOT"
echo "Contents of repo root:"
ls -la
echo ""
echo ".gitmodules contents:"
cat .gitmodules
echo ""
git submodule update --init --recursive
echo "Submodule status:"
git submodule status
echo ""

# Check if deps directory exists
echo "Checking love-apple-dependencies:"
ls -la "$DEPS_DIR" || echo "Directory doesn't exist!"
ls -la "$DEPS_DIR/shared/Frameworks/" || echo "shared/Frameworks doesn't exist!"
ls -la "$DEPS_DIR/iOS/libraries/" || echo "iOS/libraries doesn't exist!"

# 1. Set up dependency symlinks
echo "[1/4] Setting up dependency symlinks..."
mkdir -p "$XCODE_DIR/shared"
mkdir -p "$XCODE_DIR/macosx"

# Use absolute paths instead of relative symlinks
ln -sfn "$DEPS_DIR/shared/Frameworks" "$XCODE_DIR/shared/Frameworks"
ln -sfn "$DEPS_DIR/iOS/libraries" "$XCODE_DIR/ios/libraries"
ln -sfn "$DEPS_DIR/macOS/Frameworks" "$XCODE_DIR/macosx/Frameworks"

# Verify symlinks
echo "Verifying symlinks..."
ls -la "$XCODE_DIR/shared/"
ls -la "$XCODE_DIR/ios/"
ls -la "$XCODE_DIR/macosx/"

# 2. Clone the game source
echo "[2/4] Cloning Elevate game source..."
git clone --depth 1 https://github.com/tacomilkshake/elevate.git "$ELEVATE_DIR"

# 3. Build game.love
echo "[3/4] Building game.love..."
cd "$ELEVATE_DIR"
zip -9 -r "$REPO_ROOT/game.love" \
    main.lua \
    conf.lua \
    engine \
    sim \
    src \
    assets \
    data \
    -x "*.DS_Store" \
    -x "*.git*" \
    -x "tests/*" \
    -x "_legacy/*" \
    -x "ios/*" \
    -x "ios-deps/*" \
    -x "docs/*" \
    -x "*.md" \
    -x "love2d-mcp/*"
echo "game.love created: $(du -h "$REPO_ROOT/game.love" | cut -f1)"

# 4. Final verification
echo "[4/4] Final verification..."
ls -la "$XCODE_DIR/shared/Frameworks/SDL3.xcframework" || echo "SDL3 NOT FOUND"
ls -la "$XCODE_DIR/ios/libraries/" || echo "iOS libraries NOT FOUND"

echo "=== Post-Clone Setup Complete ==="
