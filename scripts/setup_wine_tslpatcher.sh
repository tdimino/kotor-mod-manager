#!/bin/bash

# KOTOR TSLPatcher Wine Environment Setup
# Sets up Wine with drive mappings for easy TSLPatcher mod installation on macOS
# This script solves the macOS path navigation problem in Wine file browsers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== KOTOR TSLPatcher Wine Environment Setup ==="
echo ""

# Step 1: Check for Wine installation
echo "Checking for Wine installation..."
if ! command -v wine &> /dev/null; then
    echo -e "${RED}✗ Wine is not installed${NC}"
    echo ""
    echo "Wine is required to run TSLPatcher (Windows .exe installers) on macOS."
    echo ""
    echo "To install Wine:"
    echo "  brew install --cask wine-stable"
    echo ""
    echo "Note: This will require your password for system-level installation."
    echo ""
    exit 1
else
    WINE_VERSION=$(wine --version 2>/dev/null | head -n1)
    echo -e "${GREEN}✓ Wine is installed: $WINE_VERSION${NC}"
fi

# Step 2: Detect KOTOR installation
echo ""
echo "Detecting KOTOR installation..."

KOTOR_DATA_PATH=""

# Common KOTOR 1 paths
KOTOR1_PATH="$HOME/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app/Contents/KOTOR Data"
KOTOR2_PATH="$HOME/Library/Application Support/Steam/steamapps/common/Knights of the Old Republic II/KOTOR2.app/Contents/GameData"

if [ -d "$KOTOR1_PATH" ]; then
    KOTOR_DATA_PATH="$KOTOR1_PATH"
    GAME_NAME="KOTOR 1"
    echo -e "${GREEN}✓ Found KOTOR 1${NC}"
elif [ -d "$KOTOR2_PATH" ]; then
    KOTOR_DATA_PATH="$KOTOR2_PATH"
    GAME_NAME="KOTOR 2"
    echo -e "${GREEN}✓ Found KOTOR 2${NC}"
else
    echo -e "${RED}✗ KOTOR installation not found${NC}"
    echo ""
    echo "Please install KOTOR via Steam first."
    echo ""
    exit 1
fi

echo "  Game: $GAME_NAME"
echo "  Path: $KOTOR_DATA_PATH"

# Step 3: Create Wine prefix if needed
echo ""
echo "Checking Wine prefix..."

WINE_PREFIX="$HOME/.wine"
if [ ! -d "$WINE_PREFIX" ]; then
    echo "Creating Wine prefix (first-time setup)..."
    WINEARCH=win64 WINEPREFIX="$WINE_PREFIX" wineboot -u
    echo -e "${GREEN}✓ Wine prefix created${NC}"
else
    echo -e "${GREEN}✓ Wine prefix exists${NC}"
fi

# Step 4: Create drive mapping (THE CRITICAL IMPROVEMENT)
echo ""
echo "Creating Wine drive mapping..."

DOSDEVICES_DIR="$WINE_PREFIX/dosdevices"
mkdir -p "$DOSDEVICES_DIR"

cd "$DOSDEVICES_DIR"

# Remove existing K: mapping if present
if [ -L "k:" ] || [ -e "k:" ]; then
    rm -f "k:"
    echo "  Removed old K: mapping"
fi

# Create symbolic link to KOTOR Data
ln -sf "$KOTOR_DATA_PATH" "k:"

if [ -L "k:" ]; then
    echo -e "${GREEN}✓ Drive mapping created: K: -> KOTOR Data${NC}"
    echo ""
    echo "  You can now select 'K:' drive in TSLPatcher installers"
    echo "  instead of navigating complex macOS paths."
else
    echo -e "${RED}✗ Failed to create drive mapping${NC}"
    exit 1
fi

# Step 5: Verify Override folder
echo ""
echo "Verifying Override folder..."

OVERRIDE_PATH="$KOTOR_DATA_PATH/Override"
if [ ! -d "$OVERRIDE_PATH" ]; then
    echo "Creating Override folder (capital O)..."
    mkdir -p "$OVERRIDE_PATH"
    echo -e "${GREEN}✓ Override folder created${NC}"
else
    echo -e "${GREEN}✓ Override folder exists${NC}"
fi

# Step 6: Summary and usage instructions
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Wine Environment Ready for TSLPatcher Mods"
echo ""
echo "Usage Instructions:"
echo "  1. Extract TSLPatcher mod to a folder"
echo "  2. Run: wine /path/to/ModInstaller.exe"
echo "  3. In the installer window, click 'Install Mod'"
echo "  4. In the file browser, select 'K:' drive"
echo "  5. Click 'Select Folder' (DO NOT navigate into subfolders)"
echo "  6. TSLPatcher will install the mod automatically"
echo ""
echo "Important:"
echo "  - Select K: drive itself, NOT the Override subfolder"
echo "  - TSLPatcher knows where to place files automatically"
echo "  - If you get GEN-6 error, you selected wrong folder"
echo ""
echo "Drive Mapping Details:"
echo "  K: -> $KOTOR_DATA_PATH"
echo ""

# Optional: Show wine drive listing
echo "Available Wine drives:"
ls -lh "$DOSDEVICES_DIR" | grep -E "^l" | awk '{print "  " $9 " -> " $11}'
echo ""

exit 0
