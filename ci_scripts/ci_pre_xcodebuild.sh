#!/bin/bash
#
# ci_pre_xcodebuild.sh - Runs before xcodebuild
#

set -ex

echo "=== Elevate iOS: Pre-Build Setup ==="

REPO_ROOT="$CI_PRIMARY_REPOSITORY_PATH"

# Initialize submodules if not already done
cd "$REPO_ROOT"
git submodule update --init --recursive

# Clone the game source and build game.love
echo "Cloning Elevate game source..."
ELEVATE_DIR="$REPO_ROOT/elevate-game"
if [ ! -d "$ELEVATE_DIR" ]; then
    git clone --depth 1 https://github.com/tacomilkshake/elevate.git "$ELEVATE_DIR"
fi

echo "Building game.love..."
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

echo "game.love created: $(ls -la "$REPO_ROOT/game.love")"
echo "=== Pre-Build Setup Complete ==="
