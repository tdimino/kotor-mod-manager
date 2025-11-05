#!/bin/bash

# KOTOR Resolution Configuration Script
# Configures KOTOR to use custom resolutions on macOS Retina displays
# Solves the issue where high resolutions don't appear in the in-game menu

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== KOTOR Resolution Configuration ===${NC}"
echo ""

# Check if KOTOR is installed
PLIST="$HOME/Library/Preferences/com.aspyr.kotor.steam.plist"
if [ ! -f "$PLIST" ]; then
    echo -e "${RED}✗ KOTOR preferences not found${NC}"
    echo "Please launch KOTOR at least once before running this script."
    exit 1
fi

# Get current system resolution
echo "Detecting system display..."
SYSTEM_RES=$(system_profiler SPDisplaysDataType | grep "Resolution:" | head -1 | sed 's/.*Resolution: //' | sed 's/ Retina//')
echo -e "${GREEN}✓ System Display:${NC} $SYSTEM_RES"
echo ""

# Display current KOTOR settings
echo "Current KOTOR settings:"
if plutil -p "$PLIST" | grep -q "Screen Width"; then
    CURRENT_WIDTH=$(defaults read com.aspyr.kotor.steam "Screen Width" 2>/dev/null || echo "Not set")
    CURRENT_HEIGHT=$(defaults read com.aspyr.kotor.steam "Screen Height" 2>/dev/null || echo "Not set")
    echo "  Resolution: ${CURRENT_WIDTH}x${CURRENT_HEIGHT}"
else
    echo "  Resolution: Not configured (using defaults)"
fi
echo ""

# Backup preferences
echo "Creating backup..."
cp "$PLIST" "${PLIST}.backup.$(date +%Y%m%d_%H%M%S)"
echo -e "${GREEN}✓ Backup created${NC}"
echo ""

# Offer resolution options
echo -e "${YELLOW}Select resolution:${NC}"
echo ""
echo "  1) 1920x1080 (Full HD, 16:9) - RECOMMENDED for High Res Menus mod"
echo "  2) 1728x1117 (Retina scaled, 3:2) - Fills MacBook Pro 14\" screen"
echo "  3) 2560x1440 (QHD, 16:9)"
echo "  4) 3456x2234 (Native Retina, 3:2) - May not work"
echo "  5) Custom resolution"
echo "  6) Cancel"
echo ""
read -p "Choose option (1-6): " CHOICE

case "$CHOICE" in
    1)
        WIDTH=1920
        HEIGHT=1080
        DESC="1920x1080 Full HD (16:9)"
        ;;
    2)
        WIDTH=1728
        HEIGHT=1117
        DESC="1728x1117 Retina scaled (3:2)"
        ;;
    3)
        WIDTH=2560
        HEIGHT=1440
        DESC="2560x1440 QHD (16:9)"
        ;;
    4)
        WIDTH=3456
        HEIGHT=2234
        DESC="3456x2234 Native Retina (3:2)"
        ;;
    5)
        echo ""
        read -p "Enter width: " WIDTH
        read -p "Enter height: " HEIGHT
        DESC="${WIDTH}x${HEIGHT} Custom"
        ;;
    6)
        echo "Cancelled."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}Configuring KOTOR for: $DESC${NC}"

# Apply settings
defaults write com.aspyr.kotor.steam "Screen Width" -int "$WIDTH"
defaults write com.aspyr.kotor.steam "Screen Height" -int "$HEIGHT"
defaults write com.aspyr.kotor.steam "Graphics - Fullscreen Res" -string "${WIDTH}x${HEIGHT}"

echo -e "${GREEN}✓ Resolution configured${NC}"
echo ""

# Verify settings
echo "Verifying configuration..."
NEW_WIDTH=$(defaults read com.aspyr.kotor.steam "Screen Width")
NEW_HEIGHT=$(defaults read com.aspyr.kotor.steam "Screen Height")
echo -e "${GREEN}✓ Confirmed:${NC} ${NEW_WIDTH}x${NEW_HEIGHT}"
echo ""

# Important notes
echo -e "${YELLOW}Important Notes:${NC}"
echo ""

if [ "$WIDTH" -eq 1920 ] && [ "$HEIGHT" -eq 1080 ]; then
    echo "✓ 1920x1080 matches your High Resolution Menus mod"
    echo "✓ Expect black bars on sides (16:9 on 3:2 display)"
    echo "  This is CORRECT - prevents UI stretching"
elif [ "$WIDTH" -eq 1728 ] && [ "$HEIGHT" -eq 1117 ]; then
    echo "⚠️  This resolution fills your screen but..."
    echo "⚠️  High Res Menus mod is designed for 1920x1080"
    echo "⚠️  UI may be slightly off"
    echo ""
    echo "Consider reinstalling High Res Menus for your aspect ratio"
else
    echo "⚠️  Custom resolution set"
    echo "⚠️  Verify High Res Menus mod matches this resolution"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Configuration Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Next steps:"
echo "  1. Launch KOTOR"
echo "  2. Resolution should now be available in Graphics Options"
echo "  3. If not shown in menu, it's already active"
echo ""
echo "To restore defaults:"
echo "  defaults delete com.aspyr.kotor.steam 'Screen Width'"
echo "  defaults delete com.aspyr.kotor.steam 'Screen Height'"
echo ""

exit 0
