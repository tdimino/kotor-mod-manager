#!/bin/bash

# configure_resolution.sh
# Configures KOTOR display resolution and fullscreen settings

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}KOTOR Resolution Configurator${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

CONFIG_PATH="$HOME/Library/Application Support/Knights of the Old Republic/swkotor.ini"

if [ ! -f "$CONFIG_PATH" ]; then
    echo "Error: swkotor.ini not found. Launch KOTOR at least once first."
    exit 1
fi

echo "Select Resolution:"
echo ""
echo "1. 1920x1080 (Full HD) - Best compatibility with widescreen mods"
echo "2. 2560x1440 (2K) - Higher quality, recommended for Retina displays"
echo ""
read -p "Enter choice (1 or 2): " choice

case $choice in
    1)
        WIDTH=1920
        HEIGHT=1080
        ;;
    2)
        WIDTH=2560
        HEIGHT=1440
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

# Backup config
cp "$CONFIG_PATH" "${CONFIG_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
echo -e "${GREEN}✅ Backup created${NC}"

# Update or add Display Options
if grep -q "\[Display Options\]" "$CONFIG_PATH"; then
    # Update existing
    sed -i '' "s/^Width=.*/Width=$WIDTH/" "$CONFIG_PATH"
    sed -i '' "s/^Height=.*/Height=$HEIGHT/" "$CONFIG_PATH"
else
    # Add new section before [Graphics Options]
    sed -i '' "/\[Graphics Options\]/i\\
[Display Options]\\
FullScreen=1\\
Width=$WIDTH\\
Height=$HEIGHT\\
RefreshRate=60\\
AllowWindowedMode=0\\
\\
" "$CONFIG_PATH"
fi

echo -e "${GREEN}✅ Resolution configured: ${WIDTH}x${HEIGHT}${NC}"
echo ""
echo -e "${YELLOW}Close KOTOR completely and relaunch with 'kotor' command${NC}"
