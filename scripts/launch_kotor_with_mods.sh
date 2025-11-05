#!/bin/bash

# KOTOR Mod-Aware Launcher
# Shows installed mods before launching the game
# Provides visual confirmation that all mods are active

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Clear screen for clean display
clear

# Display mod list banner
echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     KOTOR MODS ACTIVE - READY TO PLAY     ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
echo ""

# Detect KOTOR installation
KOTOR_DATA=""
if [ -d "$HOME/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app/Contents/KOTOR Data" ]; then
    KOTOR_DATA="$HOME/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app/Contents/KOTOR Data"
    GAME_NAME="KOTOR 1"
elif [ -d "$HOME/Library/Application Support/Steam/steamapps/common/Knights of the Old Republic II/KOTOR2.app/Contents/GameData" ]; then
    KOTOR_DATA="$HOME/Library/Application Support/Steam/steamapps/common/Knights of the Old Republic II/KOTOR2.app/Contents/GameData"
    GAME_NAME="KOTOR 2"
else
    echo -e "${RED}❌ KOTOR installation not found${NC}"
    echo "Please install KOTOR via Steam first."
    exit 1
fi

OVERRIDE="$KOTOR_DATA/Override"

# Check if Override folder exists
if [ ! -d "$OVERRIDE" ]; then
    echo -e "${BLUE}ℹ️  No mods installed (Override folder not found)${NC}"
    echo ""
    echo "Press any key to launch $GAME_NAME..."
    read -n 1 -s
    open -a Steam steam://rungameid/32370
    exit 0
fi

# Count files in Override
TOTAL_FILES=$(find "$OVERRIDE" -type f 2>/dev/null | wc -l | tr -d ' ')

# Display installed mods
echo -e "${GREEN}✅ Active Mods:${NC}"
echo ""

# Check for specific mod signatures
MODS_DETECTED=0

# 1. K1R Restoration
if [ -f "$OVERRIDE/global.jrl" ] && [ -f "$OVERRIDE/end_trask.utc" ]; then
    K1R_FILES=$(find "$OVERRIDE" -name "*.jrl" -o -name "end_trask.utc" 2>/dev/null | wc -l | tr -d ' ')
    echo "  1. K1R Restoration 1.2"
    MODS_DETECTED=$((MODS_DETECTED + 1))
fi

# 2. Widescreen Fade Fix
if [ -f "$OVERRIDE/fade.gui" ]; then
    echo "  2. Widescreen Fade Fix"
    MODS_DETECTED=$((MODS_DETECTED + 1))
fi

# 3. High Resolution Menus
GUI_COUNT=$(find "$OVERRIDE" -name "*.gui" 2>/dev/null | wc -l | tr -d ' ')
if [ "$GUI_COUNT" -gt 10 ]; then
    echo "  3. High Resolution Menus ($GUI_COUNT GUI files)"
    MODS_DETECTED=$((MODS_DETECTED + 1))
fi

# 4. Revamped FX
FX_COUNT=$(find "$OVERRIDE" -name "fx_*.tga" 2>/dev/null | wc -l | tr -d ' ')
if [ "$FX_COUNT" -gt 5 ]; then
    echo "  4. Revamped FX ($FX_COUNT effect textures)"
    MODS_DETECTED=$((MODS_DETECTED + 1))
fi

# 5. High Quality Skyboxes
SKYBOX_COUNT=$(find "$OVERRIDE" -name "*sky*.tpc" 2>/dev/null | wc -l | tr -d ' ')
if [ "$SKYBOX_COUNT" -gt 50 ]; then
    echo "  5. High Quality Skyboxes II ($SKYBOX_COUNT textures)"
    MODS_DETECTED=$((MODS_DETECTED + 1))
fi

# 6. Skybox Model Fixes
MDL_COUNT=$(find "$OVERRIDE" -name "*.mdl" 2>/dev/null | wc -l | tr -d ' ')
if [ "$MDL_COUNT" -gt 20 ]; then
    echo "  6. Skybox Model Fixes ($MDL_COUNT models)"
    MODS_DETECTED=$((MODS_DETECTED + 1))
fi

# 7. Vurt's Visual Resurgence
TPC_COUNT=$(find "$OVERRIDE" -name "*.tpc" 2>/dev/null | wc -l | tr -d ' ')
if [ "$TPC_COUNT" -gt 2000 ]; then
    echo "  7. Vurt's Visual Resurgence ($TPC_COUNT textures)"
    MODS_DETECTED=$((MODS_DETECTED + 1))
fi

# 8. Check for Wine setup (TSLPatcher mods)
if [ -L "$HOME/.wine/dosdevices/k:" ]; then
    echo "  8. Wine TSLPatcher Integration (K: drive mapped)"
    MODS_DETECTED=$((MODS_DETECTED + 1))
fi

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Total Files:${NC} $TOTAL_FILES in Override"
echo -e "${GREEN}Mods Detected:${NC} $MODS_DETECTED"
echo -e "${GREEN}Game:${NC} $GAME_NAME"

# Check installation date
if [ -f "$OVERRIDE/global.jrl" ]; then
    INSTALL_DATE=$(stat -f "%Sm" -t "%B %d, %Y" "$OVERRIDE/global.jrl" 2>/dev/null || echo "Unknown")
    echo -e "${GREEN}Last Modified:${NC} $INSTALL_DATE"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Launch prompt
echo -e "${CYAN}Press any key to launch $GAME_NAME...${NC}"
read -n 1 -s

# Launch game via Steam
if [ "$GAME_NAME" = "KOTOR 1" ]; then
    open -a Steam steam://rungameid/32370
else
    open -a Steam steam://rungameid/208580
fi

echo ""
echo -e "${GREEN}✓ Game launching...${NC}"
echo ""

exit 0
