#!/bin/bash

# verify_mods.sh
# Comprehensive mod installation verification for KOTOR

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Emojis
CHECK="✅"
CROSS="❌"
INFO="ℹ️"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}KOTOR Mod Verification${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

OVERRIDE_DIR="/Users/tomdimino/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app/Contents/KOTOR Data/Override"
INI_FILE="/Users/tomdimino/Library/Application Support/Knights of the Old Republic/swkotor.ini"

# Check 1: Override folder exists and has files
echo -e "${INFO} Checking Override folder..."
if [ -d "$OVERRIDE_DIR" ]; then
    FILE_COUNT=$(ls "$OVERRIDE_DIR" | wc -l | xargs)
    echo -e "${GREEN}${CHECK} Override folder exists: $FILE_COUNT files${NC}"
else
    echo -e "${RED}${CROSS} Override folder not found!${NC}"
    exit 1
fi

# Check 2: High Quality Blasters installed
echo ""
echo -e "${INFO} Checking High Quality Blasters..."
BLASTER_COUNT=$(ls "$OVERRIDE_DIR" | grep -E "^w_blstr.*\.(mdl|mdx)" | wc -l | xargs)
if [ "$BLASTER_COUNT" -gt 0 ]; then
    echo -e "${GREEN}${CHECK} High Quality Blasters installed ($BLASTER_COUNT model files)${NC}"
else
    echo -e "${YELLOW}${INFO} No blaster models found - mod may not be installed${NC}"
fi

# Check 3: JC's Cloaked Robes installed
echo ""
echo -e "${INFO} Checking JC's Cloaked Jedi Robes..."
SUPERMODEL_COUNT=$(ls "$OVERRIDE_DIR" | grep -E "^S_(Female|Male)" | wc -l | xargs)
ROBE_TEXTURE_COUNT=$(ls "$OVERRIDE_DIR" | grep -i "jedirobe" | wc -l | xargs)
if [ "$SUPERMODEL_COUNT" -gt 0 ]; then
    echo -e "${GREEN}${CHECK} Supermodel files installed ($SUPERMODEL_COUNT files)${NC}"
else
    echo -e "${YELLOW}${INFO} No supermodel files found - robes may not work${NC}"
fi
if [ "$ROBE_TEXTURE_COUNT" -gt 0 ]; then
    echo -e "${GREEN}${CHECK} Robe textures installed ($ROBE_TEXTURE_COUNT files)${NC}"
else
    echo -e "${YELLOW}${INFO} No robe textures found${NC}"
fi

# Check 4: Portrait mods installed
echo ""
echo -e "${INFO} Checking Portrait Mods..."
PORTRAIT_COUNT=$(ls "$OVERRIDE_DIR" | grep -E "^(PFBI|PMBI|po_p)" | wc -l | xargs)
if [ "$PORTRAIT_COUNT" -gt 0 ]; then
    echo -e "${GREEN}${CHECK} Portraits installed ($PORTRAIT_COUNT files)${NC}"
else
    echo -e "${YELLOW}${INFO} No portrait files found${NC}"
fi

# Check 5: swkotor.ini configuration
echo ""
echo -e "${INFO} Checking swkotor.ini configuration..."
if [ -f "$INI_FILE" ]; then
    echo -e "${GREEN}${CHECK} swkotor.ini found${NC}"

    # Check resolution
    WIDTH=$(grep "^Width=" "$INI_FILE" | cut -d'=' -f2)
    HEIGHT=$(grep "^Height=" "$INI_FILE" | cut -d'=' -f2)
    FULLSCREEN=$(grep "^FullScreen=" "$INI_FILE" | cut -d'=' -f2)

    echo -e "   Resolution: ${YELLOW}${WIDTH}x${HEIGHT}${NC}"
    echo -e "   Fullscreen: ${YELLOW}${FULLSCREEN}${NC} (1=yes, 0=no)"

    if [ "$WIDTH" = "2560" ] && [ "$HEIGHT" = "1440" ]; then
        echo -e "${GREEN}${CHECK} Resolution correctly set to 2K${NC}"
    else
        echo -e "${YELLOW}${INFO} Resolution is not 2K (current: ${WIDTH}x${HEIGHT})${NC}"
    fi

    if [ "$FULLSCREEN" = "1" ]; then
        echo -e "${GREEN}${CHECK} Fullscreen enabled${NC}"
    else
        echo -e "${YELLOW}${INFO} Fullscreen disabled in ini file${NC}"
    fi
else
    echo -e "${RED}${CROSS} swkotor.ini not found!${NC}"
fi

# Check 6: K1R mod files (if user had this installed)
echo ""
echo -e "${INFO} Checking for K1R Restoration mod..."
K1R_COUNT=$(ls "$OVERRIDE_DIR" | grep -i "^k1r" | wc -l | xargs)
if [ "$K1R_COUNT" -gt 0 ]; then
    echo -e "${GREEN}${CHECK} K1R files present ($K1R_COUNT files)${NC}"
else
    echo -e "${YELLOW}${INFO} K1R files not found (may not be installed)${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Verification Summary${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""
echo -e "Total Override files: ${GREEN}$FILE_COUNT${NC}"
echo -e "High Quality Blasters: ${GREEN}$BLASTER_COUNT${NC} model files"
echo -e "JC's Cloaked Robes: ${GREEN}$SUPERMODEL_COUNT${NC} supermodels, ${GREEN}$ROBE_TEXTURE_COUNT${NC} textures"
echo -e "Portrait mods: ${GREEN}$PORTRAIT_COUNT${NC} files"
echo -e "K1R Restoration: ${GREEN}$K1R_COUNT${NC} files"
echo ""

# How to verify in-game
echo -e "${BLUE}How to verify mods are working:${NC}"
echo ""
echo -e "${YELLOW}1. High Quality Blasters:${NC}"
echo -e "   - Load your save"
echo -e "   - Open Equipment screen"
echo -e "   - Check blaster models - should be highly detailed"
echo ""
echo -e "${YELLOW}2. JC's Cloaked Robes:${NC}"
echo -e "   - Look at your character or party members"
echo -e "   - Jedi robes should have flowing cloaks"
echo -e "   - Check Character screen for robe appearance"
echo ""
echo -e "${YELLOW}3. Portraits:${NC}"
echo -e "   - Start a new game"
echo -e "   - Character creation should show updated portraits"
echo -e "   - Higher resolution, more detailed faces"
echo ""
echo -e "${YELLOW}4. Resolution:${NC}"
echo -e "   - Game should be fullscreen at 2560x1440"
echo -e "   - UI should be crisp and widescreen"
echo ""
echo -e "${RED}Important: If mods don't appear in-game:${NC}"
echo -e "   1. Fully quit KOTOR (Cmd+Q)"
echo -e "   2. Relaunch with: ${GREEN}kotor${NC}"
echo -e "   3. Load existing save or start new game"
echo ""
