#!/bin/bash
#
# ci_post_clone.sh - Xcode Cloud post-clone script for Elevate iOS
#

set -e

echo "=== Elevate iOS: Post-Clone Setup ==="

REPO_ROOT="$CI_PRIMARY_REPOSITORY_PATH"
XCODE_DIR="$REPO_ROOT/platform/xcode"
DEPS_DIR="$REPO_ROOT/love-apple-dependencies"
ELEVATE_DIR="$REPO_ROOT/elevate-game"

# 1. Set up dependency symlinks
echo "[1/4] Setting up dependency symlinks..."
mkdir -p "$XCODE_DIR/shared"
ln -sf "../../../love-apple-dependencies/shared/Frameworks" "$XCODE_DIR/shared/Frameworks"
ln -sf "../../../love-apple-dependencies/iOS/libraries" "$XCODE_DIR/ios/libraries"
mkdir -p "$XCODE_DIR/macosx"
ln -sf "../../../love-apple-dependencies/macOS/Frameworks" "$XCODE_DIR/macosx/Frameworks"
echo "  ✓ Symlinks created"

# 2. Clone the game source
echo "[2/4] Cloning Elevate game source..."
git clone --depth 1 https://github.com/tacomilkshake/elevate.git "$ELEVATE_DIR"
echo "  ✓ Game source cloned"

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
echo "  ✓ game.love created ($(du -h "$REPO_ROOT/game.love" | cut -f1))"

# 4. Verify setup
echo "[4/4] Verifying setup..."
if [ -d "$XCODE_DIR/shared/Frameworks/SDL3.xcframework" ]; then
    echo "  ✓ SDL3.xcframework linked"
else
    echo "  ✗ SDL3.xcframework not found!"
    exit 1
fi

echo ""
echo "=== Post-Clone Setup Complete ==="
