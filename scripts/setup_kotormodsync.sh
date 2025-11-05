#!/bin/bash

# setup_kotormodsync.sh
# Auto-download and install KOTORModSync for macOS

set -euo pipefail

INSTALL_DIR="$HOME/KOTORModSync"
REPO="th3w1zard1/KOTORModSync"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔧 KOTORModSync Setup"
echo ""

# Check if already installed
if [ -f "$INSTALL_DIR/KOTORModSync" ]; then
    echo -e "${GREEN}✓${NC} KOTORModSync already installed at: $INSTALL_DIR"
    echo ""
    read -p "Reinstall? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
    rm -rf "$INSTALL_DIR"
fi

# Create install directory
mkdir -p "$INSTALL_DIR"

echo "Fetching latest release info..."
RELEASE_INFO=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")

# Extract download URL for macOS
DOWNLOAD_URL=$(echo "$RELEASE_INFO" | grep "browser_download_url" | grep -i "macos\|darwin\|osx" | head -1 | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
    echo -e "${YELLOW}⚠${NC}  No macOS-specific release found. Trying generic release..."
    DOWNLOAD_URL=$(echo "$RELEASE_INFO" | grep "browser_download_url" | grep "\.zip" | head -1 | cut -d '"' -f 4)
fi

if [ -z "$DOWNLOAD_URL" ]; then
    echo -e "${RED}✗${NC} Could not find downloadable release"
    echo ""
    echo "Manual installation required:"
    echo "1. Visit: https://github.com/$REPO/releases"
    echo "2. Download the macOS version"
    echo "3. Extract to: $INSTALL_DIR"
    exit 1
fi

echo "Downloading from: $DOWNLOAD_URL"
curl -L "$DOWNLOAD_URL" -o "/tmp/kotormodsync.zip"

echo "Extracting..."
unzip -q "/tmp/kotormodsync.zip" -d "$INSTALL_DIR"

# Find executable
EXEC_PATH=$(find "$INSTALL_DIR" -name "KOTORModSync" -o -name "kotormodsync" | head -1)

if [ -z "$EXEC_PATH" ]; then
    echo -e "${YELLOW}⚠${NC}  Executable not found in expected location"
    echo "Checking for alternative structures..."

    # Sometimes executables are in subdirectories
    EXEC_PATH=$(find "$INSTALL_DIR" -type f -perm +111 | grep -i "kotormodsync" | head -1)
fi

if [ -n "$EXEC_PATH" ]; then
    chmod +x "$EXEC_PATH"
    echo -e "${GREEN}✓${NC} KOTORModSync installed successfully!"
    echo ""
    echo "Location: $EXEC_PATH"
    echo ""
    echo "Usage:"
    echo "  $EXEC_PATH --help"
    echo "  $EXEC_PATH install --mod mod.toml --game-path /path/to/kotor"
else
    echo -e "${YELLOW}⚠${NC}  Installation completed but executable not found"
    echo "Files extracted to: $INSTALL_DIR"
    echo "Please verify installation manually"
fi

# Cleanup
rm -f "/tmp/kotormodsync.zip"

exit 0
