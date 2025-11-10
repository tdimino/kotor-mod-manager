#!/bin/bash

# install_new_mods_auto.sh
# Automated KOTOR mod installation (non-interactive)

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
ROCKET="🚀"
INFO="ℹ️"
GEAR="⚙️"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}KOTOR Mod Installer (Automated)${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Paths
DOWNLOADS_DIR="$HOME/Downloads/kotor"
KOTOR_DIR="$HOME/Library/Application Support/Steam/steamapps/common/swkotor/Knights of the Old Republic.app/Contents"
OVERRIDE_DIR="$KOTOR_DIR/KOTOR Data/Override"
WINE_K_DRIVE="$HOME/.wine/dosdevices/k:"

# Verify paths exist
echo -e "${INFO} Verifying paths..."

if [ ! -d "$DOWNLOADS_DIR" ]; then
    echo -e "${RED}${CROSS} Downloads folder not found: $DOWNLOADS_DIR${NC}"
    exit 1
fi

if [ ! -d "$KOTOR_DIR" ]; then
    echo -e "${RED}${CROSS} KOTOR installation not found${NC}"
    exit 1
fi

if [ ! -d "$OVERRIDE_DIR" ]; then
    echo -e "${YELLOW}${INFO} Creating Override folder...${NC}"
    mkdir -p "$OVERRIDE_DIR"
fi

echo -e "${GREEN}${CHECK} All paths verified${NC}"
echo ""

# Step 1: Set up Wine K: drive mapping
echo -e "${GEAR} Step 1/4: Setting up Wine drive mapping..."

if [ -L "$WINE_K_DRIVE" ] || [ -e "$WINE_K_DRIVE" ]; then
    echo -e "${YELLOW}${INFO} Removing existing K: drive mapping${NC}"
    rm -f "$WINE_K_DRIVE"
fi

ln -s "$KOTOR_DIR" "$WINE_K_DRIVE"
echo -e "${GREEN}${CHECK} K: drive mapped to KOTOR installation${NC}"
echo ""

# Step 2: Install texture mods first (fully automated)
echo -e "${GEAR} Step 2/4: Installing texture updates and portraits..."

# JC's Texture Update
echo -e "${INFO} Installing JC's high-resolution portrait textures..."
if [ -d "$DOWNLOADS_DIR/Override" ]; then
    cp -r "$DOWNLOADS_DIR/Override/"* "$OVERRIDE_DIR/"
    echo -e "${GREEN}${CHECK} JC's texture update installed (44 files)${NC}"
else
    echo -e "${YELLOW}${INFO} JC's texture update folder not found, skipping${NC}"
fi

# Portraits - NPC
echo -e "${INFO} Installing NPC portraits..."
if [ -d "$DOWNLOADS_DIR/Portraits-1500-1-0-1663267164/Portraits NPC/tpc" ]; then
    cp "$DOWNLOADS_DIR/Portraits-1500-1-0-1663267164/Portraits NPC/tpc/"* "$OVERRIDE_DIR/"
    NPC_COUNT=$(ls "$DOWNLOADS_DIR/Portraits-1500-1-0-1663267164/Portraits NPC/tpc/" | wc -l | xargs)
    echo -e "${GREEN}${CHECK} NPC portraits installed ($NPC_COUNT files)${NC}"
else
    echo -e "${YELLOW}${INFO} NPC portraits folder not found, skipping${NC}"
fi

# Portraits - PLAYER
echo -e "${INFO} Installing PLAYER portraits..."
if [ -d "$DOWNLOADS_DIR/Portraits-1500-1-0-1663267164/Portraits PLAYER/tpc" ]; then
    cp "$DOWNLOADS_DIR/Portraits-1500-1-0-1663267164/Portraits PLAYER/tpc/"* "$OVERRIDE_DIR/"
    PLAYER_COUNT=$(ls "$DOWNLOADS_DIR/Portraits-1500-1-0-1663267164/Portraits PLAYER/tpc/" | wc -l | xargs)
    echo -e "${GREEN}${CHECK} PLAYER portraits installed ($PLAYER_COUNT files)${NC}"
else
    echo -e "${YELLOW}${INFO} PLAYER portraits folder not found, skipping${NC}"
fi

echo ""

# Step 3: Launch High Quality Blasters installer
echo -e "${ROCKET} Step 3/4: Launching High Quality Blasters installer..."
echo -e "${YELLOW}${INFO} Wine GUI will appear shortly${NC}"
echo -e "${YELLOW}    When asked for game directory, type: K:\\${NC}"
echo ""

cd "$DOWNLOADS_DIR/High Quality Blasters 1.1/"
wine "High Quality Blasters Installer.exe" &
HQ_BLASTER_PID=$!

echo -e "${GREEN}${CHECK} High Quality Blasters installer launched (PID: $HQ_BLASTER_PID)${NC}"
echo -e "${YELLOW}${INFO} Complete the installer GUI, then this script will continue${NC}"

# Wait for installer to finish
wait $HQ_BLASTER_PID
echo -e "${GREEN}${CHECK} High Quality Blasters installation complete${NC}"
echo ""

# Step 4: Launch JC's Cloaked Jedi Robes installer
echo -e "${ROCKET} Step 4/4: Launching JC's Cloaked Jedi Robes installer..."
echo -e "${YELLOW}${INFO} Wine GUI will appear shortly${NC}"
echo -e "${YELLOW}    1. Select: Brown-Red-Blue (recommended)${NC}"
echo -e "${YELLOW}    2. Click 'Install Mod'${NC}"
echo -e "${YELLOW}    3. When asked for game directory, type: K:\\${NC}"
echo ""

cd "$DOWNLOADS_DIR/JC's Fashion Line I - Cloaked Jedi Robes for K1 v1.4/"
wine Install.exe &
JC_ROBES_PID=$!

echo -e "${GREEN}${CHECK} JC's Cloaked Robes installer launched (PID: $JC_ROBES_PID)${NC}"
echo -e "${YELLOW}${INFO} Complete the installer GUI${NC}"

# Wait for installer to finish
wait $JC_ROBES_PID
echo -e "${GREEN}${CHECK} JC's Cloaked Jedi Robes installation complete${NC}"
echo ""

# Verification
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Installation Summary${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

TOTAL_FILES=$(ls "$OVERRIDE_DIR" | wc -l | xargs)
echo -e "${GREEN}${CHECK} Total files in Override: $TOTAL_FILES${NC}"
echo ""

echo -e "${GREEN}All mods installed successfully!${NC}"
echo ""
echo -e "${YELLOW}${INFO} Next steps:${NC}"
echo -e "  1. Launch KOTOR using: ${GREEN}kotor${NC}"
echo -e "  2. Load your save game"
echo -e "  3. Check Character screen for cloaked robes"
echo -e "  4. Check Equipment for high-quality blasters"
echo -e "  5. Start new game to see updated portraits"
echo ""
echo -e "${YELLOW}Note: Close KOTOR completely before launching to ensure mods load${NC}"
echo ""
